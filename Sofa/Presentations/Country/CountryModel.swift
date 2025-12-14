//
//  CountryRouter.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import Foundation
import SwiftUI

// swiftlint:disable type_body_length
enum CountryModel {
    enum Country: CaseIterable {
        case albania
        case algeria
        case andorra
        case angola
        case antiguaAndBarbuda
        case argentina
        case armenia
        case australia
        case austria
        case azerbaijan
        case bahamas
        case bahrain
        case bangladesh
        case barbados
        case belarus
        case belgium
        case belize
        case benin
        case bhutan
        case bolivia
        case bosniaAndHerzegovina
        case botswana
        case brazil
        case brunei
        case bulgaria
        case burkinaFaso
        case burundi
        case cambodia
        case cameroon
        case canada
        case centralAfricanRepublic
        case chad
        case chile
        case china
        case colombia
        case comoros
        case congo
        case congoDemocraticRepublic
        case costaRica
        case croatia
        case cuba
        case cyprus
        case czechRepublic
        case denmark
        case djibouti
        case dominica
        case dominicanRepublic
        case ecuador
        case egypt
        case elSalvador
        case equatorialGuinea
        case eritrea
        case estonia
        case ethiopia
        case fiji
        case finland
        case france
        case gabon
        case gambia
        case georgia
        case germany
        case ghana
        case greece
        case grenada
        case guatemala
        case guinea
        case guineaBissau
        case guyana
        case haiti
        case honduras
        case hungary
        case iceland
        case india
        case indonesia
        case iran
        case iraq
        case ireland
        case israel
        case italy
        case jamaica
        case japan
        case jordan
        case kazakhstan
        case kenya
        case kiribati
        case kuwait
        case kyrgyzstan
        case koreaNorth
        case koreaSouth
        case laos
        case latvia
        case lebanon
        case lesotho
        case liberia
        case libya
        case liechtenstein
        case lithuania
        case luxembourg
        case madagascar
        case malawi
        case malaysia
        case maldives
        case mali
        case malta
        case marshallIslands
        case mauritania
        case mauritius
        case mexico
        case micronesia
        case moldova
        case monaco
        case mongolia
        case montenegro
        case morocco
        case mozambique
        case myanmar
        case namibia
        case nauru
        case nepal
        case netherlands
        case newZealand
        case nicaragua
        case niger
        case nigeria
        case northMacedonia
        case norway
        case oman
        case pakistan
        case palau
        case palestine
        case panama
        case papuaNewGuinea
        case paraguay
        case peru
        case philippines
        case poland
        case portugal
        case qatar
        case romania
        case russia
        case rwanda
        case saintKittsAndNevis
        case saintLucia
        case saintVincentAndTheGrenadines
        case samoa
        case sanMarino
        case saoTomeAndPrincipe
        case saudiArabia
        case senegal
        case serbia
        case seychelles
        case sierraLeone
        case singapore
        case slovakia
        case slovenia
        case solomonIslands
        case somalia
        case southAfrica
        case southSudan
        case spain
        case sriLanka
        case sudan
        case suriname
        case sweden
        case switzerland
        case syria
        case tajikistan
        case tanzania
        case thailand
        case togo
        case tonga
        case trinidadAndTobago
        case tunisia
        case turkey
        case turkmenistan
        case tuvalu
        case uganda
        case ukraine
        case unitedArabEmirates
        case unitedKingdom
        case unitedStates
        case uruguay
        case uzbekistan
        case vanuatu
        case vaticanCity
        case venezuela
        case vietnam
        case yemen
        case zambia
        case zimbabwe

