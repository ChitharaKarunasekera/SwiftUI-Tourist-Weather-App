//
//  WeatherForcastView.swift
//  CWK2Template
//
//  Created by girish lukka on 29/10/2023.
//

import SwiftUI

struct WeatherForecastView: View {
    // Environment object to access weather data from the view model
    @EnvironmentObject var weatherMapViewModel: WeatherMapViewModel
    
    var body: some View {
        NavigationView {
            ScrollView{
                VStack(alignment: .leading, spacing: 16) {
                    // Check and unwrap hourly weather data if available
                    if let hourlyData = weatherMapViewModel.weatherDataModel?.hourly {
                        // Horizontal scroll view for hourly weather data
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                // Loop through each hour's data and display
                                ForEach(hourlyData) { hour in
                                    HourWeatherView(current: hour)
                                }
                            }
                            .padding()
                            .padding(.horizontal, 16)
                        }
                        .frame(height: 180)
                    }
                    // Divider for visual separation
                    Divider()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    
                    VStack {
                        // List view for daily weather data
                        List {
                            // Loop through each day's data if available
                            ForEach(weatherMapViewModel.weatherDataModel?.daily ?? []) { day in
                                DailyWeatherView(day: day)
                            }
                        }
                        .listStyle(.plain)
                        .frame(height: 500)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 15)
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image(systemName: "sun.min.fill")
                        VStack {
                            // Display city name in the toolbar
                            Text("Weather Forecast for \(weatherMapViewModel.city)")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct WeatherForcastView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherForecastView()
    }
}
