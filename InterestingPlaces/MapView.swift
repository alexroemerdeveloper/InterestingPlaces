//
//  ContentView.swift
//  InterestingPlaces
//
//  Created by Alexander Römer on 20.12.19.
//  Copyright © 2019 Alexander Römer. All rights reserved.
//

import SwiftUI
import MapKit
import LocalAuthentication

struct MapView: View {
    
    @State private var centerCoordinate    = CLLocationCoordinate2D()
    @State private var locations           = [CodableMKPointAnnotation]()
    @State private var selectedPlaxe       : MKPointAnnotation?
    @State private var showingPlaceDetails = false
    @State private var showingEditScreen   = false
    @State private var isUnlock            = false
    
    
    var body: some View {
        ZStack {
            
            if isUnlock {
                MapKitView(centerCoordinate: $centerCoordinate, selectedPlace: $selectedPlaxe, showingPlaceDetails: $showingPlaceDetails, annotations: locations)
                    .edgesIgnoringSafeArea(.all)
                Circle()
                    .fill(Color.blue)
                    .opacity(0.3)
                    .frame(width: 32, height: 32)
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            //create a new location
                            let newLocation = CodableMKPointAnnotation()
                            newLocation.title = "Example Location"
                            newLocation.coordinate = self.centerCoordinate
                            self.locations.append(newLocation)
                            self.selectedPlaxe = newLocation
                            self.showingEditScreen = true
                        }) {
                            Image(systemName: "plus")
                        }
                        .padding()
                        .background(Color.black.opacity(0.75))
                        .foregroundColor(.white)
                        .font(.title)
                        .clipShape(Circle())
                        .padding(.trailing)
                    }
                }
            } else {
                //Button here
                Button("Unlock Places") {
                    self.authentication()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
        }
        .alert(isPresented: $showingPlaceDetails) {
            Alert(title: Text(selectedPlaxe?.title ?? "Unknown"), message: Text(selectedPlaxe?.subtitle ?? "Missing place information"), primaryButton: .default(Text("OK")), secondaryButton: .default(Text("Edit")) {
                //edit this place
                self.showingEditScreen = true
                })
        }
        .sheet(isPresented: $showingEditScreen, onDismiss: saveData) {
            if self.selectedPlaxe != nil {
                EditUIView(placemark: self.selectedPlaxe!)
            }
        }
        .onAppear(perform: loadData)
    }
    
    
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    private func loadData() {
        let filename = getDocumentsDirectory().appendingPathComponent("savedPlaces")
        do {
            let data = try Data(contentsOf: filename)
            locations = try JSONDecoder().decode([CodableMKPointAnnotation].self, from: data)
        } catch  {
            print("Unable to load Data")
        }
    }
    
    private func saveData() {
        do {
            let filename = getDocumentsDirectory().appendingPathComponent("savedPlaces")
            let data = try JSONEncoder().encode(self.locations)
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
        } catch  {
            print("Unable to save data")
        }
    }
    
    private func authentication() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "We need to unlock your data."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, authError) in
                
                DispatchQueue.main.async {
                    if success {
                        //authentication succesfully
                        self.isUnlock = true
                    } else {
                        // there was a problem
                    }
                }
            }
        } else {
            // no biometrics
        }
    }
    
    
    
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
