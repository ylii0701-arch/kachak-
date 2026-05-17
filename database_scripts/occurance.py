import requests
import csv
import os
import time
from datetime import datetime, timedelta
from pathlib import Path

try:
    import psycopg
except ImportError:
    try:
        import psycopg2 as psycopg
    except ImportError as exc:
        raise ImportError("Install psycopg or psycopg2 to insert occurrences into Postgres.") from exc

BASE_URL = "https://api.gbif.org/v1/occurrence/search"

LIMIT = 300
MAX_RECORDS = 3000
DELAY = 0.2
TABLE_NAME = "occurrences"
DB_URL_ENV = "DATABASE_URL"


# -----------------------------
# Date range (last 3 days)
# -----------------------------
def get_date_range():
    today = datetime.utcnow().date()
    three_days_ago = today - timedelta(days=30)
    return f"{three_days_ago},{today}"

# -----------------------------
# Fetch occurrences
# -----------------------------
def fetch_occurrences():
    all_results = []
    offset = 0

    date_range = get_date_range()
    print(f"Fetching occurrences for: {date_range}")

    while len(all_results) < MAX_RECORDS:
        params = {
            "country": "MY",
            "eventDate": date_range,
            "hasCoordinate": "true",
            "basisOfRecord": "HUMAN_OBSERVATION",
            "limit": LIMIT,
            "offset": offset
        }

        try:
            r = requests.get(BASE_URL, params=params, timeout=30)

            if r.status_code != 200:
                print(f"Stopped at offset {offset}, status={r.status_code}")
                break

            data = r.json()
            results = data.get("results", [])

            if not results:
                print("No more results.")
                break

            for occ in results:
                all_results.append({
                    "gbif_id": occ.get("key"),

                    # ✅ Correct linkage field
                    "taxon_key": occ.get("taxonKey"),

                    # ✅ Fallback if taxon_key missing
                    "scientific_name": occ.get("scientificName"),

                    "event_date": occ.get("eventDate"),
                    "latitude": occ.get("decimalLatitude"),
                    "longitude": occ.get("decimalLongitude"),

                    "country": occ.get("country"),
                    "basis_of_record": occ.get("basisOfRecord"),
                    "dataset_name": occ.get("datasetName")
                })

            print(f"Collected: {len(all_results)}")

            offset += LIMIT
            time.sleep(DELAY)

        except requests.exceptions.RequestException as e:
            print(f"Error: {e}")
            break

    return all_results


def load_database_url(env_file=".env"):
    env_path = Path(env_file)
    if env_path.exists():
        for line in env_path.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue

            key, value = line.split("=", 1)
            key = key.strip()
            value = value.strip().strip('"').strip("'")
            os.environ.setdefault(key, value)

    database_url = os.getenv(DB_URL_ENV)
    if not database_url:
        raise RuntimeError(f"{DB_URL_ENV} is missing. Add it to {env_file}.")

    return database_url


def clean_occurrence(occurrence):
    if occurrence.get("gbif_id") is None:
        return None
    if occurrence.get("latitude") is None or occurrence.get("longitude") is None:
        return None

    return (
        int(occurrence["gbif_id"]),
        int(occurrence["taxon_key"]) if occurrence.get("taxon_key") is not None else None,
        occurrence.get("scientific_name"),
        occurrence.get("event_date"),
        float(occurrence["latitude"]),
        float(occurrence["longitude"]),
        occurrence.get("country"),
        occurrence.get("basis_of_record"),
        occurrence.get("dataset_name"),
    )


def insert_into_temp_table(data):
    records = [record for record in (clean_occurrence(item) for item in data) if record]

    if not records:
        print("No valid records to insert.")
        return

    database_url = load_database_url()

    with psycopg.connect(database_url) as conn:
        with conn.cursor() as cur:
            cur.executemany(
                f"""
                INSERT INTO {TABLE_NAME}
                (gbif_id, taxon_key, scientific_name, event_date, latitude, longitude, country, basis_of_record, dataset_name)
                SELECT %s,%s,%s,%s,%s,%s,%s,%s,%s
                WHERE NOT EXISTS (
                    SELECT 1
                    FROM {TABLE_NAME}
                    WHERE gbif_id = %s
                )
                """,
                [record + (record[0],) for record in records],
            )

    print(f"Inserted {len(records)} valid records into {TABLE_NAME}.")


# -----------------------------
# Save to CSV
# -----------------------------
def save_to_csv(data, filename="occurrences_MY_last3days.csv"):
    if not data:
        print("No data to save.")
        return

    keys = data[0].keys()

    with open(filename, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=keys)
        writer.writeheader()
        writer.writerows(data)

    print(f"\nSaved {len(data)} records to {filename}")


# -----------------------------
# MAIN
# -----------------------------
if __name__ == "__main__":
    occurrences = fetch_occurrences()
    print(occurrences[:10])
    insert_into_temp_table(occurrences)
    #save_to_csv(occurrences)
