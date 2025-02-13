public without sharing class PhoneNumberValidationHandler {
    public static Map<String, String> countryPhoneRegexMap = new Map<String, String>{ 
        'AD' => '^\\+376\\d{6}$', // Andorra
        'AE' => '^\\+971\\d{8,9}$', // United Arab Emirates
        'AF' => '^\\+93\\d{9}$', // Afghanistan
        'AG' => '^\\+1\\d{10}$', // Antigua and Barbuda
        'AI' => '^\\+1\\d{10}$', // Anguilla
        'AL' => '^\\+355\\d{9}$', // Albania
        'AM' => '^\\+374\\d{8}$', // Armenia
        'AO' => '^\\+244\\d{9}$', // Angola
        'AQ' => '^\\+672\\d{5}$', // Antarctica
        'AR' => '^\\+54\\d{10}$', // Argentina
        'AT' => '^\\+43\\d{10}$', // Austria
        'AU' => '^\\+61\\d{9}$', // Australia
        'AW' => '^\\+297\\d{7}$', // Aruba
        'AX' => '^\\+358\\d{5,6}$', // Åland Islands
        'AZ' => '^\\+994\\d{9}$', // Azerbaijan
        'BA' => '^\\+387\\d{8}$', // Bosnia and Herzegovina
        'BB' => '^\\+1\\d{10}$', // Barbados
        'BD' => '^\\+880\\d{10}$', // Bangladesh
        'BE' => '^\\+32\\d{8}$', // Belgium
        'BF' => '^\\+226\\d{8}$', // Burkina Faso
        'BG' => '^\\+359\\d{9}$', // Bulgaria
        'BH' => '^\\+973\\d{8}$', // Bahrain
        'BI' => '^\\+257\\d{7}$', // Burundi
        'BJ' => '^\\+229\\d{8}$', // Benin
        'BL' => '^\\+590\\d{9}$', // Saint Barthélemy
        'BM' => '^\\+1\\d{10}$', // Bermuda
        'BN' => '^\\+673\\d{7}$', // Brunei Darussalam
        'BO' => '^\\+591\\d{8}$', // Bolivia
        'BQ' => '^\\+599\\d{7}$', // Bonaire, Sint Eustatius and Saba
        'BR' => '^\\+55\\d{10,11}$', // Brazil
        'BS' => '^\\+1\\d{10}$', // Bahamas
        'BT' => '^\\+975\\d{8}$', // Bhutan
        'BV' => '^\\+47\\d{8}$', // Bouvet Island
        'BW' => '^\\+267\\d{8}$', // Botswana
        'BY' => '^\\+375\\d{9}$', // Belarus
        'BZ' => '^\\+501\\d{7}$', // Belize
        'CA' => '^\\+1\\d{10}$', // Canada
        'CC' => '^\\+61\\d{9}$', // Cocos (Keeling) Islands
        'CD' => '^\\+243\\d{9}$', // Democratic Republic of the Congo
        'CF' => '^\\+236\\d{8}$', // Central African Republic
        'CG' => '^\\+242\\d{8}$', // Republic of the Congo
        'CH' => '^\\+41\\d{9}$', // Switzerland
        'CI' => '^\\+225\\d{8}$', // Côte d'Ivoire
        'CK' => '^\\+682\\d{5}$', // Cook Islands
        'CL' => '^\\+56\\d{9}$', // Chile
        'CM' => '^\\+237\\d{8}$', // Cameroon
        'CN' => '^\\+86\\d{11}$', // China
        'CO' => '^\\+57\\d{10}$', // Colombia
        'CR' => '^\\+506\\d{8}$', // Costa Rica
        'CU' => '^\\+53\\d{8}$', // Cuba
        'CV' => '^\\+238\\d{7}$', // Cape Verde
        'CW' => '^\\+599\\d{7}$', // Curaçao
        'CX' => '^\\+61\\d{9}$', // Christmas Island
        'CY' => '^\\+357\\d{8}$', // Cyprus
        'CZ' => '^\\+420\\d{9}$', // Czech Republic
        'DE' => '^\\+49\\d{10,11}$', // Germany
        'DJ' => '^\\+253\\d{7}$', // Djibouti
        'DK' => '^\\+45\\d{8}$', // Denmark
        'DM' => '^\\+1\\d{10}$', // Dominica
        'DO' => '^\\+1\\d{10}$', // Dominican Republic
        'DZ' => '^\\+213\\d{9}$', // Algeria
        'EC' => '^\\+593\\d{9}$', // Ecuador
        'EE' => '^\\+372\\d{7}$', // Estonia
        'EG' => '^\\+20\\d{9}$', // Egypt
        'EH' => '^\\+212\\d{9}$', // Western Sahara
        'ER' => '^\\+291\\d{7}$', // Eritrea
        'ES' => '^\\+34\\d{9}$', // Spain
        'ET' => '^\\+251\\d{9}$', // Ethiopia
        'FI' => '^\\+358\\d{9}$', // Finland
        'FJ' => '^\\+679\\d{7}$', // Fiji
        'FK' => '^\\+500\\d{7}$', // Falkland Islands (Malvinas)
        'FO' => '^\\+298\\d{6}$', // Faroe Islands
        'FR' => '^\\+33\\d{9}$', // France
        'GA' => '^\\+241\\d{7}$', // Gabon
        'GB' => '^\\+44\\d{10}$', // United Kingdom
        'GD' => '^\\+1\\d{10}$', // Grenada
        'GE' => '^\\+995\\d{9}$', // Georgia
        'GF' => '^\\+594\\d{9}$', // French Guiana
        'GG' => '^\\+44\\d{10}$', // Guernsey
        'GH' => '^\\+233\\d{9}$', // Ghana
        'GI' => '^\\+350\\d{8}$', // Gibraltar
        'GL' => '^\\+299\\d{6}$', // Greenland
        'GM' => '^\\+220\\d{7}$', // Gambia
        'GN' => '^\\+224\\d{9}$', // Guinea
        'GP' => '^\\+590\\d{9}$', // Guadeloupe
        'GQ' => '^\\+240\\d{7}$', // Equatorial Guinea
        'GR' => '^\\+30\\d{10}$', // Greece
        'GS' => '^\\+500\\d{7}$', // South Georgia and South Sandwich Islands
        'GT' => '^\\+502\\d{8}$', // Guatemala
        'GW' => '^\\+245\\d{8}$', // Guinea-Bissau
        'GY' => '^\\+592\\d{7}$', // Guyana
        'HM' => '^\\+672\\d{5}$', // Heard Island and McDonald Islands
        'HN' => '^\\+504\\d{8}$', // Honduras
        'HR' => '^\\+385\\d{9}$', // Croatia
        'HT' => '^\\+509\\d{8}$', // Haiti
        'HU' => '^\\+36\\d{9}$', // Hungary
        'ID' => '^\\+62\\d{10,11}$', // Indonesia
        'IE' => '^\\+353\\d{9}$', // Ireland
        'IL' => '^\\+972\\d{9}$', // Israel
        'IM' => '^\\+44\\d{10}$', // Isle of Man
        'IN' => '^\\+91\\d{10}$', // India
        'IO' => '^\\+246\\d{7}$', // British Indian Ocean Territory
        'IQ' => '^\\+964\\d{9}$', // Iraq
        'IR' => '^\\+98\\d{10}$', // Iran
        'IS' => '^\\+354\\d{7}$', // Iceland
        'IT' => '^\\+39\\d{9,10}$', // Italy
        'JE' => '^\\+44\\d{10}$', // Jersey
        'JM' => '^\\+1\\d{10}$', // Jamaica
        'JO' => '^\\+962\\d{9}$', // Jordan
        'JP' => '^\\+81\\d{10}$', // Japan
        'KE' => '^\\+254\\d{9}$', // Kenya
        'KG' => '^\\+996\\d{9}$', // Kyrgyzstan
        'KH' => '^\\+855\\d{9}$', // Cambodia
        'KI' => '^\\+686\\d{5}$', // Kiribati
        'KM' => '^\\+269\\d{7}$', // Comoros
        'KN' => '^\\+1\\d{10}$', // Saint Kitts and Nevis
        'KP' => '^\\+850\\d{9}$', // North Korea
        'KR' => '^\\+82\\d{9,10}$', // South Korea
        'KW' => '^\\+965\\d{8}$', // Kuwait
        'KY' => '^\\+1\\d{10}$', // Cayman Islands
        'KZ' => '^\\+7\\d{10}$', // Kazakhstan
        'LA' => '^\\+856\\d{8}$', // Laos
        'LB' => '^\\+961\\d{8}$', // Lebanon
        'LC' => '^\\+1\\d{10}$', // Saint Lucia
        'LI' => '^\\+423\\d{6}$', // Liechtenstein
        'LK' => '^\\+94\\d{9}$', // Sri Lanka
        'LR' => '^\\+231\\d{7}$', // Liberia
        'LS' => '^\\+266\\d{8}$', // Lesotho
        'LT' => '^\\+370\\d{9}$', // Lithuania
        'LU' => '^\\+352\\d{9}$', // Luxembourg
        'LV' => '^\\+371\\d{8}$', // Latvia
        'LY' => '^\\+218\\d{9}$', // Libya
        'MA' => '^\\+212\\d{9}$', // Morocco
        'MC' => '^\\+377\\d{8}$', // Monaco
        'MD' => '^\\+373\\d{9}$', // Moldova
        'ME' => '^\\+382\\d{8}$', // Montenegro
        'MF' => '^\\+590\\d{9}$', // Saint Martin (French part)
        'MG' => '^\\+261\\d{9}$', // Madagascar
        'MK' => '^\\+389\\d{9}$', // North Macedonia
        'ML' => '^\\+223\\d{8}$', // Mali
        'MM' => '^\\+95\\d{9}$', // Myanmar
        'MN' => '^\\+976\\d{8}$', // Mongolia
        'MO' => '^\\+853\\d{8}$', // Macao
        'MQ' => '^\\+596\\d{9}$', // Martinique
        'MR' => '^\\+222\\d{8}$', // Mauritania
        'MS' => '^\\+1\\d{10}$', // Montserrat
        'MT' => '^\\+356\\d{8}$', // Malta
        'MU' => '^\\+230\\d{8}$', // Mauritius
        'MV' => '^\\+960\\d{7}$', // Maldives
        'MW' => '^\\+265\\d{9}$', // Malawi
        'MX' => '^\\+52\\d{10}$', // Mexico
        'MY' => '^\\+60\\d{10}$', // Malaysia
        'MZ' => '^\\+258\\d{9}$', // Mozambique
        'NA' => '^\\+264\\d{9}$', // Namibia
        'NC' => '^\\+687\\d{6}$', // New Caledonia
        'NE' => '^\\+227\\d{8}$', // Niger
        'NF' => '^\\+672\\d{5}$', // Norfolk Island
        'NG' => '^\\+234\\d{10}$', // Nigeria
        'NI' => '^\\+505\\d{8}$', // Nicaragua
        'NL' => '^\\+31\\d{9}$', // Netherlands
        'NO' => '^\\+47\\d{8}$', // Norway
        'NP' => '^\\+977\\d{10}$', // Nepal
        'NR' => '^\\+674\\d{4}$', // Nauru
        'NU' => '^\\+683\\d{4}$', // Niue
        'NZ' => '^\\+64\\d{9,10}$', // New Zealand
        'OM' => '^\\+968\\d{8}$', // Oman
        'PA' => '^\\+507\\d{8}$', // Panama
        'PE' => '^\\+51\\d{9}$', // Peru
        'PF' => '^\\+689\\d{8}$', // French Polynesia
        'PG' => '^\\+675\\d{8}$', // Papua New Guinea
        'PH' => '^\\+63\\d{10}$', // Philippines
        'PK' => '^\\+92\\d{10}$', // Pakistan
        'PL' => '^\\+48\\d{9}$', // Poland
        'PM' => '^\\+508\\d{9}$', // Saint Pierre and Miquelon
        'PN' => '^\\+64\\d{4}$', // Pitcairn
        'PS' => '^\\+970\\d{9}$', // Palestinian Territory
        'PT' => '^\\+351\\d{9}$', // Portugal
        'PY' => '^\\+595\\d{9}$', // Paraguay
        'QA' => '^\\+974\\d{8}$', // Qatar
        'RE' => '^\\+262\\d{9}$', // Reunion
        'RO' => '^\\+40\\d{9}$', // Romania
        'RS' => '^\\+381\\d{8}$', // Serbia
        'RU' => '^\\+7\\d{10}$', // Russia
        'RW' => '^\\+250\\d{9}$', // Rwanda
        'SA' => '^\\+966\\d{9}$', // Saudi Arabia
        'SB' => '^\\+677\\d{7}$', // Solomon Islands
        'SC' => '^\\+248\\d{7}$', // Seychelles
        'SD' => '^\\+249\\d{9}$', // Sudan
        'SE' => '^\\+46\\d{9}$', // Sweden
        'SG' => '^\\+65\\d{8}$', // Singapore
        'SH' => '^\\+290\\d{5}$', // Saint Helena
        'SI' => '^\\+386\\d{9}$', // Slovenia
        'SJ' => '^\\+47\\d{8}$', // Svalbard and Jan Mayen
        'SK' => '^\\+421\\d{9}$', // Slovakia
        'SL' => '^\\+232\\d{8}$', // Sierra Leone
        'SM' => '^\\+378\\d{8}$', // San Marino
        'SN' => '^\\+221\\d{9}$', // Senegal
        'SO' => '^\\+252\\d{9}$', // Somalia
        'SR' => '^\\+597\\d{7}$', // Suriname
        'SS' => '^\\+211\\d{9}$', // South Sudan
        'ST' => '^\\+239\\d{7}$', // São Tomé and Príncipe
        'SV' => '^\\+503\\d{8}$', // El Salvador
        'SX' => '^\\+1\\d{10}$', // Sint Maarten (Dutch part)
        'SY' => '^\\+963\\d{9}$', // Syria
        'SZ' => '^\\+268\\d{8}$', // Eswatini (Swaziland)
        'TC' => '^\\+1\\d{10}$', // Turks and Caicos Islands
        'TD' => '^\\+235\\d{8}$', // Chad
        'TF' => '^\\+262\\d{9}$', // French Southern Territories
        'TG' => '^\\+228\\d{8}$', // Togo
        'TH' => '^\\+66\\d{9}$', // Thailand
        'TJ' => '^\\+992\\d{9}$', // Tajikistan
        'TK' => '^\\+690\\d{5}$', // Tokelau
        'TL' => '^\\+670\\d{8}$', // Timor-Leste
        'TM' => '^\\+993\\d{9}$', // Turkmenistan
        'TN' => '^\\+216\\d{8}$', // Tunisia
        'TO' => '^\\+676\\d{5}$', // Tonga
        'TR' => '^\\+90\\d{10}$', // Turkey
        'TT' => '^\\+1\\d{10}$', // Trinidad and Tobago
        'TV' => '^\\+688\\d{4}$', // Tuvalu
        'TZ' => '^\\+255\\d{9}$', // Tanzania
        'UA' => '^\\+380\\d{9}$', // Ukraine
        'UG' => '^\\+256\\d{9}$', // Uganda
        'UM' => '^\\+1\\d{10}$', // United States Minor Outlying Islands
        'US' => '^\\+1\\d{10}$', // United States
        'UY' => '^\\+598\\d{9}$', // Uruguay
        'UZ' => '^\\+998\\d{9}$', // Uzbekistan
        'VA' => '^\\+39\\d{9}$', // Vatican City
        'VC' => '^\\+1\\d{10}$', // Saint Vincent and the Grenadines
        'VE' => '^\\+58\\d{10}$', // Venezuela
        'VG' => '^\\+1\\d{10}$', // British Virgin Islands
        'VI' => '^\\+1\\d{10}$', // United States Virgin Islands
        'VN' => '^\\+84\\d{9}$', // Vietnam
        'VU' => '^\\+678\\d{7}$', // Vanuatu
        'WF' => '^\\+681\\d{5}$', // Wallis and Futuna
        'WS' => '^\\+685\\d{5}$', // Samoa
        'YE' => '^\\+967\\d{9}$', // Yemen
        'YT' => '^\\+262\\d{9}$', // Mayotte
        'ZA' => '^\\+27\\d{9}$', // South Africa
        'ZM' => '^\\+260\\d{9}$', // Zambia
        'ZW' => '^\\+263\\d{9}$' // Zimbabwe
    };
    

    
    public static void validatePhoneNumbers(List<Clinic_Location__c> newRecords) {
        for (Clinic_Location__c record : newRecords) {
            // Skip validation if Phone__c is null
            if (String.isBlank(record.Phone__c)) {
                continue;
            }

            // Ensure Phone__c contains only numbers (or + at the start for international numbers)
            if (!Pattern.matches('^[+]?\\d+$', record.Phone__c)) {
                record.addError('Phone__c must contain only numeric characters and start with + for international numbers.');
                continue;
            }

            // Validate against country-specific regex if Address__CountryCode__s is present
            if (!String.isBlank(record.Address__CountryCode__s)) {
                String countryCode = record.Address__CountryCode__s;
                String country = record.Address__CountryCode__s;
                String regex = countryPhoneRegexMap.get(countryCode);

                if (regex != null) {
                    if (!Pattern.matches(regex, record.Phone__c)) {
                        record.addError('Phone__c does not match the required format for country code: ' + countryCode);
                    }
                } else {
                    record.addError('Validation for country code ' + countryCode + ' is not supported.');
                }
            }
        }
    }
}