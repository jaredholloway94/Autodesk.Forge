#   "Autodesk Forge PowerShell Cmdlets - Enums"
#   Copyright © 2021 Jared M. Holloway
#   License: MIT
#   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


# Enums __________________________________________________________________________________________________________

$ServiceTypes = @{
    doc_manager = "Document Management"
    field = "Field (Classic)"
    glue = "Glue (Classic)"
    schedule = "schedule?" # what is this service???
    plan = "Plan (Classic)"
    
}

$AdminServiceTypes = @{
    admin = "Project Administration"
    doc_manager = "Document Management"
    pm = "Project Management"
    fng = "Field Management"
    collab = "Design Collaboration"
    cost = "Cost Management"
    gng = "Model Coordination"
    field = "Field (Classic)"
    glue = "Glue (Classic)"
    schedule = ""
    plan = "Plan (Classic)"
    
}

$ConstructionTypes = @(
    "New Construction",
    "Renovation"
)

$ContractTypes = @(
    "Construction Management (CM) at Risk",
    "Design-Bid",
    "Design-Bid-Build",
    "Design-Build-Operate",
    "IPD"
)

$ProjectTypes = @(
    "Commercial",
    "Convention Center",
    "Data Center",
    "Hotel / Motel",
    "Office",
    "Parking Structure / Garage",
    "Performing Arts",
    "Retail",
    "Stadium/Arena",
    "Theme Park",
    "Warehouse (non-manufacturing)",
    "Healthcare",
    "Assisted Living / Nursing Home",
    "Hospital",
    "Medical Laboratory",
    "Medical Office",
    "OutPatient Surgery Center",
    "Institutional",
    "Court House",
    "Dormitory",
    "Education Facility",
    "Government Building",
    "Library",
    "Military Facility",
    "Museum",
    "Prison / Correctional Facility",
    "Recreation Building",
    "Religious Building",
    "Research Facility / Laboratory",
    "Residential",
    "Multi-Family Housing",
    "Single-Family Housing",
    "Infrastructure",
    "Airport",
    "Bridge",
    "Canal / Waterway",
    "Dams / Flood Control / Reservoirs",
    "Harbor / River Development",
    "Rail",
    "Seaport",
    "Streets / Roads / Highways",
    "Transportation Building",
    "Tunnel",
    "Waste Water / Sewers",
    "Water Supply",
    "Industrial & Energy",
    "Manufacturing / Factory",
    "Oil & Gas",
    "Plant",
    "Power Plant",
    "Solar Far",
    "Utilities",
    "Wind Farm",
    "Sample Projects",
    "Demonstration Project",
    "Template Project",
    "Training Project"
)

$Currencies = @{
"USD" = "US Dollar"
"AUD" = "Australian Dollar"
"CAD" = "Canadian Dollar"
"EUR" = "Euro"
"GBP" = "Pound Sterling"
"ALL" = "Albanian Lek"
"AZN" = "Azerbaijani Manat"
"BYR" = "Belarusian Ruble"
"BRL" = "Brazilian Real"
"BGN" = "Bulgarian Lev"
"CNY" = "Chinese Yuan"
"HRK" = "Croatian kuna"
"CZK" = "Czech koruna"
"DKK" = "Danish krone"
"EEK" = "Estonian Kroon"
"HKD" = "Hong Kong dollar"
"HUF" = "Hungarian forint"
"ISK" = "Icelandic króna"
"INR" = "Indian rupee"
"IRR" = "Iranian rial"
"ILS" = "Israeli new shekel"
"JPY" = "Japanese yen"
"KZT" = "Kazakhstani tenge"
"KRW" = "South Korean won"
"KPW" = "North Korean won"
"KGS" = "Kyrgyzstani som"
"LVL" = "Latvian Lats"
"LTL" = "Lithuanian Litas"
"MKD" = "Macedonian denar"
"MNT" = "Mongolian tögrög"
"ANG" = "Netherlands Antillean guilder"
"NOK" = "Norwegian krone"
"PKR" = "Pakistani rupee"
"PLN" = "Polish złoty"
"RON" = "Romanian leu"
"RUB" = "Russian ruble"
"SAR" = "Saudi riyal"
"RSD" = "Serbian dinar"
"SGD" = "Singapore dollar"
"ZAR" = "South African rand"
"SEK" = "Swedish krona/kronor"
"CHF" = "Swiss franc"
"TWD" = "New Taiwan dollar"
"TRL" = "Turkish Lira"
"UAH" = "Ukrainian hryvnia"
"UZS" = "Uzbekistan som"
"YER" = "Yemeni rial"
"PHP" = "Philippine peso"
"NZD" = "New Zealand dollar"
}

$Timezones = @(
    "Pacific/Honolulu",
    "America/Juneau",
    "America/Los_Angeles",
    "America/Phoenix",
    "America/Denver",
    "America/Chicago",
    "America/New_York",
    "America/Indiana/Indianapolis",
    "Pacific/Pago_Pago",
    "Pacific/Midway",
    "America/Tijuana",
    "America/Chihuahua",
    "America/Mazatlan",
    "America/Guatemala",
    "America/Mexico_City",
    "America/Monterrey",
    "America/Regina",
    "America/Bogota",
    "America/Lima",
    "America/Caracas",
    "America/Halifax",
    "America/Guyana",
    "America/La_Paz",
    "America/Santiago",
    "America/St_Johns",
    "America/Sao_Paulo",
    "America/Argentina/Buenos_Aires",
    "America/Godthab",
    "Atlantic/South_Georgia",
    "Atlantic/Azores",
    "Atlantic/Cape_Verde",
    "Africa/Casablanca",
    "Europe/Dublin",
    "Europe/Lisbon",
    "Europe/London",
    "Africa/Monrovia",
    "ETC/UTC",
    "Europe/Amsterdam",
    "Europe/Belgrade",
    "Europe/Berlin",
    "Europe/Bratislava",
    "Europe/Brussels",
    "Europe/Budapest",
    "Europe/Copenhagen",
    "Europe/Ljubljana",
    "Europe/Madrid",
    "Europe/Paris",
    "Europe/Prague",
    "Europe/Rome",
    "Europe/Sarajevo",
    "Europe/Skopje",
    "Europe/Stockholm",
    "Europe/Vienna",
    "Europe/Warsaw",
    "Africa/Algiers",
    "Europe/Zagreb",
    "Europe/Athens",
    "Europe/Bucharest",
    "Africa/Cairo",
    "Africa/Harare",
    "Europe/Helsinki",
    "Europe/Istanbul",
    "Asia/Jerusalem",
    "Europe/Kiev",
    "Africa/Johannesburg",
    "Europe/Riga",
    "Europe/Sofia",
    "Europe/Tallinn",
    "Europe/Vilnius",
    "Asia/Baghdad",
    "Asia/Kuwait",
    "Europe/Minsk",
    "Africa/Nairobi",
    "Asia/Riyadh",
    "Asia/Tehran",
    "Asia/Muscat",
    "Asia/Baku",
    "Europe/Moscow",
    "Asia/Tbilisi",
    "Asia/Yerevan",
    "Asia/Kabul",
    "Asia/Karachi",
    "Asia/Tashkent",
    "Asia/Kolkata",
    "Asia/Colombo",
    "Asia/Kathmandu",
    "Asia/Almaty",
    "Asia/Dhaka",
    "Asia/Yekaterinburg",
    "Asia/Rangoon",
    "Asia/Bangkok",
    "Asia/Jakarta",
    "Asia/Novosibirsk",
    "Asia/Shanghai",
    "Asia/Chongqing",
    "Asia/Hong_Kong",
    "Asia/Krasnoyarsk",
    "Asia/Kuala_Lumpur",
    "Australia/Perth",
    "Asia/Singapore",
    "Asia/Taipei",
    "Asia/Ulaanbaatar",
    "Asia/Urumqi",
    "Asia/Irkutsk",
    "Asia/Tokyo",
    "Asia/Seoul",
    "Australia/Adelaide",
    "Australia/Darwin",
    "Australia/Brisbane",
    "Australia/Melbourne",
    "Pacific/Guam",
    "Australia/Hobart",
    "Pacific/Port_Moresby",
    "Australia/Sydney",
    "Asia/Yakutsk",
    "Pacific/Noumea",
    "Asia/Vladivostok",
    "Pacific/Auckland",
    "Pacific/Fiji",
    "Asia/Kamchatka",
    "Asia/Magadan",
    "Pacific/Majurov",
    "Pacific/Guadalcanal",
    "Pacific/Tongatapu",
    "Pacific/Apia",
    "Pacific/Fakaofo"
)

$Trades = @(
    "Architecture",
    "Communications",
    "Communications | Data",
    "Concrete",
    "Concrete | Cast-in-Place",
    "Concrete | Precast",
    "Construction Management",
    "Conveying Equipment",
    "Conveying Equipment | Elevators",
    "Demolition",
    "Earthwork",
    "Earthwork | Site Excavation & Grading",
    "Electrical",
    "Electrical Power Generation",
    "Electronic Safety & Security",
    "Equipment",
    "Equipment | Kitchen Appliances",
    "Exterior Improvements",
    "Exterior | Fences & Gates",
    "Exterior | Landscaping",
    "Exterior | Irrigation",
    "Finishes",
    "Finishes | Carpeting",
    "Finishes | Ceiling",
    "Finishes | Drywall",
    "Finishes | Flooring",
    "Finishes | Painting & Coating",
    "Finishes | Tile",
    "Fire Suppression",
    "Furnishings",
    "Furnishings | Casework & Cabinets",
    "Furnishings | Countertops",
    "Furnishings | Window Treatments",
    "General Contractor",
    "HVAC Heating, Ventilating, & Air Conditioning",
    "Industry-Specific Manufacturing Processing",
    "Integrated Automation",
    "Masonry",
    "Material Processing & Handling Equipment",
    "Metals",
    "Metals | Structural Steel / Framing",
    "Moisture Protection",
    "Moisture Protection | Roofing",
    "Moisture Protection | Waterproofing",
    "Openings",
    "Openings | Doors & Frames",
    "Openings | Entrances & Storefronts",
    "Openings | Glazing",
    "Openings | Roof Windows & Skylights",
    "Openings | Windows",
    "Owner",
    "Plumbing",
    "Pollution & Waste Control Equipment",
    "Process Gas & Liquid Handling, Purification, & Storage Equipment",
    "Process Heating, Cooling, & Drying Equipment",
    "Process Integration",
    "Process Integration | Piping",
    "Special Construction",
    "Specialties",
    "Specialties | Signage",
    "Utilities",
    "Water & Wastewater Equipment",
    "Waterway & Marine Construction",
    "Wood & Plastics",
    "Wood & Plastics | Millwork",
    "Wood & Plastics | Rough Carpentry"
)

