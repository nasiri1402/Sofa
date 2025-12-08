//
//  CountryRouter.swift
//  Sofa
//
//  Created by dukes on 11/4/25.
//

import Foundation
import SwiftUI

enum CountryModel {
    enum Country: String, CaseIterable {
        case albania = "Albania"
        case algeria = "Algeria"
        case andorra = "Andorra"
        case angola = "Angola"
        case antiguaAndBarbuda = "Antigua and Barbuda"
        case argentina = "Argentina"
        case armenia = "Armenia"
        case australia = "Australia"
        case austria = "Austria"
        case azerbaijan = "Azerbaijan"
        case bahamas = "Bahamas"
        case bahrain = "Bahrain"
        case bangladesh = "Bangladesh"
        case barbados = "Barbados"
        case belarus = "Belarus"
        case belgium = "Belgium"
        case belize = "Belize"
        case benin = "Benin"
        case bhutan = "Bhutan"
        case bolivia = "Bolivia"
        case bosniaAndHerzegovina = "Bosnia and Herzegovina"
        case botswana = "Botswana"
        case brazil = "Brazil"
        case brunei = "Brunei"
        case bulgaria = "Bulgaria"
        case burkinaFaso = "Burkina Faso"
        case burundi = "Burundi"
        case cambodia = "Cambodia"
        case cameroon = "Cameroon"
        case canada = "Canada"
        case centralAfricanRepublic = "Central African Republic"
        case chad = "Chad"
        case chile = "Chile"
        case china = "China"
        case colombia = "Colombia"
        case comoros = "Comoros"
        case congo = "Congo"
        case congoDemocraticRepublic = "Congo Democratic Republic"
        case costaRica = "Costa Rica"
        case croatia = "Croatia"
        case cuba = "Cuba"
        case cyprus = "Cyprus"
        case czechRepublicCzechia = "Czech Republic"
        case denmark = "Denmark"
        case djibouti = "Djibouti"
        case dominica = "Dominica"
        case dominicanRepublic = "Dominican Republic"
        case ecuador = "Ecuador"
        case egypt = "Egypt"
        case elSalvador = "El Salvador"
        case equatorialGuinea = "Equatorial Guinea"
        case eritrea = "Eritrea"
        case estonia = "Estonia"
        case ethiopia = "Ethiopia"
        case fiji = "Fiji"
        case finland = "Finland"
        case france = "France"
        case gabon = "Gabon"
        case gambia = "Gambia"
        case georgia = "Georgia"
        case germany = "Germany"
        case ghana = "Ghana"
        case greece = "Greece"
        case grenada = "Grenada"
        case guatemala = "Guatemala"
        case guinea = "Guinea"
        case guineaBissau = "Guinea-Bissau"
        case guyana = "Guyana"
        case haiti = "Haiti"
        case honduras = "Honduras"
        case hungary = "Hungary"
        case iceland = "Iceland"
        case india = "India"
        case indonesia = "Indonesia"
        case iran = "Iran"
        case iraq = "Iraq"
        case ireland = "Ireland"
        case israel = "Israel"
        case italy = "Italy"
        case jamaica = "Jamaica"
        case japan = "Japan"
        case jordan = "Jordan"
        case kazakhstan = "Kazakhstan"
        case kenya = "Kenya"
        case kiribati = "Kiribati"
        case kuwait = "Kuwait"
        case kyrgyzstan = "Kyrgyzstan"
        case koreaNorth = "Korea, North"
        case koreaSouth = "Korea, South"
        case laos = "Laos"
        case latvia = "Latvia"
        case lebanon = "Lebanon"
        case lesotho = "Lesotho"
        case liberia = "Liberia"
        case libya = "Libya"
        case liechtenstein = "Liechtenstein"
        case lithuania = "Lithuania"
        case luxembourg = "Luxembourg"
        case madagascar = "Madagascar"
        case malawi = "Malawi"
        case malaysia = "Malaysia"
        case maldives = "Maldives"
        case mali = "Mali"
        case malta = "Malta"
        case marshallIslands = "Marshall Islands"
        case mauritania = "Mauritania"
        case mauritius = "Mauritius"
        case mexico = "Mexico"
        case micronesia = "Micronesia"
        case moldova = "Moldova"
        case monaco = "Monaco"
        case mongolia = "Mongolia"
        case montenegro = "Montenegro"
        case morocco = "Morocco"
        case mozambique = "Mozambique"
        case myanmar = "Myanmar"
        case namibia = "Namibia"
        case nauru = "Nauru"
        case nepal = "Nepal"
        case netherlands = "Netherlands"
        case newZealand = "New Zealand"
        case nicaragua = "Nicaragua"
        case niger = "Niger"
        case nigeria = "Nigeria"
        case northMacedonia = "North Macedonia"
        case norway = "Norway"
        case oman = "Oman"
        case pakistan = "Pakistan"
        case palau = "Palau"
        case palestine = "Palestine"
        case panama = "Panama"
        case papuaNewGuinea = "Papua New Guinea"
        case paraguay = "Paraguay"
        case peru = "Peru"
        case philippines = "Philippines"
        case poland = "Poland"
        case portugal = "Portugal"
        case qatar = "Qatar"
        case romania = "Romania"
        case russia = "Russia"
        case rwanda = "Rwanda"
        case saintKittsAndNevis = "Saint Kitts and Nevis"
        case saintLucia = "Saint Lucia"
        case saintVincentAndTheGrenadines = "Saint Vincent and the Grenadines"
        case samoa = "Samoa"
        case sanMarino = "San Marino"
        case saoTomeAndPrincipe = "Sao Tome and Principe"
        case saudiArabia = "Saudi Arabia"
        case senegal = "Senegal"
        case serbia = "Serbia"
        case seychelles = "Seychelles"
        case sierraLeone = "Sierra Leone"
        case singapore = "Singapore"
        case slovakia = "Slovakia"
        case slovenia = "Slovenia"
        case solomonIslands = "Solomon Islands"
        case somalia = "Somalia"
        case southAfrica = "South Africa"
        case southSudan = "South Sudan"
        case spain = "Spain"
        case sriLanka = "Sri Lanka"
        case sudan = "Sudan"
        case suriname = "Suriname"
        case sweden = "Sweden"
        case switzerland = "Switzerland"
        case syria = "Syria"
        case tajikistan = "Tajikistan"
        case tanzania = "Tanzania"
        case thailand = "Thailand"
        case togo = "Togo"
        case tonga = "Tonga"
        case trinidadAndTobago = "Trinidad and Tobago"
        case tunisia = "Tunisia"
        case turkey = "Turkey"
        case turkmenistan = "Turkmenistan"
        case tuvalu = "Tuvalu"
        case uganda = "Uganda"
        case ukraine = "Ukraine"
        case unitedArabEmirates = "United Arab Emirates"
        case unitedKingdom = "United Kingdom"
        case unitedStates = "United States"
        case uruguay = "Uruguay"
        case uzbekistan = "Uzbekistan"
        case vanuatu = "Vanuatu"
        case vaticanCity = "Vatican City"
        case venezuela = "Venezuela"
        case vietnam = "Vietnam"
        case yemen = "Yemen"
        case zambia = "Zambia"
        case zimbabwe = "Zimbabwe"

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
            case .czechRepublicCzechia: .czechRepublic
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
