import '../models/species.dart';

const List<Species> speciesData = [
  Species(
    id: '1',
    commonName: 'Sun Bear',
    scientificName: 'Helarctos malayanus',
    category: Species.mammals,
    conservationStatus: Species.vulnerable,
    habitat: 'Tropical rainforests, lowland areas',
    imageUrl:
        'https://images.unsplash.com/photo-1654180537506-1825e51b7ce6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzdW4lMjBiZWFyJTIwbWFsYXlzaWElMjB3aWxkbGlmZXxlbnwxfHx8fDE3NzUxNDQ3MzF8MA&ixlib=rb-4.1.0&q=80&w=1080',
    description:
        'The smallest bear species, known for its distinctive chest marking and excellent tree-climbing abilities.',
    behaviorNotes:
        'Diurnal and primarily arboreal. Often forages for honey, insects, and fruits in trees.',
    photographyConditions:
        'Best photographed in early morning or late afternoon in dense forest areas. Requires patience as they are shy.',
    recommendedGear: [
      'Full-frame camera or smartphone',
      'Telephoto lens (200-400mm)',
      'Hiking boots',
      'Mosquito spray',
      'Camouflage clothing',
    ],
    activityPattern: 'Diurnal (Day-active)',
    bestSeasons: ['March', 'April', 'May', 'September', 'October'],
    difficultyLevel: 3,
  ),
  Species(
    id: '2',
    commonName: 'Bornean Orangutan',
    scientificName: 'Pongo pygmaeus',
    category: Species.mammals,
    conservationStatus: Species.criticallyEndangered,
    habitat: 'Primary and secondary rainforests',
    imageUrl:
        'https://images.unsplash.com/photo-1589446918494-cc44735e6f20?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxvcmFuZ3V0YW4lMjBib3JuZW8lMjBtYWxheXNpYXxlbnwxfHx8fDE3NzUxNDQ3MzJ8MA&ixlib=rb-4.1.0&q=80&w=1080',
    description:
        'Large arboreal ape with distinctive reddish-brown hair. Highly intelligent and solitary.',
    behaviorNotes:
        'Spends most time in trees. Builds nests for sleeping. Slow, deliberate movements make them easier to photograph.',
    photographyConditions:
        'Dense canopy requires good lighting. Best during mid-morning when they are most active.',
    recommendedGear: [
      'Full-frame camera',
      'Telephoto lens (300-600mm)',
      'Tripod or monopod',
      'Rain cover',
      'Hiking boots',
      'Long sleeves',
    ],
    activityPattern: 'Diurnal (Day-active)',
    bestSeasons: ['June', 'July', 'August', 'September'],
    difficultyLevel: 5,
  ),
  Species(
    id: '3',
    commonName: 'Rhinoceros Hornbill',
    scientificName: 'Buceros rhinoceros',
    category: Species.birds,
    conservationStatus: Species.vulnerable,
    habitat: 'Lowland and montane rainforests',
    imageUrl:
        'https://images.unsplash.com/photo-1725997415020-5828e023b64e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxob3JuYmlsbCUyMGJpcmQlMjBtYWxheXNpYXxlbnwxfHx8fDE3NzUxNDQ3MzN8MA&ixlib=rb-4.1.0&q=80&w=1080',
    description:
        'Large bird with distinctive casque on bill. Known for loud calls and impressive wingspan.',
    behaviorNotes:
        'Often found in pairs or small groups. Loud wing beats make them easy to locate.',
    photographyConditions:
        'Photograph from forest edges or canopy walkways. Best in early morning light.',
    recommendedGear: [
      'Camera with fast autofocus',
      'Telephoto lens (400-600mm)',
      'Binoculars',
      'Lightweight tripod',
      'Hat and sunscreen',
    ],
    activityPattern: 'Diurnal (Day-active)',
    bestSeasons: ['February', 'March', 'April', 'May'],
    difficultyLevel: 3,
  ),
  Species(
    id: '4',
    commonName: 'Clouded Leopard',
    scientificName: 'Neofelis nebulosa',
    category: Species.mammals,
    conservationStatus: Species.vulnerable,
    habitat: 'Primary evergreen rainforests',
    imageUrl:
        'https://images.unsplash.com/photo-1768726649407-4c24eb9102be?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjbG91ZGVkJTIwbGVvcGFyZCUyMHdpbGRsaWZlfGVufDF8fHx8MTc3NTE0NDczM3ww&ixlib=rb-4.1.0&q=80&w=1080',
    description:
        'Medium-sized wild cat with distinctive cloud-like markings. Excellent climber and nocturnal hunter.',
    behaviorNotes:
        'Elusive and primarily nocturnal. Rarely seen in the wild. Excellent tree climber.',
    photographyConditions:
        'Extremely challenging to photograph. Best chance at dusk/dawn. Requires camera traps or exceptional patience.',
    recommendedGear: [
      'Low-light capable camera',
      'Fast telephoto lens (300-500mm f/2.8-4)',
      'Camera trap (optional)',
      'Night vision equipment',
      'Complete camping gear',
    ],
    activityPattern: 'Nocturnal (Night-active)',
    bestSeasons: ['June', 'July', 'August'],
    difficultyLevel: 5,
  ),
  Species(
    id: '5',
    commonName: 'Proboscis Monkey',
    scientificName: 'Nasalis larvatus',
    category: Species.mammals,
    conservationStatus: Species.endangered,
    habitat: 'Mangrove forests and riverine areas',
    imageUrl:
        'https://images.unsplash.com/photo-1679411784666-711df988aebb?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwcm9ib3NjaXMlMjBtb25rZXklMjBib3JuZW98ZW58MXx8fHwxNzc1MTQ0NzQ4fDA&ixlib=rb-4.1.0&q=80&w=1080',
    description:
        'Endemic to Borneo. Males have distinctive large noses. Excellent swimmers.',
    behaviorNotes:
        'Live in groups near rivers. Most active in early morning and late afternoon. Often seen jumping between trees.',
    photographyConditions:
        'Best photographed from boats on rivers. Early morning provides best lighting and activity.',
    recommendedGear: [
      'Weather-sealed camera',
      'Telephoto lens (200-400mm)',
      'Boat access',
      'Waterproof bag',
      'Life jacket',
      'Wide-brim hat',
    ],
    activityPattern: 'Diurnal (Day-active)',
    bestSeasons: ['April', 'May', 'September', 'October'],
    difficultyLevel: 3,
  ),
  Species(
    id: '6',
    commonName: 'Malayan Tapir',
    scientificName: 'Tapirus indicus',
    category: Species.mammals,
    conservationStatus: Species.endangered,
    habitat: 'Lowland rainforests near water sources',
    imageUrl:
        'https://images.unsplash.com/photo-1771253085305-f90f40feaad6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtYWxheWFuJTIwdGFwaXIlMjB3aWxkbGlmZXxlbnwxfHx8fDE3NzUxNDQ3MzN8MA&ixlib=rb-4.1.0&q=80&w=1080',
    description:
        'Distinctive black and white coloration. Large herbivore with flexible snout.',
    behaviorNotes:
        'Nocturnal and solitary. Often found near streams and muddy areas for bathing.',
    photographyConditions:
        'Challenging due to nocturnal habits. Best at dusk near water sources. Requires low-light equipment.',
    recommendedGear: [
      'Full-frame camera with high ISO',
      'Fast telephoto lens',
      'Flash or external lighting',
      'Waterproof boots',
      'Headlamp',
      'Insect repellent',
    ],
    activityPattern: 'Nocturnal (Night-active)',
    bestSeasons: ['May', 'June', 'July', 'August', 'September'],
    difficultyLevel: 5,
  ),
  Species(
    id: '7',
    commonName: 'Asian Elephant',
    scientificName: 'Elephas maximus',
    category: Species.mammals,
    conservationStatus: Species.endangered,
    habitat: 'Tropical forests and grasslands',
    imageUrl:
        'https://images.unsplash.com/photo-1713725589822-2cb49716dc26?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhc2lhbiUyMGVsZXBoYW50JTIwd2lsZHxlbnwxfHx8fDE3NzUxNDQ3MzR8MA&ixlib=rb-4.1.0&q=80&w=1080',
    description:
        'Smaller than African elephants with smaller ears. Highly intelligent and social.',
    behaviorNotes:
        'Live in matriarchal herds. Active during early morning and late afternoon. Often near water sources.',
    photographyConditions:
        'Best photographed from safe distance. Early morning at watering holes provides excellent opportunities.',
    recommendedGear: [
      'Camera with fast autofocus',
      'Telephoto lens (300-500mm)',
      'Sturdy tripod',
      'Neutral density filters',
      'Safety distance from herd',
    ],
    activityPattern: 'Crepuscular (Dawn/Dusk active)',
    bestSeasons: ['March', 'April', 'May', 'June'],
    difficultyLevel: 3,
  ),
  Species(
    id: '8',
    commonName: 'Oriental Dwarf Kingfisher',
    scientificName: 'Ceyx erithaca',
    category: Species.birds,
    conservationStatus: Species.leastConcern,
    habitat: 'Dense lowland forests near streams',
    imageUrl:
        'https://images.unsplash.com/photo-1762421226157-44c7017b63d7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxraW5nZmlzaGVyJTIwYmlyZCUyMHRyb3BpY2FsfGVufDF8fHx8MTc3NTE0NDczNHww&ixlib=rb-4.1.0&q=80&w=1080',
    description:
        'Small, brilliantly colored kingfisher. Vibrant blue, orange, and purple plumage.',
    behaviorNotes:
        'Sits motionless on low perches waiting for prey. Darts quickly to catch insects.',
    photographyConditions:
        'Best near forest streams. Requires patience and good macro/telephoto lens. Soft morning light ideal.',
    recommendedGear: [
      'Macro lens or telephoto (200-400mm)',
      'Fast shutter speed capability',
      'Tripod or monopod',
      'Camouflage hide (optional)',
      'Insect spray',
    ],
    activityPattern: 'Diurnal (Day-active)',
    bestSeasons: ['February', 'March', 'April', 'October', 'November'],
    difficultyLevel: 3,
  ),
  Species(
    id: '9',
    commonName: 'Reticulated Python',
    scientificName: 'Malayopython reticulatus',
    category: Species.reptiles,
    conservationStatus: Species.leastConcern,
    habitat: 'Rainforests, grasslands, woodlands',
    imageUrl:
        'https://images.unsplash.com/photo-1727422500803-b79849405145?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxweXRob24lMjBzbmFrZSUyMHJlcHRpbGV8ZW58MXx8fHwxNzc1MTQ0NzM1fDA&ixlib=rb-4.1.0&q=80&w=1080',
    description:
        'One of the longest snakes in the world. Complex geometric pattern on scales.',
    behaviorNotes:
        'Mostly nocturnal. Often found near water. Non-venomous constrictor.',
    photographyConditions:
        'Caution required - maintain safe distance. Best photographed in controlled settings or with guide.',
    recommendedGear: [
      'Standard zoom lens (24-70mm)',
      'Macro lens for detail shots',
      'External flash',
      'Snake hook (with expert)',
      'First aid kit',
      'Emergency contact',
    ],
    activityPattern: 'Nocturnal (Night-active)',
    bestSeasons: ['April', 'May', 'June', 'July', 'August', 'September'],
    difficultyLevel: 4,
  ),
  Species(
    id: '10',
    commonName: 'Green Sea Turtle',
    scientificName: 'Chelonia mydas',
    category: Species.reptiles,
    conservationStatus: Species.endangered,
    habitat: 'Coastal waters, coral reefs, seagrass beds',
    imageUrl:
        'https://images.unsplash.com/photo-1549557143-90d216195a97?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzZWElMjB0dXJ0bGUlMjBtYXJpbmV8ZW58MXx8fHwxNzc1MTQ0NzM1fDA&ixlib=rb-4.1.0&q=80&w=1080',
    description:
        'Large marine turtle with distinctive greenish shell. Important for marine ecosystem health.',
    behaviorNotes:
        'Slow moving underwater. Surfaces regularly to breathe. Nests on beaches at night.',
    photographyConditions:
        'Best photographed while snorkeling or diving. Requires underwater camera housing. Respectful distance required.',
    recommendedGear: [
      'Underwater camera housing',
      'Wide-angle lens',
      'Dive/snorkel equipment',
      'Wet suit',
      'Underwater lights',
      'Red flashlight for beach nesting',
    ],
    activityPattern: 'Diurnal underwater, Nocturnal nesting',
    bestSeasons: ['May', 'June', 'July', 'August', 'September'],
    difficultyLevel: 4,
  ),
  Species(
    id: '11',
    commonName: 'Red Giant Flying Squirrel',
    scientificName: 'Petaurista petaurista',
    category: Species.mammals,
    conservationStatus: Species.leastConcern,
    habitat: 'Tropical and subtropical forests',
    imageUrl:
        'https://images.unsplash.com/photo-1648916487325-6270176ffd57?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmbHlpbmclMjBzcXVpcnJlbCUyMHdpbGRsaWZlfGVufDF8fHx8MTc3NTE0NDczNXww&ixlib=rb-4.1.0&q=80&w=1080',
    description:
        'Large flying squirrel with reddish-brown fur. Glides between trees using skin membrane.',
    behaviorNotes:
        'Strictly nocturnal. Glides up to 150 meters between trees. Best spotted with flashlight.',
    photographyConditions:
        'Very challenging - nocturnal and fast-moving. Requires night vision or infrared equipment.',
    recommendedGear: [
      'High ISO camera',
      'Fast telephoto lens',
      'External flash with diffuser',
      'Red LED headlamp',
      'Night vision scope',
      'Patience and local guide',
    ],
    activityPattern: 'Nocturnal (Night-active)',
    bestSeasons: ['March', 'April', 'September', 'October', 'November'],
    difficultyLevel: 5,
  ),
  Species(
    id: '12',
    commonName: 'Sunda Pangolin',
    scientificName: 'Manis javanica',
    category: Species.mammals,
    conservationStatus: Species.criticallyEndangered,
    habitat: 'Primary and secondary forests',
    imageUrl:
        'https://images.unsplash.com/photo-1634721247018-f014fdc0388f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwYW5nb2xpbiUyMHdpbGRsaWZlJTIwZW5kYW5nZXJlZHxlbnwxfHx8fDE3NzUxNDQ3MzZ8MA&ixlib=rb-4.1.0&q=80&w=1080',
    description:
        "Covered in protective keratin scales. Nocturnal insectivore. World's most trafficked mammal.",
    behaviorNotes:
        'Solitary and nocturnal. Rolls into ball when threatened. Extremely rare to encounter.',
    photographyConditions:
        'Exceptionally rare sighting. If encountered, photograph from distance without disturbing. Report sighting to authorities.',
    recommendedGear: [
      'Low-light camera',
      'Fast lens',
      'Silent shutter mode',
      'Red light source',
      'Authorities contact information',
      'Conservation organization numbers',
    ],
    activityPattern: 'Nocturnal (Night-active)',
    bestSeasons: ['Year-round but extremely rare'],
    difficultyLevel: 5,
  ),
];

Species? speciesById(String? id) {
  if (id == null) return null;
  for (final s in speciesData) {
    if (s.id == id) return s;
  }
  return null;
}
