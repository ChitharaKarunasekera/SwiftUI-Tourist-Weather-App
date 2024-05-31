//
//  WeatherMapViewModel.swift
//  CWK2Template
//
//  Created by girish lukka on 29/10/2023.
//

import Foundation
import SwiftUI
import CoreLocation
import MapKit


class WeatherMapViewModel: ObservableObject {
// MARK:   published variables
    @Published var weatherDataModel: WeatherDataModel?
    @Published var city = "London"
    @Published var coordinates: CLLocationCoordinate2D?
    @Published var region: MKCoordinateRegion = MKCoordinateRegion()
    @Published var errorMessage: String?
    
    init() {
// MARK:  create Task to load London weather data when the app first launches
        Task {
            do {
                try await getCoordinatesForCity(cityName: city)
                let weatherData = try await loadData(lat: coordinates?.latitude ?? 51.503300, lon: coordinates?.longitude ?? -0.079400)
                print("Weather data loaded: \(String(describing: weatherData.timezone))")
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Error loading weather data: \(error.localizedDescription)"
                }
                print("Error loading weather data: \(error)")
            }
        }
    }
    func searchCity(_ cityName: String) {
        self.city = cityName // Update city immediately to reflect in UI
        Task {
            do {
                try await getCoordinatesForCity(cityName: cityName)
            } catch {
                print("Error searching for city: \(error)")
            }
        }
        
    }
    
    func getCoordinatesForCity(cityName: String) async throws {
        let geocoder = CLGeocoder()
        if let placemarks = try? await geocoder.geocodeAddressString(cityName),
           let location = placemarks.first?.location?.coordinate {

            DispatchQueue.main.async {
                self.coordinates = location
                self.region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                Task {
                    do {
                        let weatherData = try await self.loadData(lat: location.latitude, lon: location.longitude)
                        print("Weather data loaded for \(cityName): \(String(describing: weatherData.timezone))")
                    } catch {
                        DispatchQueue.main.async {
                            self.errorMessage = "Error loading weather data for \(cityName): \(error.localizedDescription)"
                        }
                        print("Error loading weather data: \(error)")
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.errorMessage = "Error loading weather data for \(cityName)"
            }
            print("Error loading weather data")
        }
    }

    func loadData(lat: Double, lon: Double) async throws -> WeatherDataModel {
        
        if let url = URL(string: "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(lon)&appid=d1d24fe865604178f68cda9d3e45ad0e") {
            let session = URLSession(configuration: .default)

            do {
                let (data, _) = try await session.data(from: url)
                let weatherDataModel = try JSONDecoder().decode(WeatherDataModel.self, from: data)

                DispatchQueue.main.async {
                    self.weatherDataModel = weatherDataModel
                    print("weatherDataModel loaded")
                }
 
                print("MINUTELY")
                if let count = weatherDataModel.minutely?.count {
                    if let firstTimestamp = weatherDataModel.minutely?[0].dt {
                        let firstDate = Date(timeIntervalSince1970: TimeInterval(firstTimestamp))
                        let formattedFirstDate = DateFormatterUtils.shared.string(from: firstDate)
                        print("First Timestamp: \(formattedFirstDate)")
                    }

                    if let lastTimestamp = weatherDataModel.minutely?[count - 1].dt {
                        let lastDate = Date(timeIntervalSince1970: TimeInterval(lastTimestamp))
                        let formattedLastDate = DateFormatterUtils.shared.string(from: lastDate)
                        print("Last Timestamp: \(formattedLastDate)")
                    }
                }

                print("Hourly start")

                let hourlyCount = weatherDataModel.hourly.count
                print(hourlyCount)
                if hourlyCount > 0 {
                    let firstTimestamp = weatherDataModel.hourly[0].dt
                    let firstDate = Date(timeIntervalSince1970: TimeInterval(firstTimestamp))
                    let formattedFirstDate = DateFormatterUtils.shared.string(from: firstDate)
                    print("First Hourly Timestamp: \(formattedFirstDate)")
                    print("Temp in first hour: \(weatherDataModel.hourly[0].temp)")
                }

                if hourlyCount > 0 {
                    let lastTimestamp = weatherDataModel.hourly[hourlyCount - 1].dt
                    let lastDate = Date(timeIntervalSince1970: TimeInterval(lastTimestamp))
                    let formattedLastDate = DateFormatterUtils.shared.string(from: lastDate)
                    print("Last Hourly Timestamp: \(formattedLastDate)")
                    print("Temp in last hour: \(weatherDataModel.hourly[hourlyCount - 1].temp)")
                }

                print("//Hourly Complete")

                print("Daily start")
                let dailyCount = weatherDataModel.daily.count
                print(dailyCount)

                if dailyCount > 0 {
                    let firstTimestamp = weatherDataModel.daily[0].dt
                    let firstDate = Date(timeIntervalSince1970: TimeInterval(firstTimestamp))
                    let formattedFirstDate = DateFormatterUtils.shared.string(from: firstDate)
                    print("First daily Timestamp: \(formattedFirstDate)")
                    print("Temp for first day: \(weatherDataModel.daily[0].temp)")
                }

                if dailyCount > 0 {
                    let firstTimestamp = weatherDataModel.daily[dailyCount-1].dt
                    let firstDate = Date(timeIntervalSince1970: TimeInterval(firstTimestamp))
                    let formattedFirstDate = DateFormatterUtils.shared.string(from: firstDate)
                    print("Last daily Timestamp: \(formattedFirstDate)")
                    print("Temp for last day: \(weatherDataModel.daily[dailyCount-1].temp)")
                }
                print("//daily complete")
                return weatherDataModel
            } catch {

                DispatchQueue.main.async {
                    if let decodingError = error as? DecodingError {
                        self.errorMessage = "Decoding error: \(decodingError.localizedDescription)"
                    } else {
                        self.errorMessage = "Error loading weather data: \(error.localizedDescription)"
                    }
                }
                throw error 
            }
        } else {
            throw NetworkError.invalidURL
        }
    }

    enum NetworkError: Error {
        case invalidURL
    }


    func loadLocationsFromJSONFile(cityName: String) -> [Location]? {
        if let fileURL = Bundle.main.url(forResource: "places", withExtension: "json") {
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                let allLocations = try decoder.decode(MainLocation.self, from: data)

                print("dev test", allLocations.places[0].cityName)
                return allLocations.places
            } catch {
                print("Error decoding JSON: \(error)")
            }
        } else {
            print("File not found")
        }
        return nil
    }
}


