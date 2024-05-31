//
//  WeatherNowView.swift
//  CWK2Template
//
//  Created by girish lukka on 29/10/2023.
//

import SwiftUI

struct WeatherNowView: View {
    
    @EnvironmentObject var weatherMapViewModel: WeatherMapViewModel
    @State private var isLoading = false
    @State private var temporaryCity = ""
    @State private var showAlert = false
    
    var body: some View {

        ZStack {
            
            // Shows the background image
            BackgroundImageView(weatherCondition: (weatherMapViewModel.weatherDataModel?.current.weather.first?.main ?? .clear).rawValue)
            
            VStack {
                
                HStack {
                    // Search bar
                    TextField("Change Location", text: $temporaryCity)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading)

                    // Search Button
                    Button(action: {
                        // Action for search
                        hideKeyboard()
                        weatherMapViewModel.searchCity(temporaryCity)
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding(.trailing)
                }
                .padding()
                .padding(.horizontal)
                
                // Loads the weather and locations data
                WeatherDetailView(weatherDataModel: weatherMapViewModel.weatherDataModel)
                
                Spacer()
                
                if let forecast = weatherMapViewModel.weatherDataModel {
                    WeatherStatsView(forecast: forecast)
                } else {
                    Text("Unable to fetch weather data")
                        .foregroundColor(.gray)
                        .italic()
                }
            }
            
            // Exception handling
            if let errorMessage = weatherMapViewModel.errorMessage, !errorMessage.isEmpty {
                // If there's an error message, show alert
                Text("")
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")) {
                            // Reset the error message once the alert is dismissed
                            weatherMapViewModel.errorMessage = nil
                        })
                    }
                    .onAppear {
                        self.showAlert = true
                    }
            }
        }
    }
}

// Background image view with a curve
struct BackgroundImageView: View {
    var weatherCondition: String
    var body: some View {
        let imageName = backgroundImageName(for: weatherCondition)
        return Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .blur(radius: 5)
                    .clipShape(SectionCurve())
                    .ignoresSafeArea()
                    .shadow(radius: 20)
    }
}

// Utility function to determine the background image
private func backgroundImageName(for weatherCondition: String) -> String {
    switch weatherCondition.lowercased() {
    case "clear":
        return "Clear"
    case "rain":
        return "Rainy"
    case "clouds":
        return "Cloudy"
    case "snow":
        return "Snow"
    default:
        return "Clear"
    }
}

// Utility function to determine the text color
private func textColorForWeather(weatherCondition: String) -> [Color] {
    switch weatherCondition.lowercased() {
    case "clear":
        return [Color("Clear_Dark"), Color("Clear_Light")]
    case "rain":
        return [Color("Rainy_Light"), Color("Cloudy_Dark")]
    case "clouds":
        return [Color("Cloudy_Dark"), Color("Cloudy_Light")]
    case "snow":
        return [Color("Snow"), Color("Cloudy_Light")]
    default:
        return [Color("Clear_Dark"), Color("Clear_Light")]
    }
}

// Utility function to determine the background color
private func bgColorForWeather(weatherCondition: String) -> Color {
    switch weatherCondition.lowercased() {
    case "clear":
        return Color("Clear_Light")
    case "rain":
        return Color("Cloudy_Dark")
    case "clouds":
        return Color("Cloudy_Light")
    case "snow":
        return Color("Cloudy_Light")
    default:
        return Color("Clear_Light")
    }
}

// Hide keyboard after serach
private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

// Custom shape for the background image
struct SectionCurve: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let curveHeight: CGFloat = 180.0
        let curveLength: CGFloat = rect.width * 0.2
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        path.addCurve(to: CGPoint(x: rect.midX, y: rect.midY + curveHeight),
                      control1: CGPoint(x: rect.width - curveLength, y: rect.midY),
                      control2: CGPoint(x: rect.midX + curveLength, y: rect.midY + curveHeight))
        path.addCurve(to: CGPoint(x: 0, y: rect.midY),
                      control1: CGPoint(x: rect.midX - curveLength, y: rect.midY + curveHeight),
                      control2: CGPoint(x: curveLength, y: rect.midY))
        path.closeSubpath()
        
        return path
    }
}