$Countries = @{
    "Andorra" = @{
        "States" = @(
            "Canillo",
            "Encamp",
            "La Massana",
            "Ordino",
            "Sant Julià de Lòria",
            "Andorra la Vella",
            "Escaldes-Engordany"
        )
    }
    "United Arab Emirates" = @{
        "States" = @(
            "'Ajmān",
            "Abū Ȥaby [Abu Dhabi]",
            "Dubayy",
            "Al Fujayrah",
            "Ra’s al Khaymah",
            "Ash Shāriqah",
            "Umm al Qaywayn"
        )
    }
    "Afghanistan" = @{
        "States" = @(
            "Balkh",
            "Bāmyān",
            "Bādghīs",
            "Badakhshān",
            "Baghlān",
            "Dāykundī",
            "Farāh",
            "Fāryāb",
            "Ghaznī",
            "Ghōr",
            "Helmand",
            "Herāt",
            "Jowzjān",
            "Kābul",
            "Kandahār",
            "Kāpīsā",
            "Kunduz",
            "Khōst",
            "Kunar",
            "Laghmān",
            "Lōgar",
            "Nangarhār",
            "Nīmrōz",
            "Nūristān",
            "Panjshayr",
            "Parwān",
            "Paktiyā",
            "Paktīkā",
            "Samangān",
            "Sar-e Pul",
            "Takhār",
            "Uruzgān",
            "Wardak",
            "Zābul"
        )
    }
    "Antigua and Barbuda" = @{
        "States" = @(
            "Saint George",
            "Saint John",
            "Saint Mary",
            "Saint Paul",
            "Saint Peter",
            "Saint Philip",
            "Barbuda",
            "Redonda"
        )
    }
    "Anguilla" = @{
        "States" = @(
        )
    }
    "Albania" = @{
        "States" = @(
            "Berat",
            "Durrës",
            "Elbasan",
            "Fier",
            "Gjirokastër",
            "Korçë",
            "Kukës",
            "Lezhë",
            "Dibër",
            "Shkodër",
            "Tiranë",
            "Vlorë"
        )
    }
    "Armenia" = @{
        "States" = @(
            "Aragacotn",
            "Ararat",
            "Armavir",
            "Erevan",
            "Gegarkunik'",
            "Kotayk'",
            "Lory",
            "Sirak",
            "Syunik'",
            "Tavus",
            "Vayoc Jor"
        )
    }
    "Angola" = @{
        "States" = @(
            "Bengo",
            "Benguela",
            "Bié",
            "Cabinda",
            "Cuando-Cubango",
            "Cunene",
            "Cuanza Norte",
            "Cuanza Sul",
            "Huambo",
            "Huíla",
            "Lunda Norte",
            "Lunda Sul",
            "Luanda",
            "Malange",
            "Moxico",
            "Namibe",
            "Uíge",
            "Zaire"
        )
    }
    "Antarctica" = @{
        "States" = @(
        )
    }
    "Argentina" = @{
        "States" = @(
            "Salta",
            "Buenos Aires",
            "Ciudad Autónoma de Buenos Aires",
            "San Luis",
            "Entre Rios",
            "Santiago del Estero",
            "Chaco",
            "San Juan",
            "Catamarca",
            "La Pampa",
            "Mendoza",
            "Misiones",
            "Formosa",
            "Neuquen",
            "Rio Negro",
            "Santa Fe",
            "Tucuman",
            "Chubut",
            "Tierra del Fuego",
            "Corrientes",
            "Cordoba",
            "Jujuy",
            "Santa Cruz",
            "La Rioja"
        )
    }
    "American Samoa" = @{
        "States" = @(
        )
    }
    "Austria" = @{
        "States" = @(
            "Burgenland",
            "Kärnten",
            "Niederösterreich",
            "Oberösterreich",
            "Salzburg",
            "Steiermark",
            "Tirol",
            "Vorarlberg",
            "Wien"
        )
    }
    "Australia" = @{
        "States" = @(
            "Australian Capital Territory",
            "New South Wales",
            "Northern Territory",
            "Queensland",
            "South Australia",
            "Tasmania",
            "Victoria",
            "Western Australia"
        )
    }
    "Aruba" = @{
        "States" = @(
        )
    }
    "Åland Islands" = @{
        "States" = @(
        )
    }
    "Azerbaijan" = @{
        "States" = @(
            "Abşeron",
            "Ağstafa",
            "Ağcabədi",
            "Ağdam",
            "Ağdaş",
            "Ağsu",
            "Astara",
            "Bakı",
            "Balakən",
            "Bərdə",
            "Beyləqan",
            "Biləsuvar",
            "Cəbrayıl",
            "Cəlilabab",
            "Daşkəsən",
            "Füzuli",
            "Gəncə",
            "Gədəbəy",
            "Goranboy",
            "Göyçay",
            "Göygöl",
            "Hacıqabul",
            "İmişli",
            "İsmayıllı",
            "Kəlbəcər",
            "Kürdəmir",
            "Laçın",
            "Lənkəran",
            "Lerik",
            "Masallı",
            "Mingəçevir",
            "Naftalan",
            "Neftçala",
            "Naxçıvan",
            "Oğuz",
            "Qəbələ",
            "Qax",
            "Qazax",
            "Quba",
            "Qubadlı",
            "Qobustan",
            "Qusar",
            "Sabirabad",
            "Şəki",
            "Salyan",
            "Saatlı",
            "Şabran",
            "Siyəzən",
            "Şəmkir",
            "Sumqayıt",
            "Şamaxı",
            "Samux",
            "Şirvan",
            "Şuşa",
            "Tərtər",
            "Tovuz",
            "Ucar",
            "Xankəndi",
            "Xaçmaz",
            "Xocalı",
            "Xızı",
            "Xocavənd",
            "Yardımlı",
            "Yevlax",
            "Zəngilan",
            "Zaqatala",
            "Zərdab"
        )
    }
    "Bosnia and Herzegovina" = @{
        "States" = @(
            "Federacija Bosne i Hercegovine",
            "Brčko distrikt",
            "Republika Srpska"
        )
    }
    "Barbados" = @{
        "States" = @(
            "Christ Church",
            "Saint Andrew",
            "Saint George",
            "Saint James",
            "Saint John",
            "Saint Joseph",
            "Saint Lucy",
            "Saint Michael",
            "Saint Peter",
            "Saint Philip",
            "Saint Thomas"
        )
    }
    "Bangladesh" = @{
        "States" = @(
            "Barisal",
            "Chittagong",
            "Dhaka",
            "Khulna",
            "Rajshahi",
            "Rangpur",
            "Sylhet"
        )
    }
    "Belgium" = @{
        "States" = @(
            "Bruxelles-Capitale, Région de;Brussels Hoofdstedelijk Gewest",
            "Vlaams Gewest",
            "wallonne, Région"
        )
    }
    "Burkina Faso" = @{
        "States" = @(
            "Boucle du Mouhoun",
            "Cascades",
            "Centre",
            "Centre-Est",
            "Centre-Nord",
            "Centre-Ouest",
            "Centre-Sud",
            "Est",
            "Hauts-Bassins",
            "Nord",
            "Plateau-Central",
            "Sahel",
            "Sud-Ouest"
        )
    }
    "Bulgaria" = @{
        "States" = @(
            "Blagoevgrad",
            "Burgas",
            "Varna",
            "Veliko Tarnovo",
            "Vidin",
            "Vratsa",
            "Gabrovo",
            "Dobrich",
            "Kardzhali",
            "Kyustendil",
            "Lovech",
            "Montana",
            "Pazardzhik",
            "Pernik",
            "Pleven",
            "Plovdiv",
            "Razgrad",
            "Ruse",
            "Silistra",
            "Sliven",
            "Smolyan",
            "Sofia-Grad",
            "Sofia",
            "Stara Zagora",
            "Targovishte",
            "Haskovo",
            "Shumen",
            "Yambol"
        )
    }
    "Bahrain" = @{
        "States" = @(
            "Al Manāmah (Al ‘Āşimah)",
            "Al Janūbīyah",
            "Al Muḩarraq",
            "Al Wusţá",
            "Ash Shamālīyah"
        )
    }
    "Burundi" = @{
        "States" = @(
            "Bubanza",
            "Bujumbura Rural",
            "Bujumbura Mairie",
            "Bururi",
            "Cankuzo",
            "Cibitoke",
            "Gitega",
            "Kirundo",
            "Karuzi",
            "Kayanza",
            "Makamba",
            "Muramvya",
            "Mwaro",
            "Ngozi",
            "Rutana",
            "Ruyigi"
        )
    }
    "Benin" = @{
        "States" = @(
            "Atakora",
            "Alibori",
            "Atlantique",
            "Borgou",
            "Collines",
            "Donga",
            "Kouffo",
            "Littoral",
            "Mono",
            "Ouémé",
            "Plateau",
            "Zou"
        )
    }
    "Saint Barthélemy" = @{
        "States" = @(
        )
    }
    "Bermuda" = @{
        "States" = @(
        )
    }
    "Brunei Darussalam" = @{
        "States" = @(
            "Belait",
            "Brunei-Muara",
            "Temburong",
            "Tutong"
        )
    }
    "Bolivia, Plurinational State of" = @{
        "States" = @(
            "El Beni",
            "Cochabamba",
            "Chuquisaca",
            "La Paz",
            "Pando",
            "Oruro",
            "Potosí",
            "Santa Cruz",
            "Tarija"
        )
    }
    "Bonaire, Sint Eustatius and Saba" = @{
        "States" = @(
            "Bonaire",
            "Saba",
            "Sint Eustatius"
        )
    }
    "Brazil" = @{
        "States" = @(
            "Acre",
            "Alagoas",
            "Amazonas",
            "Amapá",
            "Bahia",
            "Ceará",
            "Distrito Federal",
            "Espírito Santo",
            "Fernando de Noronha",
            "Goiás",
            "Maranhão",
            "Minas Gerais",
            "Mato Grosso do Sul",
            "Mato Grosso",
            "Pará",
            "Paraíba",
            "Pernambuco",
            "Piauí",
            "Paraná",
            "Rio de Janeiro",
            "Rio Grande do Norte",
            "Rondônia",
            "Roraima",
            "Rio Grande do Sul",
            "Santa Catarina",
            "Sergipe",
            "São Paulo",
            "Tocantins"
        )
    }
    "Bahamas" = @{
        "States" = @(
            "Acklins",
            "Bimini",
            "Black Point",
            "Berry Islands",
            "Central Eleuthera",
            "Cat Island",
            "Crooked Island and Long Cay",
            "Central Abaco",
            "Central Andros",
            "East Grand Bahama",
            "Exuma",
            "City of Freeport",
            "Grand Cay",
            "Harbour Island",
            "Hope Town",
            "Inagua",
            "Long Island",
            "Mangrove Cay",
            "Mayaguana",
            "Moore's Island",
            "North Eleuthera",
            "North Abaco",
            "North Andros",
            "Rum Cay",
            "Ragged Island",
            "South Andros",
            "South Eleuthera",
            "South Abaco",
            "San Salvador",
            "Spanish Wells",
            "West Grand Bahama"
        )
    }
    "Bhutan" = @{
        "States" = @(
            "Paro",
            "Chhukha",
            "Ha",
            "Samtee",
            "Thimphu",
            "Tsirang",
            "Dagana",
            "Punakha",
            "Wangdue Phodrang",
            "Sarpang",
            "Trongsa",
            "Bumthang",
            "Zhemgang",
            "Trashigang",
            "Monggar",
            "Pemagatshel",
            "Lhuentse",
            "Samdrup Jongkha",
            "Gasa",
            "Trashi Yangtse"
        )
    }
    "Bouvet Island" = @{
        "States" = @(
        )
    }
    "Botswana" = @{
        "States" = @(
            "Central",
            "Ghanzi",
            "Kgalagadi",
            "Kgatleng",
            "Kweneng",
            "North-East",
            "North-West",
            "South-East",
            "Southern"
        )
    }
    "Belarus" = @{
        "States" = @(
            "Brèsckaja voblasc'",
            "Horad Minsk",
            "Homel'skaja voblasc'",
            "Hrodzenskaja voblasc'",
            "Mahilëuskaja voblasc'",
            "Minskaja voblasc'",
            "Vicebskaja voblasc'"
        )
    }
    "Belize" = @{
        "States" = @(
            "Belize",
            "Cayo",
            "Corozal",
            "Orange Walk",
            "Stann Creek",
            "Toledo"
        )
    }
    "Canada" = @{
        "States" = @(
            "Alberta",
            "British Columbia",
            "Manitoba",
            "New Brunswick",
            "Newfoundland and Labrador",
            "Nova Scotia",
            "Northwest Territories",
            "Nunavut",
            "Ontario",
            "Prince Edward Island",
            "Quebec",
            "Saskatchewan",
            "Yukon Territory"
        )
    }
    "Cocos (Keeling) Islands" = @{
        "States" = @(
        )
    }
    "Congo, The Democratic Republic of the" = @{
        "States" = @(
            "Bas-Congo",
            "Bandundu",
            "Équateur",
            "Katanga",
            "Kasai-Oriental",
            "Kinshasa",
            "Kasai-Occidental",
            "Maniema",
            "Nord-Kivu",
            "Orientale",
            "Sud-Kivu"
        )
    }
    "Central African Republic" = @{
        "States" = @(
            "Ouham",
            "Bamingui-Bangoran",
            "Bangui",
            "Basse-Kotto",
            "Haute-Kotto",
            "Haut-Mbomou",
            "Haute-Sangha / Mambéré-Kadéï",
            "Gribingui",
            "Kémo-Gribingui",
            "Lobaye",
            "Mbomou",
            "Ombella-M'poko",
            "Nana-Mambéré",
            "Ouham-Pendé",
            "Sangha",
            "Ouaka",
            "Vakaga"
        )
    }
    "Congo" = @{
        "States" = @(
            "Bouenza",
            "Pool",
            "Sangha",
            "Plateaux",
            "Cuvette-Ouest",
            "Lékoumou",
            "Kouilou",
            "Likouala",
            "Cuvette",
            "Niari",
            "Brazzaville"
        )
    }
    "Switzerland" = @{
        "States" = @(
            "Aargau",
            "Appenzell Innerrhoden",
            "Appenzell Ausserrhoden",
            "Bern",
            "Basel-Landschaft",
            "Basel-Stadt",
            "Fribourg",
            "Genève",
            "Glarus",
            "Graubünden",
            "Jura",
            "Luzern",
            "Neuchâtel",
            "Nidwalden",
            "Obwalden",
            "Sankt Gallen",
            "Schaffhausen",
            "Solothurn",
            "Schwyz",
            "Thurgau",
            "Ticino",
            "Uri",
            "Vaud",
            "Valais",
            "Zug",
            "Zürich"
        )
    }
    "Côte d'Ivoire" = @{
        "States" = @(
            "Lagunes (Région des)",
            "Haut-Sassandra (Région du)",
            "Savanes (Région des)",
            "Vallée du Bandama (Région de la)",
            "Moyen-Comoé (Région du)",
            "18 Montagnes (Région des)",
            "Lacs (Région des)",
            "Zanzan (Région du)",
            "Bas-Sassandra (Région du)",
            "Denguélé (Région du)",
            "Nzi-Comoé (Région)",
            "Marahoué (Région de la)",
            "Sud-Comoé (Région du)",
            "Worodouqou (Région du)",
            "Sud-Bandama (Région du)",
            "Agnébi (Région de l')",
            "Bafing (Région du)",
            "Fromager (Région du)",
            "Moyen-Cavally (Région du)"
        )
    }
    "Cook Islands" = @{
        "States" = @(
        )
    }
    "Chile" = @{
        "States" = @(
            "Aisén del General Carlos Ibáñez del Campo",
            "Antofagasta",
            "Arica y Parinacota",
            "Araucanía",
            "Atacama",
            "Bío-Bío",
            "Coquimbo",
            "Libertador General Bernardo O'Higgins",
            "Los Lagos",
            "Los Ríos",
            "Magallanes y Antártica Chilena",
            "Maule",
            "Región Metropolitana de Santiago",
            "Tarapacá",
            "Valparaíso"
        )
    }
    "Cameroon" = @{
        "States" = @(
            "Adamaoua",
            "Centre",
            "Far North",
            "East",
            "Littoral",
            "North",
            "North-West (Cameroon)",
            "West",
            "South",
            "South-West"
        )
    }
    "China" = @{
        "States" = @(
            "Beijing",
            "Tianjin",
            "Hebei",
            "Shanxi",
            "Nei Mongol",
            "Liaoning",
            "Jilin",
            "Heilongjiang",
            "Shanghai",
            "Jiangsu",
            "Zhejiang",
            "Anhui",
            "Fujian",
            "Jiangxi",
            "Shandong",
            "Henan",
            "Hubei",
            "Hunan",
            "Guangdong",
            "Guangxi",
            "Hainan",
            "Chongqing",
            "Sichuan",
            "Guizhou",
            "Yunnan",
            "Xizang",
            "Shaanxi",
            "Gansu",
            "Qinghai",
            "Ningxia",
            "Xinjiang",
            "Taiwan",
            "Xianggang (Hong-Kong)",
            "Aomen (Macau)"
        )
    }
    "Colombia" = @{
        "States" = @(
            "Amazonas",
            "Antioquia",
            "Arauca",
            "Atlántico",
            "Bolívar",
            "Boyacá",
            "Caldas",
            "Caquetá",
            "Casanare",
            "Cauca",
            "Cesar",
            "Chocó",
            "Córdoba",
            "Cundinamarca",
            "Distrito Capital de Bogotá",
            "Guainía",
            "Guaviare",
            "Huila",
            "La Guajira",
            "Magdalena",
            "Meta",
            "Nariño",
            "Norte de Santander",
            "Putumayo",
            "Quindío",
            "Risaralda",
            "Santander",
            "San Andrés, Providencia y Santa Catalina",
            "Sucre",
            "Tolima",
            "Valle del Cauca",
            "Vaupés",
            "Vichada"
        )
    }
    "Costa Rica" = @{
        "States" = @(
            "Alajuela",
            "Cartago",
            "Guanacaste",
            "Heredia",
            "Limón",
            "Puntarenas",
            "San José"
        )
    }
    "Cuba" = @{
        "States" = @(
            "Pinar del Rio",
            "La Habana",
            "Ciudad de La Habana",
            "Matanzas",
            "Villa Clara",
            "Cienfuegos",
            "Sancti Spíritus",
            "Ciego de Ávila",
            "Camagüey",
            "Las Tunas",
            "Holguín",
            "Granma",
            "Santiago de Cuba",
            "Guantánamo",
            "Isla de la Juventud"
        )
    }
    "Cape Verde" = @{
        "States" = @(
            "Ilhas de Barlavento",
            "Ilhas de Sotavento"
        )
    }
    "Curaçao" = @{
        "States" = @(
        )
    }
    "Christmas Island" = @{
        "States" = @(
        )
    }
    "Cyprus" = @{
        "States" = @(
            "Lefkosía",
            "Lemesós",
            "Lárnaka",
            "Ammóchostos",
            "Páfos",
            "Kerýneia"
        )
    }
    "Czech Republic" = @{
        "States" = @(
            "Jihočeský kraj",
            "Jihomoravský kraj",
            "Karlovarský kraj",
            "Královéhradecký kraj",
            "Liberecký kraj",
            "Moravskoslezský kraj",
            "Olomoucký kraj",
            "Pardubický kraj",
            "Plzeňský kraj",
            "Praha, hlavní město",
            "Středočeský kraj",
            "Ústecký kraj",
            "Vysočina",
            "Zlínský kraj"
        )
    }
    "Germany" = @{
        "States" = @(
            "Brandenburg",
            "Berlin",
            "Baden-Württemberg",
            "Bayern",
            "Bremen",
            "Hessen",
            "Hamburg",
            "Mecklenburg-Vorpommern",
            "Niedersachsen",
            "Nordrhein-Westfalen",
            "Rheinland-Pfalz",
            "Schleswig-Holstein",
            "Saarland",
            "Sachsen",
            "Sachsen-Anhalt",
            "Thüringen"
        )
    }
    "Djibouti" = @{
        "States" = @(
            "Arta",
            "Ali Sabieh",
            "Dikhil",
            "Djibouti",
            "Obock",
            "Tadjourah"
        )
    }
    "Denmark" = @{
        "States" = @(
            "Nordjylland",
            "Midtjylland",
            "Syddanmark",
            "Hovedstaden",
            "Sjælland"
        )
    }
    "Dominica" = @{
        "States" = @(
            "Saint Peter",
            "Saint Andrew",
            "Saint David",
            "Saint George",
            "Saint John",
            "Saint Joseph",
            "Saint Luke",
            "Saint Mark",
            "Saint Patrick",
            "Saint Paul"
        )
    }
    "Dominican Republic" = @{
        "States" = @(
            "Distrito Nacional (Santo Domingo)",
            "Azua",
            "Bahoruco",
            "Barahona",
            "Dajabón",
            "Duarte",
            "La Estrelleta [Elías Piña]",
            "El Seybo [El Seibo]",
            "Espaillat",
            "Independencia",
            "La Altagracia",
            "La Romana",
            "La Vega",
            "María Trinidad Sánchez",
            "Monte Cristi",
            "Pedernales",
            "Peravia",
            "Puerto Plata",
            "Salcedo",
            "Samaná",
            "San Cristóbal",
            "San Juan",
            "San Pedro de Macorís",
            "Sánchez Ramírez",
            "Santiago",
            "Santiago Rodríguez",
            "Valverde",
            "Monseñor Nouel",
            "Monte Plata",
            "Hato Mayor"
        )
    }
    "Algeria" = @{
        "States" = @(
            "Adrar",
            "Chlef",
            "Laghouat",
            "Oum el Bouaghi",
            "Batna",
            "Béjaïa",
            "Biskra",
            "Béchar",
            "Blida",
            "Bouira",
            "Tamanghasset",
            "Tébessa",
            "Tlemcen",
            "Tiaret",
            "Tizi Ouzou",
            "Alger",
            "Djelfa",
            "Jijel",
            "Sétif",
            "Saïda",
            "Skikda",
            "Sidi Bel Abbès",
            "Annaba",
            "Guelma",
            "Constantine",
            "Médéa",
            "Mostaganem",
            "Msila",
            "Mascara",
            "Ouargla",
            "Oran",
            "El Bayadh",
            "Illizi",
            "Bordj Bou Arréridj",
            "Boumerdès",
            "El Tarf",
            "Tindouf",
            "Tissemsilt",
            "El Oued",
            "Khenchela",
            "Souk Ahras",
            "Tipaza",
            "Mila",
            "Aïn Defla",
            "Naama",
            "Aïn Témouchent",
            "Ghardaïa",
            "Relizane"
        )
    }
    "Ecuador" = @{
        "States" = @(
            "Azuay",
            "Bolívar",
            "Carchi",
            "Orellana",
            "Esmeraldas",
            "Cañar",
            "Guayas",
            "Chimborazo",
            "Imbabura",
            "Loja",
            "Manabí",
            "Napo",
            "El Oro",
            "Pichincha",
            "Los Ríos",
            "Morona-Santiago",
            "Santo Domingo de los Tsáchilas",
            "Santa Elena",
            "Tungurahua",
            "Sucumbíos",
            "Galápagos",
            "Cotopaxi",
            "Pastaza",
            "Zamora-Chinchipe"
        )
    }
    "Estonia" = @{
        "States" = @(
            "Harjumaa",
            "Hiiumaa",
            "Ida-Virumaa",
            "Jõgevamaa",
            "Järvamaa",
            "Läänemaa",
            "Lääne-Virumaa",
            "Põlvamaa",
            "Pärnumaa",
            "Raplamaa",
            "Saaremaa",
            "Tartumaa",
            "Valgamaa",
            "Viljandimaa",
            "Võrumaa"
        )
    }
    "Egypt" = @{
        "States" = @(
            "Al Iskandarīyah",
            "Aswān",
            "Asyūt",
            "Al Bahr al Ahmar",
            "Al Buhayrah",
            "Banī Suwayf",
            "Al Qāhirah",
            "Ad Daqahlīyah",
            "Dumyāt",
            "Al Fayyūm",
            "Al Gharbīyah",
            "Al Jīzah",
            "Ḩulwān",
            "Al Ismā`īlīyah",
            "Janūb Sīnā'",
            "Al Qalyūbīyah",
            "Kafr ash Shaykh",
            "Qinā",
            "Al Minyā",
            "Al Minūfīyah",
            "Matrūh",
            "Būr Sa`īd",
            "Sūhāj",
            "Ash Sharqīyah",
            "Shamal Sīnā'",
            "As Sādis min Uktūbar",
            "As Suways",
            "Al Wādī al Jadīd"
        )
    }
    "Western Sahara" = @{
        "States" = @(
        )
    }
    "Eritrea" = @{
        "States" = @(
            "Ansabā",
            "Janūbī al Baḩrī al Aḩmar",
            "Al Janūbī",
            "Qāsh-Barkah",
            "Al Awsaţ",
            "Shimālī al Baḩrī al Aḩmar"
        )
    }
    "Spain" = @{
        "States" = @(
            "Andalucía",
            "Aragón",
            "Asturias, Principado de",
            "Cantabria",
            "Ceuta",
            "Castilla y León",
            "Castilla-La Mancha",
            "Canarias",
            "Catalunya",
            "Extremadura",
            "Galicia",
            "Illes Balears",
            "Murcia, Región de",
            "Madrid, Comunidad de",
            "Melilla",
            "Navarra, Comunidad Foral de / Nafarroako Foru Komunitatea",
            "País Vasco / Euskal Herria",
            "La Rioja",
            "Valenciana, Comunidad / Valenciana, Comunitat "
        )
    }
    "Ethiopia" = @{
        "States" = @(
            "Ādīs Ābeba",
            "Āfar",
            "Āmara",
            "Bīnshangul Gumuz",
            "Dirē Dawa",
            "Gambēla Hizboch",
            "Hārerī Hizb",
            "Oromīya",
            "YeDebub Bihēroch Bihēreseboch na Hizboch",
            "Sumalē",
            "Tigray"
        )
    }
    "Finland" = @{
        "States" = @(
            "Ahvenanmaan maakunta",
            "Etelä-Karjala",
            "Etelä-Pohjanmaa",
            "Etelä-Savo",
            "Kainuu",
            "Kanta-Häme",
            "Keski-Pohjanmaa",
            "Keski-Suomi",
            "Kymenlaakso",
            "Lappi",
            "Pirkanmaa",
            "Pohjanmaa",
            "Pohjois-Karjala",
            "Pohjois-Pohjanmaa",
            "Pohjois-Savo",
            "Päijät-Häme",
            "Satakunta",
            "Uusimaa",
            "Varsinais-Suomi"
        )
    }
    "Fiji" = @{
        "States" = @(
            "Central",
            "Eastern",
            "Northern",
            "Rotuma",
            "Western"
        )
    }
    "Falkland Islands (Malvinas)" = @{
        "States" = @(
        )
    }
    "Micronesia, Federated States of" = @{
        "States" = @(
            "Kosrae",
            "Pohnpei",
            "Chuuk",
            "Yap"
        )
    }
    "Faroe Islands" = @{
        "States" = @(
        )
    }
    "France" = @{
        "States" = @(
            "Alsace",
            "Aquitaine",
            "Saint-Barthélemy",
            "Auvergne",
            "Clipperton",
            "Bourgogne",
            "Bretagne",
            "Centre",
            "Champagne-Ardenne",
            "Guyane",
            "Guadeloupe",
            "Corse",
            "Franche-Comté",
            "Île-de-France",
            "Languedoc-Roussillon",
            "Limousin",
            "Lorraine",
            "Saint-Martin",
            "Martinique",
            "Midi-Pyrénées",
            "Nouvelle-Calédonie",
            "Nord-Pas-de-Calais",
            "Basse-Normandie",
            "Polynésie française",
            "Saint-Pierre-et-Miquelon",
            "Haute-Normandie",
            "Pays de la Loire",
            "La Réunion",
            "Picardie",
            "Poitou-Charentes",
            "Terres australes françaises",
            "Provence-Alpes-Côte d'Azur",
            "Rhône-Alpes",
            "Wallis-et-Futuna",
            "Mayotte"
        )
    }
    "Gabon" = @{
        "States" = @(
            "Estuaire",
            "Haut-Ogooué",
            "Moyen-Ogooué",
            "Ngounié",
            "Nyanga",
            "Ogooué-Ivindo",
            "Ogooué-Lolo",
            "Ogooué-Maritime",
            "Woleu-Ntem"
        )
    }
    "United Kingdom" = @{
        "States" = @(
            "Aberdeenshire",
            "Aberdeen City",
            "Argyll and Bute",
            "Isle of Anglesey;Sir Ynys Môn",
            "Angus",
            "Antrim",
            "Ards",
            "Armagh",
            "Bath and North East Somerset",
            "Blackburn with Darwen",
            "Bedford",
            "Barking and Dagenham",
            "Brent",
            "Bexley",
            "Belfast",
            "Bridgend;Pen-y-bont ar Ogwr",
            "Blaenau Gwent",
            "Birmingham",
            "Buckinghamshire",
            "Ballymena",
            "Ballymoney",
            "Bournemouth",
            "Banbridge",
            "Barnet",
            "Brighton and Hove",
            "Barnsley",
            "Bolton",
            "Blackpool",
            "Bracknell Forest",
            "Bradford",
            "Bromley",
            "Bristol, City of",
            "Bury",
            "Cambridgeshire",
            "Caerphilly;Caerffili",
            "Central Bedfordshire",
            "Ceredigion;Sir Ceredigion",
            "Craigavon",
            "Cheshire East",
            "Cheshire West and Chester",
            "Carrickfergus",
            "Cookstown",
            "Calderdale",
            "Clackmannanshire",
            "Coleraine",
            "Cumbria",
            "Camden",
            "Carmarthenshire;Sir Gaerfyrddin",
            "Cornwall",
            "Coventry",
            "Cardiff;Caerdydd",
            "Croydon",
            "Castlereagh",
            "Conwy",
            "Darlington",
            "Derbyshire",
            "Denbighshire;Sir Ddinbych",
            "Derby",
            "Devon",
            "Dungannon and South Tyrone",
            "Dumfries and Galloway",
            "Doncaster",
            "Dundee City",
            "Dorset",
            "Down",
            "Derry",
            "Dudley",
            "Durham, County",
            "Ealing",
            "England and Wales",
            "East Ayrshire",
            "Edinburgh, City of",
            "East Dunbartonshire",
            "East Lothian",
            "Eilean Siar",
            "Enfield",
            "England",
            "East Renfrewshire",
            "East Riding of Yorkshire",
            "Essex",
            "East Sussex",
            "Falkirk",
            "Fermanagh",
            "Fife",
            "Flintshire;Sir y Fflint",
            "Gateshead",
            "Great Britain",
            "Glasgow City",
            "Gloucestershire",
            "Greenwich",
            "Gwynedd",
            "Halton",
            "Hampshire",
            "Havering",
            "Hackney",
            "Herefordshire",
            "Hillingdon",
            "Highland",
            "Hammersmith and Fulham",
            "Hounslow",
            "Hartlepool",
            "Hertfordshire",
            "Harrow",
            "Haringey",
            "Isle of Wight",
            "Islington",
            "Inverclyde",
            "Kensington and Chelsea",
            "Kent",
            "Kingston upon Hull",
            "Kirklees",
            "Kingston upon Thames",
            "Knowsley",
            "Lancashire",
            "Lambeth",
            "Leicester",
            "Leeds",
            "Leicestershire",
            "Lewisham",
            "Lincolnshire",
            "Liverpool",
            "Limavady",
            "London, City of",
            "Larne",
            "Lisburn",
            "Luton",
            "Manchester",
            "Middlesbrough",
            "Medway",
            "Magherafelt",
            "Milton Keynes",
            "Midlothian",
            "Monmouthshire;Sir Fynwy",
            "Merton",
            "Moray",
            "Merthyr Tydfil;Merthyr Tudful",
            "Moyle",
            "North Ayrshire",
            "Northumberland",
            "North Down",
            "North East Lincolnshire",
            "Newcastle upon Tyne",
            "Norfolk",
            "Nottingham",
            "Northern Ireland",
            "North Lanarkshire",
            "North Lincolnshire",
            "North Somerset",
            "Newtownabbey",
            "Northamptonshire",
            "Neath Port Talbot;Castell-nedd Port Talbot",
            "Nottinghamshire",
            "North Tyneside",
            "Newham",
            "Newport;Casnewydd",
            "North Yorkshire",
            "Newry and Mourne",
            "Oldham",
            "Omagh",
            "Orkney Islands",
            "Oxfordshire",
            "Pembrokeshire;Sir Benfro",
            "Perth and Kinross",
            "Plymouth",
            "Poole",
            "Portsmouth",
            "Powys",
            "Peterborough",
            "Redcar and Cleveland",
            "Rochdale",
            "Rhondda, Cynon, Taff;Rhondda, Cynon,Taf",
            "Redbridge",
            "Reading",
            "Renfrewshire",
            "Richmond upon Thames",
            "Rotherham",
            "Rutland",
            "Sandwell",
            "South Ayrshire",
            "Scottish Borders, The",
            "Scotland",
            "Suffolk",
            "Sefton",
            "South Gloucestershire",
            "Sheffield",
            "St. Helens",
            "Shropshire",
            "Stockport",
            "Salford",
            "Slough",
            "South Lanarkshire",
            "Sunderland",
            "Solihull",
            "Somerset",
            "Southend-on-Sea",
            "Surrey",
            "Strabane",
            "Stoke-on-Trent",
            "Stirling",
            "Southampton",
            "Sutton",
            "Staffordshire",
            "Stockton-on-Tees",
            "South Tyneside",
            "Swansea;Abertawe",
            "Swindon",
            "Southwark",
            "Tameside",
            "Telford and Wrekin",
            "Thurrock",
            "Torbay",
            "Torfaen;Tor-faen",
            "Trafford",
            "Tower Hamlets",
            "United Kingdom",
            "Vale of Glamorgan, The;Bro Morgannwg",
            "Warwickshire",
            "West Berkshire",
            "West Dunbartonshire",
            "Waltham Forest",
            "Wigan",
            "Wakefield",
            "Walsall",
            "West Lothian",
            "Wales",
            "Wolverhampton",
            "Wandsworth",
            "Windsor and Maidenhead",
            "Wokingham",
            "Worcestershire",
            "Wirral",
            "Warrington",
            "Wrexham;Wrecsam",
            "Westminster",
            "West Sussex",
            "York",
            "Shetland Islands",
            "Wiltshire"
        )
    }
    "Grenada" = @{
        "States" = @(
            "Saint Andrew",
            "Saint David",
            "Saint George",
            "Saint John",
            "Saint Mark",
            "Saint Patrick",
            "Southern Grenadine Islands"
        )
    }
    "Georgia" = @{
        "States" = @(
            "Abkhazia",
            "Ajaria",
            "Guria",
            "Imeret’i",
            "Kakhet’i",
            "K’vemo K’art’li",
            "Mts’khet’a-Mt’ianet’i",
            "Racha-Lech’khumi-K’vemo Svanet’i",
            "Samts’khe-Javakhet’i",
            "Shida K’art’li",
            "Samegrelo-Zemo Svanet’i",
            "T’bilisi"
        )
    }
    "French Guiana" = @{
        "States" = @(
        )
    }
    "Guernsey" = @{
        "States" = @(
        )
    }
    "Ghana" = @{
        "States" = @(
            "Greater Accra",
            "Ashanti",
            "Brong-Ahafo",
            "Central",
            "Eastern",
            "Northern",
            "Volta",
            "Upper East",
            "Upper West",
            "Western"
        )
    }
    "Gibraltar" = @{
        "States" = @(
        )
    }
    "Greenland" = @{
        "States" = @(
            "Kommune Kujalleq",
            "Qaasuitsup Kommunia",
            "Qeqqata Kommunia",
            "Kommuneqarfik Sermersooq"
        )
    }
    "Gambia" = @{
        "States" = @(
            "Banjul",
            "Lower River",
            "Central River",
            "North Bank",
            "Upper River",
            "Western"
        )
    }
    "Guinea" = @{
        "States" = @(
            "Boké",
            "Conakry",
            "Kindia",
            "Faranah",
            "Kankan",
            "Labé",
            "Mamou",
            "Nzérékoré"
        )
    }
    "Guadeloupe" = @{
        "States" = @(
        )
    }
    "Equatorial Guinea" = @{
        "States" = @(
            "Región Continental",
            "Región Insular"
        )
    }
    "Greece" = @{
        "States" = @(
            "Agio Oros",
            "Anatoliki Makedonia kai Thraki",
            "Kentriki Makedonia",
            "Dytiki Makedonia",
            "Ipeiros",
            "Thessalia",
            "Ionia Nisia",
            "Dytiki Ellada",
            "Sterea Ellada",
            "Attiki",
            "Peloponnisos",
            "Voreio Aigaio",
            "Notio Aigaio",
            "Kriti"
        )
    }
    "South Georgia and the South Sandwich Islands" = @{
        "States" = @(
        )
    }
    "Guatemala" = @{
        "States" = @(
            "Alta Verapaz",
            "Baja Verapaz",
            "Chimaltenango",
            "Chiquimula",
            "Escuintla",
            "Guatemala",
            "Huehuetenango",
            "Izabal",
            "Jalapa",
            "Jutiapa",
            "Petén",
            "El Progreso",
            "Quiché",
            "Quetzaltenango",
            "Retalhuleu",
            "Sacatepéquez",
            "San Marcos",
            "Sololá",
            "Santa Rosa",
            "Suchitepéquez",
            "Totonicapán",
            "Zacapa"
        )
    }
    "Guam" = @{
        "States" = @(
        )
    }
    "Guinea-Bissau" = @{
        "States" = @(
            "Bissau",
            "Leste",
            "Norte",
            "Sul"
        )
    }
    "Guyana" = @{
        "States" = @(
            "Barima-Waini",
            "Cuyuni-Mazaruni",
            "Demerara-Mahaica",
            "East Berbice-Corentyne",
            "Essequibo Islands-West Demerara",
            "Mahaica-Berbice",
            "Pomeroon-Supenaam",
            "Potaro-Siparuni",
            "Upper Demerara-Berbice",
            "Upper Takutu-Upper Essequibo"
        )
    }
    "Hong Kong" = @{
        "States" = @(
        )
    }
    "Heard Island and McDonald Islands" = @{
        "States" = @(
        )
    }
    "Honduras" = @{
        "States" = @(
            "Atlántida",
            "Choluteca",
            "Colón",
            "Comayagua",
            "Copán",
            "Cortés",
            "El Paraíso",
            "Francisco Morazán",
            "Gracias a Dios",
            "Islas de la Bahía",
            "Intibucá",
            "Lempira",
            "La Paz",
            "Ocotepeque",
            "Olancho",
            "Santa Bárbara",
            "Valle",
            "Yoro"
        )
    }
    "Croatia" = @{
        "States" = @(
            "Zagrebačka županija",
            "Krapinsko-zagorska županija",
            "Sisačko-moslavačka županija",
            "Karlovačka županija",
            "Varaždinska županija",
            "Koprivničko-križevačka županija",
            "Bjelovarsko-bilogorska županija",
            "Primorsko-goranska županija",
            "Ličko-senjska županija",
            "Virovitičko-podravska županija",
            "Požeško-slavonska županija",
            "Brodsko-posavska županija",
            "Zadarska županija",
            "Osječko-baranjska županija",
            "Šibensko-kninska županija",
            "Vukovarsko-srijemska županija",
            "Splitsko-dalmatinska županija",
            "Istarska županija",
            "Dubrovačko-neretvanska županija",
            "Međimurska županija",
            "Grad Zagreb"
        )
    }
    "Haiti" = @{
        "States" = @(
            "Artibonite",
            "Centre",
            "Grande-Anse",
            "Nord",
            "Nord-Est",
            "Nord-Ouest",
            "Ouest",
            "Sud",
            "Sud-Est"
        )
    }
    "Hungary" = @{
        "States" = @(
            "Baranya",
            "Békéscsaba",
            "Békés",
            "Bács-Kiskun",
            "Budapest",
            "Borsod-Abaúj-Zemplén",
            "Csongrád",
            "Debrecen",
            "Dunaújváros",
            "Eger",
            "Érd",
            "Fejér",
            "Győr-Moson-Sopron",
            "Győr",
            "Hajdú-Bihar",
            "Heves",
            "Hódmezővásárhely",
            "Jász-Nagykun-Szolnok",
            "Komárom-Esztergom",
            "Kecskemét",
            "Kaposvár",
            "Miskolc",
            "Nagykanizsa",
            "Nógrád",
            "Nyíregyháza",
            "Pest",
            "Pécs",
            "Szeged",
            "Székesfehérvár",
            "Szombathely",
            "Szolnok",
            "Sopron",
            "Somogy",
            "Szekszárd",
            "Salgótarján",
            "Szabolcs-Szatmár-Bereg",
            "Tatabánya",
            "Tolna",
            "Vas",
            "Veszprém (county)",
            "Veszprém",
            "Zala",
            "Zalaegerszeg"
        )
    }
    "Indonesia" = @{
        "States" = @(
            "Papua",
            "Jawa",
            "Kalimantan",
            "Maluku",
            "Nusa Tenggara",
            "Sulawesi",
            "Sumatera"
        )
    }
    "Ireland" = @{
        "States" = @(
            "Connacht",
            "Leinster",
            "Munster",
            "Ulster"
        )
    }
    "Israel" = @{
        "States" = @(
            "HaDarom",
            "Hefa",
            "Yerushalayim Al Quds",
            "HaMerkaz",
            "Tel-Aviv",
            "HaZafon"
        )
    }
    "Isle of Man" = @{
        "States" = @(
        )
    }
    "India" = @{
        "States" = @(
            "Andaman and Nicobar Islands",
            "Andhra Pradesh",
            "Arunachal Pradesh",
            "Assam",
            "Bihar",
            "Chandigarh",
            "Chhattisgarh",
            "Damen and Diu",
            "Delhi",
            "Dadra and Nagar Haveli",
            "Goa",
            "Gujarat",
            "Himachal Pradesh",
            "Haryana",
            "Jharkhand",
            "Jammu and Kashmir",
            "Karnataka",
            "Kerala",
            "Lakshadweep",
            "Maharashtra",
            "Meghalaya",
            "Manipur",
            "Madhya Pradesh",
            "Mizoram",
            "Nagaland",
            "Orissa",
            "Punjab",
            "Puducherry",
            "Rajasthan",
            "Sikkim",
            "Tamil Nadu",
            "Tripura",
            "Uttar Pradesh",
            "Uttarakhand",
            "West Bengal"
        )
    }
    "British Indian Ocean Territory" = @{
        "States" = @(
        )
    }
    "Iraq" = @{
        "States" = @(
            "Al Anbar",
            "Arbil",
            "Al Basrah",
            "Babil",
            "Baghdad",
            "Dahuk",
            "Diyala",
            "Dhi Qar",
            "Karbala'",
            "Maysan",
            "Al Muthanna",
            "An Najef",
            "Ninawa",
            "Al Qadisiyah",
            "Salah ad Din",
            "As Sulaymaniyah",
            "At Ta'mim",
            "Wasit"
        )
    }
    "Iran, Islamic Republic of" = @{
        "States" = @(
            "Āzarbāyjān-e Sharqī",
            "Āzarbāyjān-e Gharbī",
            "Ardabīl",
            "Eşfahān",
            "Īlām",
            "Būshehr",
            "Tehrān",
            "Chahār Mahāll va Bakhtīārī",
            "Khūzestān",
            "Zanjān",
            "Semnān",
            "Sīstān va Balūchestān",
            "Fārs",
            "Kermān",
            "Kordestān",
            "Kermānshāh",
            "Kohgīlūyeh va Būyer Ahmad",
            "Gīlān",
            "Lorestān",
            "Māzandarān",
            "Markazī",
            "Hormozgān",
            "Hamadān",
            "Yazd",
            "Qom",
            "Golestān",
            "Qazvīn",
            "Khorāsān-e Janūbī",
            "Khorāsān-e Razavī",
            "Khorāsān-e Shemālī"
        )
    }
    "Iceland" = @{
        "States" = @(
            "Reykjavík",
            "Höfuðborgarsvæðið",
            "Suðurnes",
            "Vesturland",
            "Vestfirðir",
            "Norðurland vestra",
            "Norðurland eystra",
            "Austurland",
            "Suðurland"
        )
    }
    "Italy" = @{
        "States" = @(
            "Piemonte",
            "Valle d'Aosta",
            "Lombardia",
            "Trentino-Alto Adige",
            "Veneto",
            "Friuli-Venezia Giulia",
            "Liguria",
            "Emilia-Romagna",
            "Toscana",
            "Umbria",
            "Marche",
            "Lazio",
            "Abruzzo",
            "Molise",
            "Campania",
            "Puglia",
            "Basilicata",
            "Calabria",
            "Sicilia",
            "Sardegna"
        )
    }
    "Jersey" = @{
        "States" = @(
        )
    }
    "Jamaica" = @{
        "States" = @(
            "Kingston",
            "Saint Andrew",
            "Saint Thomas",
            "Portland",
            "Saint Mary",
            "Saint Ann",
            "Trelawny",
            "Saint James",
            "Hanover",
            "Westmoreland",
            "Saint Elizabeth",
            "Manchester",
            "Clarendon",
            "Saint Catherine"
        )
    }
    "Jordan" = @{
        "States" = @(
            "‘Ajlūn",
            "‘Ammān (Al ‘Aşimah)",
            "Al ‘Aqabah",
            "Aţ Ţafīlah",
            "Az Zarqā'",
            "Al Balqā'",
            "Irbid",
            "Jarash",
            "Al Karak",
            "Al Mafraq",
            "Mādabā",
            "Ma‘ān"
        )
    }
    "Japan" = @{
        "States" = @(
            "Hokkaido",
            "Aomori",
            "Iwate",
            "Miyagi",
            "Akita",
            "Yamagata",
            "Fukushima",
            "Ibaraki",
            "Tochigi",
            "Gunma",
            "Saitama",
            "Chiba",
            "Tokyo",
            "Kanagawa",
            "Niigata",
            "Toyama",
            "Ishikawa",
            "Fukui",
            "Yamanashi",
            "Nagano",
            "Gifu",
            "Shizuoka",
            "Aichi",
            "Mie",
            "Shiga",
            "Kyoto",
            "Osaka",
            "Hyogo",
            "Nara",
            "Wakayama",
            "Tottori",
            "Shimane",
            "Okayama",
            "Hiroshima",
            "Yamaguchi",
            "Tokushima",
            "Kagawa",
            "Ehime",
            "Kochi",
            "Fukuoka",
            "Saga",
            "Nagasaki",
            "Kumamoto",
            "Oita",
            "Miyazaki",
            "Kagoshima",
            "Okinawa"
        )
    }
    "Kenya" = @{
        "States" = @(
            "Nairobi Municipality",
            "Central",
            "Coast",
            "Eastern",
            "North-Eastern Kaskazini Mashariki",
            "Rift Valley",
            "Western Magharibi"
        )
    }
    "Kyrgyzstan" = @{
        "States" = @(
            "Batken",
            "Chü",
            "Bishkek",
            "Jalal-Abad",
            "Naryn",
            "Osh",
            "Talas",
            "Ysyk-Köl"
        )
    }
    "Cambodia" = @{
        "States" = @(
            "Banteay Mean Chey",
            "Krachoh",
            "Mondol Kiri",
            "Phnom Penh",
            "Preah Vihear",
            "Prey Veaeng",
            "Pousaat",
            "Rotanak Kiri",
            "Siem Reab",
            "Krong Preah Sihanouk",
            "Stueng Traeng",
            "Battambang",
            "Svaay Rieng",
            "Taakaev",
            "Otdar Mean Chey",
            "Krong Kaeb",
            "Krong Pailin",
            "Kampong Cham",
            "Kampong Chhnang",
            "Kampong Speu",
            "Kampong Thom",
            "Kampot",
            "Kandal",
            "Kach Kong"
        )
    }
    "Kiribati" = @{
        "States" = @(
            "Gilbert Islands",
            "Line Islands",
            "Phoenix Islands"
        )
    }
    "Comoros" = @{
        "States" = @(
            "Andjouân (Anjwān)",
            "Andjazîdja (Anjazījah)",
            "Moûhîlî (Mūhīlī)"
        )
    }
    "Saint Kitts and Nevis" = @{
        "States" = @(
            "Saint Kitts",
            "Nevis"
        )
    }
    "Korea, Democratic People's Republic of" = @{
        "States" = @(
            "P’yŏngyang",
            "P’yŏngan-namdo",
            "P’yŏngan-bukto",
            "Chagang-do",
            "Hwanghae-namdo",
            "Hwanghae-bukto",
            "Kangwŏn-do",
            "Hamgyŏng-namdo",
            "Hamgyŏng-bukto",
            "Yanggang-do",
            "Nasŏn (Najin-Sŏnbong)"
        )
    }
    "Korea, Republic of" = @{
        "States" = @(
            "Seoul Teugbyeolsi",
            "Busan Gwang'yeogsi",
            "Daegu Gwang'yeogsi",
            "Incheon Gwang'yeogsi",
            "Gwangju Gwang'yeogsi",
            "Daejeon Gwang'yeogsi",
            "Ulsan Gwang'yeogsi",
            "Gyeonggido",
            "Gang'weondo",
            "Chungcheongbukdo",
            "Chungcheongnamdo",
            "Jeonrabukdo",
            "Jeonranamdo",
            "Gyeongsangbukdo",
            "Gyeongsangnamdo",
            "Jejudo"
        )
    }
    "Kuwait" = @{
        "States" = @(
            "Al Ahmadi",
            "Al Farwānīyah",
            "Hawallī",
            "Al Jahrrā’",
            "Al Kuwayt (Al ‘Āşimah)",
            "Mubārak al Kabīr"
        )
    }
    "Cayman Islands" = @{
        "States" = @(
        )
    }
    "Kazakhstan" = @{
        "States" = @(
            "Aqmola oblysy",
            "Aqtöbe oblysy",
            "Almaty",
            "Almaty oblysy",
            "Astana",
            "Atyraū oblysy",
            "Qaraghandy oblysy",
            "Qostanay oblysy",
            "Qyzylorda oblysy",
            "Mangghystaū oblysy",
            "Pavlodar oblysy",
            "Soltüstik Quzaqstan oblysy",
            "Shyghys Qazaqstan oblysy",
            "Ongtüstik Qazaqstan oblysy",
            "Batys Quzaqstan oblysy",
            "Zhambyl oblysy"
        )
    }
    "Lao People's Democratic Republic" = @{
        "States" = @(
            "Attapu",
            "Bokèo",
            "Bolikhamxai",
            "Champasak",
            "Houaphan",
            "Khammouan",
            "Louang Namtha",
            "Louangphabang",
            "Oudômxai",
            "Phôngsali",
            "Salavan",
            "Savannakhét",
            "Vientiane",
            "Xaignabouli",
            "Xékong",
            "Xiangkhoang",
            "Xiasômboun"
        )
    }
    "Lebanon" = @{
        "States" = @(
            "Aakkâr",
            "Liban-Nord",
            "Beyrouth",
            "Baalbek-Hermel",
            "Béqaa",
            "Liban-Sud",
            "Mont-Liban",
            "Nabatîyé"
        )
    }
    "Saint Lucia" = @{
        "States" = @(
        )
    }
    "Liechtenstein" = @{
        "States" = @(
            "Balzers",
            "Eschen",
            "Gamprin",
            "Mauren",
            "Planken",
            "Ruggell",
            "Schaan",
            "Schellenberg",
            "Triesen",
            "Triesenberg",
            "Vaduz"
        )
    }
    "Sri Lanka" = @{
        "States" = @(
            "Basnāhira paḷāta",
            "Madhyama paḷāta",
            "Dakuṇu paḷāta",
            "Uturu paḷāta",
            "Næ̆gĕnahira paḷāta",
            "Vayamba paḷāta",
            "Uturumæ̆da paḷāta",
            "Ūva paḷāta",
            "Sabaragamuva paḷāta"
        )
    }
    "Liberia" = @{
        "States" = @(
            "Bong",
            "Bomi",
            "Grand Cape Mount",
            "Grand Bassa",
            "Grand Gedeh",
            "Grand Kru",
            "Lofa",
            "Margibi",
            "Montserrado",
            "Maryland",
            "Nimba",
            "Rivercess",
            "Sinoe"
        )
    }
    "Lesotho" = @{
        "States" = @(
            "Maseru",
            "Butha-Buthe",
            "Leribe",
            "Berea",
            "Mafeteng",
            "Mohale's Hoek",
            "Quthing",
            "Qacha's Nek",
            "Mokhotlong",
            "Thaba-Tseka"
        )
    }
    "Lithuania" = @{
        "States" = @(
            "Alytaus Apskritis",
            "Klaipėdos Apskritis",
            "Kauno Apskritis",
            "Marijampolės Apskritis",
            "Panevėžio Apskritis",
            "Šiaulių Apskritis",
            "Tauragés Apskritis",
            "Telšių Apskritis",
            "Utenos Apskritis",
            "Vilniaus Apskritis"
        )
    }
    "Luxembourg" = @{
        "States" = @(
            "Diekirch",
            "Grevenmacher",
            "Luxembourg"
        )
    }
    "Latvia" = @{
        "States" = @(
            "Aglonas novads",
            "Aizkraukles novads",
            "Aizputes novads",
            "Aknīstes novads",
            "Alojas novads",
            "Alsungas novads",
            "Alūksnes novads",
            "Amatas novads",
            "Apes novads",
            "Auces novads",
            "Ādažu novads",
            "Babītes novads",
            "Baldones novads",
            "Baltinavas novads",
            "Balvu novads",
            "Bauskas novads",
            "Beverīnas novads",
            "Brocēnu novads",
            "Burtnieku novads",
            "Carnikavas novads",
            "Cesvaines novads",
            "Cēsu novads",
            "Ciblas novads",
            "Dagdas novads",
            "Daugavpils novads",
            "Dobeles novads",
            "Dundagas novads",
            "Durbes novads",
            "Engures novads",
            "Ērgļu novads",
            "Garkalnes novads",
            "Grobiņas novads",
            "Gulbenes novads",
            "Iecavas novads",
            "Ikšķiles novads",
            "Ilūkstes novads",
            "Inčukalna novads",
            "Jaunjelgavas novads",
            "Jaunpiebalgas novads",
            "Jaunpils novads",
            "Jelgavas novads",
            "Jēkabpils novads",
            "Kandavas novads",
            "Kārsavas novads",
            "Kocēnu novads",
            "Kokneses novads",
            "Krāslavas novads",
            "Krimuldas novads",
            "Krustpils novads",
            "Kuldīgas novads",
            "Ķeguma novads",
            "Ķekavas novads",
            "Lielvārdes novads",
            "Limbažu novads",
            "Līgatnes novads",
            "Līvānu novads",
            "Lubānas novads",
            "Ludzas novads",
            "Madonas novads",
            "Mazsalacas novads",
            "Mālpils novads",
            "Mārupes novads",
            "Mērsraga novads",
            "Naukšēnu novads",
            "Neretas novads",
            "Nīcas novads",
            "Ogres novads",
            "Olaines novads",
            "Ozolnieku novads",
            "Pārgaujas novads",
            "Pāvilostas novads",
            "Pļaviņu novads",
            "Preiļu novads",
            "Priekules novads",
            "Priekuļu novads",
            "Raunas novads",
            "Rēzeknes novads",
            "Riebiņu novads",
            "Rojas novads",
            "Ropažu novads",
            "Rucavas novads",
            "Rugāju novads",
            "Rundāles novads",
            "Rūjienas novads",
            "Salas novads",
            "Salacgrīvas novads",
            "Salaspils novads",
            "Saldus novads",
            "Saulkrastu novads",
            "Sējas novads",
            "Siguldas novads",
            "Skrīveru novads",
            "Skrundas novads",
            "Smiltenes novads",
            "Stopiņu novads",
            "Strenču novads",
            "Talsu novads",
            "Tērvetes novads",
            "Tukuma novads",
            "Vaiņodes novads",
            "Valkas novads",
            "Varakļānu novads",
            "Vārkavas novads",
            "Vecpiebalgas novads",
            "Vecumnieku novads",
            "Ventspils novads",
            "Viesītes novads",
            "Viļakas novads",
            "Viļānu novads",
            "Zilupes novads",
            "Daugavpils",
            "Jelgava",
            "Jēkabpils",
            "Jūrmala",
            "Liepāja",
            "Rēzekne",
            "Rīga",
            "Ventspils",
            "Valmiera"
        )
    }
    "Libya" = @{
        "States" = @(
            "Banghāzī",
            "Al Buţnān",
            "Darnah",
            "Ghāt",
            "Al Jabal al Akhḑar",
            "Jaghbūb",
            "Al Jabal al Gharbī",
            "Al Jifārah",
            "Al Jufrah",
            "Al Kufrah",
            "Al Marqab",
            "Mişrātah",
            "Al Marj",
            "Murzuq",
            "Nālūt",
            "An Nuqaţ al Khams",
            "Sabhā",
            "Surt",
            "Ţarābulus",
            "Al Wāḩāt",
            "Wādī al Ḩayāt",
            "Wādī ash Shāţiʾ",
            "Az Zāwiyah"
        )
    }
    "Morocco" = @{
        "States" = @(
            "Tanger-Tétouan",
            "Gharb-Chrarda-Beni Hssen",
            "Taza-Al Hoceima-Taounate",
            "L'Oriental",
            "Fès-Boulemane",
            "Meknès-Tafilalet",
            "Rabat-Salé-Zemmour-Zaer",
            "Grand Casablanca",
            "Chaouia-Ouardigha",
            "Doukhala-Abda",
            "Marrakech-Tensift-Al Haouz",
            "Tadla-Azilal",
            "Sous-Massa-Draa",
            "Guelmim-Es Smara",
            "Laâyoune-Boujdour-Sakia el Hamra",
            "Oued ed Dahab-Lagouira"
        )
    }
    "Monaco" = @{
        "States" = @(
            "La Colle",
            "La Condamine",
            "Fontvieille",
            "La Gare",
            "Jardin Exotique",
            "Larvotto",
            "Malbousquet",
            "Monte-Carlo",
            "Moneghetti",
            "Monaco-Ville",
            "Moulins",
            "Port-Hercule",
            "Sainte-Dévote",
            "La Source",
            "Spélugues",
            "Saint-Roman",
            "Vallon de la Rousse"
        )
    }
    "Moldova, Republic of" = @{
        "States" = @(
            "Anenii Noi",
            "Bălți",
            "Tighina",
            "Briceni",
            "Basarabeasca",
            "Cahul",
            "Călărași",
            "Cimișlia",
            "Criuleni",
            "Căușeni",
            "Cantemir",
            "Chișinău",
            "Dondușeni",
            "Drochia",
            "Dubăsari",
            "Edineț",
            "Fălești",
            "Florești",
            "Găgăuzia, Unitatea teritorială autonomă",
            "Glodeni",
            "Hîncești",
            "Ialoveni",
            "Leova",
            "Nisporeni",
            "Ocnița",
            "Orhei",
            "Rezina",
            "Rîșcani",
            "Șoldănești",
            "Sîngerei",
            "Stînga Nistrului, unitatea teritorială din",
            "Soroca",
            "Strășeni",
            "Ștefan Vodă",
            "Taraclia",
            "Telenești",
            "Ungheni"
        )
    }
    "Montenegro" = @{
        "States" = @(
            "Andrijevica",
            "Bar",
            "Berane",
            "Bijelo Polje",
            "Budva",
            "Cetinje",
            "Danilovgrad",
            "Herceg-Novi",
            "Kolašin",
            "Kotor",
            "Mojkovac",
            "Nikšić",
            "Plav",
            "Pljevlja",
            "Plužine",
            "Podgorica",
            "Rožaje",
            "Šavnik",
            "Tivat",
            "Ulcinj",
            "Žabljak"
        )
    }
    "Saint Martin (French part)" = @{
        "States" = @(
        )
    }
    "Madagascar" = @{
        "States" = @(
            "Toamasina",
            "Antsiranana",
            "Fianarantsoa",
            "Mahajanga",
            "Antananarivo",
            "Toliara"
        )
    }
    "Marshall Islands" = @{
        "States" = @(
            "Ralik chain",
            "Ratak chain"
        )
    }
    "Macedonia, Republic of" = @{
        "States" = @(
            "Aerodrom",
            "Aračinovo",
            "Berovo",
            "Bitola",
            "Bogdanci",
            "Bogovinje",
            "Bosilovo",
            "Brvenica",
            "Butel",
            "Valandovo",
            "Vasilevo",
            "Vevčani",
            "Veles",
            "Vinica",
            "Vraneštica",
            "Vrapčište",
            "Gazi Baba",
            "Gevgelija",
            "Gostivar",
            "Gradsko",
            "Debar",
            "Debarca",
            "Delčevo",
            "Demir Kapija",
            "Demir Hisar",
            "Dojran",
            "Dolneni",
            "Drugovo",
            "Gjorče Petrov",
            "Želino",
            "Zajas",
            "Zelenikovo",
            "Zrnovci",
            "Ilinden",
            "Jegunovce",
            "Kavadarci",
            "Karbinci",
            "Karpoš",
            "Kisela Voda",
            "Kičevo",
            "Konče",
            "Kočani",
            "Kratovo",
            "Kriva Palanka",
            "Krivogaštani",
            "Kruševo",
            "Kumanovo",
            "Lipkovo",
            "Lozovo",
            "Mavrovo-i-Rostuša",
            "Makedonska Kamenica",
            "Makedonski Brod",
            "Mogila",
            "Negotino",
            "Novaci",
            "Novo Selo",
            "Oslomej",
            "Ohrid",
            "Petrovec",
            "Pehčevo",
            "Plasnica",
            "Prilep",
            "Probištip",
            "Radoviš",
            "Rankovce",
            "Resen",
            "Rosoman",
            "Saraj",
            "Sveti Nikole",
            "Sopište",
            "Staro Nagoričane",
            "Struga",
            "Strumica",
            "Studeničani",
            "Tearce",
            "Tetovo",
            "Centar",
            "Centar Župa",
            "Čair",
            "Čaška",
            "Češinovo-Obleševo",
            "Čučer Sandevo",
            "Štip",
            "Šuto Orizari"
        )
    }
    "Mali" = @{
        "States" = @(
            "Kayes",
            "Koulikoro",
            "Sikasso",
            "Ségou",
            "Mopti",
            "Tombouctou",
            "Gao",
            "Kidal",
            "Bamako"
        )
    }
    "Myanmar" = @{
        "States" = @(
            "Sagaing",
            "Bago",
            "Magway",
            "Mandalay",
            "Tanintharyi",
            "Yangon",
            "Ayeyarwady",
            "Kachin",
            "Kayah",
            "Kayin",
            "Chin",
            "Mon",
            "Rakhine",
            "Shan"
        )
    }
    "Mongolia" = @{
        "States" = @(
            "Orhon",
            "Darhan uul",
            "Hentiy",
            "Hövsgöl",
            "Hovd",
            "Uvs",
            "Töv",
            "Selenge",
            "Sühbaatar",
            "Ömnögovi",
            "Övörhangay",
            "Dzavhan",
            "Dundgovi",
            "Dornod",
            "Dornogovi",
            "Govi-Sumber",
            "Govi-Altay",
            "Bulgan",
            "Bayanhongor",
            "Bayan-Ölgiy",
            "Arhangay",
            "Ulanbaatar"
        )
    }
    "Macao" = @{
        "States" = @(
        )
    }
    "Northern Mariana Islands" = @{
        "States" = @(
        )
    }
    "Martinique" = @{
        "States" = @(
        )
    }
    "Mauritania" = @{
        "States" = @(
            "Hodh ech Chargui",
            "Hodh el Charbi",
            "Assaba",
            "Gorgol",
            "Brakna",
            "Trarza",
            "Adrar",
            "Dakhlet Nouadhibou",
            "Tagant",
            "Guidimaka",
            "Tiris Zemmour",
            "Inchiri",
            "Nouakchott"
        )
    }
    "Montserrat" = @{
        "States" = @(
        )
    }
    "Malta" = @{
        "States" = @(
            "Attard",
            "Balzan",
            "Birgu",
            "Birkirkara",
            "Birżebbuġa",
            "Bormla",
            "Dingli",
            "Fgura",
            "Floriana",
            "Fontana",
            "Gudja",
            "Gżira",
            "Għajnsielem",
            "Għarb",
            "Għargħur",
            "Għasri",
            "Għaxaq",
            "Ħamrun",
            "Iklin",
            "Isla",
            "Kalkara",
            "Kerċem",
            "Kirkop",
            "Lija",
            "Luqa",
            "Marsa",
            "Marsaskala",
            "Marsaxlokk",
            "Mdina",
            "Mellieħa",
            "Mġarr",
            "Mosta",
            "Mqabba",
            "Msida",
            "Mtarfa",
            "Munxar",
            "Nadur",
            "Naxxar",
            "Paola",
            "Pembroke",
            "Pietà",
            "Qala",
            "Qormi",
            "Qrendi",
            "Rabat Għawdex",
            "Rabat Malta",
            "Safi",
            "San Ġiljan",
            "San Ġwann",
            "San Lawrenz",
            "San Pawl il-Baħar",
            "Sannat",
            "Santa Luċija",
            "Santa Venera",
            "Siġġiewi",
            "Sliema",
            "Swieqi",
            "Ta’ Xbiex",
            "Tarxien",
            "Valletta",
            "Xagħra",
            "Xewkija",
            "Xgħajra",
            "Żabbar",
            "Żebbuġ Għawdex",
            "Żebbuġ Malta",
            "Żejtun",
            "Żurrieq"
        )
    }
    "Mauritius" = @{
        "States" = @(
            "Agalega Islands",
            "Black River",
            "Beau Bassin-Rose Hill",
            "Cargados Carajos Shoals",
            "Curepipe",
            "Flacq",
            "Grand Port",
            "Moka",
            "Pamplemousses",
            "Port Louis",
            "Plaines Wilhems",
            "Quatre Bornes",
            "Rodrigues Island",
            "Rivière du Rempart",
            "Savanne",
            "Vacoas-Phoenix"
        )
    }
    "Maldives" = @{
        "States" = @(
            "Central",
            "Male",
            "North Central",
            "North",
            "South Central",
            "South",
            "Upper North",
            "Upper South"
        )
    }
    "Malawi" = @{
        "States" = @(
            "Central Region",
            "Northern Region",
            "Southern Region"
        )
    }
    "Mexico" = @{
        "States" = @(
            "Aguascalientes",
            "Baja California",
            "Baja California Sur",
            "Campeche",
            "Chihuahua",
            "Chiapas",
            "Coahuila",
            "Colima",
            "Distrito Federal",
            "Durango",
            "Guerrero",
            "Guanajuato",
            "Hidalgo",
            "Jalisco",
            "México",
            "Michoacán",
            "Morelos",
            "Nayarit",
            "Nuevo León",
            "Oaxaca",
            "Puebla",
            "Querétaro",
            "Quintana Roo",
            "Sinaloa",
            "San Luis Potosí",
            "Sonora",
            "Tabasco",
            "Tamaulipas",
            "Tlaxcala",
            "Veracruz",
            "Yucatán",
            "Zacatecas"
        )
    }
    "Malaysia" = @{
        "States" = @(
            "Johor",
            "Kedah",
            "Kelantan",
            "Melaka",
            "Negeri Sembilan",
            "Pahang",
            "Pulau Pinang",
            "Perak",
            "Perlis",
            "Selangor",
            "Terengganu",
            "Sabah",
            "Sarawak",
            "Wilayah Persekutuan Kuala Lumpur",
            "Wilayah Persekutuan Labuan",
            "Wilayah Persekutuan Putrajaya"
        )
    }
    "Mozambique" = @{
        "States" = @(
            "Niassa",
            "Manica",
            "Gaza",
            "Inhambane",
            "Maputo",
            "Maputo (city)",
            "Numpula",
            "Cabo Delgado",
            "Zambezia",
            "Sofala",
            "Tete"
        )
    }
    "Namibia" = @{
        "States" = @(
            "Caprivi",
            "Erongo",
            "Hardap",
            "Karas",
            "Khomas",
            "Kunene",
            "Otjozondjupa",
            "Omaheke",
            "Okavango",
            "Oshana",
            "Omusati",
            "Oshikoto",
            "Ohangwena"
        )
    }
    "New Caledonia" = @{
        "States" = @(
        )
    }
    "Niger" = @{
        "States" = @(
            "Agadez",
            "Diffa",
            "Dosso",
            "Maradi",
            "Tahoua",
            "Tillabéri",
            "Zinder",
            "Niamey"
        )
    }
    "Norfolk Island" = @{
        "States" = @(
        )
    }
    "Nigeria" = @{
        "States" = @(
            "Abia",
            "Adamawa",
            "Akwa Ibom",
            "Anambra",
            "Bauchi",
            "Benue",
            "Borno",
            "Bayelsa",
            "Cross River",
            "Delta",
            "Ebonyi",
            "Edo",
            "Ekiti",
            "Enugu",
            "Abuja Capital Territory",
            "Gombe",
            "Imo",
            "Jigawa",
            "Kaduna",
            "Kebbi",
            "Kano",
            "Kogi",
            "Katsina",
            "Kwara",
            "Lagos",
            "Nassarawa",
            "Niger",
            "Ogun",
            "Ondo",
            "Osun",
            "Oyo",
            "Plateau",
            "Rivers",
            "Sokoto",
            "Taraba",
            "Yobe",
            "Zamfara"
        )
    }
    "Nicaragua" = @{
        "States" = @(
            "Atlántico Norte",
            "Atlántico Sur",
            "Boaco",
            "Carazo",
            "Chinandega",
            "Chontales",
            "Estelí",
            "Granada",
            "Jinotega",
            "León",
            "Madriz",
            "Managua",
            "Masaya",
            "Matagalpa",
            "Nueva Segovia",
            "Rivas",
            "Río San Juan"
        )
    }
    "Netherlands" = @{
        "States" = @(
            "Aruba",
            "Bonaire",
            "Saba",
            "Sint Eustatius",
            "Curaçao",
            "Drenthe",
            "Flevoland",
            "Friesland",
            "Gelderland",
            "Groningen",
            "Limburg",
            "Noord-Brabant",
            "Noord-Holland",
            "Overijssel",
            "Sint Maarten",
            "Utrecht",
            "Zeeland",
            "Zuid-Holland"
        )
    }
    "Norway" = @{
        "States" = @(
            "Østfold",
            "Akershus",
            "Oslo",
            "Hedmark",
            "Oppland",
            "Buskerud",
            "Vestfold",
            "Telemark",
            "Aust-Agder",
            "Vest-Agder",
            "Rogaland",
            "Hordaland",
            "Sogn og Fjordane",
            "Møre og Romsdal",
            "Sør-Trøndelag",
            "Nord-Trøndelag",
            "Nordland",
            "Troms",
            "Finnmark",
            "Svalbard (Arctic Region)",
            "Jan Mayen (Arctic Region)"
        )
    }
    "Nepal" = @{
        "States" = @(
            "Madhyamanchal",
            "Madhya Pashchimanchal",
            "Pashchimanchal",
            "Purwanchal",
            "Sudur Pashchimanchal"
        )
    }
    "Nauru" = @{
        "States" = @(
            "Aiwo",
            "Anabar",
            "Anetan",
            "Anibare",
            "Baiti",
            "Boe",
            "Buada",
            "Denigomodu",
            "Ewa",
            "Ijuw",
            "Meneng",
            "Nibok",
            "Uaboe",
            "Yaren"
        )
    }
    "Niue" = @{
        "States" = @(
        )
    }
    "New Zealand" = @{
        "States" = @(
            "Chatham Islands Territory",
            "North Island",
            "South Island"
        )
    }
    "Oman" = @{
        "States" = @(
            "Al Bāţinah",
            "Al Buraymī",
            "Ad Dākhilīya",
            "Masqaţ",
            "Musandam",
            "Ash Sharqīyah",
            "Al Wusţá",
            "Az̧ Z̧āhirah",
            "Z̧ufār"
        )
    }
    "Panama" = @{
        "States" = @(
            "Bocas del Toro",
            "Coclé",
            "Colón",
            "Chiriquí",
            "Darién",
            "Herrera",
            "Los Santos",
            "Panamá",
            "Veraguas",
            "Emberá",
            "Kuna Yala",
            "Ngöbe-Buglé"
        )
    }
    "Peru" = @{
        "States" = @(
            "Amazonas",
            "Ancash",
            "Apurímac",
            "Arequipa",
            "Ayacucho",
            "Cajamarca",
            "El Callao",
            "Cusco [Cuzco]",
            "Huánuco",
            "Huancavelica",
            "Ica",
            "Junín",
            "La Libertad",
            "Lambayeque",
            "Lima",
            "Municipalidad Metropolitana de Lima",
            "Loreto",
            "Madre de Dios",
            "Moquegua",
            "Pasco",
            "Piura",
            "Puno",
            "San Martín",
            "Tacna",
            "Tumbes",
            "Ucayali"
        )
    }
    "French Polynesia" = @{
        "States" = @(
        )
    }
    "Papua New Guinea" = @{
        "States" = @(
            "Chimbu",
            "Central",
            "East New Britain",
            "Eastern Highlands",
            "Enga",
            "East Sepik",
            "Gulf",
            "Milne Bay",
            "Morobe",
            "Madang",
            "Manus",
            "National Capital District (Port Moresby)",
            "New Ireland",
            "Northern",
            "Bougainville",
            "Sandaun",
            "Southern Highlands",
            "West New Britain",
            "Western Highlands",
            "Western"
        )
    }
    "Philippines" = @{
        "States" = @(
            "National Capital Region",
            "Ilocos (Region I)",
            "Cagayan Valley (Region II)",
            "Central Luzon (Region III)",
            "Bicol (Region V)",
            "Western Visayas (Region VI)",
            "Central Visayas (Region VII)",
            "Eastern Visayas (Region VIII)",
            "Zamboanga Peninsula (Region IX)",
            "Northern Mindanao (Region X)",
            "Davao (Region XI)",
            "Soccsksargen (Region XII)",
            "Caraga (Region XIII)",
            "Autonomous Region in Muslim Mindanao (ARMM)",
            "Cordillera Administrative Region (CAR)",
            "CALABARZON (Region IV-A)",
            "MIMAROPA (Region IV-B)"
        )
    }
    "Pakistan" = @{
        "States" = @(
            "Balochistan",
            "Gilgit-Baltistan",
            "Islamabad",
            "Azad Kashmir",
            "Khyber Pakhtunkhwa",
            "Punjab",
            "Sindh",
            "Federally Administered Tribal Areas"
        )
    }
    "Poland" = @{
        "States" = @(
            "Dolnośląskie",
            "Kujawsko-pomorskie",
            "Lubuskie",
            "Łódzkie",
            "Lubelskie",
            "Małopolskie",
            "Mazowieckie",
            "Opolskie",
            "Podlaskie",
            "Podkarpackie",
            "Pomorskie",
            "Świętokrzyskie",
            "Śląskie",
            "Warmińsko-mazurskie",
            "Wielkopolskie",
            "Zachodniopomorskie"
        )
    }
    "Saint Pierre and Miquelon" = @{
        "States" = @(
        )
    }
    "Pitcairn" = @{
        "States" = @(
        )
    }
    "Palestine, State of" = @{
        "States" = @(
            "Bethlehem",
            "Deir El Balah",
            "Gaza",
            "Hebron",
            "Jerusalem",
            "Jenin",
            "Jericho - Al Aghwar",
            "Khan Yunis",
            "Nablus",
            "North Gaza",
            "Qalqilya",
            "Ramallah",
            "Rafah",
            "Salfit",
            "Tubas",
            "Tulkarm"
        )
    }
    "Portugal" = @{
        "States" = @(
            "Aveiro",
            "Beja",
            "Braga",
            "Bragança",
            "Castelo Branco",
            "Coimbra",
            "Évora",
            "Faro",
            "Guarda",
            "Leiria",
            "Lisboa",
            "Portalegre",
            "Porto",
            "Santarém",
            "Setúbal",
            "Viana do Castelo",
            "Vila Real",
            "Viseu",
            "Região Autónoma dos Açores",
            "Região Autónoma da Madeira"
        )
    }
    "Palau" = @{
        "States" = @(
            "Aimeliik",
            "Airai",
            "Angaur",
            "Hatobohei",
            "Kayangel",
            "Koror",
            "Melekeok",
            "Ngaraard",
            "Ngarchelong",
            "Ngardmau",
            "Ngatpang",
            "Ngchesar",
            "Ngeremlengui",
            "Ngiwal",
            "Peleliu",
            "Sonsorol"
        )
    }
    "Paraguay" = @{
        "States" = @(
            "Concepción",
            "Alto Paraná",
            "Central",
            "Ñeembucú",
            "Amambay",
            "Canindeyú",
            "Presidente Hayes",
            "Alto Paraguay",
            "Boquerón",
            "San Pedro",
            "Cordillera",
            "Guairá",
            "Caaguazú",
            "Caazapá",
            "Itapúa",
            "Misiones",
            "Paraguarí",
            "Asunción"
        )
    }
    "Qatar" = @{
        "States" = @(
            "Ad Dawhah",
            "Al Khawr wa adh Dhakhīrah",
            "Ash Shamal",
            "Ar Rayyan",
            "Umm Salal",
            "Al Wakrah",
            "Az̧ Z̧a‘āyin"
        )
    }
    "Réunion" = @{
        "States" = @(
        )
    }
    "Romania" = @{
        "States" = @(
            "Alba",
            "Argeș",
            "Arad",
            "București",
            "Bacău",
            "Bihor",
            "Bistrița-Năsăud",
            "Brăila",
            "Botoșani",
            "Brașov",
            "Buzău",
            "Cluj",
            "Călărași",
            "Caraș-Severin",
            "Constanța",
            "Covasna",
            "Dâmbovița",
            "Dolj",
            "Gorj",
            "Galați",
            "Giurgiu",
            "Hunedoara",
            "Harghita",
            "Ilfov",
            "Ialomița",
            "Iași",
            "Mehedinți",
            "Maramureș",
            "Mureș",
            "Neamț",
            "Olt",
            "Prahova",
            "Sibiu",
            "Sălaj",
            "Satu Mare",
            "Suceava",
            "Tulcea",
            "Timiș",
            "Teleorman",
            "Vâlcea",
            "Vrancea",
            "Vaslui"
        )
    }
    "Serbia" = @{
        "States" = @(
            "Beograd",
            "Mačvanski okrug",
            "Kolubarski okrug",
            "Podunavski okrug",
            "Braničevski okrug",
            "Šumadijski okrug",
            "Pomoravski okrug",
            "Borski okrug",
            "Zaječarski okrug",
            "Zlatiborski okrug",
            "Moravički okrug",
            "Raški okrug",
            "Rasinski okrug",
            "Nišavski okrug",
            "Toplički okrug",
            "Pirotski okrug",
            "Jablanički okrug",
            "Pčinjski okrug",
            "Kosovo-Metohija",
            "Vojvodina"
        )
    }
    "Russian Federation" = @{
        "States" = @(
            "Adygeya, Respublika",
            "Altay, Respublika",
            "Altayskiy kray",
            "Amurskaya oblast'",
            "Arkhangel'skaya oblast'",
            "Astrakhanskaya oblast'",
            "Bashkortostan, Respublika",
            "Belgorodskaya oblast'",
            "Bryanskaya oblast'",
            "Buryatiya, Respublika",
            "Chechenskaya Respublika",
            "Chelyabinskaya oblast'",
            "Chukotskiy avtonomnyy okrug",
            "Chuvashskaya Respublika",
            "Dagestan, Respublika",
            "Respublika Ingushetiya",
            "Irkutiskaya oblast'",
            "Ivanovskaya oblast'",
            "Kamchatskiy kray",
            "Kabardino-Balkarskaya Respublika",
            "Karachayevo-Cherkesskaya Respublika",
            "Krasnodarskiy kray",
            "Kemerovskaya oblast'",
            "Kaliningradskaya oblast'",
            "Kurganskaya oblast'",
            "Khabarovskiy kray",
            "Khanty-Mansiysky avtonomnyy okrug-Yugra",
            "Kirovskaya oblast'",
            "Khakasiya, Respublika",
            "Kalmykiya, Respublika",
            "Kaluzhskaya oblast'",
            "Komi, Respublika",
            "Kostromskaya oblast'",
            "Kareliya, Respublika",
            "Kurskaya oblast'",
            "Krasnoyarskiy kray",
            "Leningradskaya oblast'",
            "Lipetskaya oblast'",
            "Magadanskaya oblast'",
            "Mariy El, Respublika",
            "Mordoviya, Respublika",
            "Moskovskaya oblast'",
            "Moskva",
            "Murmanskaya oblast'",
            "Nenetskiy avtonomnyy okrug",
            "Novgorodskaya oblast'",
            "Nizhegorodskaya oblast'",
            "Novosibirskaya oblast'",
            "Omskaya oblast'",
            "Orenburgskaya oblast'",
            "Orlovskaya oblast'",
            "Permskiy kray",
            "Penzenskaya oblast'",
            "Primorskiy kray",
            "Pskovskaya oblast'",
            "Rostovskaya oblast'",
            "Ryazanskaya oblast'",
            "Sakha, Respublika [Yakutiya]",
            "Sakhalinskaya oblast'",
            "Samaraskaya oblast'",
            "Saratovskaya oblast'",
            "Severnaya Osetiya-Alaniya, Respublika",
            "Smolenskaya oblast'",
            "Sankt-Peterburg",
            "Stavropol'skiy kray",
            "Sverdlovskaya oblast'",
            "Tatarstan, Respublika",
            "Tambovskaya oblast'",
            "Tomskaya oblast'",
            "Tul'skaya oblast'",
            "Tverskaya oblast'",
            "Tyva, Respublika [Tuva]",
            "Tyumenskaya oblast'",
            "Udmurtskaya Respublika",
            "Ul'yanovskaya oblast'",
            "Volgogradskaya oblast'",
            "Vladimirskaya oblast'",
            "Vologodskaya oblast'",
            "Voronezhskaya oblast'",
            "Yamalo-Nenetskiy avtonomnyy okrug",
            "Yaroslavskaya oblast'",
            "Yevreyskaya avtonomnaya oblast'",
            "Zabajkal'skij kraj"
        )
    }
    "Rwanda" = @{
        "States" = @(
            "Ville de Kigali",
            "Est",
            "Nord",
            "Ouest",
            "Sud"
        )
    }
    "Saudi Arabia" = @{
        "States" = @(
            "Ar Riyāḍ",
            "Makkah",
            "Al Madīnah",
            "Ash Sharqīyah",
            "Al Qaşīm",
            "Ḥā'il",
            "Tabūk",
            "Al Ḥudūd ash Shamāliyah",
            "Jīzan",
            "Najrān",
            "Al Bāhah",
            "Al Jawf",
            "`Asīr"
        )
    }
    "Solomon Islands" = @{
        "States" = @(
            "Central",
            "Choiseul",
            "Capital Territory (Honiara)",
            "Guadalcanal",
            "Isabel",
            "Makira",
            "Malaita",
            "Rennell and Bellona",
            "Temotu",
            "Western"
        )
    }
    "Seychelles" = @{
        "States" = @(
            "Anse aux Pins",
            "Anse Boileau",
            "Anse Etoile",
            "Anse Louis",
            "Anse Royale",
            "Baie Lazare",
            "Baie Sainte Anne",
            "Beau Vallon",
            "Bel Air",
            "Bel Ombre",
            "Cascade",
            "Glacis",
            "Grand Anse Mahe",
            "Grand Anse Praslin",
            "La Digue",
            "English River",
            "Mont Buxton",
            "Mont Fleuri",
            "Plaisance",
            "Pointe Larue",
            "Port Glaud",
            "Saint Louis",
            "Takamaka",
            "Les Mamelles",
            "Roche Caiman"
        )
    }
    "Sudan" = @{
        "States" = @(
            "Zalingei",
            "Sharq Dārfūr",
            "Shamāl Dārfūr",
            "Janūb Dārfūr",
            "Gharb Dārfūr",
            "Al Qaḑārif",
            "Al Jazīrah",
            "Kassalā",
            "Al Kharţūm",
            "Shamāl Kurdufān",
            "Janūb Kurdufān",
            "An Nīl al Azraq",
            "Ash Shamālīyah",
            "An Nīl",
            "An Nīl al Abyaḑ",
            "Al Baḩr al Aḩmar",
            "Sinnār"
        )
    }
    "Sweden" = @{
        "States" = @(
            "Stockholms län",
            "Västerbottens län",
            "Norrbottens län",
            "Uppsala län",
            "Södermanlands län",
            "Östergötlands län",
            "Jönköpings län",
            "Kronobergs län",
            "Kalmar län",
            "Gotlands län",
            "Blekinge län",
            "Skåne län",
            "Hallands län",
            "Västra Götalands län",
            "Värmlands län",
            "Örebro län",
            "Västmanlands län",
            "Dalarnas län",
            "Gävleborgs län",
            "Västernorrlands län",
            "Jämtlands län"
        )
    }
    "Singapore" = @{
        "States" = @(
            "Central Singapore",
            "North East",
            "North West",
            "South East",
            "South West"
        )
    }
    "Saint Helena, Ascension and Tristan da Cunha" = @{
        "States" = @(
            "Ascension",
            "Saint Helena",
            "Tristan da Cunha"
        )
    }
    "Slovenia" = @{
        "States" = @(
            "Ajdovščina",
            "Beltinci",
            "Bled",
            "Bohinj",
            "Borovnica",
            "Bovec",
            "Brda",
            "Brezovica",
            "Brežice",
            "Tišina",
            "Celje",
            "Cerklje na Gorenjskem",
            "Cerknica",
            "Cerkno",
            "Črenšovci",
            "Črna na Koroškem",
            "Črnomelj",
            "Destrnik",
            "Divača",
            "Dobrepolje",
            "Dobrova-Polhov Gradec",
            "Dol pri Ljubljani",
            "Domžale",
            "Dornava",
            "Dravograd",
            "Duplek",
            "Gorenja vas-Poljane",
            "Gorišnica",
            "Gornja Radgona",
            "Gornji Grad",
            "Gornji Petrovci",
            "Grosuplje",
            "Šalovci",
            "Hrastnik",
            "Hrpelje-Kozina",
            "Idrija",
            "Ig",
            "Ilirska Bistrica",
            "Ivančna Gorica",
            "Izola/Isola",
            "Jesenice",
            "Juršinci",
            "Kamnik",
            "Kanal",
            "Kidričevo",
            "Kobarid",
            "Kobilje",
            "Kočevje",
            "Komen",
            "Koper/Capodistria",
            "Kozje",
            "Kranj",
            "Kranjska Gora",
            "Krško",
            "Kungota",
            "Kuzma",
            "Laško",
            "Lenart",
            "Lendava/Lendva",
            "Litija",
            "Ljubljana",
            "Ljubno",
            "Ljutomer",
            "Logatec",
            "Loška dolina",
            "Loški Potok",
            "Luče",
            "Lukovica",
            "Majšperk",
            "Maribor",
            "Medvode",
            "Mengeš",
            "Metlika",
            "Mežica",
            "Miren-Kostanjevica",
            "Mislinja",
            "Moravče",
            "Moravske Toplice",
            "Mozirje",
            "Murska Sobota",
            "Muta",
            "Naklo",
            "Nazarje",
            "Nova Gorica",
            "Novo mesto",
            "Odranci",
            "Ormož",
            "Osilnica",
            "Pesnica",
            "Piran/Pirano",
            "Pivka",
            "Podčetrtek",
            "Podvelka",
            "Postojna",
            "Preddvor",
            "Ptuj",
            "Puconci",
            "Rače-Fram",
            "Radeče",
            "Radenci",
            "Radlje ob Dravi",
            "Radovljica",
            "Ravne na Koroškem",
            "Ribnica",
            "Rogašovci",
            "Rogaška Slatina",
            "Rogatec",
            "Ruše",
            "Semič",
            "Sevnica",
            "Sežana",
            "Slovenj Gradec",
            "Slovenska Bistrica",
            "Slovenske Konjice",
            "Starče",
            "Sveti Jurij",
            "Šenčur",
            "Šentilj",
            "Šentjernej",
            "Šentjur",
            "Škocjan",
            "Škofja Loka",
            "Škofljica",
            "Šmarje pri Jelšah",
            "Šmartno ob Paki",
            "Šoštanj",
            "Štore",
            "Tolmin",
            "Trbovlje",
            "Trebnje",
            "Tržič",
            "Turnišče",
            "Velenje",
            "Velike Lašče",
            "Videm",
            "Vipava",
            "Vitanje",
            "Vodice",
            "Vojnik",
            "Vrhnika",
            "Vuzenica",
            "Zagorje ob Savi",
            "Zavrč",
            "Zreče",
            "Železniki",
            "Žiri",
            "Benedikt",
            "Bistrica ob Sotli",
            "Bloke",
            "Braslovče",
            "Cankova",
            "Cerkvenjak",
            "Dobje",
            "Dobrna",
            "Dobrovnik/Dobronak",
            "Dolenjske Toplice",
            "Grad",
            "Hajdina",
            "Hoče-Slivnica",
            "Hodoš/Hodos",
            "Horjul",
            "Jezersko",
            "Komenda",
            "Kostel",
            "Križevci",
            "Lovrenc na Pohorju",
            "Markovci",
            "Miklavž na Dravskem polju",
            "Mirna Peč",
            "Oplotnica",
            "Podlehnik",
            "Polzela",
            "Prebold",
            "Prevalje",
            "Razkrižje",
            "Ribnica na Pohorju",
            "Selnica ob Dravi",
            "Sodražica",
            "Solčava",
            "Sveta Ana",
            "Sveta Andraž v Slovenskih Goricah",
            "Šempeter-Vrtojba",
            "Tabor",
            "Trnovska vas",
            "Trzin",
            "Velika Polana",
            "Veržej",
            "Vransko",
            "Žalec",
            "Žetale",
            "Žirovnica",
            "Žužemberk",
            "Šmartno pri Litiji",
            "Apače",
            "Cirkulane",
            "Kosanjevica na Krki",
            "Makole",
            "Mokronog-Trebelno",
            "Poljčane",
            "Renče-Vogrsko",
            "Središče ob Dravi",
            "Straža",
            "Sveta Trojica v Slovenskih Goricah",
            "Sveti Tomaž",
            "Šmarjeske Topliče",
            "Gorje",
            "Log-Dragomer",
            "Rečica ob Savinji",
            "Sveti Jurij v Slovenskih Goricah",
            "Šentrupert"
        )
    }
    "Svalbard and Jan Mayen" = @{
        "States" = @(
        )
    }
    "Slovakia" = @{
        "States" = @(
            "Banskobystrický kraj",
            "Bratislavský kraj",
            "Košický kraj",
            "Nitriansky kraj",
            "Prešovský kraj",
            "Trnavský kraj",
            "Trenčiansky kraj",
            "Žilinský kraj"
        )
    }
    "Sierra Leone" = @{
        "States" = @(
            "Eastern",
            "Northern",
            "Southern (Sierra Leone)",
            "Western Area (Freetown)"
        )
    }
    "San Marino" = @{
        "States" = @(
            "Acquaviva",
            "Chiesanuova",
            "Domagnano",
            "Faetano",
            "Fiorentino",
            "Borgo Maggiore",
            "San Marino",
            "Montegiardino",
            "Serravalle"
        )
    }
    "Senegal" = @{
        "States" = @(
            "Diourbel",
            "Dakar",
            "Fatick",
            "Kaffrine",
            "Kolda",
            "Kédougou",
            "Kaolack",
            "Louga",
            "Matam",
            "Sédhiou",
            "Saint-Louis",
            "Tambacounda",
            "Thiès",
            "Ziguinchor"
        )
    }
    "Somalia" = @{
        "States" = @(
            "Awdal",
            "Bakool",
            "Banaadir",
            "Bari",
            "Bay",
            "Galguduud",
            "Gedo",
            "Hiirsan",
            "Jubbada Dhexe",
            "Jubbada Hoose",
            "Mudug",
            "Nugaal",
            "Saneag",
            "Shabeellaha Dhexe",
            "Shabeellaha Hoose",
            "Sool",
            "Togdheer",
            "Woqooyi Galbeed"
        )
    }
    "Suriname" = @{
        "States" = @(
            "Brokopondo",
            "Commewijne",
            "Coronie",
            "Marowijne",
            "Nickerie",
            "Paramaribo",
            "Para",
            "Saramacca",
            "Sipaliwini",
            "Wanica"
        )
    }
    "South Sudan" = @{
        "States" = @(
            "Northern Bahr el-Ghazal",
            "Western Bahr el-Ghazal",
            "Central Equatoria",
            "Eastern Equatoria",
            "Western Equatoria",
            "Jonglei",
            "Lakes",
            "Upper Nile",
            "Unity",
            "Warrap"
        )
    }
    "Sao Tome and Principe" = @{
        "States" = @(
            "Príncipe",
            "São Tomé"
        )
    }
    "El Salvador" = @{
        "States" = @(
            "Ahuachapán",
            "Cabañas",
            "Chalatenango",
            "Cuscatlán",
            "La Libertad",
            "Morazán",
            "La Paz",
            "Santa Ana",
            "San Miguel",
            "Sonsonate",
            "San Salvador",
            "San Vicente",
            "La Unión",
            "Usulután"
        )
    }
    "Sint Maarten (Dutch part)" = @{
        "States" = @(
        )
    }
    "Syrian Arab Republic" = @{
        "States" = @(
            "Dimashq",
            "Dar'a",
            "Dayr az Zawr",
            "Al Hasakah",
            "Homs",
            "Halab",
            "Hamah",
            "Idlib",
            "Al Ladhiqiyah",
            "Al Qunaytirah",
            "Ar Raqqah",
            "Rif Dimashq",
            "As Suwayda'",
            "Tartus"
        )
    }
    "Swaziland" = @{
        "States" = @(
            "Hhohho",
            "Lubombo",
            "Manzini",
            "Shiselweni"
        )
    }
    "Turks and Caicos Islands" = @{
        "States" = @(
        )
    }
    "Chad" = @{
        "States" = @(
            "Al Baṭḩah",
            "Baḩr al Ghazāl",
            "Būrkū",
            "Shārī Bāqirmī",
            "Innīdī",
            "Qīrā",
            "Ḥajjar Lamīs",
            "Kānim",
            "Al Buḩayrah",
            "Lūqūn al Gharbī",
            "Lūqūn ash Sharqī",
            "Māndūl",
            "Shārī al Awsaṭ",
            "Māyū Kībbī ash Sharqī",
            "Māyū Kībbī al Gharbī",
            "Madīnat Injamīnā",
            "Waddāy",
            "Salāmāt",
            "Sīlā",
            "Tānjilī",
            "Tibastī",
            "Wādī Fīrā"
        )
    }
    "French Southern Territories" = @{
        "States" = @(
        )
    }
    "Togo" = @{
        "States" = @(
            "Région du Centre",
            "Région de la Kara",
            "Région Maritime",
            "Région des Plateaux",
            "Région des Savannes"
        )
    }
    "Thailand" = @{
        "States" = @(
            "Krung Thep Maha Nakhon Bangkok",
            "Samut Prakan",
            "Nonthaburi",
            "Pathum Thani",
            "Phra Nakhon Si Ayutthaya",
            "Ang Thong",
            "Lop Buri",
            "Sing Buri",
            "Chai Nat",
            "Saraburi",
            "Chon Buri",
            "Rayong",
            "Chanthaburi",
            "Trat",
            "Chachoengsao",
            "Prachin Buri",
            "Nakhon Nayok",
            "Sa Kaeo",
            "Nakhon Ratchasima",
            "Buri Ram",
            "Surin",
            "Si Sa Ket",
            "Ubon Ratchathani",
            "Yasothon",
            "Chaiyaphum",
            "Amnat Charoen",
            "Nong Bua Lam Phu",
            "Khon Kaen",
            "Udon Thani",
            "Loei",
            "Nong Khai",
            "Maha Sarakham",
            "Roi Et",
            "Kalasin",
            "Sakon Nakhon",
            "Nakhon Phanom",
            "Mukdahan",
            "Chiang Mai",
            "Lamphun",
            "Lampang",
            "Uttaradit",
            "Phrae",
            "Nan",
            "Phayao",
            "Chiang Rai",
            "Mae Hong Son",
            "Nakhon Sawan",
            "Uthai Thani",
            "Kamphaeng Phet",
            "Tak",
            "Sukhothai",
            "Phitsanulok",
            "Phichit",
            "Phetchabun",
            "Ratchaburi",
            "Kanchanaburi",
            "Suphan Buri",
            "Nakhon Pathom",
            "Samut Sakhon",
            "Samut Songkhram",
            "Phetchaburi",
            "Prachuap Khiri Khan",
            "Nakhon Si Thammarat",
            "Krabi",
            "Phangnga",
            "Phuket",
            "Surat Thani",
            "Ranong",
            "Chumphon",
            "Songkhla",
            "Satun",
            "Trang",
            "Phatthalung",
            "Pattani",
            "Yala",
            "Narathiwat",
            "Phatthaya"
        )
    }
    "Tajikistan" = @{
        "States" = @(
            "Gorno-Badakhshan",
            "Khatlon",
            "Sughd"
        )
    }
    "Tokelau" = @{
        "States" = @(
        )
    }
    "Timor-Leste" = @{
        "States" = @(
            "Aileu",
            "Ainaro",
            "Baucau",
            "Bobonaro",
            "Cova Lima",
            "Díli",
            "Ermera",
            "Lautem",
            "Liquiça",
            "Manufahi",
            "Manatuto",
            "Oecussi",
            "Viqueque"
        )
    }
    "Turkmenistan" = @{
        "States" = @(
            "Ahal",
            "Balkan",
            "Daşoguz",
            "Lebap",
            "Mary",
            "Aşgabat"
        )
    }
    "Tunisia" = @{
        "States" = @(
            "Tunis",
            "Ariana",
            "Ben Arous",
            "La Manouba",
            "Nabeul",
            "Zaghouan",
            "Bizerte",
            "Béja",
            "Jendouba",
            "Le Kef",
            "Siliana",
            "Kairouan",
            "Kasserine",
            "Sidi Bouzid",
            "Sousse",
            "Monastir",
            "Mahdia",
            "Sfax",
            "Gafsa",
            "Tozeur",
            "Kebili",
            "Gabès",
            "Medenine",
            "Tataouine"
        )
    }
    "Tonga" = @{
        "States" = @(
            "'Eua",
            "Ha'apai",
            "Niuas",
            "Tongatapu",
            "Vava'u"
        )
    }
    "Turkey" = @{
        "States" = @(
            "Adana",
            "Adıyaman",
            "Afyonkarahisar",
            "Ağrı",
            "Amasya",
            "Ankara",
            "Antalya",
            "Artvin",
            "Aydın",
            "Balıkesir",
            "Bilecik",
            "Bingöl",
            "Bitlis",
            "Bolu",
            "Burdur",
            "Bursa",
            "Çanakkale",
            "Çankırı",
            "Çorum",
            "Denizli",
            "Diyarbakır",
            "Edirne",
            "Elazığ",
            "Erzincan",
            "Erzurum",
            "Eskişehir",
            "Gaziantep",
            "Giresun",
            "Gümüşhane",
            "Hakkâri",
            "Hatay",
            "Isparta",
            "Mersin",
            "İstanbul",
            "İzmir",
            "Kars",
            "Kastamonu",
            "Kayseri",
            "Kırklareli",
            "Kırşehir",
            "Kocaeli",
            "Konya",
            "Kütahya",
            "Malatya",
            "Manisa",
            "Kahramanmaraş",
            "Mardin",
            "Muğla",
            "Muş",
            "Nevşehir",
            "Niğde",
            "Ordu",
            "Rize",
            "Sakarya",
            "Samsun",
            "Siirt",
            "Sinop",
            "Sivas",
            "Tekirdağ",
            "Tokat",
            "Trabzon",
            "Tunceli",
            "Şanlıurfa",
            "Uşak",
            "Van",
            "Yozgat",
            "Zonguldak",
            "Aksaray",
            "Bayburt",
            "Karaman",
            "Kırıkkale",
            "Batman",
            "Şırnak",
            "Bartın",
            "Ardahan",
            "Iğdır",
            "Yalova",
            "Karabük",
            "Kilis",
            "Osmaniye",
            "Düzce"
        )
    }
    "Trinidad and Tobago" = @{
        "States" = @(
            "Arima",
            "Chaguanas",
            "Couva-Tabaquite-Talparo",
            "Diego Martin",
            "Eastern Tobago",
            "Penal-Debe",
            "Port of Spain",
            "Princes Town",
            "Point Fortin",
            "Rio Claro-Mayaro",
            "San Fernando",
            "Sangre Grande",
            "Siparia",
            "San Juan-Laventille",
            "Tunapuna-Piarco",
            "Western Tobago"
        )
    }
    "Tuvalu" = @{
        "States" = @(
            "Funafuti",
            "Niutao",
            "Nukufetau",
            "Nukulaelae",
            "Nanumea",
            "Nanumanga",
            "Nui",
            "Vaitupu"
        )
    }
    "Taiwan" = @{
        "States" = @(
            "Changhua",
            "Chiay City",
            "Chiayi",
            "Hsinchu",
            "Hsinchui City",
            "Hualien",
            "Ilan",
            "Keelung City",
            "Kaohsiung City",
            "Kaohsiung",
            "Miaoli",
            "Nantou",
            "Penghu",
            "Pingtung",
            "Taoyuan",
            "Tainan City",
            "Tainan",
            "Taipei City",
            "Taipei",
            "Taitung",
            "Taichung City",
            "Taichung",
            "Yunlin"
        )
    }
    "Tanzania, United Republic of" = @{
        "States" = @(
            "Arusha",
            "Dar-es-Salaam",
            "Dodoma",
            "Iringa",
            "Kagera",
            "Kaskazini Pemba",
            "Kaskazini Unguja",
            "Kigoma",
            "Kilimanjaro",
            "Kusini Pemba",
            "Kusini Unguja",
            "Lindi",
            "Mara",
            "Mbeya",
            "Mjini Magharibi",
            "Morogoro",
            "Mtwara",
            "Mwanza",
            "Pwani",
            "Rukwa",
            "Ruvuma",
            "Shinyanga",
            "Singida",
            "Tabora",
            "Tanga",
            "Manyara"
        )
    }
    "Ukraine" = @{
        "States" = @(
            "Vinnyts'ka Oblast'",
            "Volyns'ka Oblast'",
            "Luhans'ka Oblast'",
            "Dnipropetrovs'ka Oblast'",
            "Donets'ka Oblast'",
            "Zhytomyrs'ka Oblast'",
            "Zakarpats'ka Oblast'",
            "Zaporiz'ka Oblast'",
            "Ivano-Frankivs'ka Oblast'",
            "Kyïvs'ka mis'ka rada",
            "Kyïvs'ka Oblast'",
            "Kirovohrads'ka Oblast'",
            "Sevastopol",
            "Respublika Krym",
            "L'vivs'ka Oblast'",
            "Mykolaïvs'ka Oblast'",
            "Odes'ka Oblast'",
            "Poltavs'ka Oblast'",
            "Rivnens'ka Oblast'",
            "Sums 'ka Oblast'",
            "Ternopil's'ka Oblast'",
            "Kharkivs'ka Oblast'",
            "Khersons'ka Oblast'",
            "Khmel'nyts'ka Oblast'",
            "Cherkas'ka Oblast'",
            "Chernihivs'ka Oblast'",
            "Chernivets'ka Oblast'"
        )
    }
    "Uganda" = @{
        "States" = @(
            "Central",
            "Eastern",
            "Northern",
            "Western"
        )
    }
    "United States Minor Outlying Islands" = @{
        "States" = @(
            "Johnston Atoll",
            "Midway Islands",
            "Navassa Island",
            "Wake Island",
            "Baker Island",
            "Howland Island",
            "Jarvis Island",
            "Kingman Reef",
            "Palmyra Atoll"
        )
    }
    "United States" = @{
        "States" = @(
            "Alaska",
            "Alabama",
            "Arkansas",
            "American Samoa",
            "Arizona",
            "California",
            "Colorado",
            "Connecticut",
            "District of Columbia",
            "Delaware",
            "Florida",
            "Georgia",
            "Guam",
            "Hawaii",
            "Iowa",
            "Idaho",
            "Illinois",
            "Indiana",
            "Kansas",
            "Kentucky",
            "Louisiana",
            "Massachusetts",
            "Maryland",
            "Maine",
            "Michigan",
            "Minnesota",
            "Missouri",
            "Northern Mariana Islands",
            "Mississippi",
            "Montana",
            "North Carolina",
            "North Dakota",
            "Nebraska",
            "New Hampshire",
            "New Jersey",
            "New Mexico",
            "Nevada",
            "New York",
            "Ohio",
            "Oklahoma",
            "Oregon",
            "Pennsylvania",
            "Puerto Rico",
            "Rhode Island",
            "South Carolina",
            "South Dakota",
            "Tennessee",
            "Texas",
            "United States Minor Outlying Islands",
            "Utah",
            "Virginia",
            "Virgin Islands",
            "Vermont",
            "Washington",
            "Wisconsin",
            "West Virginia",
            "Wyoming",
            "Armed Forces Americas (except Canada)",
            "Armed Forces Africa, Canada, Europe, Middle East",
            "Armed Forces Pacific"
        )
    }
    "Uruguay" = @{
        "States" = @(
            "Artigas",
            "Canelones",
            "Cerro Largo",
            "Colonia",
            "Durazno",
            "Florida",
            "Flores",
            "Lavalleja",
            "Maldonado",
            "Montevideo",
            "Paysandú",
            "Río Negro",
            "Rocha",
            "Rivera",
            "Salto",
            "San José",
            "Soriano",
            "Tacuarembó",
            "Treinta y Tres"
        )
    }
    "Uzbekistan" = @{
        "States" = @(
            "Andijon",
            "Buxoro",
            "Farg'ona",
            "Jizzax",
            "Namangan",
            "Navoiy",
            "Qashqadaryo",
            "Qoraqalpog'iston Respublikasi",
            "Samarqand",
            "Sirdaryo",
            "Surxondaryo",
            "Toshkent",
            "Xorazm"
        )
    }
    "Holy See (Vatican City State)" = @{
        "States" = @(
        )
    }
    "Saint Vincent and the Grenadines" = @{
        "States" = @(
            "Charlotte",
            "Saint Andrew",
            "Saint David",
            "Saint George",
            "Saint Patrick",
            "Grenadines"
        )
    }
    "Venezuela, Bolivarian Republic of" = @{
        "States" = @(
            "Distrito Federal",
            "Anzoátegui",
            "Apure",
            "Aragua",
            "Barinas",
            "Bolívar",
            "Carabobo",
            "Cojedes",
            "Falcón",
            "Guárico",
            "Lara",
            "Mérida",
            "Miranda",
            "Monagas",
            "Nueva Esparta",
            "Portuguesa",
            "Sucre",
            "Táchira",
            "Trujillo",
            "Yaracuy",
            "Zulia",
            "Dependencias Federales",
            "Vargas",
            "Delta Amacuro",
            "Amazonas"
        )
    }
    "Virgin Islands, British" = @{
        "States" = @(
        )
    }
    "Virgin Islands, U.S." = @{
        "States" = @(
        )
    }
    "Vietnam" = @{
        "States" = @(
            "Lai Châu",
            "Lào Cai",
            "Hà Giang",
            "Cao Bằng",
            "Sơn La",
            "Yên Bái",
            "Tuyên Quang",
            "Lạng Sơn",
            "Quảng Ninh",
            "Hoà Bình",
            "Hà Tây",
            "Ninh Bình",
            "Thái Bình",
            "Thanh Hóa",
            "Nghệ An",
            "Hà Tỉnh",
            "Quảng Bình",
            "Quảng Trị",
            "Thừa Thiên-Huế",
            "Quảng Nam",
            "Kon Tum",
            "Quảng Ngãi",
            "Gia Lai",
            "Bình Định",
            "Phú Yên",
            "Đắc Lắk",
            "Khánh Hòa",
            "Lâm Đồng",
            "Ninh Thuận",
            "Tây Ninh",
            "Đồng Nai",
            "Bình Thuận",
            "Long An",
            "Bà Rịa-Vũng Tàu",
            "An Giang",
            "Đồng Tháp",
            "Tiền Giang",
            "Kiên Giang",
            "Vĩnh Long",
            "Bến Tre",
            "Trà Vinh",
            "Sóc Trăng",
            "Bắc Kạn",
            "Bắc Giang",
            "Bạc Liêu",
            "Bắc Ninh",
            "Bình Dương",
            "Bình Phước",
            "Cà Mau",
            "Hải Duong",
            "Hà Nam",
            "Hưng Yên",
            "Nam Định",
            "Phú Thọ",
            "Thái Nguyên",
            "Vĩnh Phúc",
            "Điện Biên",
            "Đắk Nông",
            "Hậu Giang",
            "Cần Thơ",
            "Đà Nẵng",
            "Hà Nội",
            "Hải Phòng",
            "Hồ Chí Minh [Sài Gòn]"
        )
    }
    "Vanuatu" = @{
        "States" = @(
            "Malampa",
            "Pénama",
            "Sanma",
            "Shéfa",
            "Taféa",
            "Torba"
        )
    }
    "Wallis and Futuna" = @{
        "States" = @(
        )
    }
    "Samoa" = @{
        "States" = @(
            "A'ana",
            "Aiga-i-le-Tai",
            "Atua",
            "Fa'asaleleaga",
            "Gaga'emauga",
            "Gagaifomauga",
            "Palauli",
            "Satupa'itea",
            "Tuamasaga",
            "Va'a-o-Fonoti",
            "Vaisigano"
        )
    }
    "Yemen" = @{
        "States" = @(
            "Abyān",
            "'Adan",
            "'Amrān",
            "Al Bayḑā'",
            "Aḑ Ḑāli‘",
            "Dhamār",
            "Ḩaḑramawt",
            "Ḩajjah",
            "Ibb",
            "Al Jawf",
            "Laḩij",
            "Ma'rib",
            "Al Mahrah",
            "Al Ḩudaydah",
            "Al Maḩwīt",
            "Raymah",
            "Şa'dah",
            "Shabwah",
            "Şan'ā'",
            "Tā'izz"
        )
    }
    "Mayotte" = @{
        "States" = @(
        )
    }
    "South Africa" = @{
        "States" = @(
            "Eastern Cape",
            "Free State",
            "Gauteng",
            "Limpopo",
            "Mpumalanga",
            "Northern Cape",
            "North-West (South Africa)",
            "Western Cape",
            "Kwazulu-Natal"
        )
    }
    "Zambia" = @{
        "States" = @(
            "Western",
            "Central",
            "Eastern",
            "Luapula",
            "Northern",
            "North-Western",
            "Southern (Zambia)",
            "Copperbelt",
            "Lusaka"
        )
    }
    "Zimbabwe" = @{
        "States" = @(
            "Bulawayo",
            "Harare",
            "Manicaland",
            "Mashonaland Central",
            "Mashonaland East",
            "Midlands",
            "Matabeleland North",
            "Matabeleland South",
            "Masvingo",
            "Mashonaland West"
        )
    }
}

