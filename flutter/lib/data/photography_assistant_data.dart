import '../models/species.dart';

enum ShootingScenario { lowLight, fastMoving, longDistance, unsupported }

class ShootingAdvice {
  const ShootingAdvice({
    required this.detectedEquipment,
    required this.settings,
    required this.tips,
    required this.explanation,
    required this.terms,
  });

  final List<String> detectedEquipment;
  final List<String> settings;
  final List<String> tips;
  final String explanation;
  final Map<String, String> terms;
}

class TripChecklist {
  const TripChecklist({
    required this.photoEquipment,
    required this.outdoorEssentials,
    required this.weatherNotice,
  });

  final List<String> photoEquipment;
  final List<String> outdoorEssentials;
  final String weatherNotice;
}

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

ShootingScenario scenarioFromLabel(String label) {
  switch (label) {
    case 'Low light':
      return ShootingScenario.lowLight;
    case 'Fast-moving animals':
      return ShootingScenario.fastMoving;
    case 'Long-distance shooting':
      return ShootingScenario.longDistance;
    default:
      return ShootingScenario.unsupported;
  }
}

List<String> detectEquipment(String rawInput) {
  final normalized = rawInput.toLowerCase().trim();
  if (normalized.isEmpty) return const [];

  final pieces = rawInput
      .split(RegExp(r'[,/\n+]'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  final hasKnownGear = [
    'camera',
    'dslr',
    'mirrorless',
    'phone',
    'iphone',
    'android',
    'lens',
    'tripod',
    'monopod',
    'flash',
  ].any(normalized.contains);

  if (!hasKnownGear && pieces.length < 2) {
    return const [];
  }
  return pieces;
}

ShootingAdvice? buildShootingAdvice({
  required List<String> equipment,
  required ShootingScenario scenario,
}) {
  if (equipment.isEmpty || scenario == ShootingScenario.unsupported) return null;

  switch (scenario) {
    case ShootingScenario.lowLight:
      return ShootingAdvice(
        detectedEquipment: equipment,
        settings: const [
          'Mode: Aperture Priority (A/Av) or Manual (M).',
          'Aperture: widest available value (for example f/2.8 to f/5.6).',
          'Shutter speed: at least 1/250s for handheld wildlife.',
          'ISO: start around 1600, increase only when needed.',
        ],
        tips: const [
          'Use a tripod, monopod, or stable surface.',
          'Shoot short bursts and keep the sharpest frame.',
          'Focus on the eye to keep the subject expressive.',
        ],
        explanation:
            'Low light requires balancing brightness and sharpness. Wider aperture and higher ISO add light, while minimum shutter speed helps avoid blur.',
        terms: const {
          'ISO': 'Sensor sensitivity to light.',
          'Aperture': 'Lens opening size; lower f-number means more light.',
          'Shutter speed': 'How long the camera exposes each photo.',
        },
      );
    case ShootingScenario.fastMoving:
      return ShootingAdvice(
        detectedEquipment: equipment,
        settings: const [
          'Mode: Shutter Priority (S/Tv) or Manual (M).',
          'Shutter speed: 1/1250s to 1/2000s for action.',
          'Autofocus: Continuous AF (AF-C / AI Servo).',
          'Drive mode: High-speed burst.',
        ],
        tips: const [
          'Start tracking early before the animal reaches your frame.',
          'Keep focus point near the head or upper body.',
          'Use smooth panning for side movement.',
        ],
        explanation:
            'Action scenes need very fast shutter and continuous focus updates. Burst shooting improves your chance of getting one sharp moment.',
        terms: const {
          'AF-C / AI Servo': 'Focus mode that keeps updating for moving subjects.',
          'Burst': 'Taking many photos quickly while holding shutter.',
        },
      );
    case ShootingScenario.longDistance:
      return ShootingAdvice(
        detectedEquipment: equipment,
        settings: const [
          'Use your longest focal length.',
          'Shutter speed: at least 1/(focal length x 2).',
          'Aperture: around f/5.6 to f/8 for detail.',
          'Enable image stabilization if available.',
        ],
        tips: const [
          'Use a tripod or monopod to reduce shake.',
          'Avoid strong noon heat shimmer when possible.',
          'Shoot multiple frames and keep the clearest one.',
        ],
        explanation:
            'Long-distance shots magnify vibration and atmospheric blur. Stabilization and faster shutter speed improve consistency.',
        terms: const {
          'Focal length': 'How much the lens zooms into distant subjects.',
          'Image stabilization': 'Camera or lens feature that reduces handshake blur.',
        },
      );
    case ShootingScenario.unsupported:
      return null;
  }
}

TripChecklist? buildTripChecklist({
  required String animalInput,
  required String weatherInput,
}) {
  final animal = animalInput.toLowerCase().trim();
  if (animal.length < 3) return null;

  final equipment = <String>[
    'Spare memory card and lens cloth.',
    'Fully charged batteries plus one backup.',
  ];
  if (animal.contains('bird') || animal.contains('hornbill')) {
    equipment.addAll([
      'Telephoto lens (400mm or longer).',
      'Fast autofocus setup for flight shots.',
      'Light monopod for easier tracking.',
    ]);
  } else if (animal.contains('insect') || animal.contains('frog')) {
    equipment.addAll([
      'Macro lens or close-focus zoom.',
      'Diffused flash for small subjects.',
      'Small tripod for low-angle framing.',
    ]);
  } else {
    equipment.addAll([
      'General wildlife zoom lens (70-300mm).',
      'Tripod or monopod for stability.',
    ]);
  }

  final essentials = <String>[
    'Drinking water and light snacks.',
    'First aid kit and emergency contact.',
    'Power bank and offline map access.',
  ];

  String weatherNotice;
  switch (weatherInput) {
    case 'Rainy':
      essentials.addAll([
        'Rain jacket and dry bag.',
        'Lens rain cover and quick-dry towel.',
      ]);
      weatherNotice = 'Rain expected: prioritize waterproof protection.';
      break;
    case 'Sunny':
      essentials.addAll([
        'Sun hat, sunscreen, and sunglasses.',
        'Extra water and breathable clothing.',
      ]);
      weatherNotice = 'Strong sun expected: prioritize heat and UV protection.';
      break;
    case 'Windy':
      essentials.addAll([
        'Windproof outer layer.',
        'Tripod stabilizer or weight bag.',
      ]);
      weatherNotice = 'Wind expected: stabilize your camera setup.';
      break;
    default:
      essentials.addAll([
        'Pack one light rain shell and sun protection.',
        'Wear layers for changing conditions.',
      ]);
      weatherNotice =
          'Weather information unavailable now, showing general preparation tips.';
  }

  return TripChecklist(
    photoEquipment: equipment,
    outdoorEssentials: essentials,
    weatherNotice: weatherNotice,
  );
}

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
