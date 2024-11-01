//
//  ContentView.swift
//  SwiftUI-Weather
//
//  Created by kangajan kuganathan on 2024-10-22.
//

import SwiftUI

struct ContentView: View {
    
    @State var isNight = false
    @State var cityName = "london"
    @State var data: WeatherData?
    
    func getWeather() async throws -> WeatherData {
        let endpoint = "https://api.openweathermap.org/data/2.5/forecast?q=\(cityName)&appid=b8116526df2a729c2426f3f6391cff0e&units=metric"
        
        // Check if the URL is valid
        guard let url = URL(string: endpoint) else {
            throw WeatherError.invalideUrl
        }
        
        // Fetch data
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Check if the response status code is 200 (OK)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw WeatherError.invalideResponse
        }
        
        // Decode the JSON data
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(WeatherData.self, from: data)
        } catch {
            print("Decoding error: \(error)")  // Helps with debugging
            throw WeatherError.invalideData
        }
    }
    
    func callWeatherData() async {
        do {
            data = try await getWeather()
        } catch WeatherError.invalideUrl {
            print("Invalide Url")
        } catch WeatherError.invalideData {
            print("Invalide Data")
        } catch WeatherError.invalideResponse {
            print("Invalide Response")
        } catch {
            print("Unexpected Error")
        }
    }

    var body: some View {
        ZStack {
            BackgroudView(isNight: isNight)
            VStack {
                
                HStack {
                    CityTextView(cityName: "\(data?.city.name ?? "city PlaceHolder"), \(data?.city.country ?? "Country placeholder")")
                    
                    Spacer()
                    
                    Button {
                        isNight.toggle()
                    } label: {
                        WeatherButton(imageName: !isNight ? "moon" : "sun.min",
                                      textColor: .white,
                                      backgroundColor: .yellow, isNight: !isNight)
                    }.padding()
                }
                MainWeatherStatusView(imageName: {
                    if(data?.list.first?.weather.first?.main.lowercased() == "rain") {
                        return WeatherIcon.rain.rawValue
                    } else if(data?.list.first?.weather.first?.main.lowercased() == "Clouds") {
                        return WeatherIcon.cloud.rawValue
                    } else if(data?.list.first?.weather.first?.main.lowercased() == "clear") {
                        return WeatherIcon.Clear.rawValue
                    }else {
                        return "cloud.sun.fill"
                    }
                }(),
                                      temperature: Int(data?.list.first?.main.temp ?? 45))
           
                HStack(spacing:20) {
                    if let forecasts = data?.list {
                        ForEach(forecasts.prefix(5).indices, id: \.self) { index in
                            let forecast = forecasts[index] // Access the specific Forecast using the index
                            WeatherDayView(
                                weatherType: forecast.weather.first?.main ?? "Unknown", // Safely access the weather type
                                imageName: {
                                    if(forecast.weather.first?.main.lowercased() == "rain") {
                                        return WeatherIcon.rain.rawValue
                                    } else if(forecast.weather.first?.main.lowercased() == "Clouds") {
                                        return WeatherIcon.cloud.rawValue
                                    } else if(forecast.weather.first?.main.lowercased() == "clear") {
                                        return WeatherIcon.Clear.rawValue
                                    }else {
                                        return "cloud.sun.fill"
                                    }
                                }(),
                                temprature: Int(forecast.main.temp) // Access temperature directly
                            )
                            
                        }
                    }

                }
                Spacer()
                
                
                Spacer()
                TabView(selection: $cityName) {
                                // Tab for London
                                Text("Welcome to London!")
                                    .tabItem {
                                        Label("London", systemImage: "crown")
                                        
                                    }
                                    .tag("London")
                                    .task {
                                        await callWeatherData()
                                    }// Set the tag to the city name

                                // Tab for Jaffna
                                Text("Explore Jaffna!")
                                    .tabItem {
                                        Label("Jaffna", systemImage: "beach.umbrella")
                                    }
                                    .tag("Jaffna")
                                    .task {
                                        await callWeatherData()
                                    }// Set the tag to the city name

                                // Tab for Paris
                                Text("Bienvenue à Paris!")
                                    .tabItem {
                                        Label("Paris", systemImage: "binoculars")
                                        
                                    }
                                
                                    .tag("Paris") // Set the tag to the city name
                                    .task {
                                        await callWeatherData()
                                    }

                                // Tab for Tokyo
                                Text("こんにちは Tokyo!")
                                    .tabItem {
                                        Label("Tokyo", systemImage: "arcade.stick.console")
                                    }
                                    .tag("Tokyo") // Set the tag to the city name
                                    .task {
                                        await callWeatherData()
                                    }
                }.frame(height: 70)
                    
            }
        }.task {
            await callWeatherData()
        }
    }
}

#Preview {
    ContentView()
}

struct WeatherDayView: View {
    var weatherType: String
    var imageName: String
    var temprature: Int
    var body: some View {
        VStack(spacing:10) {
            Text(weatherType)
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundColor(.white)
            Image(systemName: imageName)
                .resizable()
                .symbolRenderingMode(.multicolor)
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            Text("\(temprature)°")
                .font(.system(size: 25, weight: .medium, design: .default))
                .foregroundColor(.white)
        }
    }
}

struct BackgroudView: View {
    var isNight: Bool
    var body: some View {
        ContainerRelativeShape()
            .fill(!isNight ? Color.blue.gradient : Color.black.gradient)
            .ignoresSafeArea()
    }
}

struct CityTextView: View {
    var cityName: String
    var body: some View {
        Text(cityName)
            .font(.system(size: 32, weight: .medium, design: .default))
            .foregroundColor(.white)
            .padding()
    }
}


struct MainWeatherStatusView: View {
    var imageName: String
    var temperature: Int
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: imageName)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 180, height: 180)
            Text("\(temperature)°")
                .font(.system(size: 70, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.bottom, 40)
    }
}

enum WeatherIcon: String {
    case cloud = "cloud.fill"
    case rain = "cloud.rain.fill"
    case Clear = "sun.max.fill"
}