$Languages = @{
    "en" = "English"
    "de" = "German"
}


# Abstract Completers ____________________________________________________________________________________________

function StandardCompleter
{
    param
    (
        [String[]]
        $CompletionsList,

        [string]
        $CommandName,

        [string]
        $ParameterName,

        [string]
        $WordToComplete,

        [System.Management.Automation.Language.CommandAst]
        $CommandAst,

        [System.Collections.IDictionary]
        $FakeBoundParameters
    )

    # get initial values
    $Completions = $CompletionsList

    # filter $Completions by anything already typed.
    if ($WordToComplete) {$Completions = $Completions | where {$_ -like "*$WordToComplete*"}}

    # wrap $Completions with 'non-word' characters in single-quotes.
    $Completions = $Completions | foreach { if ($_ -match "^\w*$") {"$_"} else {"`'$_`'"} }
    
    # unwrap $Completions array for one-by-one tab-completion
    $Completions | foreach {$_}
}


function CommentedCompleterFromKeys
{
    # "Key <#  Value  #>" where KEY -like $WordToComplete

    param
    (
        [Hashtable]
        $CommentsDict,

        [string]
        $CommandName,

        [string]
        $ParameterName,

        [string]
        $WordToComplete,

        [System.Management.Automation.Language.CommandAst]
        $CommandAst,

        [System.Collections.IDictionary]
        $FakeBoundParameters
    )

    # get initial values
    $Completions = $CommentsDict.Keys

    # filter completions by anything already typed.
    if ($WordToComplete) { $Completions = $Completions | where {$_ -like "*$WordToComplete*"} }

    # wrap completions with 'non-word' characters in single-quotes.
    # add comments to tab-completion, from dict vals.
    $Completions = $Completions | foreach {
        if ($_ -match "^\w*$") {"$_ <#  $($CommentsDict[$_])  #>"}
        else {"`'$_`' <#  $($CommentsDict[$_])  #>"}
    }
    # unwrap $Completions array for one-by-one tab-completion
    $Completions | foreach {$_}
}


