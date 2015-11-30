codes =
  'Human Movement':
    'Home': [
      'Dwelling, living quarters, sleeping quarters'
      'Children, family'
      'Daily movement/travel'
      'Flood'
      'Drought'
      'Conflict'
      'Protection from predators/animals'
      'Safety'
      'Religion'
    ]
    'Work': [
      'Work  activities'
      'Agriculture areas'
      'Grazing areas'
      'Hunting territories'
      'Boundaries'
      'Livestock areas'
      'Markets'
      'Crops'
      'Business'
    ]
    'Travel': [
      'Traveling to shop/buy/sell/trade'
      'Hunting trips'
      'Transporting  animals'
      'Transportation: walking, biking, cart, truck, plane, boat, trains'
      'Overnight trips'
      'Reasons for travel'
      'Travel destinations'
      'Border crossings'
      'Travel obstacles/issues'
      'Transportation of resources/moving'
    ]
    'Observed Environment': [
      'Town roads/ports/trains'
      'New buildings/roads/construction'
      'Route changes'
      'Abandoned land'
    ]
  'Socioeconomics':
    'Daily routine': [
      'Meal preparation'
      'Shopping'
      'Childcare'
      'Market  trips'
      'Groceries'
      'Purchases'
      'Errands'
    ]
    'Animal responsibilities': [
      'Animal duties/responsibilities'
      'Feeding/grazing'
      'Tasks/roles by age or gender'
      'Sick animals'
      'Slaughtering/Butchering'
    ]
    'Education': [
      'School/education/graduation'
      'Reading/understanding numbers'
      'Dropping out'
    ]
    'Economics': [
      'Livelihood'
      'Earning/earning changes throughout year'
      'Large purchases'
      'Income'
      'Purchases for event/holiday'
      'Social standing (compared to neighbors/others)'
      'Expenses'
      'Number of jobs/activities'
    ]
  'Biosecurity in Human Environments':
    'Water and food': [
      'Water source (where does it come from?)'
      'Water taste/quality/purification'
      'Rain/rainwater/water taps/well'
      'Storing food/storing water'
      'Pests/rats/pesticides/cockroaches/insects'
      'Kitchen'
      'Cleaning'
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
      'Washing hands'
      'Showering/bathing'
      'Soap'
      'Leave shoes/footwear outside'
    ]
  'Illness Medical Care/Treatment and Death':
    'Household illness/wellness': [
      'Sick relatives'
      'Caretaking of sick'
      'Types of sickness'
      'Unusual illness'
      'Symptoms of illness'
      'Ebola'
      'SARS'
      'MERS'
      'Other endemic zoonotic diseases'
      'Dispensaries/medication'
      'Births'
    ]
    'Illness from animals': [
      'Illness from animals'
    ]
    'Medical Care and Treatment': [
      'Doctor/clinic visit'
      'Medicine/treatment'
      'Cost of medicine/doctor/treatment'
      'Professionals (doctor, nurse, religious leader, healthcare worker, etc.)'
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
  'Human Animal Contact':
    'Indirect Contact/Food': [
      'Meat/animal consumption'
      'Acquisition of meat'
      'Preparing meat'
      'Meat/animal storage'
      'Butchering'
      'Animal taboos'
      'Infected animals'
      'Wildlife consumption'
      'Purchasing meat or wildlife'
      'Cleaning up after animals'
      'Meat/dead animal markets'
      'Animals around dwelling/pests'
      'Signs of animals (hear smell)'
      'Feces'
      'Animal tracks'
      'Garbage disturbance'
      'Observed animals'
      'Hunting'
    ]
    'Direct Contact': [
      'Ownership of animals'
      'Live animals'
      'Pets'
      'Playing with animals (wild or domestic alive or dead)'
      'Animal caretaking'
      'Feeding animals'
      'Grazing animals'
      'Working with animals'
      'Live animal markets/wet markets'
      'Ranching'
      'Animal husbandry'
      'Buying/selling/trading live animals'
    ]
    'Bite': [
      'Scratch'
      'Animal handling'
      'Killing live animals/slaughtering'
      'Handling of wildlife'
    ]
    'Animal products/rites': [
      'Animal byproducts (milk, leather, magic, medical)'
      'Magic involving animals'
      'Fertilizer'
    ]
    'Animal health': [
      'Animals eating/sleeping/grazing'
      'Sick animals'
      'Animal caretaking activities/roles'
      'Animal waste'
      'Cleaning animal areas'
      'Veterinary care'
      'Vaccinations'
      'Outbreak'
      'Die off'
    ]
    'Perceptions and knowledge': [
      'Exotic or expensive animals'
      'Wildlife consumption'
      'Regulations/laws regarding animals (e.g. hunting, eating, poaching regulations)'
      'Danger from animals'
      'Conservation'
      'Taboos'
      'Special occasions/holidays'
      'Feasts/holy days'
    ]

caseCountCodes = [
  'Case count'
  'Death count'
]

CodingKeywords = new Mongo.Collection('keywords')
CodingKeyword = Astro.Class
  name: 'CodingKeyword'
  collection: CodingKeywords
  fields:
    headerId: 'string'
    subHeaderId: 'string'
    label: 'string'
    caseCount: 'boolean'
  behaviors: ['timestamp']
  methods:
    _subHeader: ->
      SubHeaders.findOne(@subHeaderId)
    _header: ->
      Headers.findOne(@_subHeader().headerId)
    color: ->
      @_header().color
    headerLabel: ->
      @_header().label
    subHeaderLabel: ->
      @_subHeader().label

if Meteor.isServer
  Meteor.startup ->
    unless CodingKeywords.findOne({})
      i = 0
      for header, subHeaders of codes
        i++
        headerId = Headers.insert
          'label': header
          'color': i

        for subHeader, keywords of subHeaders
          subHeaderId = SubHeaders.insert
            'label': subHeader
            'headerId': headerId

          for keyword in keywords
            CodingKeywords.insert
              'label': keyword
              'subHeaderId': subHeaderId

    i = 0
    for header in caseCountCodes
      unless CodingKeywords.findOne({header: header})
        i++
        CodingKeywords.insert
          'header': header
          'color': i
          'caseCount': true
