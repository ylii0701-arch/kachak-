# KACHAK

Beginner-friendly wildlife photography support platform focused on Malaysia.

KACHAK helps users discover species, plan where and when to shoot, improve photo quality, and learn responsible wildlife photography practices through map, prediction, and AI-assisted features.

- **Group**: TM06 (Group Name: 60MT)
- **Repository**: [GitHub - ylii0701-arch/kachak-](https://github.com/ylii0701-arch/kachak-)
- **Web Demo**: [KACHAK Web](https://ylii0701-arch.github.io/kachak-/)
- **Android APK**: [Download app-release.apk](https://github.com/ylii0701-arch/kachak-/releases/download/kachakv-Iteration3/app-release.apk)

---

## Project Overview

Wildlife photography can increase biodiversity awareness, but beginners often struggle with fragmented information, unclear locations, poor timing decisions, and low success rates. KACHAK addresses this by combining species discovery, map exploration, occurrence-style prediction, AI recognition, image quality feedback, and guided onboarding in one app.

This repository currently contains the **Flutter client** and deployment workflow for web preview. Some backend/cloud elements are part of the planned architecture and will be expanded in later iterations.

---

## Key Features

- **Species Discovery & Filtering**
  - Search and filter by category, conservation status, difficulty, city/site context.
- **Interactive Map Exploration**
  - Explore wildlife-related locations, markers, and contextual weather/map overlays.
- **Occurrence Prediction**
  - Species-oriented prediction views based on weather/site context and local model inference.
- **AI Species Recognition**
  - Upload/capture photo and receive likely species identification support.
- **Image Quality Analysis**
  - Analyze sharpness, exposure, contrast, and framing with actionable suggestions.
- **Mission / Task Guidance**
  - Beginner-oriented photography tasks and challenge flow.
- **AI Photography Assistant**
  - Chat-based guidance for settings, field preparation, and practical tips.
- **Multilingual UI**
  - English, Malay (Bahasa Melayu), and Simplified Chinese.
- **Onboarding & Spotlight Walkthrough**
  - First-run guided explanation of major app pages and controls.

---

## Technology Stack

### Frontend
- Flutter (Dart)
- Material 3 + custom theme
- `provider` for app state
- `shared_preferences` for local persistence

### Backend / Cloud (Target Architecture)
- Neon PostgreSQL (target managed relational database)
- Vercel serverless/API layer (target internal REST backend)

### Maps, Location, Weather
- `flutter_map`, `latlong2`
- `geolocator`
- OpenWeather API

### AI & Image
- Google Gemini API (chat + recognition support)
- ONNX Runtime (`onnxruntime`) for local prediction model usage
- `image_picker`, `image`, `exif` (image handling)

### Notifications & Permissions
- `flutter_local_notifications`
- `permission_handler`

### Deployment
- GitHub Actions (Flutter Web build/deploy)
- GitHub Pages (web host)

---

## Repository Structure

```text
kachak-/
├─ flutter/
│  ├─ lib/
│  │  ├─ config/        # API keys, defaults
│  │  ├─ data/          # Local static datasets
│  │  ├─ models/        # Domain models
│  │  ├─ providers/     # Shared state controllers
│  │  ├─ screens/       # App pages
│  │  ├─ services/      # API, AI, prediction, business logic
│  │  ├─ theme/         # App theme and colors
│  │  ├─ utils/         # Helpers and utilities
│  │  └─ widgets/       # Reusable UI components
│  ├─ assets/           # Images, model assets
│  ├─ web/              # Flutter web host files
│  └─ pubspec.yaml
├─ database_scripts/    # Planned/related DB scripts
└─ README.md
```

---

## Getting Started

### Prerequisites

- Flutter SDK (stable)
- Dart SDK (bundled with Flutter)
- Chrome (for Flutter web) and/or Android Studio device/emulator
- Git

### Clone and Install

```bash
git clone https://github.com/ylii0701-arch/kachak-.git
cd kachak-/flutter
flutter pub get
```

### Environment Configuration

KACHAK reads keys from `String.fromEnvironment` (see `flutter/lib/config/map_keys.dart`).

Pass keys at runtime/build:

```bash
flutter run -d chrome \
  --dart-define=MAPBOX_ACCESS_TOKEN=YOUR_MAPBOX_TOKEN \
  --dart-define=OPENWEATHER_API_KEY=YOUR_OPENWEATHER_KEY \
  --dart-define=GEMINI_API_KEY=YOUR_GEMINI_KEY
```

For Android:

```bash
flutter run -d android \
  --dart-define=MAPBOX_ACCESS_TOKEN=YOUR_MAPBOX_TOKEN \
  --dart-define=OPENWEATHER_API_KEY=YOUR_OPENWEATHER_KEY \
  --dart-define=GEMINI_API_KEY=YOUR_GEMINI_KEY
```

> Do not commit real API keys to source control.

---

## Usage

1. Launch app and complete onboarding/walkthrough.
2. Browse species on **Home** with search/filter/sort.
3. Explore relevant locations on **Map**.
4. Open **Identify** to:
   - run species recognition, or
   - run image quality analysis.
5. Use **Mission** for guided photography tasks.
6. Save species and enable alert preferences in **Saved**.

---

## Build & Deploy

### Local Build

```bash
cd flutter
flutter build web --release
```

### GitHub Pages

Deployment is automated via GitHub Actions workflow in:

- `.github/workflows/`

Current public deployment target:

- [https://ylii0701-arch.github.io/kachak-/](https://ylii0701-arch.github.io/kachak-/)

---

## Current Scope vs Future Scope

### Implemented in this repository
- Flutter client app
- Local data files for many species/map/prediction contexts
- Gemini integration for chat and recognition flows
- ONNX local prediction service integration
- Web deployment pipeline

### Planned / expanding
- Full backend integration via Vercel internal APIs
- Cloud relational data layer on Neon PostgreSQL
- More automated external data ingestion pipelines
- Expanded account-level cross-device persistence

### Architecture Clarification
- The backend target is Neon + Vercel.
- In the current repository state, many runtime datasets are still served from local Dart files under `flutter/lib/data/`.
- The transition plan is to progressively replace static data imports with internal API calls backed by Vercel + Neon.

---

## Development Workflow

Recommended team workflow:

1. Create a feature branch from `main`.
2. Implement and test changes locally.
3. Run quality checks:
   ```bash
   flutter analyze
   ```
4. Commit and push branch.
5. Open Pull Request and review.
6. Merge to `main` for deployment flow.

---

## Roadmap (High-Level)

- Backend API integration for replacing static data paths progressively
- Improved prediction robustness and performance on mobile web
- Enhanced AI fallback resilience during high-traffic periods
- Expanded tutorial and mission content
- APK release packaging and distribution

---

## Support

For questions, bugs, or feature requests:

- Open an issue in this repo: [Issues](https://github.com/ylii0701-arch/kachak-/issues)

---

## Contributors / Acknowledgment

Built by **TM06 (60MT)** for FIT5120 Industry Experience Studio.

Acknowledgment to course mentors, reviewers, and teammates contributing across UI, data, AI integration, and deployment.

---

## Project Status

Active student project in iterative development.

- Web build: available
- Android APK: in progress

---

## References

- [Monash University Malaysia - A story beyond the lens](https://www.monash.edu.my/news-and-events/trending/a-story-beyond-the-lens)
- [GBIF](https://www.gbif.org)
- [IUCN Red List](https://www.iucnredlist.org)
- [Royal Ontario Museum - Challenges of wildlife photography](https://www.rom.on.ca/magazine/challenges-wildlife-photography)
- [BBC Culture - The photographers changing the way we see animals](https://www.bbc.com/culture/article/20200609-the-photographers-changing-the-way-we-see-animals)
- [Akari Photo Tours - Wildlife photography challenges](https://akariphototours.com/blog/ten-reasons-why-wildlife-photography-is-one-of-the-most-challenging-and-rewarding-genres-of-photography/)
