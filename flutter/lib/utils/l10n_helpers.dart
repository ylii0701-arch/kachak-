import '../l10n/app_localizations.dart';
import '../models/species.dart';

/// Maps a raw species category string to its localized equivalent.
String localizedCategory(AppLocalizations? l, String category) {
  switch (category) {
    case Species.mammals:
      return l?.categoryMammals ?? category;
    case Species.birds:
      return l?.categoryBirds ?? category;
    case Species.reptiles:
      return l?.categoryReptiles ?? category;
    case Species.amphibians:
      return l?.categoryAmphibians ?? category;
    case Species.insects:
      return l?.categoryInsects ?? category;
    default:
      return category;
  }
}

/// Maps a raw conservation status string to its localized equivalent.
String localizedStatus(AppLocalizations? l, String status) {
  switch (status) {
    case Species.leastConcern:
      return l?.statusLeastConcern ?? status;
    case Species.nearThreatened:
      return l?.statusNearThreatened ?? status;
    case Species.vulnerable:
      return l?.statusVulnerable ?? status;
    case Species.endangered:
      return l?.statusEndangered ?? status;
    case Species.criticallyEndangered:
      return l?.statusCriticallyEndangered ?? status;
    default:
      return status;
  }
}