function CommentedCompleterFromValues
{
    # "Key <#  Value  #>" where VALUE -like $WordToComplete

    param
    (
        [Hashtable]
        $CommentsDict,

        [string]
        $CommandName,

        [string]
        $ParameterName,

        [string]
        $WordToComplete,

        [System.Management.Automation.Language.CommandAst]
        $CommandAst,

        [System.Collections.IDictionary]
        $FakeBoundParameters
    )

    # get initial values
    $Completions = $CommentsDict.Keys

    # filter completions by anything already typed.
    if ($WordToComplete) {
        $WordToComplete = $WordToComplete.Split(',')[-1]
        $Completions = $Completions | where {$CommentsDict[$_] -like "*$WordToComplete*"}
    }

    # wrap completions with 'non-word' characters in single-quotes.
    # add comments to tab-completion, from dict vals.
    $Completions = $Completions | foreach {
        if ($_ -match "^\w*$") {"$_ <#  $($CommentsDict[$_])  #>"}
        else {"`'$_`' <#  $($CommentsDict[$_])  #>"}
    }
    # unwrap $Completions array for one-by-one tab-completion
    $Completions | foreach {$_}
}



# Concrete Completers ____________________________________________________________________________________________

function ServiceTypeCompleter
{
    param
    (
        [string]
        $CommandName,

        [string]
        $ParameterName,

        [string]
        $WordToComplete,

        [System.Management.Automation.Language.CommandAst]
        $CommandAst,

        [System.Collections.IDictionary]
        $FakeBoundParameters
    )
    
    $completer_args = @{
        CommentsDict = $ServiceTypes
        CommandName = $CommandName
        ParameterName = $ParameterName
        WordToComplete = $WordToComplete
        CommandAst = $CommandAst
        FakeBoundParameters = $FakeBoundParameters
    }

    CommentedCompleterFromValues @completer_args
}

