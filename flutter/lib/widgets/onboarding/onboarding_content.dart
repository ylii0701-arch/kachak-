import 'package:flutter/material.dart';

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
const Map<OnboardingTour, IntroContent> kOnboardingContent = {
  OnboardingTour.home: IntroContent(
    title: 'Discover species',
    subtitle:
        'Browse Malaysian wildlife as if flipping through a field-guide journal.',
    steps: [
      IntroStep(
        icon: Icons.search_rounded,
        title: 'Search by name',
        body:
            'Type a common or scientific name to jump straight to a species card.',
      ),
      IntroStep(
        icon: Icons.tune_rounded,
        title: 'Filter & sort',
        body:
            'Use tabs to filter by location, category, conservation status, and difficulty.',
      ),
      IntroStep(
        icon: Icons.grid_view_rounded,
        title: 'Switch layouts',
        body:
            'Tap the layout button on the right to toggle between list and grid.',
      ),
      IntroStep(
        icon: Icons.bookmark_outline_rounded,
        title: 'Save favourites',
        body: 'Bookmark any card to revisit it later from the side menu.',
      ),
      IntroStep(
        icon: Icons.location_on_outlined,
        title: 'Area predictions in Home',
        body: 'Choose a location in Filter to switch Home into prediction-ranked results.',
      ),
    ],
  ),
  OnboardingTour.saved: IntroContent(
    title: 'Saved species',
    subtitle:
        'Revisit your bookmarked species and open details quickly.',
    steps: [
      IntroStep(
        icon: Icons.favorite_outline_rounded,
        title: 'Your favourites',
        body:
            'Species you bookmark from Home and details appear here automatically.',
      ),
      IntroStep(
        icon: Icons.open_in_new_rounded,
        title: 'Open species details',
        body:
            'Tap any saved card to jump into full species detail and prediction shortcuts.',
      ),
      IntroStep(
        icon: Icons.delete_outline_rounded,
        title: 'Clean up list',
        body:
            'Remove saved entries when your shortlist changes.',
      ),
    ],
  ),
  OnboardingTour.identify: IntroContent(
    title: 'AI species recognition',
    subtitle:
        'Snap a photo or pick one from your gallery to identify Malaysian wildlife instantly.',
    steps: [
      IntroStep(
        icon: Icons.photo_camera_outlined,
        title: 'Take a photo',
        body: 'Use your camera for the freshest, sharpest result.',
      ),
      IntroStep(
        icon: Icons.upload_rounded,
        title: 'Upload from gallery',
        body: 'Pick an existing photo from your device.',
      ),
      IntroStep(
        icon: Icons.tips_and_updates_outlined,
        title: 'Tips for best results',
        body:
            'Well-lit, clear shots of a single subject deliver the best matches.',
      ),
    ],
  ),
  OnboardingTour.mission: IntroContent(
    title: 'Personalised photo missions',
    subtitle:
        'Answer a short quiz and we will design a mission for your gear and skill level.',
    steps: [
      IntroStep(
        icon: Icons.checklist_rounded,
        title: 'Quick quiz',
        body:
            'Tell us about your gear, time, subject, and difficulty preference.',
      ),
      IntroStep(
        icon: Icons.flag_outlined,
        title: 'Get your mission',
        body: 'Receive a tailored field plan with step-by-step tasks.',
      ),
      IntroStep(
        icon: Icons.add_a_photo_outlined,
        title: 'Submit proof',
        body:
            'Upload a photo to mark a task complete and unlock the next step.',
      ),
    ],
  ),
  OnboardingTour.map: IntroContent(
    title: 'Explore on the map',
    subtitle: 'Find wildlife sites, weather, and recent sightings around you.',
    steps: [
      IntroStep(
        icon: Icons.search_rounded,
        title: 'Search a location',
        body:
            'Use the search bar at the top to jump to a city, park, or coordinate.',
      ),
      IntroStep(
        icon: Icons.place_outlined,
        title: 'Tap markers',
        body:
            'Markers show known habitats. Tap one for species details and weather.',
      ),
      IntroStep(
        icon: Icons.adjust_outlined,
        title: 'Use the radius tool',
        body: 'Adjust the search radius to focus on the area around you.',
      ),
    ],
  ),
};

/// Slides shown the very first time a user opens the app.
const List<IntroStep> kWelcomeSlides = [
  IntroStep(
    icon: Icons.eco_rounded,
    title: 'Welcome to KACHAK',
    body:
        'A bright, beginner-friendly companion for Malaysian wildlife photographers.',
  ),
  IntroStep(
    icon: Icons.explore_outlined,
    title: 'Five tools, one journey',
    body:
        'Discover species, save favourites, identify photos with AI, run guided missions, and explore on the map.',
  ),
  IntroStep(
    icon: Icons.touch_app_outlined,
    title: 'Tap a tab to begin',
    body:
        'We will show a quick tour the first time you open each section. Reopen it any time from the menu.',
  ),
];
