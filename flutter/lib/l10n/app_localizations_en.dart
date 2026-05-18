// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navMap => 'Map';

  @override
  String get navIdentify => 'Identify';

  @override
  String get navMission => 'Mission';

  @override
  String get navSaved => 'Saved';

  @override
  String get menuTitle => 'Menu';

  @override
  String get menuLanguage => 'Language';

  @override
  String get menuMoreInfo => 'MORE INFO';

  @override
  String get menuNatureFirst => 'Nature First Principle';

  @override
  String get menuShowTutorial => 'Show tutorial';

  @override
  String get menuAboutUs => 'About us';

  @override
  String get homeTitle => 'Malaysian Wildlife Explorer';

  @override
  String get homeSearchHint => 'Search species name';

  @override
  String get homeFilter => 'Filter';

  @override
  String get homeSort => 'Sort';

  @override
  String get homeClear => 'Clear';

  @override
  String get homeResetFilters => 'Reset filters';

  @override
  String get homeConfirm => 'Confirm';

  @override
  String get homeReset => 'Reset';

  @override
  String get homeNoResults => 'No species found';

  @override
  String get homeNoFilterResults => 'No results match your filters';

  @override
  String get homeClearSearch => 'Clear search';

  @override
  String get homeCity => 'City';

  @override
  String get homeSite => 'Site';

  @override
  String get homeAll => 'All';

  @override
  String get homeCategory => 'Category';

  @override
  String get homeConservationStatus => 'Conservation Status';

  @override
  String get homeDifficultyLevel => 'Shooting Difficulty Level';

  @override
  String get homeSortBy => 'Sort By';

  @override
  String get homeSortNone => 'None';

  @override
  String get homeSortConservation => 'Conservation Status';

  @override
  String get homeSortDifficulty => 'Difficulty Level';

  @override
  String get homeOrderAsc => 'Ascending';

  @override
  String get homeOrderDesc => 'Descending';

  @override
  String get homeAreaPrediction =>
      'Showing prediction-ranked species for selected area.';

  @override
  String get homeAllRegions => 'All regions';

  @override
  String get homeDifficulty => 'Difficulty:';

  @override
  String get homeLocationTab => 'Location';

  @override
  String get homeSpeciesTab => 'Species';

  @override
  String get homeShowMore => 'Show more';

  @override
  String get homeShowLess => 'Show less';

  @override
  String get identifyTitle => 'Image Recognition';

  @override
  String get identifySpeciesTab => 'Species';

  @override
  String get identifyQualityTab => 'Image Quality';

  @override
  String get identifySpeciesSubtitle =>
      'Scan a wildlife photo with AI species identification.';

  @override
  String get identifyQualitySubtitle =>
      'Analyze your photo\'s sharpness, exposure, and framing.';

  @override
  String get identifyScanNow => 'Scan Now';

  @override
  String get identifyScoreNow => 'Score Now';

  @override
  String get identifyPickerHint => 'Tap to take photo or upload from gallery';

  @override
  String get identifyTakePhoto => 'Take photo';

  @override
  String get identifyUploadGallery => 'Upload from gallery';

  @override
  String get identifyCancel => 'Cancel';

  @override
  String get identifyTipsTitle => 'Tips for best species scan';

  @override
  String get identifyTipLighting => 'Use good lighting';

  @override
  String get identifyTipLightingBody =>
      'Natural light gives better identification.';

  @override
  String get identifyTipCentered => 'Keep animal centered';

  @override
  String get identifyTipCenteredBody =>
      'Avoid cutting the animal out of frame.';

  @override
  String get identifyTipClear => 'Clear background';

  @override
  String get identifyTipClearBody =>
      'Minimize distracting elements behind the subject.';

  @override
  String get identifyAnalyzing => 'Analyzing your photo...';

  @override
  String get identifyFailed => 'Failed to analyze image. Please try again.';

  @override
  String get savedEmptyTitle => 'No favorite species yet';

  @override
  String get savedEmptyBody =>
      'Start exploring and save species you want to photograph.';

  @override
  String get savedExploreButton => 'Explore species';

  @override
  String get savedTitle => 'Saved';

  @override
  String savedSpeciesCount(int count) {
    return '$count species';
  }

  @override
  String get speciesDetailAbout => 'About';

  @override
  String get speciesDetailBehavior => 'Behavior & Notes';

  @override
  String get speciesDetailPhotography => 'Photography Conditions';

  @override
  String get speciesDetailGear => 'Recommended Gear';

  @override
  String get speciesDetailBestSeasons => 'Best Seasons';

  @override
  String get speciesDetailPrediction => 'Current Prediction';

  @override
  String get speciesDetailSavedToFav => 'Saved to Favorites';

  @override
  String get speciesDetailSaveToFav => 'Save to Favorites';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonError => 'Error';

  @override
  String get commonPrevious => 'Previous';

  @override
  String get commonNext => 'Next';

  @override
  String get categoryMammals => 'Mammals';

  @override
  String get categoryBirds => 'Birds';

  @override
  String get categoryReptiles => 'Reptiles';

  @override
  String get categoryAmphibians => 'Amphibians';

  @override
  String get categoryInsects => 'Insects';

  @override
  String get statusLeastConcern => 'Least Concern';

  @override
  String get statusNearThreatened => 'Near Threatened';

  @override
  String get statusVulnerable => 'Vulnerable';

  @override
  String get statusEndangered => 'Endangered';

  @override
  String get statusCriticallyEndangered => 'Critically Endangered';

  @override
  String get shootingDifficulty => 'Shooting difficulty';

  @override
  String get speciesDetailHabitat => 'Habitat';

  @override
  String get speciesDetailHabitatLocations => 'Habitat & Locations';

  @override
  String get speciesDetailDiet => 'Diet';

  @override
  String get speciesDetailSeeMorePrediction => 'See more prediction details';

  @override
  String get speciesDetailBestTime => 'Best Time';

  @override
  String get speciesDetailWeather => 'Weather';

  @override
  String get speciesDetailTemp => 'Temp';

  @override
  String get speciesDetailHumidity => 'Humidity';

  @override
  String get speciesDetailActivityPattern => 'Activity Pattern';

  @override
  String get predictionTitle => '7-Day Occurrence Forecast';

  @override
  String get predictionKeyFactors => 'Key Factors';

  @override
  String get predictionAlertOff => 'Alert Off';

  @override
  String get predictionAlertOn => 'Alert On';

  @override
  String get predictionToday => 'Today';

  @override
  String get predictionTomorrow => 'Tomorrow';

  @override
  String get predictionBestTime => 'Best Time';

  @override
  String get predictionWeather => 'Weather';

  @override
  String get predictionTemperature => 'Temperature';

  @override
  String get predictionHumidity => 'Humidity';

  @override
  String get predictionUnknown => 'Unknown';

  @override
  String get predictionViewFullSpecies => 'View Full Species Details';

  @override
  String get predictionCalculating => 'Calculating predictions...';

  @override
  String get predictionBack => 'Back';

  @override
  String predictionBestSite(String site) {
    return 'Best Site: $site';
  }

  @override
  String get mapSearchHint => 'Search species';

  @override
  String get mapMyLocation => 'My Location';

  @override
  String get mapWeather => 'Weather';

  @override
  String get mapSpeciesSites => 'Species Sites';

  @override
  String get identifyTotalScore => 'Total score';

  @override
  String get identifySharpness => 'Sharpness';

  @override
  String get identifyExposure => 'Exposure';

  @override
  String get identifyContrast => 'Contrast';

  @override
  String get identifySubjectFraming => 'Subject framing';

  @override
  String get identifyHowToImprove => 'How to improve this photo';

  @override
  String get identifyTryAnother => 'Try another photo';

  @override
  String get identifySpeciesResult => 'Species identified';

  @override
  String get identifyConfidence => 'Confidence';

  @override
  String get identifyNotRecognized => 'Species not recognized';

  @override
  String get identifyLow => 'Low';

  @override
  String get identifyMedium => 'Medium';

  @override
  String get identifyHigh => 'High';

  @override
  String get identifyScanningSpecies => 'Scanning species...';

  @override
  String get identifyScoringQuality => 'Scoring photo quality...';

  @override
  String get missionTitle => 'Photo Mission';

  @override
  String get missionSubtitle => 'Malaysian Wildlife Explorer';

  @override
  String get missionPersonalise =>
      'Personalise and find your perfect challenge today!';

  @override
  String get missionChoosePrefs =>
      'Choose your preferences and we\'ll create missions just for you.';

  @override
  String get missionLetsBegin => 'Let\'s Begin!';

  @override
  String get missionIdeasTitle => 'Mission Ideas for You';

  @override
  String get missionIdeasSubtitle => 'Quick inspiration to get started';

  @override
  String get missionGearQuestion => 'What gear do you have?';

  @override
  String get missionGearSubtitle => 'Select your camera setup';

  @override
  String get missionDifficultyQuestion => 'Choose your challenge level';

  @override
  String get missionDifficultySubtitle =>
      'How difficult should this mission be?';

  @override
  String get missionSubjectQuestion => 'What subject do you prefer?';

  @override
  String get missionSubjectSubtitle => 'Select wildlife category';

  @override
  String get missionTimeQuestion => 'Preferred shoot time?';

  @override
  String get missionTimeSubtitle => 'Pick your ideal session window';

  @override
  String get missionYourMission => 'Your Photography Mission';

  @override
  String missionLocationHint(String hint) {
    return 'Location hint: $hint';
  }

  @override
  String get missionMoveOn => 'Move on to Task List';

  @override
  String get missionResetChoices => 'Reset Choices';

  @override
  String get missionWeeklyTask => 'Weekly Task';

  @override
  String get missionStartOver => 'Start Over';

  @override
  String get missionSubmitProof => 'Upload Proof Photo';

  @override
  String get missionCasual => 'Casual';

  @override
  String get missionStandard => 'Standard';

  @override
  String get missionChallenging => 'Challenging';

  @override
  String get missionMorning => 'Morning';

  @override
  String get missionAfternoon => 'Afternoon';

  @override
  String get missionEvening => 'Evening';

  @override
  String get missionNight => 'Night';

  @override
  String get missionMidnight => 'Midnight';

  @override
  String get onboardingWelcomeTitle => 'Welcome to KACHAK';

  @override
  String get onboardingWelcomeBody =>
      'A bright, beginner-friendly companion for Malaysian wildlife photographers.';

  @override
  String get onboardingFiveTools => 'Five tools, one journey';

  @override
  String get onboardingFiveToolsBody =>
      'Discover species, save favourites, identify photos with AI, run guided missions, and explore on the map.';

  @override
  String get onboardingTapTab => 'Tap a tab to begin';

  @override
  String get onboardingTapTabBody =>
      'We will show a quick tour the first time you open each section. Reopen it any time from the menu.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get tourHomeTitle => 'Discover species';

  @override
  String get tourHomeSubtitle =>
      'Browse Malaysian wildlife as if flipping through a field-guide journal.';

  @override
  String get tourSearchTitle => 'Search by name';

  @override
  String get tourSearchBody =>
      'Type a common or scientific name to jump straight to a species card.';

  @override
  String get tourFilterTitle => 'Filter & sort';

  @override
  String get tourFilterBody =>
      'Use tabs to filter by location, category, conservation status, and difficulty.';

  @override
  String get tourLayoutTitle => 'Switch layouts';

  @override
  String get tourLayoutBody =>
      'Tap the layout button on the right to toggle between list and grid.';

  @override
  String get tourSaveTitle => 'Save favourites';

  @override
  String get tourSaveBody =>
      'Bookmark any card to revisit it later from the side menu.';

  @override
  String get tourAreaTitle => 'Area predictions in Home';

  @override
  String get tourAreaBody =>
      'Choose a location in Filter to switch Home into prediction-ranked results.';

  @override
  String get tourIdentifyTitle => 'AI species recognition';

  @override
  String get tourIdentifySubtitle =>
      'Snap a photo or pick one from your gallery to identify Malaysian wildlife instantly.';

  @override
  String get tourTakePhotoTitle => 'Take a photo';

  @override
  String get tourTakePhotoBody =>
      'Use your camera for the freshest, sharpest result.';

  @override
  String get tourUploadTitle => 'Upload from gallery';

  @override
  String get tourUploadBody => 'Pick an existing photo from your device.';

  @override
  String get tourTipsTitle => 'Tips for best results';

  @override
  String get tourTipsBody =>
      'Well-lit, clear shots of a single subject deliver the best matches.';

  @override
  String get tourMapTitle => 'Explore on the map';

  @override
  String get tourMapSubtitle =>
      'Find wildlife sites, weather, and recent sightings around you.';

  @override
  String get tourMapSearchTitle => 'Search a location';

  @override
  String get tourMapSearchBody =>
      'Use the search bar at the top to jump to a city, park, or coordinate.';

  @override
  String get tourMapMarkersTitle => 'Tap markers';

  @override
  String get tourMapMarkersBody =>
      'Markers show known habitats. Tap one for species details and weather.';

  @override
  String get tourMapRadiusTitle => 'Use the radius tool';

  @override
  String get tourMapRadiusBody =>
      'Adjust the search radius to focus on the area around you.';

  @override
  String get tourMissionTitle => 'Personalised photo missions';

  @override
  String get tourMissionSubtitle =>
      'Answer a short quiz and we will design a mission for your gear and skill level.';

  @override
  String get tourQuizTitle => 'Quick quiz';

  @override
  String get tourQuizBody =>
      'Tell us about your gear, time, subject, and difficulty preference.';

  @override
  String get tourGetMissionTitle => 'Get your mission';

  @override
  String get tourGetMissionBody =>
      'Receive a tailored field plan with step-by-step tasks.';

  @override
  String get tourSubmitTitle => 'Submit proof';

  @override
  String get tourSubmitBody =>
      'Upload a photo to mark a task complete and unlock the next step.';

  @override
  String get tourSavedTitle => 'Saved species';

  @override
  String get tourSavedSubtitle =>
      'Revisit your bookmarked species and open details quickly.';

  @override
  String get tourFavTitle => 'Your favourites';

  @override
  String get tourFavBody =>
      'Species you bookmark from Home and details appear here automatically.';

  @override
  String get tourOpenTitle => 'Open species details';

  @override
  String get tourOpenBody =>
      'Tap any saved card to jump into full species detail and prediction shortcuts.';

  @override
  String get tourCleanTitle => 'Clean up list';

  @override
  String get tourCleanBody =>
      'Remove saved entries when your shortlist changes.';

  @override
  String get identifyTipBlur => 'Avoid blur';

  @override
  String get identifyTipBlurBody =>
      'Hold steady or tap to focus before shooting.';

  @override
  String get identifyPrediction => 'Prediction';

  @override
  String get identifyOpenDetails => 'Open full details';

  @override
  String get identifyUseMissionProof => 'Use as mission proof';

  @override
  String get mapLocationDenied => 'Location access denied';

  @override
  String get mapLocationError => 'Unable to get location';

  @override
  String get mapWeatherLoadError => 'Unable to load weather data';

  @override
  String get mapClearSearch => 'Clear search';

  @override
  String get mapRefreshWeather => 'Refresh weather';

  @override
  String get mapHideCityWeather => 'Hide city weather';

  @override
  String get mapShowCityWeather => 'Show city weather';

  @override
  String get mapShowSpeciesPhotoSpots => 'Show species photo spots';

  @override
  String get mapZoomIn => 'Zoom in';

  @override
  String get mapZoomOut => 'Zoom out';

  @override
  String get mapRestricted => 'Restricted';

  @override
  String get mapClose => 'Close';

  @override
  String get mapLastSeen => 'Last seen';

  @override
  String get mapDangerZone => 'Danger zone';

  @override
  String get mapOutsideProtected => 'Outside protected area';

  @override
  String get mapViewMoreDetails => 'View more details';

  @override
  String get mapHumidity => 'Humidity';

  @override
  String get mapWind => 'Wind';

  @override
  String get mapPredictionRegion => 'Prediction region';

  @override
  String get mapNextForecast => 'Next forecast';

  @override
  String get mapForecastUnavailable => 'Forecast unavailable';

  @override
  String get mapHumidityShort => 'Humidity';

  @override
  String get mapWindShort => 'Wind';

  @override
  String get missionResetConfirm => 'Reset all choices and start over?';

  @override
  String get missionReset => 'Reset';

  @override
  String get missionBirds => 'Birds';

  @override
  String get missionMammals => 'Mammals';

  @override
  String get missionInsects => 'Insects';

  @override
  String get missionReptiles => 'Reptiles';

  @override
  String get missionAmphibians => 'Amphibians';

  @override
  String get detailRecordedObservation => 'Recorded observation';

  @override
  String get detailLastSeen => 'Last seen';

  @override
  String get detailTapRowHint =>
      'Tap a row to open the map centered on that pin.';

  @override
  String get detailShowMore => 'Show more';

  @override
  String get detailShowLess => 'Show less';

  @override
  String get detailNationalPark => 'National Park';

  @override
  String get detailDifficult => 'Difficult';

  @override
  String get spotlightFilterTitle => 'Filter wildlife list';

  @override
  String get spotlightFilterBody =>
      'Use Filter to narrow by location and species attributes.';

  @override
  String get spotlightFilterTabsTitle => 'Location and species filters';

  @override
  String get spotlightFilterTabsBody =>
      'Use the Location tab to filter by city or site. Switch to Species to set category, conservation status, and difficulty.';

  @override
  String get spotlightLayoutTitle => 'Switch layouts';

  @override
  String get spotlightLayoutBody =>
      'Tap to toggle between card grid and compact list.';

  @override
  String get spotlightAiChatTitle => 'AI assistant';

  @override
  String get spotlightAiChatBody =>
      'Ask about wildlife photography planning, preparation, and field tips.';

  @override
  String get spotlightMapPageTitle => 'Map page';

  @override
  String get spotlightMapPageBody =>
      'Map helps you view wildlife locations and explore areas by place.';

  @override
  String get spotlightIdentifyPageTitle => 'Identify page';

  @override
  String get spotlightIdentifyPageBody =>
      'Identify lets you identify wildlife from your captured photo.';

  @override
  String get spotlightMissionPageTitle => 'Mission page';

  @override
  String get spotlightMissionPageBody =>
      'Mission gives guided tasks and learning challenges while exploring.';

  @override
  String get spotlightSavedPageTitle => 'Saved page';

  @override
  String get spotlightSavedPageBody =>
      'Saved keeps your bookmarked species for quick access.';

  @override
  String get spotlightMapRefreshTitle => 'Refresh map weather';

  @override
  String get spotlightMapRefreshBody =>
      'Reload weather information from all city marker stations.';

  @override
  String get spotlightMapWeatherTitle => 'Toggle weather layer';

  @override
  String get spotlightMapWeatherBody =>
      'Show or hide weather markers to focus on sightings or forecast context.';

  @override
  String get spotlightMapFocusTitle => 'Focus wildlife hotspots';

  @override
  String get spotlightMapFocusBody =>
      'Jump the camera to fit known wildlife and photography hotspot coverage.';

  @override
  String get spotlightMapMyLocTitle => 'Go to my location';

  @override
  String get spotlightMapMyLocBody =>
      'Center the map back to your current position quickly.';

  @override
  String get spotlightMapZoomInTitle => 'Zoom in';

  @override
  String get spotlightMapZoomInBody =>
      'Increase map zoom for close-up marker and area details.';

  @override
  String get spotlightMapZoomOutTitle => 'Zoom out';

  @override
  String get spotlightMapZoomOutBody =>
      'Reduce map zoom to see wider region context.';

  @override
  String get spotlightMapWeatherMarkerTitle => 'Weather marker';

  @override
  String get spotlightMapWeatherMarkerBody =>
      'City weather shows current conditions and short forecast for planning shoots.';

  @override
  String get spotlightMapAnimalMarkerTitle => 'Animal marker';

  @override
  String get spotlightMapAnimalMarkerBody =>
      'Tap an animal marker to see species information, photos, and nearby weather.';

  @override
  String get spotlightDetailAlertTitle => 'Enable alerts';

  @override
  String get spotlightDetailAlertBody =>
      'After saving, tap this icon to enable species notifications for higher-probability sightings.';

  @override
  String get spotlightDetailPredictionTitle => 'Current prediction';

  @override
  String get spotlightDetailPredictionBody =>
      'This card shows the best site and current weather-based probability for spotting this species.';

  @override
  String get spotlightDetailObservationTitle => 'Recorded observation';

  @override
  String get spotlightDetailObservationBody =>
      'This first recorded observation row includes the latest sighting and coordinates.';

  @override
  String get spotlightDetailMapTitle => 'Open on map';

  @override
  String get spotlightDetailMapBody =>
      'Tap this map button to view the animal last occurrence directly on the map.';

  @override
  String get chatTitle => 'Photo Assistant';

  @override
  String get chatSubtitle => 'Camera settings & tips';

  @override
  String get chatWelcome => 'What can I help with?';

  @override
  String get chatHint => 'Ask anything about wildlife photography...';

  @override
  String get chatDisclaimer =>
      'Photography AI chat can make mistakes. Please double check responses.';

  @override
  String get chatCopied => 'Message copied';

  @override
  String get chatIrrelevant =>
      'This is unrelated to wildlife photography. Please try another question.';

  @override
  String get chatSuggestion1 =>
      'What camera settings should I use for birds in flight?';

  @override
  String get chatSuggestion2 =>
      'Recommend equipment for photographing nocturnal animals';

  @override
  String get chatSuggestion3 =>
      'Best settings for macro photography of insects';

  @override
  String get chatSuggestion4 => 'What should I bring for a rainforest shoot?';

  @override
  String get chatClarifyGear =>
      'Please share your camera and lens so I can tailor the settings.';

  @override
  String get chatClarifyAnimal =>
      'Please clarify your target animal first so I can prepare the right checklist.';

  @override
  String get notificationHighProbTitle => 'Optimal Conditions Detected!';

  @override
  String notificationHighProbBody(int count) {
    return '$count of your saved animals have >=80% chance of appearing today!';
  }
}
