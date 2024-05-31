//
//  HourWeatherView.swift
//  CWK2Template
//
//  Created by girish lukka on 02/11/2023.
//

import SwiftUI

struct HourWeatherView: View {
    var current: Current

    var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                
                // Display weather icon
                if let iconName = current.weather.first?.icon {
                    let iconUrl = "https://openweathermap.org/img/wn/\(iconName)@2x.png"
                    AsyncImage(url: URL(string: iconUrl)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    } placeholder: {
                        ProgressView()
                    }
                }
                
                // Temperature Visualization
                HStack {
                    Text("\(formattedTemp(tempK: current.temp))°C")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .bold()

                    Spacer()

                    // Show Thermometer icon changing color based on temp
                    Image(systemName: "thermometer")
                        .resizable()
                        .frame(width: 20, height: 40)
                        .foregroundColor(temperatureColor(tempK: current.temp))
                }
                
                // Weather Description
                if let description = current.weather.first?.weatherDescription.rawValue {
                    Text(description.capitalized)
                        .font(.title3)
                        // Custom color #5B5C5D
                        .foregroundColor(Color(red: 91/255, green: 92/255, blue: 93/255))
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                }
                
                // Formatted Date and Time
                Text(DateFormatterUtils.formattedDateWithDay(from: TimeInterval(current.dt)))
                    .font(.headline)
                    .foregroundColor(Color(red: 117/255, green: 117/255, blue: 117/255)) //Custom color #757575

            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(12)
            .shadow(radius: 5)
        }

    // Consolidated Temperature Conversion Function
    private func temperatureColor(tempK: Double) -> Color {
        // Return color based on temperature
        let tempC = tempK - 273.15
        return tempC > 15 ? Color.red : Color.blue
    }

    private func formattedTemp(tempK: Double) -> String {
        let tempC = tempK - 273.15
        return String(format: "%.0f", tempC)
    }
}