// Weather detail view
struct WeatherDetailView: View {
    var weatherDataModel: WeatherDataModel?

    var body: some View {
        if let forecast = weatherDataModel {
            let weatherCondition = forecast.current.weather.first?.main ?? .clear // Assuming .clear as default
            let textColor = textColorForWeather(weatherCondition: weatherCondition.rawValue)

            VStack {
                Text(forecast.timezone)
                    .shadow(radius: 10)
                    .font(.largeTitle)
                    .foregroundColor(textColor[0])
                    .fontDesign(.rounded)
                                
                Text(forecast.current.weather.first?.weatherDescription.rawValue.capitalized ?? "N/A")
                    .shadow(radius: 10)
                    .font(.title2)
                    .foregroundColor(textColor[0])
                    .fontDesign(.rounded)
                    .bold()
                
                VStack {
                    HStack {
                        let tempK = forecast.current.temp
                        let tempC = tempK - 273.15
                        let formattedTemp = String(format: "%.0f°C", tempC)
                        Text(formattedTemp)
                            .shadow(radius: 10)
                            .font(.system(size: 80))
                            .foregroundColor(textColor[0])
                            .bold()
                        
                        // Display weather icon
                        let iconName = forecast.current.weather.first?.icon
                        let iconUrl = "https://openweathermap.org/img/wn/\(iconName ?? "")@2x.png"
                        AsyncImage(url: URL(string: iconUrl)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 200)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    HStack {
                        Spacer()
                        Text(DateFormatterUtils.formattedDateTime(from: TimeInterval(forecast.current.dt)))
                            .font(.title3)
                            .foregroundColor(textColor[0])
                            .fontDesign(.rounded)
                    }
                    .padding(.horizontal, 50)
                }
            }
        } else {
            ProgressView()
        }
    }
}

// Weather statistics view (humidity, wind speed, pressure)
struct WeatherStatsView: View {
    var forecast: WeatherDataModel

    var body: some View {
        
        let weatherCondition = forecast.current.weather.first?.main ?? .clear // Assuming .clear as default
        let textColor = textColorForWeather(weatherCondition: weatherCondition.rawValue)
        
        HStack(spacing: 20) {
            WeatherInfoViewCard(value: "\(forecast.current.humidity)%", label: "Humidity", iconUrl: "drop.fill", textColor: textColor[0], bgColor: textColor[1])
            WeatherInfoViewCard(value: "\(forecast.current.windSpeed) mph", label: "Windspeed", iconUrl: "wind", textColor: textColor[0], bgColor: textColor[1])
            WeatherInfoViewCard(value: "\(forecast.current.pressure) hPa", label: "Pressure", iconUrl: "dial.min", textColor: textColor[0], bgColor: textColor[1])
        }
        .padding(.bottom, 50)
    }
}

// Individual weather info component
struct WeatherInfoViewCard: View {
    var value: String
    var label: String
    var iconUrl: String
    var textColor: Color
    var bgColor: Color

    var body: some View {
        VStack {
            
            Image(systemName: iconUrl)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(Color(textColor))

            Text(value)
                .foregroundColor(Color(textColor))
                .font(.caption)
                .bold()
                
            Text(label)
                .font(.caption)
                .foregroundColor(Color(textColor))
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(width: 100, height: 90)
        .background(Color(bgColor).opacity(0.4))
        .cornerRadius(10)
        .shadow(radius: 30)
                
    }
}

struct WeatherStatView: View {
    let title: String
    let value: String
    let systemImage: String
    
    var body: some View {
        HStack {
            VStack {
                Image(systemName: systemImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.black)
            }
            Text(value)
                .font(.headline)
        }
        .padding()

    }
}
