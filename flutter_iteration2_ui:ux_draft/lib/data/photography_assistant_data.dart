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
  '2': 'Mostly fruits, plus young leaves and bark.',
  '3': 'Fruits, insects, and small vertebrates.',
  '4': 'Leaves, fruits, seeds, and unripe mangrove shoots.',
  '5': 'Leaves, shoots, and forest fruits.',
  '6': 'Grass, bark, roots, and soft vegetation.',
  '7': 'Small insects, larvae, and tiny amphibians.',
  '9': 'Mainly seagrass and marine algae.',
  '12': 'Mainly fish and small crustaceans.',
};

ShootingScenario scenarioFromLabel(String value) {
  switch (value) {
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
  final chunks = rawInput
      .split(RegExp(r'[,/\n]'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  final knownKeywords = [
    'camera',
    'dslr',
    'mirrorless',
    'iphone',
    'android',
    'phone',
    'lens',
    'tripod',
    'monopod',
    'flash',
    'telephoto',
  ];
  final hasKnown = knownKeywords.any(normalized.contains);
  if (!hasKnown && chunks.length < 2) return const [];
  return chunks;
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
          'Aperture: use the widest value your lens allows (for example f/2.8 to f/5.6).',
          'Shutter speed: keep at least 1/250s for handheld wildlife shots.',
          'ISO: start around ISO 1600 and increase only if the photo is still too dark.',
        ],
        tips: const [
          'Stabilize your camera with a tripod or by leaning on a tree.',
          'Shoot short bursts so one frame is more likely to be sharp.',
          'Focus on the eye; a sharp eye makes the whole photo look better.',
        ],
        explanation:
            'Low light needs a balance between brightness and sharpness. Wide aperture and higher ISO brighten the image, while minimum shutter speed helps avoid motion blur.',
        terms: const {
          'ISO': 'How sensitive your camera sensor is to light.',
          'Aperture': 'Lens opening size; lower f-number means more light.',
          'Shutter speed': 'How long the sensor records light for one photo.',
        },
      );
    case ShootingScenario.fastMoving:
      return ShootingAdvice(
        detectedEquipment: equipment,
        settings: const [
          'Mode: Shutter Priority (S/Tv) or Manual (M).',
          'Shutter speed: start from 1/1250s, increase to 1/2000s for birds in flight.',
          'Autofocus: Continuous AF (AF-C/AI Servo).',
          'Drive mode: High-speed burst shooting.',
        ],
        tips: const [
          'Track the animal early and keep focus point on the head.',
          'Use a slightly wider frame first, then crop later.',
          'Pan smoothly with movement to maintain subject sharpness.',
        ],
        explanation:
            'Fast animals require very quick shutter speed and continuous autofocus. Burst mode increases your chance of catching a clean action moment.',
        terms: const {
          'AF-C / AI Servo': 'Focus mode that keeps updating while subject moves.',
          'Burst mode': 'Taking many photos quickly by holding the shutter button.',
        },
      );
    case ShootingScenario.longDistance:
      return ShootingAdvice(
        detectedEquipment: equipment,
        settings: const [
          'Use your longest lens focal length.',
          'Shutter speed: at least 1 / focal length x 2 (example: 1/800s at 400mm).',
          'Aperture: around f/5.6 to f/8 for good detail.',
          'Enable image stabilization if available.',
        ],
        tips: const [
          'Use tripod or monopod to reduce shake.',
          'Avoid strong midday heat shimmer when possible.',
          'Take several frames and keep the sharpest one.',
        ],
        explanation:
            'Long-distance photos magnify small camera shake and atmospheric blur. Faster shutter speed, stable support, and repeated shots improve consistency.',
        terms: const {
          'Focal length': 'How much your lens zooms into distant subjects.',
          'Image stabilization': 'Camera/lens feature that reduces hand shake.',
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
  final animal = animalInput.trim().toLowerCase();
  if (animal.isEmpty) return null;

  final photoGear = <String>[
    'Spare SD cards and cleaned lens cloth.',
    'Fully charged batteries plus one backup.',
  ];

  if (animal.contains('bird') || animal.contains('hornbill')) {
    photoGear.addAll([
      'Telephoto lens (400mm or longer).',
      'Fast autofocus body and high-speed burst mode.',
      'Light monopod for tracking birds.',
    ]);
  } else if (animal.contains('elephant') ||
      animal.contains('bear') ||
      animal.contains('monkey') ||
      animal.contains('mammal')) {
    photoGear.addAll([
      'Zoom lens around 100-400mm.',
      'Polarizing filter for foliage glare.',
      'Comfortable camera strap for long walks.',
    ]);
  } else if (animal.contains('insect') ||
      animal.contains('frog') ||
      animal.contains('reptile') ||
      animal.contains('snake')) {
    photoGear.addAll([
      'Macro lens or close-focus telephoto lens.',
      'Portable flash with diffuser.',
      'Small tripod for low-angle framing.',
    ]);
  } else {
    photoGear.addAll([
      'General wildlife zoom lens (70-300mm).',
      'Supportive tripod or monopod.',
    ]);
  }

  final essentials = <String>[
    'Drinking water and light snacks.',
    'Basic first aid kit and emergency contact plan.',
    'Power bank for phone and navigation.',
  ];

  String weatherNotice;
  switch (weatherInput) {
    case 'Rainy':
      essentials.addAll([
        'Rain jacket and dry bag for electronics.',
        'Lens rain cover and quick-dry towel.',
      ]);
      weatherNotice = 'Weather-based advice: Rain expected, prioritize waterproof protection.';
      break;
    case 'Sunny':
      essentials.addAll([
        'Sun hat, sunscreen, and sunglasses.',
        'Extra water and light breathable clothing.',
      ]);
      weatherNotice = 'Weather-based advice: Strong sun expected, prioritize heat and UV protection.';
      break;
    case 'Windy':
      essentials.addAll([
        'Windproof outer layer.',
        'Tripod weight hook or stabilization bag.',
      ]);
      weatherNotice = 'Weather-based advice: Wind expected, stabilize your camera setup.';
      break;
    case 'Unavailable':
      essentials.addAll([
        'Pack layered clothing for changing conditions.',
        'Carry both lightweight rain shell and sun protection.',
      ]);
      weatherNotice =
          'Live weather data is unavailable right now. Here is a general preparation checklist for variable conditions.';
      break;
    default:
      weatherNotice = 'General weather-safe packing guidance applied.';
  }

  return TripChecklist(
    photoEquipment: photoGear,
    outdoorEssentials: essentials,
    weatherNotice: weatherNotice,
  );
}

MissionRecommendation buildMissionRecommendation({
  required String gear,
  required String difficulty,
  required String subject,
}) {
  final gearText = gear == 'Smartphone'
      ? 'smartphone kit'
      : 'DSLR/mirrorless setup';

  final missionName = switch (subject) {
    'Insects' => 'Macro Forest Hunt',
    'Mammals' => 'River Edge Mammal Watch',
    _ => 'Canopy Bird Patrol',
  };

  final location = switch (subject) {
    'Insects' => 'shaded forest trail with streams',
    'Mammals' => 'riverbank or mangrove boardwalk',
    _ => 'forest edge lookout before sunrise',
  };

  final task = switch (difficulty) {
    'Casual' => 'Capture 3 clear photos of one subject type with stable framing.',
    'Standard' => 'Capture 5 photos: wide scene, medium shot, and close-up details.',
    _ => 'Capture an action sequence (at least 4 shots) with one sharp hero frame.',
  };

  return MissionRecommendation(
    title: missionName,
    locationHint: 'Recommended location style: $location',
    task: task,
    explanation:
        'This mission matches your $gearText, your selected $difficulty effort level, and your interest in $subject. The goal is realistic for beginners while still helping you practice useful wildlife photography skills.',
  );
}

Species? matchSpeciesByImageName(String imagePath, List<Species> allSpecies) {
  final normalized = imagePath.toLowerCase();
  const keywordToSpecies = <String, String>{
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
    'sunbird': '11',
    'otter': '12',
    'monitor': '13',
    'frog': '14',
    'beetle': '15',
  };

  for (final entry in keywordToSpecies.entries) {
    if (normalized.contains(entry.key)) {
      final id = entry.value;
      for (final species in allSpecies) {
        if (species.id == id) return species;
      }
    }
  }
  return null;
}
