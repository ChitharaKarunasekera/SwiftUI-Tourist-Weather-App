//
//  TouristPlacesMapView.swift
//  CWK2Template
//
//  Created by girish lukka on 29/10/2023.
//

import Foundation
import SwiftUI
import CoreLocation
import MapKit

struct TouristPlacesMapView: View {
    
    @EnvironmentObject var weatherMapViewModel: WeatherMapViewModel
    
    @State var locations: [Location]! = []
    @State var  mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.5216871, longitude: -0.1391574), latitudinalMeters: 600, longitudinalMeters: 600)
    
    
    var body: some View {
        NavigationView {
            VStack(spacing: 5) {
                if weatherMapViewModel.coordinates != nil {
                    VStack(spacing: 10){
                        if let locationsData = locations {
                            Map(coordinateRegion: $mapRegion, showsUserLocation: true, annotationItems: locations) { location in
                                MapAnnotation(coordinate: location.coordinates) {
                                    VStack {
                                        Text(location.name) // Custom label
                                            .font(.caption)
                                            .foregroundColor(.white)
                                            .padding(5)
                                            .background(Color.black.opacity(0.7))
                                            .cornerRadius(10)
                                        Image(systemName: "mappin.circle.fill") // Custom marker image
                                            .foregroundColor(.red)
                                            .imageScale(.large)
                                    }
                                }
                            }
                            .edgesIgnoringSafeArea(.all)
                            .frame(height: 300)
                        }
                        else {
                            Map(coordinateRegion: $mapRegion, showsUserLocation: true)
                                .edgesIgnoringSafeArea(.all)
                                .frame(height: 300)
                                .mapStyle(.imagery)
                        }
                            
                        VStack{
    
                            Text("Tourist Attractions in \(weatherMapViewModel.city)")
                                .font(.title2)
                        }
                    }
                    
                }

                ListView(locations: locations.filter { $0.cityName == weatherMapViewModel.city })
                
                
            }
        }
        .onAppear {
            // process the loading of tourist places
            locations = weatherMapViewModel.loadLocationsFromJSONFile(cityName: weatherMapViewModel.city)
        }
    }
}

struct ListView: View {
    var locations: [Location]
    
    var body: some View {
        ScrollView {
            if locations.isEmpty {
                // Display message if no locations are found
                Text("No Locations Found")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                VStack (spacing: 20) {
                    ForEach(locations, id: \.id) { location in
                        VStack(alignment: .leading) {
                            // Display the first image
                            VStack (alignment: .center) {
                                if let firstImageName = location.imageNames.first {
                                    Image(firstImageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 150)
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                        .padding()
                                }
                            }
                            
                            Text(location.name)
                                .font(.headline)
                                .padding(.top, 5)
                            
                            Text(location.description)
                                .font(.subheadline)
                                .foregroundColor(Color(red: 117/255, green: 117/255, blue: 117/255))
                            
                            if let url = URL(string: location.link) {
                                Link("Learn More", destination: url)
                                    .font(.body)
                                    .foregroundColor(.blue)
                                    .padding()
                            }
                        }
                        .padding(.horizontal)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(15)
                        .shadow(radius: 3)
                    }
                }
                .padding()
            }
        }
    }
}


struct TouristPlacesMapView_Previews: PreviewProvider {
    static var previews: some View {
        TouristPlacesMapView()
    }
}
