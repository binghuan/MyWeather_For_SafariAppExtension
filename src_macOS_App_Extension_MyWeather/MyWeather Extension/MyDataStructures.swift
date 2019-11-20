//
//  MyModels.swift
//  MyWeather Extension
//
//  Created by binghuan on 11/20/19.
//  Copyright © 2019 Studio Bing-Huan. All rights reserved.
//

import Foundation

struct WeatherResponse: Codable {
    let data: WeatherData
}

struct WeatherData: Codable {
    let current_condition: [CurrentCondition]
    let request: [Request]
    let ClimateAverages: [ClimateAverages]
    //    var weather: [String]?
}

struct ClimateAverages: Codable {
    let month:[MonthlyData]
}

struct MonthlyData: Codable {
    let absMaxTemp: String
    let absMaxTemp_F:String
    let avgDailyRainfall: String
    let avgMinTemp:String
    let avgMinTemp_F:String
    let index:String
    let name:String
}

struct Request: Codable {
    let query: String
    let type: String
}

struct CurrentCondition: Codable {
    let observation_time: String
    let temp_C: String
    let temp_F: String
    let weatherCode: String
    let windspeedMiles: String
    let windspeedKmph: String
    let winddirDegree: String
    let winddir16Point: String
    let precipMM: String
    let precipInches: String
    let humidity: String
    let visibility: String
    let visibilityMiles: String
    let pressure: String
    let pressureInches: String
    let cloudcover: String
    let FeelsLikeC: String
    let FeelsLikeF: String
    let uvIndex: Int
    let weatherIconUrl:[WeatherIconUrl]
    let weatherDesc:[WeatherDesc]
}

struct WeatherIconUrl: Codable {
    var value: String
}
struct WeatherDesc: Codable {
    var value: String
}
