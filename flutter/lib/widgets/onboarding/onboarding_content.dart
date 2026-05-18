import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/onboarding_service.dart';

/// A single highlighted step inside an onboarding sheet or carousel page.
class IntroStep {
  const IntroStep({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

/// Copy + visuals for one tour (e.g. Home, Identify).
class IntroContent {
  const IntroContent({
    required this.title,
    required this.subtitle,
    required this.steps,
  });

  final String title;
  final String subtitle;
  final List<IntroStep> steps;
}

/// Per-page tutorial copy. Kept lightweight so it can be tweaked without
/// touching screen code.
Map<OnboardingTour, IntroContent> kOnboardingContent(BuildContext context) {
  final l = AppLocalizations.of(context);
  return {
    OnboardingTour.home: IntroContent(
      title: l?.tourHomeTitle ?? 'Discover species',
      subtitle: l?.tourHomeSubtitle ??
          'Browse Malaysian wildlife as if flipping through a field-guide journal.',
      steps: [
        IntroStep(
          icon: Icons.search_rounded,
          title: l?.tourSearchTitle ?? 'Search by name',
          body: l?.tourSearchBody ??
              'Type a common or scientific name to jump straight to a species card.',
        ),
        IntroStep(
          icon: Icons.tune_rounded,
          title: l?.tourFilterTitle ?? 'Filter & sort',
          body: l?.tourFilterBody ??
              'Use tabs to filter by location, category, conservation status, and difficulty.',
        ),
        IntroStep(
          icon: Icons.grid_view_rounded,
          title: l?.tourLayoutTitle ?? 'Switch layouts',
          body: l?.tourLayoutBody ??
              'Tap the layout button on the right to toggle between list and grid.',
        ),
        IntroStep(
          icon: Icons.bookmark_outline_rounded,
          title: l?.tourSaveTitle ?? 'Save favourites',
          body: l?.tourSaveBody ??
              'Bookmark any card to revisit it later from the side menu.',
        ),
        IntroStep(
          icon: Icons.location_on_outlined,
          title: l?.tourAreaTitle ?? 'Area predictions in Home',
          body: l?.tourAreaBody ??
              'Choose a location in Filter to switch Home into prediction-ranked results.',
        ),
      ],
    ),
    OnboardingTour.saved: IntroContent(
      title: l?.tourSavedTitle ?? 'Saved species',
      subtitle: l?.tourSavedSubtitle ??
          'Revisit your bookmarked species and open details quickly.',
      steps: [
        IntroStep(
          icon: Icons.favorite_outline_rounded,
          title: l?.tourFavTitle ?? 'Your favourites',
          body: l?.tourFavBody ??
              'Species you bookmark from Home and details appear here automatically.',
        ),
        IntroStep(
          icon: Icons.open_in_new_rounded,
          title: l?.tourOpenTitle ?? 'Open species details',
          body: l?.tourOpenBody ??
              'Tap any saved card to jump into full species detail and prediction shortcuts.',
        ),
        IntroStep(
          icon: Icons.delete_outline_rounded,
          title: l?.tourCleanTitle ?? 'Clean up list',
          body: l?.tourCleanBody ??
              'Remove saved entries when your shortlist changes.',
        ),
      ],
    ),
    OnboardingTour.identify: IntroContent(
      title: l?.tourIdentifyTitle ?? 'AI species recognition',
      subtitle: l?.tourIdentifySubtitle ??
          'Snap a photo or pick one from your gallery to identify Malaysian wildlife instantly.',
      steps: [
        IntroStep(
          icon: Icons.photo_camera_outlined,
          title: l?.tourTakePhotoTitle ?? 'Take a photo',
          body: l?.tourTakePhotoBody ??
              'Use your camera for the freshest, sharpest result.',
        ),
        IntroStep(
          icon: Icons.upload_rounded,
          title: l?.tourUploadTitle ?? 'Upload from gallery',
          body: l?.tourUploadBody ??
              'Pick an existing photo from your device.',
        ),
        IntroStep(
          icon: Icons.tips_and_updates_outlined,
          title: l?.tourTipsTitle ?? 'Tips for best results',
          body: l?.tourTipsBody ??
              'Well-lit, clear shots of a single subject deliver the best matches.',
        ),
      ],
    ),
    OnboardingTour.mission: IntroContent(
      title: l?.tourMissionTitle ?? 'Personalised photo missions',
      subtitle: l?.tourMissionSubtitle ??
          'Answer a short quiz and we will design a mission for your gear and skill level.',
      steps: [
        IntroStep(
          icon: Icons.checklist_rounded,
          title: l?.tourQuizTitle ?? 'Quick quiz',
          body: l?.tourQuizBody ??
              'Tell us about your gear, time, subject, and difficulty preference.',
        ),
        IntroStep(
          icon: Icons.flag_outlined,
          title: l?.tourGetMissionTitle ?? 'Get your mission',
          body: l?.tourGetMissionBody ??
              'Receive a tailored field plan with step-by-step tasks.',
        ),
        IntroStep(
          icon: Icons.add_a_photo_outlined,
          title: l?.tourSubmitTitle ?? 'Submit proof',
          body: l?.tourSubmitBody ??
              'Upload a photo to mark a task complete and unlock the next step.',
        ),
      ],
    ),
    OnboardingTour.map: IntroContent(
      title: l?.tourMapTitle ?? 'Explore on the map',
      subtitle: l?.tourMapSubtitle ??
          'Find wildlife sites, weather, and recent sightings around you.',
      steps: [
        IntroStep(
          icon: Icons.search_rounded,
          title: l?.tourMapSearchTitle ?? 'Search a location',
          body: l?.tourMapSearchBody ??
              'Use the search bar at the top to jump to a city, park, or coordinate.',
        ),
        IntroStep(
          icon: Icons.place_outlined,
          title: l?.tourMapMarkersTitle ?? 'Tap markers',
          body: l?.tourMapMarkersBody ??
              'Markers show known habitats. Tap one for species details and weather.',
        ),
        IntroStep(
          icon: Icons.adjust_outlined,
          title: l?.tourMapRadiusTitle ?? 'Use the radius tool',
          body: l?.tourMapRadiusBody ??
              'Adjust the search radius to focus on the area around you.',
        ),
      ],
    ),
  };
}

/// Slides shown the very first time a user opens the app.
List<IntroStep> kWelcomeSlides(BuildContext context) {
  final l = AppLocalizations.of(context);
  return [
    IntroStep(
      icon: Icons.eco_rounded,
      title: l?.onboardingWelcomeTitle ?? 'Welcome to KACHAK',
      body: l?.onboardingWelcomeBody ??
          'A bright, beginner-friendly companion for Malaysian wildlife photographers.',
    ),
    IntroStep(
      icon: Icons.explore_outlined,
      title: l?.onboardingFiveTools ?? 'Five tools, one journey',
      body: l?.onboardingFiveToolsBody ??
          'Discover species, save favourites, identify photos with AI, run guided missions, and explore on the map.',
    ),
    IntroStep(
      icon: Icons.touch_app_outlined,
      title: l?.onboardingTapTab ?? 'Tap a tab to begin',
      body: l?.onboardingTapTabBody ??
          'We will show a quick tour the first time you open each section. Reopen it any time from the menu.',
    ),
  ];
}
