import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ms'),
    Locale('zh'),
  ];

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navIdentify.
  ///
  /// In en, this message translates to:
  /// **'Identify'**
  String get navIdentify;

  /// No description provided for @navMission.
  ///
  /// In en, this message translates to:
  /// **'Mission'**
  String get navMission;

  /// No description provided for @navSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get navSaved;

  /// No description provided for @menuTitle.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuTitle;

  /// No description provided for @menuLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get menuLanguage;

  /// No description provided for @menuMoreInfo.
  ///
  /// In en, this message translates to:
  /// **'MORE INFO'**
  String get menuMoreInfo;

  /// No description provided for @menuNatureFirst.
  ///
  /// In en, this message translates to:
  /// **'Nature First Principle'**
  String get menuNatureFirst;

  /// No description provided for @menuShowTutorial.
  ///
  /// In en, this message translates to:
  /// **'Show tutorial'**
  String get menuShowTutorial;

  /// No description provided for @menuAboutUs.
  ///
  /// In en, this message translates to:
  /// **'About us'**
  String get menuAboutUs;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Malaysian Wildlife Explorer'**
  String get homeTitle;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search species name'**
  String get homeSearchHint;

  /// No description provided for @homeFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get homeFilter;

  /// No description provided for @homeSort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get homeSort;

  /// No description provided for @homeClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get homeClear;

  /// No description provided for @homeResetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get homeResetFilters;

  /// No description provided for @homeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get homeConfirm;

  /// No description provided for @homeReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get homeReset;

  /// No description provided for @homeNoResults.
  ///
  /// In en, this message translates to:
  /// **'No species found'**
  String get homeNoResults;

  /// No description provided for @homeNoFilterResults.
  ///
  /// In en, this message translates to:
  /// **'No results match your filters'**
  String get homeNoFilterResults;

  /// No description provided for @homeClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get homeClearSearch;

  /// No description provided for @homeCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get homeCity;

  /// No description provided for @homeSite.
  ///
  /// In en, this message translates to:
  /// **'Site'**
  String get homeSite;

  /// No description provided for @homeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get homeAll;

  /// No description provided for @homeCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get homeCategory;

  /// No description provided for @homeConservationStatus.
  ///
  /// In en, this message translates to:
  /// **'Conservation Status'**
  String get homeConservationStatus;

  /// No description provided for @homeDifficultyLevel.
  ///
  /// In en, this message translates to:
  /// **'Shooting Difficulty Level'**
  String get homeDifficultyLevel;

  /// No description provided for @homeSortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get homeSortBy;

  /// No description provided for @homeSortNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get homeSortNone;

  /// No description provided for @homeSortConservation.
  ///
  /// In en, this message translates to:
  /// **'Conservation Status'**
  String get homeSortConservation;

  /// No description provided for @homeSortDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty Level'**
  String get homeSortDifficulty;

  /// No description provided for @homeOrderAsc.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get homeOrderAsc;

  /// No description provided for @homeOrderDesc.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get homeOrderDesc;

  /// No description provided for @homeAreaPrediction.
  ///
  /// In en, this message translates to:
  /// **'Showing prediction-ranked species for selected area.'**
  String get homeAreaPrediction;

  /// No description provided for @homeAllRegions.
  ///
  /// In en, this message translates to:
  /// **'All regions'**
  String get homeAllRegions;

  /// No description provided for @homeDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty:'**
  String get homeDifficulty;

  /// No description provided for @homeLocationTab.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get homeLocationTab;

  /// No description provided for @homeSpeciesTab.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get homeSpeciesTab;

  /// No description provided for @homeShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get homeShowMore;

  /// No description provided for @homeShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get homeShowLess;

  /// No description provided for @identifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Image Recognition'**
  String get identifyTitle;

  /// No description provided for @identifySpeciesTab.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get identifySpeciesTab;

  /// No description provided for @identifyQualityTab.
  ///
  /// In en, this message translates to:
  /// **'Image Quality'**
  String get identifyQualityTab;

  /// No description provided for @identifySpeciesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan a wildlife photo with AI species identification.'**
  String get identifySpeciesSubtitle;

  /// No description provided for @identifyQualitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Analyze your photo\'s sharpness, exposure, and framing.'**
  String get identifyQualitySubtitle;

  /// No description provided for @identifyScanNow.
  ///
  /// In en, this message translates to:
  /// **'Scan Now'**
  String get identifyScanNow;

  /// No description provided for @identifyScoreNow.
  ///
  /// In en, this message translates to:
  /// **'Score Now'**
  String get identifyScoreNow;

  /// No description provided for @identifyPickerHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to take photo or upload from gallery'**
  String get identifyPickerHint;

  /// No description provided for @identifyTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get identifyTakePhoto;

  /// No description provided for @identifyUploadGallery.
  ///
  /// In en, this message translates to:
  /// **'Upload from gallery'**
  String get identifyUploadGallery;

  /// No description provided for @identifyCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get identifyCancel;

  /// No description provided for @identifyTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tips for best species scan'**
  String get identifyTipsTitle;

  /// No description provided for @identifyTipLighting.
  ///
  /// In en, this message translates to:
  /// **'Use good lighting'**
  String get identifyTipLighting;

  /// No description provided for @identifyTipLightingBody.
  ///
  /// In en, this message translates to:
  /// **'Natural light gives better identification.'**
  String get identifyTipLightingBody;

  /// No description provided for @identifyTipCentered.
  ///
  /// In en, this message translates to:
  /// **'Keep animal centered'**
  String get identifyTipCentered;

  /// No description provided for @identifyTipCenteredBody.
  ///
  /// In en, this message translates to:
  /// **'Avoid cutting the animal out of frame.'**
  String get identifyTipCenteredBody;

  /// No description provided for @identifyTipClear.
  ///
  /// In en, this message translates to:
  /// **'Clear background'**
  String get identifyTipClear;

  /// No description provided for @identifyTipClearBody.
  ///
  /// In en, this message translates to:
  /// **'Minimize distracting elements behind the subject.'**
  String get identifyTipClearBody;

  /// No description provided for @identifyAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your photo...'**
  String get identifyAnalyzing;

  /// No description provided for @identifyFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to analyze image. Please try again.'**
  String get identifyFailed;

  /// No description provided for @savedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorite species yet'**
  String get savedEmptyTitle;

  /// No description provided for @savedEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Start exploring and save species you want to photograph.'**
  String get savedEmptyBody;

  /// No description provided for @savedExploreButton.
  ///
  /// In en, this message translates to:
  /// **'Explore species'**
  String get savedExploreButton;

  /// No description provided for @savedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedTitle;

  /// No description provided for @savedSpeciesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} species'**
  String savedSpeciesCount(int count);

  /// No description provided for @speciesDetailAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get speciesDetailAbout;

  /// No description provided for @speciesDetailBehavior.
  ///
  /// In en, this message translates to:
  /// **'Behavior & Notes'**
  String get speciesDetailBehavior;

  /// No description provided for @speciesDetailPhotography.
  ///
  /// In en, this message translates to:
  /// **'Photography Conditions'**
  String get speciesDetailPhotography;

  /// No description provided for @speciesDetailGear.
  ///
  /// In en, this message translates to:
  /// **'Recommended Gear'**
  String get speciesDetailGear;

  /// No description provided for @speciesDetailBestSeasons.
  ///
  /// In en, this message translates to:
  /// **'Best Seasons'**
  String get speciesDetailBestSeasons;

  /// No description provided for @speciesDetailPrediction.
  ///
  /// In en, this message translates to:
  /// **'Current Prediction'**
  String get speciesDetailPrediction;

  /// No description provided for @speciesDetailSavedToFav.
  ///
  /// In en, this message translates to:
  /// **'Saved to Favorites'**
  String get speciesDetailSavedToFav;

  /// No description provided for @speciesDetailSaveToFav.
  ///
  /// In en, this message translates to:
  /// **'Save to Favorites'**
  String get speciesDetailSaveToFav;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @commonPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get commonPrevious;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @categoryMammals.
  ///
  /// In en, this message translates to:
  /// **'Mammals'**
  String get categoryMammals;

  /// No description provided for @categoryBirds.
  ///
  /// In en, this message translates to:
  /// **'Birds'**
  String get categoryBirds;

  /// No description provided for @categoryReptiles.
  ///
  /// In en, this message translates to:
  /// **'Reptiles'**
  String get categoryReptiles;

  /// No description provided for @categoryAmphibians.
  ///
  /// In en, this message translates to:
  /// **'Amphibians'**
  String get categoryAmphibians;

  /// No description provided for @categoryInsects.
  ///
  /// In en, this message translates to:
  /// **'Insects'**
  String get categoryInsects;

  /// No description provided for @statusLeastConcern.
  ///
  /// In en, this message translates to:
  /// **'Least Concern'**
  String get statusLeastConcern;

  /// No description provided for @statusNearThreatened.
  ///
  /// In en, this message translates to:
  /// **'Near Threatened'**
  String get statusNearThreatened;

  /// No description provided for @statusVulnerable.
  ///
  /// In en, this message translates to:
  /// **'Vulnerable'**
  String get statusVulnerable;

  /// No description provided for @statusEndangered.
  ///
  /// In en, this message translates to:
  /// **'Endangered'**
  String get statusEndangered;

  /// No description provided for @statusCriticallyEndangered.
  ///
  /// In en, this message translates to:
  /// **'Critically Endangered'**
  String get statusCriticallyEndangered;

  /// No description provided for @shootingDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Shooting difficulty'**
  String get shootingDifficulty;

  /// No description provided for @speciesDetailHabitat.
  ///
  /// In en, this message translates to:
  /// **'Habitat'**
  String get speciesDetailHabitat;

  /// No description provided for @speciesDetailHabitatLocations.
  ///
  /// In en, this message translates to:
  /// **'Habitat & Locations'**
  String get speciesDetailHabitatLocations;

  /// No description provided for @speciesDetailDiet.
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get speciesDetailDiet;

  /// No description provided for @speciesDetailSeeMorePrediction.
  ///
  /// In en, this message translates to:
  /// **'See more prediction details'**
  String get speciesDetailSeeMorePrediction;

  /// No description provided for @speciesDetailBestTime.
  ///
  /// In en, this message translates to:
  /// **'Best Time'**
  String get speciesDetailBestTime;

  /// No description provided for @speciesDetailWeather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get speciesDetailWeather;

  /// No description provided for @speciesDetailTemp.
  ///
  /// In en, this message translates to:
  /// **'Temp'**
  String get speciesDetailTemp;

  /// No description provided for @speciesDetailHumidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get speciesDetailHumidity;

  /// No description provided for @speciesDetailActivityPattern.
  ///
  /// In en, this message translates to:
  /// **'Activity Pattern'**
  String get speciesDetailActivityPattern;

  /// No description provided for @predictionTitle.
  ///
  /// In en, this message translates to:
  /// **'7-Day Occurrence Forecast'**
  String get predictionTitle;

  /// No description provided for @predictionKeyFactors.
  ///
  /// In en, this message translates to:
  /// **'Key Factors'**
  String get predictionKeyFactors;

  /// No description provided for @predictionAlertOff.
  ///
  /// In en, this message translates to:
  /// **'Alert Off'**
  String get predictionAlertOff;

  /// No description provided for @predictionAlertOn.
  ///
  /// In en, this message translates to:
  /// **'Alert On'**
  String get predictionAlertOn;

  /// No description provided for @predictionToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get predictionToday;

  /// No description provided for @predictionTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get predictionTomorrow;

  /// No description provided for @predictionBestTime.
  ///
  /// In en, this message translates to:
  /// **'Best Time'**
  String get predictionBestTime;

  /// No description provided for @predictionWeather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get predictionWeather;

  /// No description provided for @predictionTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get predictionTemperature;

  /// No description provided for @predictionHumidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get predictionHumidity;

  /// No description provided for @predictionUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get predictionUnknown;

  /// No description provided for @predictionViewFullSpecies.
  ///
  /// In en, this message translates to:
  /// **'View Full Species Details'**
  String get predictionViewFullSpecies;

  /// No description provided for @predictionCalculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating predictions...'**
  String get predictionCalculating;

  /// No description provided for @predictionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get predictionBack;

  /// No description provided for @predictionBestSite.
  ///
  /// In en, this message translates to:
  /// **'Best Site: {site}'**
  String predictionBestSite(String site);

  /// No description provided for @mapSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search species'**
  String get mapSearchHint;

  /// No description provided for @mapMyLocation.
  ///
  /// In en, this message translates to:
  /// **'My Location'**
  String get mapMyLocation;

  /// No description provided for @mapWeather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get mapWeather;

  /// No description provided for @mapSpeciesSites.
  ///
  /// In en, this message translates to:
  /// **'Species Sites'**
  String get mapSpeciesSites;

  /// No description provided for @identifyTotalScore.
  ///
  /// In en, this message translates to:
  /// **'Total score'**
  String get identifyTotalScore;

  /// No description provided for @identifySharpness.
  ///
  /// In en, this message translates to:
  /// **'Sharpness'**
  String get identifySharpness;

  /// No description provided for @identifyExposure.
  ///
  /// In en, this message translates to:
  /// **'Exposure'**
  String get identifyExposure;

  /// No description provided for @identifyContrast.
  ///
  /// In en, this message translates to:
  /// **'Contrast'**
  String get identifyContrast;

  /// No description provided for @identifySubjectFraming.
  ///
  /// In en, this message translates to:
  /// **'Subject framing'**
  String get identifySubjectFraming;

  /// No description provided for @identifyHowToImprove.
  ///
  /// In en, this message translates to:
  /// **'How to improve this photo'**
  String get identifyHowToImprove;

  /// No description provided for @identifyTryAnother.
  ///
  /// In en, this message translates to:
  /// **'Try another photo'**
  String get identifyTryAnother;

  /// No description provided for @identifySpeciesResult.
  ///
  /// In en, this message translates to:
  /// **'Species identified'**
  String get identifySpeciesResult;

  /// No description provided for @identifyConfidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get identifyConfidence;

  /// No description provided for @identifyNotRecognized.
  ///
  /// In en, this message translates to:
  /// **'Species not recognized'**
  String get identifyNotRecognized;

  /// No description provided for @identifyLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get identifyLow;

  /// No description provided for @identifyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get identifyMedium;

  /// No description provided for @identifyHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get identifyHigh;

  /// No description provided for @identifyScanningSpecies.
  ///
  /// In en, this message translates to:
  /// **'Scanning species...'**
  String get identifyScanningSpecies;

  /// No description provided for @identifyScoringQuality.
  ///
  /// In en, this message translates to:
  /// **'Scoring photo quality...'**
  String get identifyScoringQuality;

  /// No description provided for @missionTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo Mission'**
  String get missionTitle;

  /// No description provided for @missionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Malaysian Wildlife Explorer'**
  String get missionSubtitle;

  /// No description provided for @missionPersonalise.
  ///
  /// In en, this message translates to:
  /// **'Personalise and find your perfect challenge today!'**
  String get missionPersonalise;

  /// No description provided for @missionChoosePrefs.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferences and we\'ll create missions just for you.'**
  String get missionChoosePrefs;

  /// No description provided for @missionLetsBegin.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Begin!'**
  String get missionLetsBegin;

  /// No description provided for @missionIdeasTitle.
  ///
  /// In en, this message translates to:
  /// **'Mission Ideas for You'**
  String get missionIdeasTitle;

  /// No description provided for @missionIdeasSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick inspiration to get started'**
  String get missionIdeasSubtitle;

  /// No description provided for @missionGearQuestion.
  ///
  /// In en, this message translates to:
  /// **'What gear do you have?'**
  String get missionGearQuestion;

  /// No description provided for @missionGearSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your camera setup'**
  String get missionGearSubtitle;

  /// No description provided for @missionDifficultyQuestion.
  ///
  /// In en, this message translates to:
  /// **'Choose your challenge level'**
  String get missionDifficultyQuestion;

  /// No description provided for @missionDifficultySubtitle.
  ///
  /// In en, this message translates to:
  /// **'How difficult should this mission be?'**
  String get missionDifficultySubtitle;

  /// No description provided for @missionSubjectQuestion.
  ///
  /// In en, this message translates to:
  /// **'What subject do you prefer?'**
  String get missionSubjectQuestion;

  /// No description provided for @missionSubjectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select wildlife category'**
  String get missionSubjectSubtitle;

  /// No description provided for @missionTimeQuestion.
  ///
  /// In en, this message translates to:
  /// **'Preferred shoot time?'**
  String get missionTimeQuestion;

  /// No description provided for @missionTimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick your ideal session window'**
  String get missionTimeSubtitle;

  /// No description provided for @missionYourMission.
  ///
  /// In en, this message translates to:
  /// **'Your Photography Mission'**
  String get missionYourMission;

  /// No description provided for @missionLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Location hint: {hint}'**
  String missionLocationHint(String hint);

  /// No description provided for @missionMoveOn.
  ///
  /// In en, this message translates to:
  /// **'Move on to Task List'**
  String get missionMoveOn;

  /// No description provided for @missionResetChoices.
  ///
  /// In en, this message translates to:
  /// **'Reset Choices'**
  String get missionResetChoices;

  /// No description provided for @missionWeeklyTask.
  ///
  /// In en, this message translates to:
  /// **'Weekly Task'**
  String get missionWeeklyTask;

  /// No description provided for @missionStartOver.
  ///
  /// In en, this message translates to:
  /// **'Start Over'**
  String get missionStartOver;

  /// No description provided for @missionSubmitProof.
  ///
  /// In en, this message translates to:
  /// **'Upload Proof Photo'**
  String get missionSubmitProof;

  /// No description provided for @missionCasual.
  ///
  /// In en, this message translates to:
  /// **'Casual'**
  String get missionCasual;

  /// No description provided for @missionStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get missionStandard;

  /// No description provided for @missionChallenging.
  ///
  /// In en, this message translates to:
  /// **'Challenging'**
  String get missionChallenging;

  /// No description provided for @missionMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get missionMorning;

  /// No description provided for @missionAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get missionAfternoon;

  /// No description provided for @missionEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get missionEvening;

  /// No description provided for @missionNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get missionNight;

  /// No description provided for @missionMidnight.
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get missionMidnight;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to KACHAK'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'A bright, beginner-friendly companion for Malaysian wildlife photographers.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingFiveTools.
  ///
  /// In en, this message translates to:
  /// **'Five tools, one journey'**
  String get onboardingFiveTools;

  /// No description provided for @onboardingFiveToolsBody.
  ///
  /// In en, this message translates to:
  /// **'Discover species, save favourites, identify photos with AI, run guided missions, and explore on the map.'**
  String get onboardingFiveToolsBody;

  /// No description provided for @onboardingTapTab.
  ///
  /// In en, this message translates to:
  /// **'Tap a tab to begin'**
  String get onboardingTapTab;

  /// No description provided for @onboardingTapTabBody.
  ///
  /// In en, this message translates to:
  /// **'We will show a quick tour the first time you open each section. Reopen it any time from the menu.'**
  String get onboardingTapTabBody;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @tourHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover species'**
  String get tourHomeTitle;

  /// No description provided for @tourHomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse Malaysian wildlife as if flipping through a field-guide journal.'**
  String get tourHomeSubtitle;

  /// No description provided for @tourSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get tourSearchTitle;

  /// No description provided for @tourSearchBody.
  ///
  /// In en, this message translates to:
  /// **'Type a common or scientific name to jump straight to a species card.'**
  String get tourSearchBody;

  /// No description provided for @tourFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter & sort'**
  String get tourFilterTitle;

  /// No description provided for @tourFilterBody.
  ///
  /// In en, this message translates to:
  /// **'Use tabs to filter by location, category, conservation status, and difficulty.'**
  String get tourFilterBody;

  /// No description provided for @tourLayoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch layouts'**
  String get tourLayoutTitle;

  /// No description provided for @tourLayoutBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the layout button on the right to toggle between list and grid.'**
  String get tourLayoutBody;

  /// No description provided for @tourSaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Save favourites'**
  String get tourSaveTitle;

  /// No description provided for @tourSaveBody.
  ///
  /// In en, this message translates to:
  /// **'Bookmark any card to revisit it later from the side menu.'**
  String get tourSaveBody;

  /// No description provided for @tourAreaTitle.
  ///
  /// In en, this message translates to:
  /// **'Area predictions in Home'**
  String get tourAreaTitle;

  /// No description provided for @tourAreaBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a location in Filter to switch Home into prediction-ranked results.'**
  String get tourAreaBody;

  /// No description provided for @tourIdentifyTitle.
  ///
  /// In en, this message translates to:
  /// **'AI species recognition'**
  String get tourIdentifyTitle;

  /// No description provided for @tourIdentifySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Snap a photo or pick one from your gallery to identify Malaysian wildlife instantly.'**
  String get tourIdentifySubtitle;

  /// No description provided for @tourTakePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get tourTakePhotoTitle;

  /// No description provided for @tourTakePhotoBody.
  ///
  /// In en, this message translates to:
  /// **'Use your camera for the freshest, sharpest result.'**
  String get tourTakePhotoBody;

  /// No description provided for @tourUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload from gallery'**
  String get tourUploadTitle;

  /// No description provided for @tourUploadBody.
  ///
  /// In en, this message translates to:
  /// **'Pick an existing photo from your device.'**
  String get tourUploadBody;

  /// No description provided for @tourTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tips for best results'**
  String get tourTipsTitle;

  /// No description provided for @tourTipsBody.
  ///
  /// In en, this message translates to:
  /// **'Well-lit, clear shots of a single subject deliver the best matches.'**
  String get tourTipsBody;

  /// No description provided for @tourMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore on the map'**
  String get tourMapTitle;

  /// No description provided for @tourMapSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find wildlife sites, weather, and recent sightings around you.'**
  String get tourMapSubtitle;

  /// No description provided for @tourMapSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search a location'**
  String get tourMapSearchTitle;

  /// No description provided for @tourMapSearchBody.
  ///
  /// In en, this message translates to:
  /// **'Use the search bar at the top to jump to a city, park, or coordinate.'**
  String get tourMapSearchBody;

  /// No description provided for @tourMapMarkersTitle.
  ///
  /// In en, this message translates to:
  /// **'Tap markers'**
  String get tourMapMarkersTitle;

  /// No description provided for @tourMapMarkersBody.
  ///
  /// In en, this message translates to:
  /// **'Markers show known habitats. Tap one for species details and weather.'**
  String get tourMapMarkersBody;

  /// No description provided for @tourMapRadiusTitle.
  ///
  /// In en, this message translates to:
  /// **'Use the radius tool'**
  String get tourMapRadiusTitle;

  /// No description provided for @tourMapRadiusBody.
  ///
  /// In en, this message translates to:
  /// **'Adjust the search radius to focus on the area around you.'**
  String get tourMapRadiusBody;

  /// No description provided for @tourMissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Personalised photo missions'**
  String get tourMissionTitle;

  /// No description provided for @tourMissionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Answer a short quiz and we will design a mission for your gear and skill level.'**
  String get tourMissionSubtitle;

  /// No description provided for @tourQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick quiz'**
  String get tourQuizTitle;

  /// No description provided for @tourQuizBody.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your gear, time, subject, and difficulty preference.'**
  String get tourQuizBody;

  /// No description provided for @tourGetMissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Get your mission'**
  String get tourGetMissionTitle;

  /// No description provided for @tourGetMissionBody.
  ///
  /// In en, this message translates to:
  /// **'Receive a tailored field plan with step-by-step tasks.'**
  String get tourGetMissionBody;

  /// No description provided for @tourSubmitTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit proof'**
  String get tourSubmitTitle;

  /// No description provided for @tourSubmitBody.
  ///
  /// In en, this message translates to:
  /// **'Upload a photo to mark a task complete and unlock the next step.'**
  String get tourSubmitBody;

  /// No description provided for @tourSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved species'**
  String get tourSavedTitle;

  /// No description provided for @tourSavedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Revisit your bookmarked species and open details quickly.'**
  String get tourSavedSubtitle;

  /// No description provided for @tourFavTitle.
  ///
  /// In en, this message translates to:
  /// **'Your favourites'**
  String get tourFavTitle;

  /// No description provided for @tourFavBody.
  ///
  /// In en, this message translates to:
  /// **'Species you bookmark from Home and details appear here automatically.'**
  String get tourFavBody;

  /// No description provided for @tourOpenTitle.
  ///
  /// In en, this message translates to:
  /// **'Open species details'**
  String get tourOpenTitle;

  /// No description provided for @tourOpenBody.
  ///
  /// In en, this message translates to:
  /// **'Tap any saved card to jump into full species detail and prediction shortcuts.'**
  String get tourOpenBody;

  /// No description provided for @tourCleanTitle.
  ///
  /// In en, this message translates to:
  /// **'Clean up list'**
  String get tourCleanTitle;

  /// No description provided for @tourCleanBody.
  ///
  /// In en, this message translates to:
  /// **'Remove saved entries when your shortlist changes.'**
  String get tourCleanBody;

  /// No description provided for @identifyTipBlur.
  ///
  /// In en, this message translates to:
  /// **'Avoid blur'**
  String get identifyTipBlur;

  /// No description provided for @identifyTipBlurBody.
  ///
  /// In en, this message translates to:
  /// **'Hold steady or tap to focus before shooting.'**
  String get identifyTipBlurBody;

  /// No description provided for @identifyPrediction.
  ///
  /// In en, this message translates to:
  /// **'Prediction'**
  String get identifyPrediction;

  /// No description provided for @identifyOpenDetails.
  ///
  /// In en, this message translates to:
  /// **'Open full details'**
  String get identifyOpenDetails;

  /// No description provided for @identifyUseMissionProof.
  ///
  /// In en, this message translates to:
  /// **'Use as mission proof'**
  String get identifyUseMissionProof;

  /// No description provided for @mapLocationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location access denied'**
  String get mapLocationDenied;

  /// No description provided for @mapLocationError.
  ///
  /// In en, this message translates to:
  /// **'Unable to get location'**
  String get mapLocationError;

  /// No description provided for @mapWeatherLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load weather data'**
  String get mapWeatherLoadError;

  /// No description provided for @mapClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get mapClearSearch;

  /// No description provided for @mapRefreshWeather.
  ///
  /// In en, this message translates to:
  /// **'Refresh weather'**
  String get mapRefreshWeather;

  /// No description provided for @mapHideCityWeather.
  ///
  /// In en, this message translates to:
  /// **'Hide city weather'**
  String get mapHideCityWeather;

  /// No description provided for @mapShowCityWeather.
  ///
  /// In en, this message translates to:
  /// **'Show city weather'**
  String get mapShowCityWeather;

  /// No description provided for @mapShowSpeciesPhotoSpots.
  ///
  /// In en, this message translates to:
  /// **'Show species photo spots'**
  String get mapShowSpeciesPhotoSpots;

  /// No description provided for @mapZoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get mapZoomIn;

  /// No description provided for @mapZoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get mapZoomOut;

  /// No description provided for @mapRestricted.
  ///
  /// In en, this message translates to:
  /// **'Restricted'**
  String get mapRestricted;

  /// No description provided for @mapClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get mapClose;

  /// No description provided for @mapLastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen'**
  String get mapLastSeen;

  /// No description provided for @mapDangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get mapDangerZone;

  /// No description provided for @mapOutsideProtected.
  ///
  /// In en, this message translates to:
  /// **'Outside protected area'**
  String get mapOutsideProtected;

  /// No description provided for @mapViewMoreDetails.
  ///
  /// In en, this message translates to:
  /// **'View more details'**
  String get mapViewMoreDetails;

  /// No description provided for @mapHumidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get mapHumidity;

  /// No description provided for @mapWind.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get mapWind;

  /// No description provided for @mapPredictionRegion.
  ///
  /// In en, this message translates to:
  /// **'Prediction region'**
  String get mapPredictionRegion;

  /// No description provided for @mapNextForecast.
  ///
  /// In en, this message translates to:
  /// **'Next forecast'**
  String get mapNextForecast;

  /// No description provided for @mapForecastUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Forecast unavailable'**
  String get mapForecastUnavailable;

  /// No description provided for @mapHumidityShort.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get mapHumidityShort;

  /// No description provided for @mapWindShort.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get mapWindShort;

  /// No description provided for @missionResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reset all choices and start over?'**
  String get missionResetConfirm;

  /// No description provided for @missionReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get missionReset;

  /// No description provided for @missionBirds.
  ///
  /// In en, this message translates to:
  /// **'Birds'**
  String get missionBirds;

  /// No description provided for @missionMammals.
  ///
  /// In en, this message translates to:
  /// **'Mammals'**
  String get missionMammals;

  /// No description provided for @missionInsects.
  ///
  /// In en, this message translates to:
  /// **'Insects'**
  String get missionInsects;

  /// No description provided for @missionReptiles.
  ///
  /// In en, this message translates to:
  /// **'Reptiles'**
  String get missionReptiles;

  /// No description provided for @missionAmphibians.
  ///
  /// In en, this message translates to:
  /// **'Amphibians'**
  String get missionAmphibians;

  /// No description provided for @detailRecordedObservation.
  ///
  /// In en, this message translates to:
  /// **'Recorded observation'**
  String get detailRecordedObservation;

  /// No description provided for @detailLastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen'**
  String get detailLastSeen;

  /// No description provided for @detailTapRowHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a row to open the map centered on that pin.'**
  String get detailTapRowHint;

  /// No description provided for @detailShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get detailShowMore;

  /// No description provided for @detailShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get detailShowLess;

  /// No description provided for @detailNationalPark.
  ///
  /// In en, this message translates to:
  /// **'National Park'**
  String get detailNationalPark;

  /// No description provided for @detailDifficult.
  ///
  /// In en, this message translates to:
  /// **'Difficult'**
  String get detailDifficult;

  /// No description provided for @spotlightFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter wildlife list'**
  String get spotlightFilterTitle;

  /// No description provided for @spotlightFilterBody.
  ///
  /// In en, this message translates to:
  /// **'Use Filter to narrow by location and species attributes.'**
  String get spotlightFilterBody;

  /// No description provided for @spotlightFilterTabsTitle.
  ///
  /// In en, this message translates to:
  /// **'Location and species filters'**
  String get spotlightFilterTabsTitle;

  /// No description provided for @spotlightFilterTabsBody.
  ///
  /// In en, this message translates to:
  /// **'Use the Location tab to filter by city or site. Switch to Species to set category, conservation status, and difficulty.'**
  String get spotlightFilterTabsBody;

  /// No description provided for @spotlightLayoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch layouts'**
  String get spotlightLayoutTitle;

  /// No description provided for @spotlightLayoutBody.
  ///
  /// In en, this message translates to:
  /// **'Tap to toggle between card grid and compact list.'**
  String get spotlightLayoutBody;

  /// No description provided for @spotlightAiChatTitle.
  ///
  /// In en, this message translates to:
  /// **'AI assistant'**
  String get spotlightAiChatTitle;

  /// No description provided for @spotlightAiChatBody.
  ///
  /// In en, this message translates to:
  /// **'Ask about wildlife photography planning, preparation, and field tips.'**
  String get spotlightAiChatBody;

  /// No description provided for @spotlightMapPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Map page'**
  String get spotlightMapPageTitle;

  /// No description provided for @spotlightMapPageBody.
  ///
  /// In en, this message translates to:
  /// **'Map helps you view wildlife locations and explore areas by place.'**
  String get spotlightMapPageBody;

  /// No description provided for @spotlightIdentifyPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Identify page'**
  String get spotlightIdentifyPageTitle;

  /// No description provided for @spotlightIdentifyPageBody.
  ///
  /// In en, this message translates to:
  /// **'Identify lets you identify wildlife from your captured photo.'**
  String get spotlightIdentifyPageBody;

  /// No description provided for @spotlightMissionPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Mission page'**
  String get spotlightMissionPageTitle;

  /// No description provided for @spotlightMissionPageBody.
  ///
  /// In en, this message translates to:
  /// **'Mission gives guided tasks and learning challenges while exploring.'**
  String get spotlightMissionPageBody;

  /// No description provided for @spotlightSavedPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved page'**
  String get spotlightSavedPageTitle;

  /// No description provided for @spotlightSavedPageBody.
  ///
  /// In en, this message translates to:
  /// **'Saved keeps your bookmarked species for quick access.'**
  String get spotlightSavedPageBody;

  /// No description provided for @spotlightMapRefreshTitle.
  ///
  /// In en, this message translates to:
  /// **'Refresh map weather'**
  String get spotlightMapRefreshTitle;

  /// No description provided for @spotlightMapRefreshBody.
  ///
  /// In en, this message translates to:
  /// **'Reload weather information from all city marker stations.'**
  String get spotlightMapRefreshBody;

  /// No description provided for @spotlightMapWeatherTitle.
  ///
  /// In en, this message translates to:
  /// **'Toggle weather layer'**
  String get spotlightMapWeatherTitle;

  /// No description provided for @spotlightMapWeatherBody.
  ///
  /// In en, this message translates to:
  /// **'Show or hide weather markers to focus on sightings or forecast context.'**
  String get spotlightMapWeatherBody;

  /// No description provided for @spotlightMapFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus wildlife hotspots'**
  String get spotlightMapFocusTitle;

  /// No description provided for @spotlightMapFocusBody.
  ///
  /// In en, this message translates to:
  /// **'Jump the camera to fit known wildlife and photography hotspot coverage.'**
  String get spotlightMapFocusBody;

  /// No description provided for @spotlightMapMyLocTitle.
  ///
  /// In en, this message translates to:
  /// **'Go to my location'**
  String get spotlightMapMyLocTitle;

  /// No description provided for @spotlightMapMyLocBody.
  ///
  /// In en, this message translates to:
  /// **'Center the map back to your current position quickly.'**
  String get spotlightMapMyLocBody;

  /// No description provided for @spotlightMapZoomInTitle.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get spotlightMapZoomInTitle;

  /// No description provided for @spotlightMapZoomInBody.
  ///
  /// In en, this message translates to:
  /// **'Increase map zoom for close-up marker and area details.'**
  String get spotlightMapZoomInBody;

  /// No description provided for @spotlightMapZoomOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get spotlightMapZoomOutTitle;

  /// No description provided for @spotlightMapZoomOutBody.
  ///
  /// In en, this message translates to:
  /// **'Reduce map zoom to see wider region context.'**
  String get spotlightMapZoomOutBody;

  /// No description provided for @spotlightMapWeatherMarkerTitle.
  ///
  /// In en, this message translates to:
  /// **'Weather marker'**
  String get spotlightMapWeatherMarkerTitle;

  /// No description provided for @spotlightMapWeatherMarkerBody.
  ///
  /// In en, this message translates to:
  /// **'City weather shows current conditions and short forecast for planning shoots.'**
  String get spotlightMapWeatherMarkerBody;

  /// No description provided for @spotlightMapAnimalMarkerTitle.
  ///
  /// In en, this message translates to:
  /// **'Animal marker'**
  String get spotlightMapAnimalMarkerTitle;

  /// No description provided for @spotlightMapAnimalMarkerBody.
  ///
  /// In en, this message translates to:
  /// **'Tap an animal marker to see species information, photos, and nearby weather.'**
  String get spotlightMapAnimalMarkerBody;

  /// No description provided for @spotlightDetailAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable alerts'**
  String get spotlightDetailAlertTitle;

  /// No description provided for @spotlightDetailAlertBody.
  ///
  /// In en, this message translates to:
  /// **'After saving, tap this icon to enable species notifications for higher-probability sightings.'**
  String get spotlightDetailAlertBody;

  /// No description provided for @spotlightDetailPredictionTitle.
  ///
  /// In en, this message translates to:
  /// **'Current prediction'**
  String get spotlightDetailPredictionTitle;

  /// No description provided for @spotlightDetailPredictionBody.
  ///
  /// In en, this message translates to:
  /// **'This card shows the best site and current weather-based probability for spotting this species.'**
  String get spotlightDetailPredictionBody;

  /// No description provided for @spotlightDetailObservationTitle.
  ///
  /// In en, this message translates to:
  /// **'Recorded observation'**
  String get spotlightDetailObservationTitle;

  /// No description provided for @spotlightDetailObservationBody.
  ///
  /// In en, this message translates to:
  /// **'This first recorded observation row includes the latest sighting and coordinates.'**
  String get spotlightDetailObservationBody;

  /// No description provided for @spotlightDetailMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Open on map'**
  String get spotlightDetailMapTitle;

  /// No description provided for @spotlightDetailMapBody.
  ///
  /// In en, this message translates to:
  /// **'Tap this map button to view the animal last occurrence directly on the map.'**
  String get spotlightDetailMapBody;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo Assistant'**
  String get chatTitle;

  /// No description provided for @chatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Camera settings & tips'**
  String get chatSubtitle;

  /// No description provided for @chatWelcome.
  ///
  /// In en, this message translates to:
  /// **'What can I help with?'**
  String get chatWelcome;

  /// No description provided for @chatHint.
  ///
  /// In en, this message translates to:
  /// **'Ask anything about wildlife photography...'**
  String get chatHint;

  /// No description provided for @chatDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Photography AI chat can make mistakes. Please double check responses.'**
  String get chatDisclaimer;

  /// No description provided for @chatCopied.
  ///
  /// In en, this message translates to:
  /// **'Message copied'**
  String get chatCopied;

  /// No description provided for @chatIrrelevant.
  ///
  /// In en, this message translates to:
  /// **'This is unrelated to wildlife photography. Please try another question.'**
  String get chatIrrelevant;

  /// No description provided for @chatSuggestion1.
  ///
  /// In en, this message translates to:
  /// **'What camera settings should I use for birds in flight?'**
  String get chatSuggestion1;

  /// No description provided for @chatSuggestion2.
  ///
  /// In en, this message translates to:
  /// **'Recommend equipment for photographing nocturnal animals'**
  String get chatSuggestion2;

  /// No description provided for @chatSuggestion3.
  ///
  /// In en, this message translates to:
  /// **'Best settings for macro photography of insects'**
  String get chatSuggestion3;

  /// No description provided for @chatSuggestion4.
  ///
  /// In en, this message translates to:
  /// **'What should I bring for a rainforest shoot?'**
  String get chatSuggestion4;

  /// No description provided for @chatClarifyGear.
  ///
  /// In en, this message translates to:
  /// **'Please share your camera and lens so I can tailor the settings.'**
  String get chatClarifyGear;

  /// No description provided for @chatClarifyAnimal.
  ///
  /// In en, this message translates to:
  /// **'Please clarify your target animal first so I can prepare the right checklist.'**
  String get chatClarifyAnimal;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ms', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ms':
      return AppLocalizationsMs();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