        var isoCode: String {
            switch self {
            case .albania: "AL"
            case .algeria: "DZ"
            case .andorra: "AD"
            case .angola: "AO"
            case .antiguaAndBarbuda: "AG"
            case .argentina: "AR"
            case .armenia: "AM"
            case .australia: "AU"
            case .austria: "AT"
            case .azerbaijan: "AZ"
            case .bahamas: "BS"
            case .bahrain: "BH"
            case .bangladesh: "BD"
            case .barbados: "BB"
            case .belarus: "BY"
            case .belgium: "BE"
            case .belize: "BZ"
            case .benin: "BJ"
            case .bhutan: "BT"
            case .bolivia: "BO"
            case .bosniaAndHerzegovina: "BA"
            case .botswana: "BW"
            case .brazil: "BR"
            case .brunei: "BN"
            case .bulgaria: "BG"
            case .burkinaFaso: "BF"
            case .burundi: "BI"
            case .cambodia: "KH"
            case .cameroon: "CM"
            case .canada: "CA"
            case .centralAfricanRepublic: "CF"
            case .chad: "TD"
            case .chile: "CL"
            case .china: "CN"
            case .colombia: "CO"
            case .comoros: "KM"
            case .congo: "CG"
            case .congoDemocraticRepublic: "CD"
            case .costaRica: "CR"
            case .croatia: "HR"
            case .cuba: "CU"
            case .cyprus: "CY"
            case .czechRepublic: "CZ"
            case .denmark: "DK"
            case .djibouti: "DJ"
            case .dominica: "DM"
            case .dominicanRepublic: "DO"
            case .ecuador: "EC"
            case .egypt: "EG"
            case .elSalvador: "SV"
            case .equatorialGuinea: "GQ"
            case .eritrea: "ER"
            case .estonia: "EE"
            case .ethiopia: "ET"
            case .fiji: "FJ"
            case .finland: "FI"
            case .france: "FR"
            case .gabon: "GA"
            case .gambia: "GM"
            case .georgia: "GE"
            case .germany: "DE"
            case .ghana: "GH"
            case .greece: "GR"
            case .grenada: "GD"
            case .guatemala: "GT"
            case .guinea: "GN"
            case .guineaBissau: "GW"
            case .guyana: "GY"
            case .haiti: "HT"
            case .honduras: "HN"
            case .hungary: "HU"
            case .iceland: "IS"
            case .india: "IN"
            case .indonesia: "ID"
            case .iran: "IR"
            case .iraq: "IQ"
            case .ireland: "IE"
            case .israel: "IL"
            case .italy: "IT"
            case .jamaica: "JM"
            case .japan: "JP"
            case .jordan: "JO"
            case .kazakhstan: "KZ"
            case .kenya: "KE"
            case .kiribati: "KI"
            case .kuwait: "KW"
            case .kyrgyzstan: "KG"
            case .koreaNorth: "KP"
            case .koreaSouth: "KR"
            case .laos: "LA"
            case .latvia: "LV"
            case .lebanon: "LB"
            case .lesotho: "LS"
            case .liberia: "LR"
            case .libya: "LY"
            case .liechtenstein: "LI"
            case .lithuania: "LT"
            case .luxembourg: "LU"
            case .madagascar: "MG"
            case .malawi: "MW"
            case .malaysia: "MY"
            case .maldives: "MV"
            case .mali: "ML"
            case .malta: "MT"
            case .marshallIslands: "MH"
            case .mauritania: "MR"
            case .mauritius: "MU"
            case .mexico: "MX"
            case .micronesia: "FM"
            case .moldova: "MD"
            case .monaco: "MC"
            case .mongolia: "MN"
            case .montenegro: "ME"
            case .morocco: "MA"
            case .mozambique: "MZ"
            case .myanmar: "MM"
            case .namibia: "NA"
            case .nauru: "NR"
            case .nepal: "NP"
            case .netherlands: "NL"
            case .newZealand: "NZ"
            case .nicaragua: "NI"
            case .niger: "NE"
            case .nigeria: "NG"
            case .northMacedonia: "MK"
            case .norway: "NO"
            case .oman: "OM"
            case .pakistan: "PK"
            case .palau: "PW"
            case .palestine: "PS"
            case .panama: "PA"
            case .papuaNewGuinea: "PG"
            case .paraguay: "PY"
            case .peru: "PE"
            case .philippines: "PH"
            case .poland: "PL"
            case .portugal: "PT"
            case .qatar: "QA"
            case .romania: "RO"
            case .russia: "RU"
            case .rwanda: "RW"
            case .saintKittsAndNevis: "KN"
            case .saintLucia: "LC"
            case .saintVincentAndTheGrenadines: "VC"
            case .samoa: "WS"
            case .sanMarino: "SM"
            case .saoTomeAndPrincipe: "ST"
            case .saudiArabia: "SA"
            case .senegal: "SN"
            case .serbia: "RS"
            case .seychelles: "SC"
            case .sierraLeone: "SL"
            case .singapore: "SG"
            case .slovakia: "SK"
            case .slovenia: "SI"
            case .solomonIslands: "SB"
            case .somalia: "SO"
            case .southAfrica: "ZA"
            case .southSudan: "SS"
            case .spain: "ES"
            case .sriLanka: "LK"
            case .sudan: "SD"
            case .suriname: "SR"
            case .sweden: "SE"
            case .switzerland: "CH"
            case .syria: "SY"
            case .tajikistan: "TJ"
            case .tanzania: "TZ"
            case .thailand: "TH"
            case .togo: "TG"
            case .tonga: "TO"
            case .trinidadAndTobago: "TT"
            case .tunisia: "TN"
            case .turkey: "TR"
            case .turkmenistan: "TM"
            case .tuvalu: "TV"
            case .uganda: "UG"
            case .ukraine: "UA"
            case .unitedArabEmirates: "AE"
            case .unitedKingdom: "GB"
            case .unitedStates: "US"
            case .uruguay: "UY"
            case .uzbekistan: "UZ"
            case .vanuatu: "VU"
            case .vaticanCity: "VA"
            case .venezuela: "VE"
            case .vietnam: "VN"
            case .yemen: "YE"
            case .zambia: "ZM"
            case .zimbabwe: "ZW"
            }
        }