function AdminServiceTypeCompleter
{
    param
    (
        [string]
        $CommandName,

        [string]
        $ParameterName,

        [string]
        $WordToComplete,

        [System.Management.Automation.Language.CommandAst]
        $CommandAst,

        [System.Collections.IDictionary]
        $FakeBoundParameters
    )
    
    $completer_args = @{
        CommentsDict = $AdminServiceTypes
        CommandName = $CommandName
        ParameterName = $ParameterName
        WordToComplete = $WordToComplete
        CommandAst = $CommandAst
        FakeBoundParameters = $FakeBoundParameters
    }

    CommentedCompleterFromValues @completer_args
}


function ConstructionTypeCompleter
{
    param
    (
        [string]
        $CommandName,

        [string]
        $ParameterName,

        [string]
        $WordToComplete,

        [System.Management.Automation.Language.CommandAst]
        $CommandAst,

        [System.Collections.IDictionary]
        $FakeBoundParameters
    )
    
    $completer_args = @{
        CompletionsList = $ConstructionTypes
        CommandName = $CommandName
        ParameterName = $ParameterName
        WordToComplete = $WordToComplete
        CommandAst = $CommandAst
        FakeBoundParameters = $FakeBoundParameters
    }

    StandardCompleter @completer_args
}


function ContractTypeCompleter {
    param (
        [string]
        $CommandName,

        [string]
        $ParameterName,

        [string]
        $WordToComplete,

        [System.Management.Automation.Language.CommandAst]
        $CommandAst,

        [System.Collections.IDictionary]
        $FakeBoundParameters
    )
    
    $completer_args = @{
        CompletionsList = $ContractTypes
        CommandName = $CommandName
        ParameterName = $ParameterName
        WordToComplete = $WordToComplete
        CommandAst = $CommandAst
        FakeBoundParameters = $FakeBoundParameters
    }

    StandardCompleter @completer_args
}


