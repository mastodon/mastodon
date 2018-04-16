# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Indexes
      module Countries
        include CountryIndexDefinition

        country 'AD', 'Andorra' do |c|
          c.timezone 'Europe/Andorra', 85, 2, 91, 60
        end
        country 'AE', 'United Arab Emirates' do |c|
          c.timezone 'Asia/Dubai', 253, 10, 553, 10
        end
        country 'AF', 'Afghanistan' do |c|
          c.timezone 'Asia/Kabul', 2071, 60, 346, 5
        end
        country 'AG', 'Antigua & Barbuda' do |c|
          c.timezone 'America/Port_of_Spain', 213, 20, -3691, 60
        end
        country 'AI', 'Anguilla' do |c|
          c.timezone 'America/Port_of_Spain', 213, 20, -3691, 60
        end
        country 'AL', 'Albania' do |c|
          c.timezone 'Europe/Tirane', 124, 3, 119, 6
        end
        country 'AM', 'Armenia' do |c|
          c.timezone 'Asia/Yerevan', 2411, 60, 89, 2
        end
        country 'AO', 'Angola' do |c|
          c.timezone 'Africa/Lagos', 129, 20, 17, 5, 'West Africa Time (UTC+1)'
        end
        country 'AQ', 'Antarctica' do |c|
          c.timezone 'Antarctica/Rothera', -2027, 30, -1022, 15, 'Rothera Station, Adelaide Island'
          c.timezone 'Antarctica/Palmer', -324, 5, -641, 10, 'Palmer Station, Anvers Island'
          c.timezone 'Antarctica/Mawson', -338, 5, 3773, 60, 'Mawson Station, Holme Bay'
          c.timezone 'Antarctica/Davis', -823, 12, 2339, 30, 'Davis Station, Vestfold Hills'
          c.timezone 'Antarctica/Casey', -3977, 60, 6631, 60, 'Casey Station, Bailey Peninsula'
          c.timezone 'Antarctica/Vostok', -392, 5, 1069, 10, 'Vostok Station, Lake Vostok'
          c.timezone 'Antarctica/DumontDUrville', -200, 3, 8401, 60, 'Dumont-d\'Urville Station, Terre Adelie'
          c.timezone 'Antarctica/Syowa', -124211, 1800, 3959, 100, 'Syowa Station, E Ongul I'
          c.timezone 'Antarctica/Troll', -259241, 3600, 507, 200, 'Troll Station, Queen Maud Land'
          c.timezone 'Pacific/Auckland', -553, 15, 5243, 30, 'New Zealand time'
        end
        country 'AR', 'Argentina' do |c|
          c.timezone 'America/Argentina/Buenos_Aires', -173, 5, -1169, 20, 'Buenos Aires (BA, CF)'
          c.timezone 'America/Argentina/Cordoba', -157, 5, -3851, 60, 'most locations (CB, CC, CN, ER, FM, MN, SE, SF)'
          c.timezone 'America/Argentina/Salta', -1487, 60, -785, 12, '(SA, LP, NQ, RN)'
          c.timezone 'America/Argentina/Jujuy', -1451, 60, -653, 10, 'Jujuy (JY)'
          c.timezone 'America/Argentina/Tucuman', -1609, 60, -3913, 60, 'Tucumán (TM)'
          c.timezone 'America/Argentina/Catamarca', -427, 15, -3947, 60, 'Catamarca (CT), Chubut (CH)'
          c.timezone 'America/Argentina/La_Rioja', -883, 30, -1337, 20, 'La Rioja (LR)'
          c.timezone 'America/Argentina/San_Juan', -473, 15, -4111, 60, 'San Juan (SJ)'
          c.timezone 'America/Argentina/Mendoza', -1973, 60, -4129, 60, 'Mendoza (MZ)'
          c.timezone 'America/Argentina/San_Luis', -1999, 60, -1327, 20, 'San Luis (SL)'
          c.timezone 'America/Argentina/Rio_Gallegos', -1549, 30, -4153, 60, 'Santa Cruz (SC)'
          c.timezone 'America/Argentina/Ushuaia', -274, 5, -683, 10, 'Tierra del Fuego (TF)'
        end
        country 'AS', 'Samoa (American)' do |c|
          c.timezone 'Pacific/Pago_Pago', -214, 15, -1707, 10, 'Samoa, Midway'
        end
        country 'AT', 'Austria' do |c|
          c.timezone 'Europe/Vienna', 2893, 60, 49, 3
        end
        country 'AU', 'Australia' do |c|
          c.timezone 'Australia/Lord_Howe', -631, 20, 1909, 12, 'Lord Howe Island'
          c.timezone 'Antarctica/Macquarie', -109, 2, 3179, 20, 'Macquarie Island'
          c.timezone 'Australia/Hobart', -2573, 60, 8839, 60, 'Tasmania - most locations'
          c.timezone 'Australia/Currie', -599, 15, 2158, 15, 'Tasmania - King Island'
          c.timezone 'Australia/Melbourne', -2269, 60, 4349, 30, 'Victoria'
          c.timezone 'Australia/Sydney', -508, 15, 9073, 60, 'New South Wales - most locations'
          c.timezone 'Australia/Broken_Hill', -639, 20, 2829, 20, 'New South Wales - Yancowinna'
          c.timezone 'Australia/Brisbane', -412, 15, 4591, 30, 'Queensland - most locations'
          c.timezone 'Australia/Lindeman', -304, 15, 149, 1, 'Queensland - Holiday Islands'
          c.timezone 'Australia/Adelaide', -419, 12, 1663, 12, 'South Australia'
          c.timezone 'Australia/Darwin', -187, 15, 785, 6, 'Northern Territory'
          c.timezone 'Australia/Perth', -639, 20, 2317, 20, 'Western Australia - most locations'
          c.timezone 'Australia/Eucla', -1903, 60, 1933, 15, 'Western Australia - Eucla area'
        end
        country 'AW', 'Aruba' do |c|
          c.timezone 'America/Curacao', 731, 60, -69, 1
        end
        country 'AX', 'Aaland Islands' do |c|
          c.timezone 'Europe/Helsinki', 361, 6, 749, 30
        end
        country 'AZ', 'Azerbaijan' do |c|
          c.timezone 'Asia/Baku', 2423, 60, 997, 20
        end
        country 'BA', 'Bosnia & Herzegovina' do |c|
          c.timezone 'Europe/Belgrade', 269, 6, 41, 2
        end
        country 'BB', 'Barbados' do |c|
          c.timezone 'America/Barbados', 131, 10, -3577, 60
        end
        country 'BD', 'Bangladesh' do |c|
          c.timezone 'Asia/Dhaka', 1423, 60, 1085, 12
        end
        country 'BE', 'Belgium' do |c|
          c.timezone 'Europe/Brussels', 305, 6, 13, 3
        end
        country 'BF', 'Burkina Faso' do |c|
          c.timezone 'Africa/Abidjan', 319, 60, -121, 30
        end
        country 'BG', 'Bulgaria' do |c|
          c.timezone 'Europe/Sofia', 2561, 60, 1399, 60
        end
        country 'BH', 'Bahrain' do |c|
          c.timezone 'Asia/Qatar', 1517, 60, 773, 15
        end
        country 'BI', 'Burundi' do |c|
          c.timezone 'Africa/Maputo', -779, 30, 391, 12, 'Central Africa Time (UTC+2)'
        end
        country 'BJ', 'Benin' do |c|
          c.timezone 'Africa/Lagos', 129, 20, 17, 5, 'West Africa Time (UTC+1)'
        end
        country 'BL', 'St Barthelemy' do |c|
          c.timezone 'America/Port_of_Spain', 213, 20, -3691, 60
        end
        country 'BM', 'Bermuda' do |c|
          c.timezone 'Atlantic/Bermuda', 1937, 60, -1943, 30
        end
        country 'BN', 'Brunei' do |c|
          c.timezone 'Asia/Brunei', 74, 15, 1379, 12
        end
        country 'BO', 'Bolivia' do |c|
          c.timezone 'America/La_Paz', -33, 2, -1363, 20
        end
        country 'BQ', 'Caribbean Netherlands' do |c|
          c.timezone 'America/Curacao', 731, 60, -69, 1
        end
        country 'BR', 'Brazil' do |c|
          c.timezone 'America/Noronha', -77, 20, -389, 12, 'Atlantic islands'
          c.timezone 'America/Belem', -29, 20, -2909, 60, 'Amapá, E Pará'
          c.timezone 'America/Fortaleza', -223, 60, -77, 2, 'NE Brazil (MA, PI, CE, RN, PB)'
          c.timezone 'America/Recife', -161, 20, -349, 10, 'Pernambuco'
          c.timezone 'America/Araguaina', -36, 5, -241, 5, 'Tocantins'
          c.timezone 'America/Maceio', -29, 3, -2143, 60, 'Alagoas, Sergipe'
          c.timezone 'America/Bahia', -779, 60, -2311, 60, 'Bahia'
          c.timezone 'America/Sao_Paulo', -353, 15, -2797, 60, 'S & SE Brazil (GO, DF, MG, ES, RJ, SP, PR, SC, RS)'
          c.timezone 'America/Campo_Grande', -409, 20, -3277, 60, 'Mato Grosso do Sul'
          c.timezone 'America/Cuiaba', -187, 12, -673, 12, 'Mato Grosso'
          c.timezone 'America/Santarem', -73, 30, -823, 15, 'W Pará'
          c.timezone 'America/Porto_Velho', -263, 30, -639, 10, 'Rondônia'
          c.timezone 'America/Boa_Vista', 169, 60, -182, 3, 'Roraima'
          c.timezone 'America/Manaus', -47, 15, -3601, 60, 'E Amazonas'
          c.timezone 'America/Eirunepe', -20, 3, -1048, 15, 'W Amazonas'
          c.timezone 'America/Rio_Branco', -299, 30, -339, 5, 'Acre'
        end
        country 'BS', 'Bahamas' do |c|
          c.timezone 'America/Nassau', 301, 12, -1547, 20
        end
        country 'BT', 'Bhutan' do |c|
          c.timezone 'Asia/Thimphu', 412, 15, 1793, 20
        end
        country 'BV', 'Bouvet Island'
        country 'BW', 'Botswana' do |c|
          c.timezone 'Africa/Maputo', -779, 30, 391, 12, 'Central Africa Time (UTC+2)'
        end
        country 'BY', 'Belarus' do |c|
          c.timezone 'Europe/Minsk', 539, 10, 827, 30
        end
        country 'BZ', 'Belize' do |c|
          c.timezone 'America/Belize', 35, 2, -441, 5
        end
        country 'CA', 'Canada' do |c|
          c.timezone 'America/St_Johns', 1427, 30, -3163, 60, 'Newfoundland Time, including SE Labrador'
          c.timezone 'America/Halifax', 893, 20, -318, 5, 'Atlantic Time - Nova Scotia (most places), PEI'
          c.timezone 'America/Glace_Bay', 231, 5, -1199, 20, 'Atlantic Time - Nova Scotia - places that did not observe DST 1966-1971'
          c.timezone 'America/Moncton', 461, 10, -3887, 60, 'Atlantic Time - New Brunswick'
          c.timezone 'America/Goose_Bay', 160, 3, -725, 12, 'Atlantic Time - Labrador - most locations'
          c.timezone 'America/Blanc-Sablon', 617, 12, -3427, 60, 'Atlantic Standard Time - Quebec - Lower North Shore'
          c.timezone 'America/Toronto', 873, 20, -4763, 60, 'Eastern Time - Ontario & Quebec - most locations'
          c.timezone 'America/Nipigon', 2941, 60, -1324, 15, 'Eastern Time - Ontario & Quebec - places that did not observe DST 1967-1973'
          c.timezone 'America/Thunder_Bay', 2903, 60, -357, 4, 'Eastern Time - Thunder Bay, Ontario'
          c.timezone 'America/Iqaluit', 956, 15, -1027, 15, 'Eastern Time - east Nunavut - most locations'
          c.timezone 'America/Pangnirtung', 992, 15, -986, 15, 'Eastern Time - Pangnirtung, Nunavut'
          c.timezone 'America/Resolute', 33613, 450, -22759, 240, 'Central Time - Resolute, Nunavut'
          c.timezone 'America/Atikokan', 175531, 3600, -54973, 600, 'Eastern Standard Time - Atikokan, Ontario and Southampton I, Nunavut'
          c.timezone 'America/Rankin_Inlet', 3769, 60, -331499, 3600, 'Central Time - central Nunavut'
          c.timezone 'America/Winnipeg', 2993, 60, -1943, 20, 'Central Time - Manitoba & west Ontario'
          c.timezone 'America/Rainy_River', 2923, 60, -2837, 30, 'Central Time - Rainy River & Fort Frances, Ontario'
          c.timezone 'America/Regina', 252, 5, -2093, 20, 'Central Standard Time - Saskatchewan - most locations'
          c.timezone 'America/Swift_Current', 3017, 60, -647, 6, 'Central Standard Time - Saskatchewan - midwest'
          c.timezone 'America/Edmonton', 1071, 20, -1702, 15, 'Mountain Time - Alberta, east British Columbia & west Saskatchewan'
          c.timezone 'America/Cambridge_Bay', 24881, 360, -37819, 360, 'Mountain Time - west Nunavut'
          c.timezone 'America/Yellowknife', 1249, 20, -2287, 20, 'Mountain Time - central Northwest Territories'
          c.timezone 'America/Inuvik', 246059, 3600, -8023, 60, 'Mountain Time - west Northwest Territories'
          c.timezone 'America/Creston', 491, 10, -6991, 60, 'Mountain Standard Time - Creston, British Columbia'
          c.timezone 'America/Dawson_Creek', 1793, 30, -3607, 30, 'Mountain Standard Time - Dawson Creek & Fort Saint John, British Columbia'
          c.timezone 'America/Vancouver', 739, 15, -7387, 60, 'Pacific Time - west British Columbia'
          c.timezone 'America/Whitehorse', 3643, 60, -2701, 20, 'Pacific Time - south Yukon'
          c.timezone 'America/Dawson', 961, 15, -1673, 12, 'Pacific Time - north Yukon'
        end
        country 'CC', 'Cocos (Keeling) Islands' do |c|
          c.timezone 'Indian/Cocos', -73, 6, 1163, 12
        end
        country 'CD', 'Congo (Dem. Rep.)' do |c|
          c.timezone 'Africa/Maputo', -779, 30, 391, 12, 'Central Africa Time (UTC+2)'
          c.timezone 'Africa/Lagos', 129, 20, 17, 5, 'West Africa Time (UTC+1)'
        end
        country 'CF', 'Central African Rep.' do |c|
          c.timezone 'Africa/Lagos', 129, 20, 17, 5, 'West Africa Time (UTC+1)'
        end
        country 'CG', 'Congo (Rep.)' do |c|
          c.timezone 'Africa/Lagos', 129, 20, 17, 5, 'West Africa Time (UTC+1)'
        end
        country 'CH', 'Switzerland' do |c|
          c.timezone 'Europe/Zurich', 2843, 60, 128, 15, 'Swiss time'
        end
        country 'CI', 'Cote d\'Ivoire' do |c|
          c.timezone 'Africa/Abidjan', 319, 60, -121, 30
        end
        country 'CK', 'Cook Islands' do |c|
          c.timezone 'Pacific/Rarotonga', -637, 30, -4793, 30
        end
        country 'CL', 'Chile' do |c|
          c.timezone 'America/Santiago', -669, 20, -212, 3, 'most locations'
          c.timezone 'Pacific/Easter', -543, 20, -3283, 30, 'Easter Island'
        end
        country 'CM', 'Cameroon' do |c|
          c.timezone 'Africa/Lagos', 129, 20, 17, 5, 'West Africa Time (UTC+1)'
        end
        country 'CN', 'China' do |c|
          c.timezone 'Asia/Shanghai', 937, 30, 1822, 15, 'Beijing Time'
          c.timezone 'Asia/Urumqi', 219, 5, 1051, 12, 'Xinjiang Time'
        end
        country 'CO', 'Colombia' do |c|
          c.timezone 'America/Bogota', 23, 5, -889, 12
        end
        country 'CR', 'Costa Rica' do |c|
          c.timezone 'America/Costa_Rica', 149, 15, -1009, 12
        end
        country 'CU', 'Cuba' do |c|
          c.timezone 'America/Havana', 347, 15, -2471, 30
        end
        country 'CV', 'Cape Verde' do |c|
          c.timezone 'Atlantic/Cape_Verde', 179, 12, -1411, 60
        end
        country 'CW', 'Curacao' do |c|
          c.timezone 'America/Curacao', 731, 60, -69, 1
        end
        country 'CX', 'Christmas Island' do |c|
          c.timezone 'Indian/Christmas', -125, 12, 6343, 60
        end
        country 'CY', 'Cyprus' do |c|
          c.timezone 'Asia/Nicosia', 211, 6, 1001, 30
        end
        country 'CZ', 'Czech Republic' do |c|
          c.timezone 'Europe/Prague', 601, 12, 433, 30
        end
        country 'DE', 'Germany' do |c|
          c.timezone 'Europe/Berlin', 105, 2, 401, 30, 'Berlin time'
          c.timezone 'Europe/Zurich', 2843, 60, 128, 15, 'Swiss time'
        end
        country 'DJ', 'Djibouti' do |c|
          c.timezone 'Africa/Nairobi', -77, 60, 2209, 60
        end
        country 'DK', 'Denmark' do |c|
          c.timezone 'Europe/Copenhagen', 167, 3, 151, 12
        end
        country 'DM', 'Dominica' do |c|
          c.timezone 'America/Port_of_Spain', 213, 20, -3691, 60
        end
        country 'DO', 'Dominican Republic' do |c|
          c.timezone 'America/Santo_Domingo', 277, 15, -699, 10
        end
        country 'DZ', 'Algeria' do |c|
          c.timezone 'Africa/Algiers', 2207, 60, 61, 20
        end
        country 'EC', 'Ecuador' do |c|
          c.timezone 'America/Guayaquil', -13, 6, -479, 6, 'mainland'
          c.timezone 'Pacific/Galapagos', -9, 10, -448, 5, 'Galápagos Islands'
        end
        country 'EE', 'Estonia' do |c|
          c.timezone 'Europe/Tallinn', 713, 12, 99, 4
        end
        country 'EG', 'Egypt' do |c|
          c.timezone 'Africa/Cairo', 601, 20, 125, 4
        end
        country 'EH', 'Western Sahara' do |c|
          c.timezone 'Africa/El_Aaiun', 543, 20, -66, 5
        end
        country 'ER', 'Eritrea' do |c|
          c.timezone 'Africa/Nairobi', -77, 60, 2209, 60
        end
        country 'ES', 'Spain' do |c|
          c.timezone 'Europe/Madrid', 202, 5, -221, 60, 'mainland'
          c.timezone 'Africa/Ceuta', 2153, 60, -319, 60, 'Ceuta & Melilla'
          c.timezone 'Atlantic/Canary', 281, 10, -77, 5, 'Canary Islands'
        end
        country 'ET', 'Ethiopia' do |c|
          c.timezone 'Africa/Nairobi', -77, 60, 2209, 60
        end
        country 'FI', 'Finland' do |c|
          c.timezone 'Europe/Helsinki', 361, 6, 749, 30
        end
        country 'FJ', 'Fiji' do |c|
          c.timezone 'Pacific/Fiji', -272, 15, 2141, 12
        end
        country 'FK', 'Falkland Islands' do |c|
          c.timezone 'Atlantic/Stanley', -517, 10, -1157, 20
        end
        country 'FM', 'Micronesia' do |c|
          c.timezone 'Pacific/Chuuk', 89, 12, 9107, 60, 'Chuuk (Truk) and Yap'
          c.timezone 'Pacific/Pohnpei', 209, 30, 9493, 60, 'Pohnpei (Ponape)'
          c.timezone 'Pacific/Kosrae', 319, 60, 9779, 60, 'Kosrae'
        end
        country 'FO', 'Faroe Islands' do |c|
          c.timezone 'Atlantic/Faroe', 3721, 60, -203, 30
        end
        country 'FR', 'France' do |c|
          c.timezone 'Europe/Paris', 733, 15, 7, 3
        end
        country 'GA', 'Gabon' do |c|
          c.timezone 'Africa/Lagos', 129, 20, 17, 5, 'West Africa Time (UTC+1)'
        end
        country 'GB', 'Britain (UK)' do |c|
          c.timezone 'Europe/London', 6181, 120, -451, 3600
        end
        country 'GD', 'Grenada' do |c|
          c.timezone 'America/Port_of_Spain', 213, 20, -3691, 60
        end
        country 'GE', 'Georgia' do |c|
          c.timezone 'Asia/Tbilisi', 2503, 60, 2689, 60
        end
        country 'GF', 'French Guiana' do |c|
          c.timezone 'America/Cayenne', 74, 15, -157, 3
        end
        country 'GG', 'Guernsey' do |c|
          c.timezone 'Europe/London', 6181, 120, -451, 3600
        end
        country 'GH', 'Ghana' do |c|
          c.timezone 'Africa/Accra', 111, 20, -13, 60
        end
        country 'GI', 'Gibraltar' do |c|
          c.timezone 'Europe/Gibraltar', 542, 15, -107, 20
        end
        country 'GL', 'Greenland' do |c|
          c.timezone 'America/Godthab', 3851, 60, -776, 15, 'most locations'
          c.timezone 'America/Danmarkshavn', 2303, 30, -56, 3, 'east coast, north of Scoresbysund'
          c.timezone 'America/Scoresbysund', 4229, 60, -659, 30, 'Scoresbysund / Ittoqqortoormiit'
          c.timezone 'America/Thule', 2297, 30, -4127, 60, 'Thule / Pituffik'
        end
        country 'GM', 'Gambia' do |c|
          c.timezone 'Africa/Abidjan', 319, 60, -121, 30
        end
        country 'GN', 'Guinea' do |c|
          c.timezone 'Africa/Abidjan', 319, 60, -121, 30
        end
        country 'GP', 'Guadeloupe' do |c|
          c.timezone 'America/Port_of_Spain', 213, 20, -3691, 60
        end
        country 'GQ', 'Equatorial Guinea' do |c|
          c.timezone 'Africa/Lagos', 129, 20, 17, 5, 'West Africa Time (UTC+1)'
        end
        country 'GR', 'Greece' do |c|
          c.timezone 'Europe/Athens', 1139, 30, 1423, 60
        end
        country 'GS', 'South Georgia & the South Sandwich Islands' do |c|
          c.timezone 'Atlantic/South_Georgia', -814, 15, -548, 15
        end
        country 'GT', 'Guatemala' do |c|
          c.timezone 'America/Guatemala', 439, 30, -5431, 60
        end
        country 'GU', 'Guam' do |c|
          c.timezone 'Pacific/Guam', 202, 15, 579, 4
        end
        country 'GW', 'Guinea-Bissau' do |c|
          c.timezone 'Africa/Bissau', 237, 20, -187, 12
        end
        country 'GY', 'Guyana' do |c|
          c.timezone 'America/Guyana', 34, 5, -349, 6
        end
        country 'HK', 'Hong Kong' do |c|
          c.timezone 'Asia/Hong_Kong', 1337, 60, 2283, 20
        end
        country 'HM', 'Heard Island & McDonald Islands'
        country 'HN', 'Honduras' do |c|
          c.timezone 'America/Tegucigalpa', 141, 10, -5233, 60
        end
        country 'HR', 'Croatia' do |c|
          c.timezone 'Europe/Belgrade', 269, 6, 41, 2
        end
        country 'HT', 'Haiti' do |c|
          c.timezone 'America/Port-au-Prince', 278, 15, -217, 3
        end
        country 'HU', 'Hungary' do |c|
          c.timezone 'Europe/Budapest', 95, 2, 229, 12
        end
        country 'ID', 'Indonesia' do |c|
          c.timezone 'Asia/Jakarta', -37, 6, 534, 5, 'Java & Sumatra'
          c.timezone 'Asia/Pontianak', -1, 30, 328, 3, 'west & central Borneo'
          c.timezone 'Asia/Makassar', -307, 60, 597, 5, 'east & south Borneo, Sulawesi (Celebes), Bali, Nusa Tengarra, west Timor'
          c.timezone 'Asia/Jayapura', -38, 15, 1407, 10, 'west New Guinea (Irian Jaya) & Malukus (Moluccas)'
        end
        country 'IE', 'Ireland' do |c|
          c.timezone 'Europe/Dublin', 160, 3, -25, 4
        end
        country 'IL', 'Israel' do |c|
          c.timezone 'Asia/Jerusalem', 11441, 360, 63403, 1800
        end
        country 'IM', 'Isle of Man' do |c|
          c.timezone 'Europe/London', 6181, 120, -451, 3600
        end
        country 'IN', 'India' do |c|
          c.timezone 'Asia/Kolkata', 338, 15, 2651, 30
        end
        country 'IO', 'British Indian Ocean Territory' do |c|
          c.timezone 'Indian/Chagos', -22, 3, 869, 12
        end
        country 'IQ', 'Iraq' do |c|
          c.timezone 'Asia/Baghdad', 667, 20, 533, 12
        end
        country 'IR', 'Iran' do |c|
          c.timezone 'Asia/Tehran', 107, 3, 1543, 30
        end
        country 'IS', 'Iceland' do |c|
          c.timezone 'Atlantic/Reykjavik', 1283, 20, -437, 20
        end
        country 'IT', 'Italy' do |c|
          c.timezone 'Europe/Rome', 419, 10, 749, 60
        end
        country 'JE', 'Jersey' do |c|
          c.timezone 'Europe/London', 6181, 120, -451, 3600
        end
        country 'JM', 'Jamaica' do |c|
          c.timezone 'America/Jamaica', 12937, 720, -11519, 150
        end
        country 'JO', 'Jordan' do |c|
          c.timezone 'Asia/Amman', 639, 20, 539, 15
        end
        country 'JP', 'Japan' do |c|
          c.timezone 'Asia/Tokyo', 32089, 900, 503081, 3600
        end
        country 'KE', 'Kenya' do |c|
          c.timezone 'Africa/Nairobi', -77, 60, 2209, 60
        end
        country 'KG', 'Kyrgyzstan' do |c|
          c.timezone 'Asia/Bishkek', 429, 10, 373, 5
        end
        country 'KH', 'Cambodia' do |c|
          c.timezone 'Asia/Bangkok', 55, 4, 6031, 60
        end
        country 'KI', 'Kiribati' do |c|
          c.timezone 'Pacific/Tarawa', 17, 12, 173, 1, 'Gilbert Islands'
          c.timezone 'Pacific/Enderbury', -47, 15, -2053, 12, 'Phoenix Islands'
          c.timezone 'Pacific/Kiritimati', 28, 15, -472, 3, 'Line Islands'
        end
        country 'KM', 'Comoros' do |c|
          c.timezone 'Africa/Nairobi', -77, 60, 2209, 60
        end
        country 'KN', 'St Kitts & Nevis' do |c|
          c.timezone 'America/Port_of_Spain', 213, 20, -3691, 60
        end
        country 'KP', 'Korea (North)' do |c|
          c.timezone 'Asia/Pyongyang', 2341, 60, 503, 4
        end
        country 'KR', 'Korea (South)' do |c|
          c.timezone 'Asia/Seoul', 751, 20, 3809, 30
        end
        country 'KW', 'Kuwait' do |c|
          c.timezone 'Asia/Riyadh', 739, 30, 2803, 60
        end
        country 'KY', 'Cayman Islands' do |c|
          c.timezone 'America/Panama', 269, 30, -1193, 15
        end
        country 'KZ', 'Kazakhstan' do |c|
          c.timezone 'Asia/Almaty', 173, 4, 1539, 20, 'most locations'
          c.timezone 'Asia/Qyzylorda', 224, 5, 982, 15, 'Qyzylorda (Kyzylorda, Kzyl-Orda)'
          c.timezone 'Asia/Aqtobe', 3017, 60, 343, 6, 'Aqtobe (Aktobe)'
          c.timezone 'Asia/Aqtau', 2671, 60, 754, 15, 'Atyrau (Atirau, Gur\'yev), Mangghystau (Mankistau)'
          c.timezone 'Asia/Oral', 3073, 60, 1027, 20, 'West Kazakhstan'
        end
        country 'LA', 'Laos' do |c|
          c.timezone 'Asia/Bangkok', 55, 4, 6031, 60
        end
        country 'LB', 'Lebanon' do |c|
          c.timezone 'Asia/Beirut', 2033, 60, 71, 2
        end
        country 'LC', 'St Lucia' do |c|
          c.timezone 'America/Port_of_Spain', 213, 20, -3691, 60
        end
        country 'LI', 'Liechtenstein' do |c|
          c.timezone 'Europe/Zurich', 2843, 60, 128, 15, 'Swiss time'
        end
        country 'LK', 'Sri Lanka' do |c|
          c.timezone 'Asia/Colombo', 104, 15, 1597, 20
        end
        country 'LR', 'Liberia' do |c|
          c.timezone 'Africa/Monrovia', 63, 10, -647, 60
        end
        country 'LS', 'Lesotho' do |c|
          c.timezone 'Africa/Johannesburg', -105, 4, 28, 1
        end
        country 'LT', 'Lithuania' do |c|
          c.timezone 'Europe/Vilnius', 3281, 60, 1519, 60
        end
        country 'LU', 'Luxembourg' do |c|
          c.timezone 'Europe/Luxembourg', 248, 5, 123, 20
        end
        country 'LV', 'Latvia' do |c|
          c.timezone 'Europe/Riga', 1139, 20, 241, 10
        end
        country 'LY', 'Libya' do |c|
          c.timezone 'Africa/Tripoli', 329, 10, 791, 60
        end
        country 'MA', 'Morocco' do |c|
          c.timezone 'Africa/Casablanca', 673, 20, -91, 12
        end
        country 'MC', 'Monaco' do |c|
          c.timezone 'Europe/Monaco', 437, 10, 443, 60
        end
        country 'MD', 'Moldova' do |c|
          c.timezone 'Europe/Chisinau', 47, 1, 173, 6
        end
        country 'ME', 'Montenegro' do |c|
          c.timezone 'Europe/Belgrade', 269, 6, 41, 2
        end
        country 'MF', 'St Martin (French part)' do |c|
          c.timezone 'America/Port_of_Spain', 213, 20, -3691, 60
        end
        country 'MG', 'Madagascar' do |c|
          c.timezone 'Africa/Nairobi', -77, 60, 2209, 60
        end
        country 'MH', 'Marshall Islands' do |c|
          c.timezone 'Pacific/Majuro', 143, 20, 856, 5, 'most locations'
          c.timezone 'Pacific/Kwajalein', 109, 12, 502, 3, 'Kwajalein'
        end
        country 'MK', 'Macedonia' do |c|
          c.timezone 'Europe/Belgrade', 269, 6, 41, 2
        end
        country 'ML', 'Mali' do |c|
          c.timezone 'Africa/Abidjan', 319, 60, -121, 30
        end
        country 'MM', 'Myanmar (Burma)' do |c|
          c.timezone 'Asia/Rangoon', 1007, 60, 577, 6
        end
        country 'MN', 'Mongolia' do |c|
          c.timezone 'Asia/Ulaanbaatar', 575, 12, 6413, 60, 'most locations'
          c.timezone 'Asia/Hovd', 2881, 60, 1833, 20, 'Bayan-Ölgii, Govi-Altai, Hovd, Uvs, Zavkhan'
          c.timezone 'Asia/Choibalsan', 721, 15, 229, 2, 'Dornod, Sükhbaatar'
        end
        country 'MO', 'Macau' do |c|
          c.timezone 'Asia/Macau', 667, 30, 1363, 12
        end
        country 'MP', 'Northern Mariana Islands' do |c|
          c.timezone 'Pacific/Guam', 202, 15, 579, 4
        end
        country 'MQ', 'Martinique' do |c|
          c.timezone 'America/Martinique', 73, 5, -733, 12
        end
        country 'MR', 'Mauritania' do |c|
          c.timezone 'Africa/Abidjan', 319, 60, -121, 30
        end
        country 'MS', 'Montserrat' do |c|
          c.timezone 'America/Port_of_Spain', 213, 20, -3691, 60
        end
        country 'MT', 'Malta' do |c|
          c.timezone 'Europe/Malta', 359, 10, 871, 60
        end
        country 'MU', 'Mauritius' do |c|
          c.timezone 'Indian/Mauritius', -121, 6, 115, 2
        end
        country 'MV', 'Maldives' do |c|
          c.timezone 'Indian/Maldives', 25, 6, 147, 2
        end
        country 'MW', 'Malawi' do |c|
          c.timezone 'Africa/Maputo', -779, 30, 391, 12, 'Central Africa Time (UTC+2)'
        end
        country 'MX', 'Mexico' do |c|
          c.timezone 'America/Mexico_City', 97, 5, -1983, 20, 'Central Time - most locations'
          c.timezone 'America/Cancun', 253, 12, -2603, 30, 'Central Time - Quintana Roo'
          c.timezone 'America/Merida', 629, 30, -5377, 60, 'Central Time - Campeche, Yucatán'
          c.timezone 'America/Monterrey', 77, 3, -6019, 60, 'Mexican Central Time - Coahuila, Durango, Nuevo León, Tamaulipas away from US border'
          c.timezone 'America/Matamoros', 155, 6, -195, 2, 'US Central Time - Coahuila, Durango, Nuevo León, Tamaulipas near US border'
          c.timezone 'America/Mazatlan', 1393, 60, -1277, 12, 'Mountain Time - S Baja, Nayarit, Sinaloa'
          c.timezone 'America/Chihuahua', 859, 30, -1273, 12, 'Mexican Mountain Time - Chihuahua away from US border'
          c.timezone 'America/Ojinaga', 887, 30, -1253, 12, 'US Mountain Time - Chihuahua near US border'
          c.timezone 'America/Hermosillo', 436, 15, -3329, 30, 'Mountain Standard Time - Sonora'
          c.timezone 'America/Tijuana', 488, 15, -7021, 60, 'US Pacific Time - Baja California near US border'
          c.timezone 'America/Santa_Isabel', 303, 10, -1723, 15, 'Mexican Pacific Time - Baja California away from US border'
          c.timezone 'America/Bahia_Banderas', 104, 5, -421, 4, 'Mexican Central Time - Bahía de Banderas'
        end
        country 'MY', 'Malaysia' do |c|
          c.timezone 'Asia/Kuala_Lumpur', 19, 6, 1017, 10, 'peninsular Malaysia'
          c.timezone 'Asia/Kuching', 31, 20, 331, 3, 'Sabah & Sarawak'
        end
        country 'MZ', 'Mozambique' do |c|
          c.timezone 'Africa/Maputo', -779, 30, 391, 12, 'Central Africa Time (UTC+2)'
        end
        country 'NA', 'Namibia' do |c|
          c.timezone 'Africa/Windhoek', -677, 30, 171, 10
        end
        country 'NC', 'New Caledonia' do |c|
          c.timezone 'Pacific/Noumea', -334, 15, 3329, 20
        end
        country 'NE', 'Niger' do |c|
          c.timezone 'Africa/Lagos', 129, 20, 17, 5, 'West Africa Time (UTC+1)'
        end
        country 'NF', 'Norfolk Island' do |c|
          c.timezone 'Pacific/Norfolk', -581, 20, 5039, 30
        end
        country 'NG', 'Nigeria' do |c|
          c.timezone 'Africa/Lagos', 129, 20, 17, 5, 'West Africa Time (UTC+1)'
        end
        country 'NI', 'Nicaragua' do |c|
          c.timezone 'America/Managua', 243, 20, -5177, 60
        end
        country 'NL', 'Netherlands' do |c|
          c.timezone 'Europe/Amsterdam', 1571, 30, 49, 10
        end
        country 'NO', 'Norway' do |c|
          c.timezone 'Europe/Oslo', 719, 12, 43, 4
        end
        country 'NP', 'Nepal' do |c|
          c.timezone 'Asia/Kathmandu', 1663, 60, 5119, 60
        end
        country 'NR', 'Nauru' do |c|
          c.timezone 'Pacific/Nauru', -31, 60, 2003, 12
        end
        country 'NU', 'Niue' do |c|
          c.timezone 'Pacific/Niue', -1141, 60, -2039, 12
        end
        country 'NZ', 'New Zealand' do |c|
          c.timezone 'Pacific/Auckland', -553, 15, 5243, 30, 'New Zealand time'
          c.timezone 'Pacific/Chatham', -879, 20, -3531, 20, 'Chatham Islands'
        end
        country 'OM', 'Oman' do |c|
          c.timezone 'Asia/Dubai', 253, 10, 553, 10
        end
        country 'PA', 'Panama' do |c|
          c.timezone 'America/Panama', 269, 30, -1193, 15
        end
        country 'PE', 'Peru' do |c|
          c.timezone 'America/Lima', -241, 20, -1541, 20
        end
        country 'PF', 'French Polynesia' do |c|
          c.timezone 'Pacific/Tahiti', -263, 15, -4487, 30, 'Society Islands'
          c.timezone 'Pacific/Marquesas', -9, 1, -279, 2, 'Marquesas Islands'
          c.timezone 'Pacific/Gambier', -347, 15, -2699, 20, 'Gambier Islands'
        end
        country 'PG', 'Papua New Guinea' do |c|
          c.timezone 'Pacific/Port_Moresby', -19, 2, 883, 6
        end
        country 'PH', 'Philippines' do |c|
          c.timezone 'Asia/Manila', 175, 12, 121, 1
        end
        country 'PK', 'Pakistan' do |c|
          c.timezone 'Asia/Karachi', 373, 15, 1341, 20
        end
        country 'PL', 'Poland' do |c|
          c.timezone 'Europe/Warsaw', 209, 4, 21, 1
        end
        country 'PM', 'St Pierre & Miquelon' do |c|
          c.timezone 'America/Miquelon', 941, 20, -169, 3
        end
        country 'PN', 'Pitcairn' do |c|
          c.timezone 'Pacific/Pitcairn', -376, 15, -1561, 12
        end
        country 'PR', 'Puerto Rico' do |c|
          c.timezone 'America/Puerto_Rico', 11081, 600, -118991, 1800
        end
        country 'PS', 'Palestine' do |c|
          c.timezone 'Asia/Gaza', 63, 2, 517, 15, 'Gaza Strip'
          c.timezone 'Asia/Hebron', 473, 15, 7019, 200, 'West Bank'
        end
        country 'PT', 'Portugal' do |c|
          c.timezone 'Europe/Lisbon', 2323, 60, -137, 15, 'mainland'
          c.timezone 'Atlantic/Madeira', 979, 30, -169, 10, 'Madeira Islands'
          c.timezone 'Atlantic/Azores', 566, 15, -77, 3, 'Azores'
        end
        country 'PW', 'Palau' do |c|
          c.timezone 'Pacific/Palau', 22, 3, 8069, 60
        end
        country 'PY', 'Paraguay' do |c|
          c.timezone 'America/Asuncion', -379, 15, -173, 3
        end
        country 'QA', 'Qatar' do |c|
          c.timezone 'Asia/Qatar', 1517, 60, 773, 15
        end
        country 'RE', 'Reunion' do |c|
          c.timezone 'Indian/Reunion', -313, 15, 832, 15, 'Réunion, Crozet Is, Scattered Is'
        end
        country 'RO', 'Romania' do |c|
          c.timezone 'Europe/Bucharest', 1333, 30, 261, 10
        end
        country 'RS', 'Serbia' do |c|
          c.timezone 'Europe/Belgrade', 269, 6, 41, 2
        end
        country 'RU', 'Russia' do |c|
          c.timezone 'Europe/Kaliningrad', 3283, 60, 41, 2, 'Moscow-01 - Kaliningrad'
          c.timezone 'Europe/Moscow', 66907, 1200, 8464, 225, 'Moscow+00 - west Russia'
          c.timezone 'Europe/Simferopol', 899, 20, 341, 10, 'Moscow+00 - Crimea'
          c.timezone 'Europe/Volgograd', 731, 15, 533, 12, 'Moscow+00 - Caspian Sea'
          c.timezone 'Europe/Samara', 266, 5, 1003, 20, 'Moscow+00 (Moscow+01 after 2014-10-26) - Samara, Udmurtia'
          c.timezone 'Asia/Yekaterinburg', 1137, 20, 303, 5, 'Moscow+02 - Urals'
          c.timezone 'Asia/Omsk', 55, 1, 367, 5, 'Moscow+03 - west Siberia'
          c.timezone 'Asia/Novosibirsk', 1651, 30, 995, 12, 'Moscow+03 - Novosibirsk'
          c.timezone 'Asia/Novokuznetsk', 215, 4, 5227, 60, 'Moscow+03 (Moscow+04 after 2014-10-26) - Kemerovo'
          c.timezone 'Asia/Krasnoyarsk', 3361, 60, 557, 6, 'Moscow+04 - Yenisei River'
          c.timezone 'Asia/Irkutsk', 784, 15, 313, 3, 'Moscow+05 - Lake Baikal'
          c.timezone 'Asia/Chita', 1041, 20, 1702, 15, 'Moscow+06 (Moscow+05 after 2014-10-26) - Zabaykalsky'
          c.timezone 'Asia/Yakutsk', 62, 1, 389, 3, 'Moscow+06 - Lena River'
          c.timezone 'Asia/Khandyga', 225563, 3600, 243997, 1800, 'Moscow+06 - Tomponsky, Ust-Maysky'
          c.timezone 'Asia/Vladivostok', 259, 6, 1979, 15, 'Moscow+07 - Amur River'
          c.timezone 'Asia/Sakhalin', 1409, 30, 1427, 10, 'Moscow+07 - Sakhalin Island'
          c.timezone 'Asia/Ust-Nera', 232417, 3600, 10742, 75, 'Moscow+07 - Oymyakonsky'
          c.timezone 'Asia/Magadan', 1787, 30, 754, 5, 'Moscow+08 (Moscow+07 after 2014-10-26) - Magadan'
          c.timezone 'Asia/Srednekolymsk', 1012, 15, 9223, 60, 'Moscow+08 - E Sakha, N Kuril Is'
          c.timezone 'Asia/Kamchatka', 3181, 60, 3173, 20, 'Moscow+08 (Moscow+09 after 2014-10-26) - Kamchatka'
          c.timezone 'Asia/Anadyr', 259, 4, 10649, 60, 'Moscow+08 (Moscow+09 after 2014-10-26) - Bering Sea'
        end
        country 'RW', 'Rwanda' do |c|
          c.timezone 'Africa/Maputo', -779, 30, 391, 12, 'Central Africa Time (UTC+2)'
        end
        country 'SA', 'Saudi Arabia' do |c|
          c.timezone 'Asia/Riyadh', 739, 30, 2803, 60
        end
        country 'SB', 'Solomon Islands' do |c|
          c.timezone 'Pacific/Guadalcanal', -143, 15, 801, 5
        end
        country 'SC', 'Seychelles' do |c|
          c.timezone 'Indian/Mahe', -14, 3, 832, 15
        end
        country 'SD', 'Sudan' do |c|
          c.timezone 'Africa/Khartoum', 78, 5, 488, 15
        end
        country 'SE', 'Sweden' do |c|
          c.timezone 'Europe/Stockholm', 178, 3, 361, 20
        end
        country 'SG', 'Singapore' do |c|
          c.timezone 'Asia/Singapore', 77, 60, 2077, 20
        end
        country 'SH', 'St Helena' do |c|
          c.timezone 'Africa/Abidjan', 319, 60, -121, 30
        end
        country 'SI', 'Slovenia' do |c|
          c.timezone 'Europe/Belgrade', 269, 6, 41, 2
        end
        country 'SJ', 'Svalbard & Jan Mayen' do |c|
          c.timezone 'Europe/Oslo', 719, 12, 43, 4
        end
        country 'SK', 'Slovakia' do |c|
          c.timezone 'Europe/Prague', 601, 12, 433, 30
        end
        country 'SL', 'Sierra Leone' do |c|
          c.timezone 'Africa/Abidjan', 319, 60, -121, 30
        end
        country 'SM', 'San Marino' do |c|
          c.timezone 'Europe/Rome', 419, 10, 749, 60
        end
        country 'SN', 'Senegal' do |c|
          c.timezone 'Africa/Abidjan', 319, 60, -121, 30
        end
        country 'SO', 'Somalia' do |c|
          c.timezone 'Africa/Nairobi', -77, 60, 2209, 60
        end
        country 'SR', 'Suriname' do |c|
          c.timezone 'America/Paramaribo', 35, 6, -331, 6
        end
        country 'SS', 'South Sudan' do |c|
          c.timezone 'Africa/Khartoum', 78, 5, 488, 15
        end
        country 'ST', 'Sao Tome & Principe' do |c|
          c.timezone 'Africa/Abidjan', 319, 60, -121, 30
        end
        country 'SV', 'El Salvador' do |c|
          c.timezone 'America/El_Salvador', 137, 10, -446, 5
        end
        country 'SX', 'St Maarten (Dutch part)' do |c|
          c.timezone 'America/Curacao', 731, 60, -69, 1
        end
        country 'SY', 'Syria' do |c|
          c.timezone 'Asia/Damascus', 67, 2, 363, 10
        end
        country 'SZ', 'Swaziland' do |c|
          c.timezone 'Africa/Johannesburg', -105, 4, 28, 1
        end
        country 'TC', 'Turks & Caicos Is' do |c|
          c.timezone 'America/Grand_Turk', 322, 15, -1067, 15
        end
        country 'TD', 'Chad' do |c|
          c.timezone 'Africa/Ndjamena', 727, 60, 301, 20
        end
        country 'TF', 'French Southern & Antarctic Lands' do |c|
          c.timezone 'Indian/Kerguelen', -17767, 360, 28087, 400, 'Kerguelen, St Paul I, Amsterdam I'
          c.timezone 'Indian/Reunion', -313, 15, 832, 15, 'Réunion, Crozet Is, Scattered Is'
        end
        country 'TG', 'Togo' do |c|
          c.timezone 'Africa/Abidjan', 319, 60, -121, 30
        end
        country 'TH', 'Thailand' do |c|
          c.timezone 'Asia/Bangkok', 55, 4, 6031, 60
        end
        country 'TJ', 'Tajikistan' do |c|
          c.timezone 'Asia/Dushanbe', 463, 12, 344, 5
        end
        country 'TK', 'Tokelau' do |c|
          c.timezone 'Pacific/Fakaofo', -281, 30, -5137, 30
        end
        country 'TL', 'East Timor' do |c|
          c.timezone 'Asia/Dili', -171, 20, 1507, 12
        end
        country 'TM', 'Turkmenistan' do |c|
          c.timezone 'Asia/Ashgabat', 759, 20, 3503, 60
        end
        country 'TN', 'Tunisia' do |c|
          c.timezone 'Africa/Tunis', 184, 5, 611, 60
        end
        country 'TO', 'Tonga' do |c|
          c.timezone 'Pacific/Tongatapu', -127, 6, -1051, 6
        end
        country 'TR', 'Turkey' do |c|
          c.timezone 'Europe/Istanbul', 2461, 60, 869, 30
        end
        country 'TT', 'Trinidad & Tobago' do |c|
          c.timezone 'America/Port_of_Spain', 213, 20, -3691, 60
        end
        country 'TV', 'Tuvalu' do |c|
          c.timezone 'Pacific/Funafuti', -511, 60, 10753, 60
        end
        country 'TW', 'Taiwan' do |c|
          c.timezone 'Asia/Taipei', 501, 20, 243, 2
        end
        country 'TZ', 'Tanzania' do |c|
          c.timezone 'Africa/Nairobi', -77, 60, 2209, 60
        end
        country 'UA', 'Ukraine' do |c|
          c.timezone 'Europe/Kiev', 1513, 30, 1831, 60, 'most locations'
          c.timezone 'Europe/Uzhgorod', 2917, 60, 223, 10, 'Ruthenia'
          c.timezone 'Europe/Zaporozhye', 287, 6, 211, 6, 'Zaporozh\'ye, E Lugansk / Zaporizhia, E Luhansk'
        end
        country 'UG', 'Uganda' do |c|
          c.timezone 'Africa/Nairobi', -77, 60, 2209, 60
        end
        country 'UM', 'US minor outlying islands' do |c|
          c.timezone 'Pacific/Wake', 1157, 60, 9997, 60, 'Wake Island'
          c.timezone 'Pacific/Pago_Pago', -214, 15, -1707, 10, 'Samoa, Midway'
          c.timezone 'Pacific/Honolulu', 15341, 720, -18943, 120, 'Hawaii time'
        end
        country 'US', 'United States' do |c|
          c.timezone 'America/New_York', 48857, 1200, -266423, 3600, 'Eastern Time'
          c.timezone 'America/Detroit', 152393, 3600, -19931, 240, 'Eastern Time - Michigan - most locations'
          c.timezone 'America/Kentucky/Louisville', 9181, 240, -154367, 1800, 'Eastern Time - Kentucky - Louisville area'
          c.timezone 'America/Kentucky/Monticello', 132587, 3600, -101819, 1200, 'Eastern Time - Kentucky - Wayne County'
          c.timezone 'America/Indiana/Indianapolis', 23861, 600, -310169, 3600, 'Eastern Time - Indiana - most locations'
          c.timezone 'America/Indiana/Vincennes', 69619, 1800, -315103, 3600, 'Eastern Time - Indiana - Daviess, Dubois, Knox & Martin Counties'
          c.timezone 'America/Indiana/Winamac', 29557, 720, -311771, 3600, 'Eastern Time - Indiana - Pulaski County'
          c.timezone 'America/Indiana/Marengo', 17269, 450, -310841, 3600, 'Eastern Time - Indiana - Crawford County'
          c.timezone 'America/Indiana/Petersburg', 138571, 3600, -314203, 3600, 'Eastern Time - Indiana - Pike County'
          c.timezone 'America/Indiana/Vevay', 34873, 900, -153121, 1800, 'Eastern Time - Indiana - Switzerland County'
          c.timezone 'America/Chicago', 837, 20, -1753, 20, 'Central Time'
          c.timezone 'America/Indiana/Tell_City', 136631, 3600, -312341, 3600, 'Central Time - Indiana - Perry County'
          c.timezone 'America/Indiana/Knox', 9911, 240, -693, 8, 'Central Time - Indiana - Starke County'
          c.timezone 'America/Menominee', 40597, 900, -105137, 1200, 'Central Time - Michigan - Dickinson, Gogebic, Iron & Menominee Counties'
          c.timezone 'America/North_Dakota/Center', 169619, 3600, -121559, 1200, 'Central Time - North Dakota - Oliver County'
          c.timezone 'America/North_Dakota/New_Salem', 9369, 200, -121693, 1200, 'Central Time - North Dakota - Morton County (except Mandan area)'
          c.timezone 'America/North_Dakota/Beulah', 56717, 1200, -916, 9, 'Central Time - North Dakota - Mercer County'
          c.timezone 'America/Denver', 47687, 1200, -125981, 1200, 'Mountain Time'
          c.timezone 'America/Boise', 157009, 3600, -46481, 400, 'Mountain Time - south Idaho & east Oregon'
          c.timezone 'America/Phoenix', 20069, 600, -16811, 150, 'Mountain Standard Time - Arizona (except Navajo)'
          c.timezone 'America/Los_Angeles', 30647, 900, -212837, 1800, 'Pacific Time'
          c.timezone 'America/Metlakatla', 198457, 3600, -18947, 144, 'Pacific Standard Time - Annette Island, Alaska'
          c.timezone 'America/Anchorage', 44077, 720, -539641, 3600, 'Alaska Time'
          c.timezone 'America/Juneau', 209887, 3600, -483911, 3600, 'Alaska Time - Alaska panhandle'
          c.timezone 'America/Sitka', 41167, 720, -487087, 3600, 'Alaska Time - southeast Alaska panhandle'
          c.timezone 'America/Yakutat', 214369, 3600, -251509, 1800, 'Alaska Time - Alaska panhandle neck'
          c.timezone 'America/Nome', 58051, 900, -595463, 3600, 'Alaska Time - west Alaska'
          c.timezone 'America/Adak', 1297, 25, -635969, 3600, 'Aleutian Islands'
          c.timezone 'Pacific/Honolulu', 15341, 720, -18943, 120, 'Hawaii time'
        end
        country 'UY', 'Uruguay' do |c|
          c.timezone 'America/Montevideo', -2093, 60, -3371, 60
        end
        country 'UZ', 'Uzbekistan' do |c|
          c.timezone 'Asia/Samarkand', 119, 3, 334, 5, 'west Uzbekistan'
          c.timezone 'Asia/Tashkent', 124, 3, 693, 10, 'east Uzbekistan'
        end
        country 'VA', 'Vatican City' do |c|
          c.timezone 'Europe/Rome', 419, 10, 749, 60
        end
        country 'VC', 'St Vincent' do |c|
          c.timezone 'America/Port_of_Spain', 213, 20, -3691, 60
        end
        country 'VE', 'Venezuela' do |c|
          c.timezone 'America/Caracas', 21, 2, -1004, 15
        end
        country 'VG', 'Virgin Islands (UK)' do |c|
          c.timezone 'America/Port_of_Spain', 213, 20, -3691, 60
        end
        country 'VI', 'Virgin Islands (US)' do |c|
          c.timezone 'America/Port_of_Spain', 213, 20, -3691, 60
        end
        country 'VN', 'Vietnam' do |c|
          c.timezone 'Asia/Bangkok', 55, 4, 6031, 60
        end
        country 'VU', 'Vanuatu' do |c|
          c.timezone 'Pacific/Efate', -53, 3, 2021, 12
        end
        country 'WF', 'Wallis & Futuna' do |c|
          c.timezone 'Pacific/Wallis', -133, 10, -1057, 6
        end
        country 'WS', 'Samoa (western)' do |c|
          c.timezone 'Pacific/Apia', -83, 6, -2576, 15
        end
        country 'YE', 'Yemen' do |c|
          c.timezone 'Asia/Riyadh', 739, 30, 2803, 60
        end
        country 'YT', 'Mayotte' do |c|
          c.timezone 'Africa/Nairobi', -77, 60, 2209, 60
        end
        country 'ZA', 'South Africa' do |c|
          c.timezone 'Africa/Johannesburg', -105, 4, 28, 1
        end
        country 'ZM', 'Zambia' do |c|
          c.timezone 'Africa/Maputo', -779, 30, 391, 12, 'Central Africa Time (UTC+2)'
        end
        country 'ZW', 'Zimbabwe' do |c|
          c.timezone 'Africa/Maputo', -779, 30, 391, 12, 'Central Africa Time (UTC+2)'
        end
      end
    end
  end
end