        var name: String {
            Locale.current.localizedString(forRegionCode: isoCode) ?? isoCode
        }

        var flag: ImageResource {
            switch self {
            case .albania: .albania
            case .algeria: .algeria
            case .andorra: .andorra
            case .angola: .angola
            case .antiguaAndBarbuda: .antiguaAndBarbuda
            case .argentina: .argentina
            case .armenia: .armenia
            case .australia: .australia
            case .austria: .austria
            case .azerbaijan: .azerbaijan
            case .bahamas: .bahamas
            case .bahrain: .bahrain
            case .bangladesh: .bangladesh
            case .barbados: .barbados
            case .belarus: .belarus
            case .belgium: .belgium
            case .belize: .belize
            case .benin: .benin
            case .bhutan: .bhutan
            case .bolivia: .bolivia
            case .bosniaAndHerzegovina: .bosniaAndHerzegovina
            case .botswana: .botswana
            case .brazil: .brazil
            case .brunei: .brunei
            case .bulgaria: .bulgaria
            case .burkinaFaso: .burkinaFaso
            case .burundi: .burundi
            case .cambodia: .cambodia
            case .cameroon: .cameroon
            case .canada: .canada
            case .centralAfricanRepublic: .centralAfricanRepublic
            case .chad: .chad
            case .chile: .chile
            case .china: .china
            case .colombia: .colombia
            case .comoros: .comoros
            case .congo: .congo
            case .congoDemocraticRepublic: .congoDemocraticRepublic
            case .costaRica: .costaRica
            case .croatia: .croatia
            case .cuba: .cuba
            case .cyprus: .cyprus
            case .czechRepublic: .czechRepublic
            case .denmark: .denmark
            case .djibouti: .djibouti
            case .dominica: .dominica
            case .dominicanRepublic: .dominicanRepublic
            case .ecuador: .ecuador
            case .egypt: .egypt
            case .elSalvador: .elSalvador
            case .equatorialGuinea: .equatorialGuinea
            case .eritrea: .eritrea
            case .estonia: .estonia
            case .ethiopia: .ethiopia
            case .fiji: .fiji
            case .finland: .finland
            case .france: .france
            case .gabon: .gabon
            case .gambia: .gambia
            case .georgia: .georgia
            case .germany: .germany
            case .ghana: .ghana
            case .greece: .greece
            case .grenada: .grenada
            case .guatemala: .guatemala
            case .guinea: .guinea
            case .guineaBissau: .guineaBissau
            case .guyana: .guyana
            case .haiti: .haiti
            case .honduras: .honduras
            case .hungary: .hungary
            case .iceland: .iceland
            case .india: .india
            case .indonesia: .indonesia
            case .iran: .iran
            case .iraq: .iraq
            case .ireland: .ireland
            case .israel: .israel
            case .italy: .italy
            case .jamaica: .jamaica
            case .japan: .japan
            case .jordan: .jordan
            case .kazakhstan: .kazakhstan
            case .kenya: .kenya
            case .kiribati: .kiribati
            case .kuwait: .kuwait
            case .kyrgyzstan: .kyrgyzstan
            case .koreaNorth: .northKorea
            case .koreaSouth: .southKorea
            case .laos: .laos
            case .latvia: .latvia
            case .lebanon: .lebanon
            case .lesotho: .lesotho
            case .liberia: .liberia
            case .libya: .libya
            case .liechtenstein: .liechtenstein
            case .lithuania: .lithuania
            case .luxembourg: .luxembourg
            case .madagascar: .madagascar
            case .malawi: .malawi
            case .malaysia: .malaysia
            case .maldives: .maldives
            case .mali: .mali
            case .malta: .malta
            case .marshallIslands: .marshallIslands
            case .mauritania: .mauritania
            case .mauritius: .mauritius
            case .mexico: .mexico
            case .micronesia: .micronesia
            case .moldova: .moldova
            case .monaco: .monaco
            case .mongolia: .mongolia
            case .montenegro: .montenegro
            case .morocco: .morocco
            case .mozambique: .mozambique
            case .myanmar: .myanmar
            case .namibia: .namibia
            case .nauru: .nauru
            case .nepal: .nepal
            case .netherlands: .netherlands
            case .newZealand: .newZealand
            case .nicaragua: .nicaragua
            case .niger: .niger
            case .nigeria: .nigeria
            case .northMacedonia: .northMacedonia
            case .norway: .norway
            case .oman: .oman
            case .pakistan: .pakistan
            case .palau: .palau
            case .palestine: .palestine
            case .panama: .panama
            case .papuaNewGuinea: .papuaNewGuinea
            case .paraguay: .paraguay
            case .peru: .peru
            case .philippines: .philippines
            case .poland: .poland
            case .portugal: .portugal
            case .qatar: .qatar
            case .romania: .romania
            case .russia: .russia
            case .rwanda: .rwanda
            case .saintKittsAndNevis: .saintKittsAndNevis
            case .saintLucia: .saintLucia
            case .saintVincentAndTheGrenadines: .saintVincentAndTheGrenadines
            case .samoa: .samoa
            case .sanMarino: .sanMarino
            case .saoTomeAndPrincipe: .saoTomeAndPrincipe
            case .saudiArabia: .saudiArabia
            case .senegal: .senegal
            case .serbia: .serbia
            case .seychelles: .seychelles
            case .sierraLeone: .sierraLeone
            case .singapore: .singapore
            case .slovakia: .slovakia
            case .slovenia: .slovenia
            case .solomonIslands: .solomonIslands
            case .somalia: .somalia
            case .southAfrica: .southAfrica
            case .southSudan: .southSudan
            case .spain: .spain
            case .sriLanka: .sriLanka
            case .sudan: .sudan
            case .suriname: .suriname
            case .sweden: .sweden
            case .switzerland: .switzerland
            case .syria: .syria
            case .tajikistan: .tajikistan
            case .tanzania: .tanzania
            case .thailand: .thailand
            case .togo: .togo
            case .tonga: .tonga
            case .trinidadAndTobago: .trinidadAndTobago
            case .tunisia: .tunisia
            case .turkey: .turkey
            case .turkmenistan: .turkmenistan
            case .tuvalu: .tuvalu
            case .uganda: .uganda
            case .ukraine: .ukraine
            case .unitedArabEmirates: .unitedArabEmirates
            case .unitedKingdom: .unitedKingdom
            case .unitedStates: .unitedStates
            case .uruguay: .uruguay
            case .uzbekistan: .uzbekistan
            case .vanuatu: .vanuatu
            case .vaticanCity: .vaticanCity
            case .venezuela: .venezuela
            case .vietnam: .vietnam
            case .yemen: .yemen
            case .zambia: .zambia
            case .zimbabwe: .zimbabwe
            }
        }
    }
}
// swiftlint:enable type_body_length