function ProjectTypeCompleter {
    param (
        [string]
        $CommandName,

        [string]
        $ParameterName,

        [string]
        $WordToComplete,

        [System.Management.Automation.Language.CommandAst]
        $CommandAst,

        [System.Collections.IDictionary]
        $FakeBoundParameters
    )

    $completer_args = @{
        CompletionsList = $ProjectTypes
        CommandName = $CommandName
        ParameterName = $ParameterName
        WordToComplete = $WordToComplete
        CommandAst = $CommandAst
        FakeBoundParameters = $FakeBoundParameters
    }

    StandardCompleter @completer_args
}


function CurrencyCompleter
{
    param
    (
        [string]
        $CommandName,

        [string]
        $ParameterName,

        [string]
        $WordToComplete,

        [System.Management.Automation.Language.CommandAst]
        $CommandAst,

        [System.Collections.IDictionary]
        $FakeBoundParameters
    )

    $completer_args = @{
        CommentsDict = $Currencies
        CommandName = $CommandName
        ParameterName = $ParameterName
        WordToComplete = $WordToComplete
        CommandAst = $CommandAst
        FakeBoundParameters = $FakeBoundParameters
    }

    CommentedCompleterFromKeys @completer_args
}


function TimezoneCompleter
{
    param
    (
        [string]
        $CommandName,

        [string]
        $ParameterName,

        [string]
        $WordToComplete,

        [System.Management.Automation.Language.CommandAst]
        $CommandAst,

        [System.Collections.IDictionary]
        $FakeBoundParameters
    )

    $completer_args = @{
        CompletionsList = $Timezones
        CommandName = $CommandName
        ParameterName = $ParameterName
        WordToComplete = $WordToComplete
        CommandAst = $CommandAst
        FakeBoundParameters = $FakeBoundParameters
    }

    StandardCompleter @completer_args
}


