import 'package:flutter/material.dart';

typedef ConservationStatus = String;
typedef SpeciesCategory = String;

class Species {
  const Species({
    required this.id,
    required this.commonName,
    required this.scientificName,
    required this.category,
    required this.conservationStatus,
    required this.habitat,
    required this.imageUrl,
    required this.description,
    required this.behaviorNotes,
    required this.photographyConditions,
    required this.recommendedGear,
    required this.activityPattern,
    required this.bestSeasons,
    required this.difficultyLevel,
  });

  final String id;
  final String commonName;
  final String scientificName;
  final String category;
  final String conservationStatus;
  final String habitat;
  final String imageUrl;
  final String description;
  final String behaviorNotes;
  final String photographyConditions;
  final List<String> recommendedGear;
  final String activityPattern;
  final List<String> bestSeasons;
  final int difficultyLevel;

  static const String leastConcern = 'Least Concern';
  static const String nearThreatened = 'Near Threatened';
  static const String vulnerable = 'Vulnerable';
  static const String endangered = 'Endangered';
  static const String criticallyEndangered = 'Critically Endangered';

  static const String mammals = 'Mammals';
  static const String birds = 'Birds';
  static const String reptiles = 'Reptiles';
  static const String amphibians = 'Amphibians';
  static const String insects = 'Insects';
}

Color statusBackgroundColor(String status) {
  switch (status) {
    case Species.leastConcern:
      return const Color(0xFF6FCF97);
    case Species.nearThreatened:
      return const Color(0xFFA8E6CF);
    case Species.vulnerable:
      return const Color(0xFFFBBF24);
    case Species.endangered:
      return const Color(0xFFF97316);
    case Species.criticallyEndangered:
      return const Color(0xFFDC2626);
    default:
      return Colors.grey;
  }
}

Color statusForegroundColor(String status) {
  switch (status) {
    case Species.nearThreatened:
    case Species.vulnerable:
      return const Color(0xFF1F2937);
    default:
      return Colors.white;
  }
}

int conservationStatusRank(String status) {
  const order = [
    Species.leastConcern,
    Species.nearThreatened,
    Species.vulnerable,
    Species.endangered,
    Species.criticallyEndangered,
  ];
  final i = order.indexOf(status);
  return i >= 0 ? i : 0;
}

String statusAbbreviation(String status) {
  return status.split(' ').map((w) => w.isNotEmpty ? w[0] : '').join();
}
