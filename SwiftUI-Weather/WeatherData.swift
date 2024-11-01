import Foundation

struct WeatherData: Codable {
    let city: City
    let list: [Forecast]  // Renamed for clarity
}

struct City: Codable {
    let name: String
    let country: String
}

struct Forecast: Codable { // Renamed from List to avoid confusion with Swift's List type
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double  // Changed to Double for precision
}

struct Weather: Codable {
    let main: String
}
