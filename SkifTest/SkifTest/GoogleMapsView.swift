//
//  MapViewControllerBridge.swift
//  SkifTest
//
//  Created by Никита Пивоваров on 20.11.2023.
//

import GoogleMaps
import SwiftUI

struct GoogleMapsView: UIViewRepresentable {
    
    @Binding var points: [Model]
    @Binding var speed: [Double]
    private let zoom: Float = 15.0
    
    let mapView = GMSMapView()
    
    func makeUIView(context: Self.Context) -> GMSMapView {
        mapView
    }
    
    func updateUIView(_ uiView: GMSMapView, context: Context) {
        
    }
    
    func drawPath() {
        guard points.count > 0 else { return }
        mapView.animate(to: GMSCameraPosition(latitude: points[0].latitude, longitude: points[0].longitude, zoom: 15))
        var bluePath = [GMSMutablePath]()
        var yellowPath = [GMSMutablePath]()
        var redPath = [GMSMutablePath]()
        
        var isBlue = false
        var isYellow = false
        var isRed = false
        
        speed.enumerated().forEach { (i, value) in
            if value <= 70 {
                if isBlue {
                    bluePath.last?.add(CLLocationCoordinate2D(latitude: points[i].latitude, longitude: points[i].longitude))
                    bluePath.last?.add(CLLocationCoordinate2D(latitude: points[i+1].latitude, longitude: points[i+1].longitude))
                } else {
                    isBlue = true
                    isYellow = false
                    isRed = false
                    
                    let path = GMSMutablePath()
                    path.add(CLLocationCoordinate2D(latitude: points[i].latitude, longitude: points[i].longitude))
                    path.add(CLLocationCoordinate2D(latitude: points[i+1].latitude, longitude: points[i+1].longitude))
                    bluePath.append(path)
                }
            } else if value <= 90 {
                if isYellow {
                    yellowPath.last?.add(CLLocationCoordinate2D(latitude: points[i].latitude, longitude: points[i].longitude))
                    yellowPath.last?.add(CLLocationCoordinate2D(latitude: points[i+1].latitude, longitude: points[i+1].longitude))
                } else {
                    isBlue = false
                    isYellow = true
                    isRed = false
                    
                    let path = GMSMutablePath()
                    path.add(CLLocationCoordinate2D(latitude: points[i].latitude, longitude: points[i].longitude))
                    path.add(CLLocationCoordinate2D(latitude: points[i+1].latitude, longitude: points[i+1].longitude))
                    yellowPath.append(path)
                }
            } else {
                if isRed {
                    redPath.last?.add(CLLocationCoordinate2D(latitude: points[i].latitude, longitude: points[i].longitude))
                    redPath.last?.add(CLLocationCoordinate2D(latitude: points[i+1].latitude, longitude: points[i+1].longitude))
                } else {
                    isBlue = false
                    isYellow = false
                    isRed = true
                    
                    let path = GMSMutablePath()
                    path.add(CLLocationCoordinate2D(latitude: points[i].latitude, longitude: points[i].longitude))
                    path.add(CLLocationCoordinate2D(latitude: points[i+1].latitude, longitude: points[i+1].longitude))
                    redPath.append(path)
                }
            }
        }
        
        bluePath.forEach { path in
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 3.0
            polyline.strokeColor = .blue
            polyline.map = mapView
        }
        
        yellowPath.forEach { path in
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 3.0
            polyline.strokeColor = .yellow
            polyline.map = mapView
        }
        
        redPath.forEach { path in
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 3.0
            polyline.strokeColor = .red
            polyline.map = mapView
        }
    }
}
