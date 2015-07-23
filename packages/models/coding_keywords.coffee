codes =
  [
    {
      'heading': 'Human Movement'
      'subHeadings':
        'Home': [
          'Dwelling, living  quarters, sleeping  quarters',
          'Children, family',
          'Daily movement/travel',
          'Flood',
          'Drought',
          'Conflict',
          'Protection  from  predators/ animals',
          'Safety',
          'Religion'
        ]
        'Work': [
          'Work  activities',
          'Agriculture areas',
          'Grazing areas',
          'Hunting territories',
          'Boundaries',
          'Livestock areas',
          'Markets',
          'Crops',
          'Business'
        ]
        'Travel': [
          'Traveling to  Shop/buy/sell/trade',
          'Hunting trips',
          'Transporting  animals',
          'Transportation: Walking,  biking, cart, truck,',
          'Plane, boat, trains',
          'Overnight trips',
          'Reasons for travel',
          'Travel destinations',
          'Border crossings',
          'Travel obstacles/issues',
          'Transportation of resources/moving'
        ]
        'Observed Environment': [
          'Town roads/ports/ trains',
          'New buildings/roads/construction',
          'Route changes',
          'Abandoned land'
        ]
    },
    {
    'heading': 'Socioeconomics'
    'subHeadings':
      'Daily routine': [
        'Meal preparation',
        'Shopping',
        'Childcare',
        'Market  trips',
        'Groceries',
        'Purchases',
        'Errands'
      ]
      'Animal responsibilities': [
        'Animal duties/responsibilities',
        'Feeding/grazing',
        'Tasks/roles by age or gender',
        'Sick animals',
        'Slaughtering/Butchering'
      ]
      'Education': [
        'School/education/graduation',
        'Reading/understanding numbers',
        'Dropping out'
      ]
      'Economics': [
        'Livelihood',
        'Earning/earning changes throughout year',
        'Large purchases',
        'Income',
        'Purchases for event/holiday',
        'Social standing (compared to Neighbors/others)',
        'Expenses',
        'Number of jobs/activities'
      ]
    },
    {
    'heading': 'Biosecurity in Human Environments'
    'subHeadings':
      'Water and food': [
        'Water source (where does it come from?)',
        'Water taste/quality/purification',
        'Rain/rainwater/water taps/well',
        'Storing food/storing water',
        'Pests/rats/pesticides/cockroaches/insects',
        'Kitchen',
        'Cleaning ',
        'Water usage'
      ]

      'Sanitation': [
        'Waste management/garbage'
        'Toilets/latrines/bathroom'
        'Cleaning bathroom/kitchen'
        'Feces'
        'Urine'
        'Pesticides'
      ]
      'Hygiene': [
        'Washing hands',
        'Showering/bathing',
        'Soap',
        'Leave shoes/footwear outside'
      ]
    },
    {
    'heading': 'Illness, Medical Care/Treatment and Death'
    'subHeadings':
      'Household illness/Wellness': [
        'Sick relatives',
        'Caretaking of sick',
        'Types of sickness',
        'Unusual illness',
        'Symptoms of illness',
        'Ebola',
        'SARS',
        'MERS',
        '(Other endemic zoonotic diseases)',
        'Dispensaries/medication',
        'Births'
      ]
      'Illness from animals': [
        'Illness from animals'
      ]
      'Medical Care and Treatment': [
        'Doctor/clinic visit'
        'Medicine/Treatment'
        'Cost of medicine/doctor/treatment'
        'Professionals (doctor, nurse, religious leader, healthcare worker etc…)'
        'Traditional medicine'
        'Ethno botany '
        'Healthcare protocols'
      ]
      'Death': [
        'Reporting death'
        'Burial/burial rites'
        'Funeral tradition/rites'
        'Dead body/corpse'
        'Body preparation'
      ]
    },
    {
    'heading': 'Human Animal Contact'
    'subHeadings':
      'Indirect Contact/Food': [
        'Meat/animal consumption',
        'Acquisition of meat',
        'Preparing meat',
        'Meat/animal storage',
        'Butchering',
        'Animal taboos',
        'Infected animals',
        'Wildlife consumption',
        'Purchasing meat or wildlife',
        'Cleaning up after animals',
        'Meat/dead animal markets',
        'Animals around dwelling/pests',
        'Signs of animals (hear, smell)',
        'Feces',
        'Animal tracks',
        'Garbage disturbance',
        'Observed animals',
        'Hunting'
      ]

      'Direct Contact': [
        'Ownership of animals',
        'Live animals',
        'Pets',
        'Playing with animals (wild or domestic, alive or dead)',
        'Animal caretaking',
        'Feeding animals',
        'Grazing animals',
        'Working with animals',
        'Live animal markets/wet markets',
        'Ranching',
        'Animal husbandry',
        'Buying/selling/trading live animals'
      ]

      'Bite': [
        'Scratch',
        'Animal handling',
        'Killing live animals/slaughtering',
        'Handling of wildlife'
      ]

      'Animal products/rites': [
        'Animal byproducts (milk, leather, magic, medical)',
        'Magic involving animals',
        'Fertilizer'
      ]

      'Animal health': [
        'Animals eating/sleeping/grazing',
        'Sick animals',
        'Animal caretaking activities/roles',
        'Animal waste',
        'Cleaning animal areas',
        'Veterinary care',
        'Vaccinations',
        'Outbreak',
        'Die off'
      ]

      'Perceptions and knowledge': [
        'Exotic or expensive animals',
        'Wildlife consumption',
        'Regulations/laws regarding animals (eg. Hunting, eating, poaching regulations)',
        'Danger from animals',
        'Conservation',
        'Taboos',
        'Special occasions/holidays',
        'feasts/holy days'
      ]
    }
  ]

CodingKeywords = new Meteor.Collection(null)
for codeCategory in codes
  CodingKeywords.insert codeCategory
