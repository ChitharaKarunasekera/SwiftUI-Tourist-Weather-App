//
//  DailyWeatherView.swift
//  CWK2Template
//
//  Created by girish lukka on 02/11/2023.
//

import SwiftUI

struct DailyWeatherView: View {
    var day: Daily
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                // Display formatted date
                Text(DateFormatterUtils.formattedDateWithWeekdayAndDay(from: TimeInterval(day.dt)))
                    .font(.headline)

                // Display weather description
                if let description = day.weather.first?.weatherDescription.rawValue {
                    Text(description.capitalized)
                        .font(.body)
                }
            }

            Spacer()

            // Display temperature
            Text("\(formattedTemp(tempK: day.temp.day))°C / \(formattedFeelsLike(feelsLike: day.feelsLike.day))°C")
                .font(.title3)

            // Display weather icon
            if let iconName = day.weather.first?.icon {
                let iconUrl = "https://openweathermap.org/img/wn/\(iconName)@2x.png"
                AsyncImage(url: URL(string: iconUrl)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                } placeholder: {
                    ProgressView()
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
        }
}

private func formattedTemp(tempK: Double) -> String {
    let tempC = tempK - 273.15
    return String(format: "%.0f", tempC)
}

private func formattedFeelsLike(feelsLike:Double) -> String {
    let feelsLikeC = feelsLike - 273.15
    return String(format: "%.0f", feelsLikeC)
}

struct DailyWeatherView_Previews: PreviewProvider {
    static var day = WeatherMapViewModel().weatherDataModel!.daily
    static var previews: some View {
        DailyWeatherView(day: day[0])
    }
}
