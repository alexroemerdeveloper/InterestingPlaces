//
//  MapKitView.swift
//  InterestingPlaces
//
//  Created by Alexander Römer on 20.12.19.
//  Copyright © 2019 Alexander Römer. All rights reserved.
//

import SwiftUI
import MapKit

struct MapKitView: UIViewRepresentable {
    
    @Binding var centerCoordinate   : CLLocationCoordinate2D
    @Binding var selectedPlace      : MKPointAnnotation?
    @Binding var showingPlaceDetails: Bool
    
    var annotations: [MKPointAnnotation]
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapKitView
        
        init(_ parent: MapKitView) {
            self.parent = parent
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            print(mapView.centerCoordinate)
            parent.centerCoordinate = mapView.centerCoordinate
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let id = "Placemark"
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: id)
            
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: id)
                annotationView?.canShowCallout = true
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }
        
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let placemark = view.annotation as? MKPointAnnotation else { return }
            parent.selectedPlace = placemark
            parent.showingPlaceDetails = true
        }
    }
    
    
    
    func makeCoordinator() -> MapKitView.Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<MapKitView>) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
//        let annotation        = MKPointAnnotation()
//        annotation.title      = "London"
//        annotation.subtitle   = "Capital of London"
//        annotation.coordinate = CLLocationCoordinate2D(latitude: 51.5, longitude: 0.13)
//        mapView.addAnnotation(annotation)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapKitView>) {
        print("Updating")
        if annotations.count != uiView.annotations.count {
            uiView.removeAnnotations(uiView.annotations)
            uiView.addAnnotations(annotations)
        }
    }
    
}


extension MKPointAnnotation {
    static var example: MKPointAnnotation {
        let annotation        = MKPointAnnotation()
        annotation.title      = "London"
        annotation.subtitle   = "Capital of London"
        annotation.coordinate = CLLocationCoordinate2D(latitude: 51.5, longitude: 0.13)
        return annotation
    }
}

struct MapKitView_Previews: PreviewProvider {
    static var previews: some View {
        MapKitView(centerCoordinate: .constant(MKPointAnnotation.example.coordinate), selectedPlace: .constant(MKPointAnnotation.example), showingPlaceDetails: .constant(false),  annotations: [MKPointAnnotation.example])
    }
}
