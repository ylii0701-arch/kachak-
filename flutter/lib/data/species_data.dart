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
    'https://images.unsplash.com/photo-1589446918494-cc44735e6f20?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
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
    'https://images.unsplash.com/photo-1725997415020-5828e023b64e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
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
    commonName: 'Proboscis Monkey',
    scientificName: 'Nasalis larvatus',
    category: Species.mammals,
    conservationStatus: Species.endangered,
    habitat: 'Mangrove forests and riverine areas',
    imageUrl:
    'https://images.unsplash.com/photo-1679411784666-711df988aebb?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
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
    id: '5',
    commonName: 'Malayan Tapir',
    scientificName: 'Tapirus indicus',
    category: Species.mammals,
    conservationStatus: Species.endangered,
    habitat: 'Lowland rainforests near water sources',
    imageUrl:
    'https://images.unsplash.com/photo-1771253085305-f90f40feaad6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
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
    id: '6',
    commonName: 'Asian Elephant',
    scientificName: 'Elephas maximus',
    category: Species.mammals,
    conservationStatus: Species.endangered,
    habitat: 'Tropical forests and grasslands',
    imageUrl:
    'https://images.unsplash.com/photo-1713725589822-2cb49716dc26?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
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
    id: '7',
    commonName: 'Oriental Dwarf Kingfisher',
    scientificName: 'Ceyx erithaca',
    category: Species.birds,
    conservationStatus: Species.leastConcern,
    habitat: 'Dense lowland forests near streams',
    imageUrl:
    'https://images.unsplash.com/photo-1762421226157-44c7017b63d7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
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
    id: '8',
    commonName: 'Reticulated Python',
    scientificName: 'Malayopython reticulatus',
    category: Species.reptiles,
    conservationStatus: Species.leastConcern,
    habitat: 'Rainforests, grasslands, woodlands',
    imageUrl:
    'https://images.unsplash.com/photo-1727422500803-b79849405145?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
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
    id: '9',
    commonName: 'Green Sea Turtle',
    scientificName: 'Chelonia mydas',
    category: Species.reptiles,
    conservationStatus: Species.endangered,
    habitat: 'Coastal waters, coral reefs, seagrass beds',
    imageUrl:
    'https://images.unsplash.com/photo-1549557143-90d216195a97?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
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
    id: '10',
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
    id: '11',
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
  Species(
    id: '12',
    commonName: 'Malayan Tiger',
    scientificName: 'Panthera tigris jacksoni',
    category: Species.mammals,
    conservationStatus: Species.criticallyEndangered,
    habitat: 'Deep tropical broadleaf forests of Peninsular Malaysia',
    imageUrl:
    'https://images.unsplash.com/photo-1561731216-c3a4d99437d5?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
    description:
    'The iconic apex predator of Peninsular Malaysia. Known for its striking stripes and highly elusive nature.',
    behaviorNotes:
    'Highly territorial and primarily nocturnal. They are excellent swimmers and often use rivers to cool down or travel.',
    photographyConditions:
    'Extremely rare to see on foot. Photography is almost exclusively done via professionally set remote DSLR camera traps.',
    recommendedGear: [
      'DSLR/Mirrorless Camera Traps',
      'Infrared motion sensors',
      'Off-camera weather-sealed flashes',
      'Local ranger/guide (Mandatory)',
    ],
    activityPattern: 'Nocturnal (Night-active)',
    bestSeasons: ['Year-round (Subject to camera trap triggers)'],
    difficultyLevel: 5,
  ),
  Species(
    id: '13',
    commonName: 'Mainland Clouded Leopard',
    scientificName: 'Neofelis nebulosa',
    category: Species.mammals,
    conservationStatus: Species.vulnerable,
    habitat: 'Primary evergreen tropical forests in Peninsular Malaysia',
    imageUrl:
    'https://images.unsplash.com/photo-1768726649407-4c24eb9102be?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjbG91ZGVkJTIwbGVvcGFyZCUyMHdpbGRsaWZlfGVufDF8fHx8MTc3NTE0NDczM3ww&ixlib=rb-4.1.0&q=80&w=1080',
    description:
    'Found exclusively in Peninsular (West) Malaysia. It features slightly larger "cloud" markings compared to its Bornean cousin.',
    behaviorNotes:
    'Highly arboreal and incredibly agile. They can descend trees headfirst and hang upside down from branches.',
    photographyConditions:
    'Requires extreme patience. Best photographed at dawn or dusk when they are most active. Often only captured via remote camera traps.',
    recommendedGear: [
      'Low-light capable telephoto lens (f/2.8 or faster)',
      'Remote camera traps',
      'Sturdy tripod',
      'Silent shutter mode',
    ],
    activityPattern: 'Crepuscular / Nocturnal',
    bestSeasons: ['Dry season (easier tracking)'],
    difficultyLevel: 5,
  ),
  Species(
    id: '14',
    commonName: 'Sunda Clouded Leopard',
    scientificName: 'Neofelis diardi',
    category: Species.mammals,
    conservationStatus: Species.vulnerable,
    habitat: 'Tropical rainforests of Malaysian Borneo',
    imageUrl:
    'https://images.unsplash.com/photo-1768726649407-4c24eb9102be?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjbG91ZGVkJTIwbGVvcGFyZCUyMHdpbGRsaWZlfGVufDF8fHx8MTc3NTE0NDczM3ww&ixlib=rb-4.1.0&q=80&w=1080',
    description:
    'Found exclusively in Malaysian Borneo. Separated from the mainland species over a million years ago, it features darker fur and tighter spots.',
    behaviorNotes:
    'A master climber with the longest canine teeth relative to skull size of any living cat.',
    photographyConditions:
    'Deramakot Forest Reserve in Sabah offers the highest chances of spotting them globally, usually from a 4x4 during guided night safaris.',
    recommendedGear: [
      'Fast telephoto lens (f/2.8)',
      'External spotlight',
      'High ISO capable camera body',
      'Rain gear',
    ],
    activityPattern: 'Nocturnal (Active at night)',
    bestSeasons: ['March to October (Drier months in Borneo)'],
    difficultyLevel: 5,
  ),
  Species(
    id: '15',
    commonName: 'Malayan Banded Pitta',
    scientificName: 'Hydrornis irena',
    category: Species.birds,
    conservationStatus: Species.nearThreatened,
    habitat: 'Lowland primary and secondary forests with dense undergrowth',
    imageUrl:
    'https://upload.wikimedia.org/wikipedia/commons/thumb/2/23/Malayan_banded_pitta.jpg/800px-Malayan_banded_pitta.jpg',
    description:
    'A "holy grail" bird for local photographers. The male features a stunning combination of deep blue, bright yellow, and fiery orange plumage.',
    behaviorNotes:
    'Shy, ground-dwelling bird that hops through leaf litter searching for insects and worms.',
    photographyConditions:
    'Incredibly challenging due to the dark forest floor. Photographers often use camouflage hides and wait for hours.',
    recommendedGear: [
      'Super-telephoto lens (500mm - 600mm)',
      'Sturdy tripod with gimbal head',
      'Camouflage popup hide',
      'Camera with excellent low-light autofocus',
    ],
    activityPattern: 'Diurnal (Early morning)',
    bestSeasons: ['May to August (Breeding season)'],
    difficultyLevel: 4,
  ),
  Species(
    id: '16',
    commonName: 'Malayan Horned Frog',
    scientificName: 'Megophrys nasuta',
    category: Species.amphibians,
    conservationStatus: Species.leastConcern,
    habitat: 'Damp leaf litter on the forest floor near streams',
    imageUrl:
    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cc/Megophrys_nasuta_-_Khao_Sok.jpg/800px-Megophrys_nasuta_-_Khao_Sok.jpg',
    description:
    'A macro photographer’s dream. It possesses incredible camouflage that mimics dead leaves, complete with horn-like projections over its eyes.',
    behaviorNotes:
    'An ambush predator that relies entirely on staying completely still until prey walks past.',
    photographyConditions:
    'They do not move much when spotted, making them excellent, cooperative subjects for focus-stacking and creative macro lighting.',
    recommendedGear: [
      'Macro lens (90mm - 105mm)',
      'Off-camera flash with a softbox/diffuser',
      'Ground-level tripod or beanbag',
      'Knee pads for crawling',
    ],
    activityPattern: 'Nocturnal (Active after rain)',
    bestSeasons: ['Monsoon transition periods (Higher humidity)'],
    difficultyLevel: 2,
  ),
  Species(
    id: '17',
    commonName: 'Rajah Brooke\'s Birdwing',
    scientificName: 'Trogonoptera brookiana',
    category: Species.insects,
    conservationStatus: Species.leastConcern,
    habitat: 'Rainforests near hot springs or mineral-rich riverbanks',
    imageUrl:
    'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Rajah_Brooke%27s_Birdwing_%28Trogonoptera_brookiana_albescens%29_male.jpg/800px-Rajah_Brooke%27s_Birdwing_%28Trogonoptera_brookiana_albescens%29_male.jpg',
    description:
    'The national butterfly of Malaysia. It is massive and striking, featuring jet-black wings with electric green feather-like markings.',
    behaviorNotes:
    'Males are famous for "mud-puddling"—gathering in large numbers on wet ground or hot springs to drink minerals.',
    photographyConditions:
    'Best photographed when puddling. If you approach slowly, they will ignore you while they drink, allowing for spectacular group shots.',
    recommendedGear: [
      'Tele-macro lens or 300mm telephoto',
      'Circular polarizer (to remove glare)',
      'Fast shutter speed',
    ],
    activityPattern: 'Diurnal (Mid-morning to early afternoon)',
    bestSeasons: ['Year-round (Best on sunny days after a rainstorm)'],
    difficultyLevel: 3,
  ),
];

Species? speciesById(String? id) {
  if (id == null) return null;
  for (final s in speciesData) {
    if (s.id == id) return s;
  }
  return null;
}