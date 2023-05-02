//
//  WeatherView.swift
//  CrashAssist
//
//  Created by Netanel Sadeghi on 5/1/23.
//

import SwiftUI

struct WeatherResponse: Codable {
    let weather: [Weather]
    let main: Main
    let name: String
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Main: Codable {
    let temp: Double
    let temp_min: Double
    let temp_max: Double
    let humidity: Double
}

class WeatherViewModel: ObservableObject {
    @Published var temperature: Double?
    @Published var humidity: Double?
    @Published var icon: String?
    @Published var cityName: String?
    
    let apiKey = "f0f20b63c5d05046f30ce45c5c5ab41c"
    let city = "Los Angeles"
    let units = "imperial"
    let baseUrl = "https://api.openweathermap.org/data/2.5/weather"
    
    func fetchWeather() {
        let urlString = "\(baseUrl)?q=\(city)&units=\(units)&appid=\(apiKey)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching weather data: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            
            do {
                let weather = try JSONDecoder().decode(WeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    self.temperature = weather.main.temp
                    self.humidity = weather.main.humidity
                    self.icon = weather.weather.first?.icon
                    self.cityName = weather.name
                }
            } catch {
                print("Error decoding weather data: \(error.localizedDescription)")
            }
        }.resume()
    }
}

struct WeatherView: View {
    @StateObject var viewModel = WeatherViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            if let cityName = viewModel.cityName {
                Text(cityName)
                    .font(.title)
            }
            
            if let icon = viewModel.icon {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.system(size: 100))
            }
            
            if let temperature = viewModel.temperature {
                Text("\(Int(temperature))°F")
                    .font(.largeTitle)
            }
            
            if let humidity = viewModel.humidity {
                Text("Humidity: \(Int(humidity))%")
                    .font(.headline)
            }
        }
        .onAppear {
            viewModel.fetchWeather()
        }
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView()
    }
}