function TradeCompleter
{
    param
    (
        [string]
        $CommandName,

        [string]
        $ParameterName,

        [string]
        $WordToComplete,

        [System.Management.Automation.Language.CommandAst]
        $CommandAst,

        [System.Collections.IDictionary]
        $FakeBoundParameters
    )

    $completer_args = @{
        CompletionsList = $Trades
        CommandName = $CommandName
        ParameterName = $ParameterName
        WordToComplete = $WordToComplete
        CommandAst = $CommandAst
        FakeBoundParameters = $FakeBoundParameters
    }

    StandardCompleter @completer_args
}


function CountryCompleter
{
    param
    (
        [string]
        $CommandName,

        [string]
        $ParameterName,

        [string]
        $WordToComplete,

        [System.Management.Automation.Language.CommandAst]
        $CommandAst,

        [System.Collections.IDictionary]
        $FakeBoundParameters
    )

    $completer_args = @{
        CompletionsList = $Countries.Keys
        CommandName = $CommandName
        ParameterName = $ParameterName
        WordToComplete = $WordToComplete
        CommandAst = $CommandAst
        FakeBoundParameters = $FakeBoundParameters
    }

    StandardCompleter @completer_args
}


function StateCompleter
{
    param
    (
        [string]
        $CommandName,

        [string]
        $ParameterName,

        [string]
        $WordToComplete,

        [System.Management.Automation.Language.CommandAst]
        $CommandAst,

        [System.Collections.IDictionary]
        $FakeBoundParameters
    )

    if ($FakeBoundParameters.ContainsKey("Country"))
    {
        $completer_args = @{
            CompletionsList = $Countries.$($FakeBoundParameters.Country).States
            CommandName = $CommandName
            ParameterName = $ParameterName
            WordToComplete = $WordToComplete
            CommandAst = $CommandAst
            FakeBoundParameters = $FakeBoundParameters
        }

        $Completions = StandardCompleter @completer_args
    }
    else
    {
        $Completions = @("<#  !!! Provide -Country parameter value first !!!  #>")
    }

    $Completions | foreach {$_}
}


