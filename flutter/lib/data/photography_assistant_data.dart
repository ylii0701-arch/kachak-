import '../models/species.dart';

class MissionRecommendation {
  const MissionRecommendation({
    required this.title,
    required this.locationHint,
    required this.task,
    required this.explanation,
  });

  final String title;
  final String locationHint;
  final String task;
  final String explanation;
}

const Map<String, String> speciesDietData = {
  '1': 'Fruits, insects, termites, and honey.',
  '2': 'Mostly fruits, plus bark and young leaves.',
  '3': 'Fruits, insects, and small vertebrates.',
  '4': 'Leaves, seeds, fruits, and mangrove shoots.',
  '5': 'Leaves, shoots, and lowland forest fruits.',
  '6': 'Grass, roots, bark, and soft plants.',
  '7': 'Small insects, larvae, and tiny amphibians.',
  '9': 'Seagrass and marine algae.',
  '12': 'Small fish, crabs, and shellfish.',
};

MissionRecommendation buildMissionRecommendation({
  required String gear,
  required String difficulty,
  required String subject,
}) {
  final mission = switch ((subject, difficulty)) {
    ('Insects', 'Casual') => 'Streamside Macro Warm-up',
    ('Insects', 'Standard') => 'Forest Macro Story Set',
    ('Insects', _) => 'Advanced Insect Motion Hunt',
    ('Mammals', 'Casual') => 'Riverbank Mammal Observation',
    ('Mammals', 'Standard') => 'Mammal Behavior Sequence',
    ('Mammals', _) => 'Dawn Mammal Tracking Challenge',
    ('Birds', 'Casual') => 'Backyard Bird Focus Practice',
    ('Birds', 'Standard') => 'Forest Edge Bird Series',
    ('Birds', _) => 'High-speed Bird Action Session',
    _ => 'Beginner Wildlife Mission',
  };

  final location = switch (subject) {
    'Insects' => 'Shaded trail near water or leaf litter',
    'Mammals' => 'River edges, boardwalks, or open forest clearings',
    _ => 'Forest edge or canopy opening before sunrise',
  };

  final task = switch (difficulty) {
    'Casual' => 'Capture 3 clear shots with stable framing.',
    'Standard' => 'Capture 5 shots: wide, medium, close, and one behavior moment.',
    _ => 'Capture an action sequence with one final hero shot.',
  };

  return MissionRecommendation(
    title: mission,
    locationHint: location,
    task: task,
    explanation:
        'This mission fits your $gear setup, $difficulty difficulty, and $subject preference. It keeps the challenge achievable while helping you improve core wildlife photography skills.',
  );
}

Species? predictSpeciesFromImagePath(String imagePath, List<Species> allSpecies) {
  final value = imagePath.toLowerCase();
  const map = {
    'bear': '1',
    'orangutan': '2',
    'hornbill': '3',
    'monkey': '4',
    'tapir': '5',
    'elephant': '6',
    'kingfisher': '7',
    'python': '8',
    'turtle': '9',
    'squirrel': '10',
    'otter': '12',
    'frog': '14',
  };

  String? id;
  for (final entry in map.entries) {
    if (value.contains(entry.key)) {
      id = entry.value;
      break;
    }
  }
  if (id == null) return null;
  for (final species in allSpecies) {
    if (species.id == id) return species;
  }
  return null;
}
