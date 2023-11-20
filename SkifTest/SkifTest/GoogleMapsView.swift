//
//  MapViewControllerBridge.swift
//  SkifTest
//
//  Created by Никита Пивоваров on 20.11.2023.
//

import GoogleMaps
import SwiftUI

struct GoogleMapsView: UIViewRepresentable {
    
    private let zoom: Float = 15.0
    
    func makeUIView(context: Self.Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView()
        mapView.camera = camera
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        
    }
}