function LanguageCompleter
{
    param
    (
        [string]
        $CommandName,

        [string]
        $ParameterName,

        [string]
        $WordToComplete,

        [System.Management.Automation.Language.CommandAst]
        $CommandAst,

        [System.Collections.IDictionary]
        $FakeBoundParameters
    )

    $completer_args = @{
        CommentsDict = $Languages
        CommandName = $CommandName
        ParameterName = $ParameterName
        WordToComplete = $WordToComplete
        CommandAst = $CommandAst
        FakeBoundParameters = $FakeBoundParameters
    }

    CommentedCompleterFromKeys @completer_args
}


function DateCompleter
{
    param
    (
        [string]
        $CommandName,

        [string]
        $ParameterName,

        [string]
        $WordToComplete,

        [System.Management.Automation.Language.CommandAst]
        $CommandAst,

        [System.Collections.IDictionary]
        $FakeBoundParameters
    )

    if ($WordToComplete)
    {
        ( [DateTime]::Parse($WordToComplete) + [TimeSpan]::FromDays(1) ).ToString("yyyy-MM-dd")
    }
    else
    {
        [DateTime]::Today.ToString("yyyy-MM-dd")
    }
}


function MoneyValueCompleter
{
    param
    (
        [string]
        $CommandName,

        [string]
        $ParameterName,

        [string]
        $WordToComplete,

        [System.Management.Automation.Language.CommandAst]
        $CommandAst,

        [System.Collections.IDictionary]
        $FakeBoundParameters
    )

    if ($WordToComplete)
    {
        "$($WordToComplete | Convert-MoneyAbrev) <# $WordToComplete #>"
    }
    else
    {
        0
    }
}


# Validators _____________________________________________________________________________________________________

function ServiceTypeValidator
{
    <#
    - can be empty string (-> all available services will be enabled)
    - can be multiple services (as comma-separated string)
    https://forge.autodesk.com/en/docs/bim360/v1/reference/http/projects-POST/#body-structure
    #>

    if ($_ -eq "")
    { # all service types
        $true
    }
    elseif ($_ -like "*,*")
    { # multiple service types
        foreach ($i in $_.Split(",")) {$i -in $ServiceTypes.Keys}
    }
    else
    { # one service type
        $_ -in $ServiceTypes.Keys
    }
}

function AdminServiceTypeValidator
{
    <#
    #>

    if ($_ -eq "")
    { # all service types
        $true
    }
    elseif ($_ -like "*,*")
    { # multiple service types
        foreach ($i in $_.Split(",")) {$i -in $AdminServiceTypes.Keys}
    }
    else
    { # one service type
        $_ -in $AdminServiceTypes.Keys
    }
}

function ConstructionTypeValidator
{
    $_ -in $ConstructionTypes
}

function ContractTypeValidator
{
    $_ -in $ContractTypes
}

function ProjectTypeValidator
{
    $_ -in $ProjectTypes
}

function CurrencyValidator
{
    $_ -in $Currencies.Keys
}

function TimezoneValidator
{
    $_ -in $Timezones
}

function TradeValidator
{
    $_ -in $Trades
}

function CountryValidator
{
    $_ -in $Countries.Keys
}

function StateValidator
{
    $_ -in $Countries.$Country.States
}

function LanguageValidator
{
    $_ -in $Languages.Keys
}

function DateValidator
{
    $_ -match "^\d\d\d\d-\d\d-\d\d$"
}

function MoneyValueValidator
{
    $_ -match "^\d*$"
}


# Testing ________________________________________________________________________________________________________

# function Test-Func {
#     param (
#         [Parameter()]
#         [ArgumentCompleter({ ServiceTypeCompleter @args })]
#         [ValidateScript({ ServiceTypeValidator })]
#         $ServiceTypes,
        
#         [Parameter()]
#         [ArgumentCompleter({ ConstructionTypeCompleter @args })]
#         [ValidateScript({ ConstructionTypeValidator })]
#         $ConstructionType,
        
#         [Parameter()]
#         [ArgumentCompleter({ ContractTypeCompleter @args })]
#         [ValidateScript({ ContractTypeValidator })]
#         $ContractType,
        
#         [Parameter()]
#         [ArgumentCompleter({ ProjectTypeCompleter @args })]
#         [ValidateScript({ ProjectTypeValidator })]
#         $ProjectType,
        
#         [Parameter()]
#         [ArgumentCompleter({ CurrencyCompleter @args })]
#         [ValidateScript({ CurrencyValidator })]
#         $Currency,
        
#         [Parameter()]
#         [ArgumentCompleter({ TimezoneCompleter @args })]
#         [ValidateScript({ TimezoneValidator })]
#         $Timezone,
        
#         [Parameter()]
#         [ArgumentCompleter({ TradeCompleter @args })]
#         [ValidateScript({ TradeValidator })]
#         $Trade,
        
#         [Parameter()]
#         [ArgumentCompleter({ CountryCompleter @args })]
#         [ValidateScript({ CountryValidator })]
#         $Country,
        
#         [Parameter()]
#         [ArgumentCompleter({ StateCompleter @args })]
#         [ValidateScript({ StateValidator })]
#         $State,
        
#         [Parameter()]
#         [ArgumentCompleter({ LanguageCompleter @args })]
#         [ValidateScript({ LanguageValidator })]
#         $Language,
        
#         [Parameter()]
#         [ArgumentCompleter({ DateCompleter @args })]
#         [ValidateScript({ DateValidator })]
#         $Date,
        
#         [Parameter()]
#         [ArgumentCompleter({ MoneyValueCompleter @args })]
#         [ValidateScript({ MoneyValueValidator })]
#         $MoneyValue
#     )
#     Write-Host $ServiceType
#     Write-Host $ConstructionType
#     Write-Host $ContractType
#     Write-Host $ProjectType
#     Write-Host $Currency
#     Write-Host $Timezone
#     Write-Host $Trade
#     Write-Host $Country
#     Write-Host $State
#     Write-Host $Language
#     Write-Host $Date
#     Write-host $MoneyValue
# }
