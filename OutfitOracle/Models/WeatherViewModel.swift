//
//  WeatherViewModel.swift
//  OutfitOracle
//
//  Created by 刘佳雨 on 2025/4/24.
//

import Foundation

@Observable
class WeatherViewModel {
    
    struct Returned: Codable {
        var current: Current
    }
    
    struct Current: Codable {
        var temperature_2m: Double
        var apparent_temperature: Double
        var weather_code: Int
    }
    
    var temperature = 0.0
    var feelsLike = 0.0
    var weatherCode = 0
    var urlString = "https://api.open-meteo.com/v1/forecast?latitude=42.33467401570891&longitude=-71.17007347605109&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m&hourly=uv_index&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum&temperature_unit=fahrenheit&wind_speed_unit=mph&precipitation_unit=inch&timezone=auto"
    
    func getData() async {
        print("🕸️ We are accessing URL: \(urlString)")
        guard let url = URL(string: urlString) else {
            print("😡 ERROR: Could not create a url from \(urlString)")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let returned = try? JSONDecoder().decode(Returned.self, from: data) else {
                print("😡 JSON ERROR: Couldn ot decode returned JSON")
                return
            }
            temperature = returned.current.temperature_2m
            feelsLike = returned.current.apparent_temperature
            weatherCode = returned.current.weather_code
            
        } catch {
            print("😡 ERROR: Could not get data from \(urlString)")
        }
                    
    }
}
