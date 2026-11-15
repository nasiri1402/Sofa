import Foundation

@main struct CountryRegressions {
    static func main() {
        let saved = Profile.Country(isoCode: "US", name: "Соединенные Штаты Америки")
        precondition(saved.localizedName(in: Locale(identifier: "en")).contains("United States"))
        precondition(saved.localizedName(in: Locale(identifier: "ru")).contains("Штаты"))
        precondition(saved.localizedName(in: Locale(identifier: "de")).contains("Vereinigte Staaten"))
        print("PASS: stored Russian country name follows English, Russian and German UI locales")
        let lowercase = Profile.Country(isoCode: "us", name: "Legacy")
        precondition(lowercase.localizedName(in: Locale(identifier: "en")) == saved.localizedName(in: Locale(identifier: "en")))
        print("PASS: lowercase legacy ISO code is normalized for display")
        for code in ["", "not-an-ISO-code", "ZZ"] {
            let unknown = Profile.Country(isoCode: code, name: "Saved legacy region")
            precondition(unknown.localizedName(in: Locale(identifier: "en")) == "Saved legacy region")
        }
        print("PASS: unknown legacy country keeps the saved fallback name")
        precondition(saved.isoCode == "US" && saved.name == "Соединенные Штаты Америки")
        print("PASS: changing display language does not mutate persisted country fields")
    }
}
