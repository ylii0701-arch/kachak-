import requests
import psycopg2
import pandas as pd
import os
from datetime import datetime
from dotenv import load_dotenv
import time

load_dotenv(".env")

DB_URL = os.getenv("DATABASE_URL")

# ---------------------------
# CONFIG
# ---------------------------
PARAMS = "T2M,PRECTOTCORR,RH2M,WS2M"

# ---------------------------
# DB CONNECTION
# ---------------------------
conn = psycopg2.connect(DB_URL)

# ---------------------------
# LOAD OCCURRENCE DATA
# ---------------------------
query = """
SELECT latitude, longitude, event_date
FROM occurrences
WHERE latitude IS NOT NULL AND longitude IS NOT NULL;
"""

occ_df = pd.read_sql(query, conn)

# ---------------------------
# CLEAN event_date (FIXES YOUR ERROR)
# ---------------------------
occ_df["event_date"] = pd.to_datetime(
    occ_df["event_date"],
    errors="coerce"   # invalid → NaT
)

# Drop invalid rows
occ_df = occ_df.dropna(subset=["event_date"])

# Convert to YYYYMMDD string
occ_df["date"] = occ_df["event_date"].dt.strftime("%Y%m%d")

# ---------------------------
# SNAP TO GRID (~0.5°)
# ---------------------------
def snap(coord):
    return round(coord * 2) / 2

occ_df["lat"] = occ_df["latitude"].apply(snap)
occ_df["lon"] = occ_df["longitude"].apply(snap)

# Keep only needed columns
occ_df = occ_df[["lat", "lon", "date"]].drop_duplicates()

print(f"✅ Unique (lat, lon, date): {len(occ_df)}")

# ---------------------------
# GROUP BY LOCATION
# ---------------------------
grouped = occ_df.groupby(["lat", "lon"])

# ---------------------------
# API FETCH
# ---------------------------
def fetch_weather(lat, lon, start, end):
    url = "https://power.larc.nasa.gov/api/temporal/daily/point"

    params = {
        "parameters": PARAMS,
        "community": "RE",
        "longitude": lon,
        "latitude": lat,
        "start": start,
        "end": end,
        "format": "JSON"
    }

    res = requests.get(url, params=params)
    data = res.json()

    if "properties" not in data:
        print("❌ API error:", data)
        return None

    return data

# ---------------------------
# CLEAN VALUE
# ---------------------------
def clean(v):
    if v is None or v == -999:
        return None
    return float(v)

# ---------------------------
# UPSERT
# ---------------------------
def upsert_weather(cur, lat, lon, date, temp, rain, humidity, wind):
    cur.execute("""
        INSERT INTO weather_data (lat, lon, date, temperature, rainfall, humidity, wind_speed)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (lat, lon, date)
        DO UPDATE SET
            temperature = EXCLUDED.temperature,
            rainfall = EXCLUDED.rainfall,
            humidity = EXCLUDED.humidity,
            wind_speed = EXCLUDED.wind_speed;
    """, (lat, lon, date, temp, rain, humidity, wind))

# ---------------------------
# MAIN LOOP
# ---------------------------
with conn.cursor() as cur:

    total = len(grouped)

    for i, ((lat, lon), group) in enumerate(grouped):

        print(f"[{i+1}/{total}] Processing {lat}, {lon}")

        dates = sorted(group["date"])

        # Validate date strings (extra safety)
        dates = [d for d in dates if isinstance(d, str) and len(d) == 8]

        if not dates:
            continue

        start = dates[0]
        end = dates[-1]

        data = fetch_weather(lat, lon, start, end)

        if data is None:
            continue

        params = data["properties"]["parameter"]

        temp_data = params.get("T2M", {})
        rain_data = params.get("PRECTOTCORR", {})
        humidity_data = params.get("RH2M", {})
        wind_data = params.get("WS2M", {})

        for d in dates:
            try:
                date_obj = datetime.strptime(d, "%Y%m%d").date()
            except ValueError:
                print("❌ Bad date skipped:", d)
                continue

            temp = clean(temp_data.get(d))
            rain = clean(rain_data.get(d))
            humidity = clean(humidity_data.get(d))
            wind = clean(wind_data.get(d))

            upsert_weather(cur, lat, lon, date_obj, temp, rain, humidity, wind)

        conn.commit()

        # Prevent API throttling
        time.sleep(0.3)

conn.close()

print("✅ Weather ingestion complete")