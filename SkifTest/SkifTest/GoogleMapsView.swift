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
    @Environment(\.colorScheme) var colorScheme
    private let zoom: Float = 15.0
    
    let mapView = GMSMapView()
    let marker = GMSMarker()
    
    func makeUIView(context: Self.Context) -> GMSMapView {
        applyColorSchemeToMap()
        return mapView
    }
    
    func updateUIView(_ uiView: GMSMapView, context: Context) {
        applyColorSchemeToMap()
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
                    bluePath.last?.add(CLLocationCoordinate2D(latitude: points[i].latitude, 
                                                              longitude: points[i].longitude))
                    bluePath.last?.add(CLLocationCoordinate2D(latitude: points[i+1].latitude,
                                                              longitude: points[i+1].longitude))
                } else {
                    isBlue = true
                    isYellow = false
                    isRed = false
                    
                    let path = GMSMutablePath()
                    path.add(CLLocationCoordinate2D(latitude: points[i].latitude, 
                                                    longitude: points[i].longitude))
                    path.add(CLLocationCoordinate2D(latitude: points[i+1].latitude,
                                                    longitude: points[i+1].longitude))
                    bluePath.append(path)
                }
            } else if value <= 90 {
                if isYellow {
                    yellowPath.last?.add(CLLocationCoordinate2D(latitude: points[i].latitude,
                                                                longitude: points[i].longitude))
                    yellowPath.last?.add(CLLocationCoordinate2D(latitude: points[i+1].latitude, 
                                                                longitude: points[i+1].longitude))
                } else {
                    isBlue = false
                    isYellow = true
                    isRed = false
                    
                    let path = GMSMutablePath()
                    path.add(CLLocationCoordinate2D(latitude: points[i].latitude,
                                                    longitude: points[i].longitude))
                    path.add(CLLocationCoordinate2D(latitude: points[i+1].latitude, 
                                                    longitude: points[i+1].longitude))
                    yellowPath.append(path)
                }
            } else {
                if isRed {
                    redPath.last?.add(CLLocationCoordinate2D(latitude: points[i].latitude, 
                                                             longitude: points[i].longitude))
                    redPath.last?.add(CLLocationCoordinate2D(latitude: points[i+1].latitude, 
                                                             longitude: points[i+1].longitude))
                } else {
                    isBlue = false
                    isYellow = false
                    isRed = true
                    
                    let path = GMSMutablePath()
                    path.add(CLLocationCoordinate2D(latitude: points[i].latitude, 
                                                    longitude: points[i].longitude))
                    path.add(CLLocationCoordinate2D(latitude: points[i+1].latitude, 
                                                    longitude: points[i+1].longitude))
                    redPath.append(path)
                }
            }
        }
        
        bluePath.forEach { path in
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 3.0
            polyline.strokeColor = .newBlue
            polyline.map = mapView
        }
        
        yellowPath.forEach { path in
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 3.0
            polyline.strokeColor = .newYellow
            polyline.map = mapView
        }
        
        redPath.forEach { path in
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 3.0
            polyline.strokeColor = .newRed
            polyline.map = mapView
        }
        
        createMarker()
    }
    
    func applyColorSchemeToMap() {
        do {
            if let styleURL = Bundle.main.url(forResource: (colorScheme == .dark) ? "DarkColorScheme" : "LightColorScheme", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }
    
    func createMarker() {
        guard points.count > 0 else { return }
        
        marker.position = CLLocationCoordinate2D(latitude: points[0].latitude, longitude: points[0].longitude)
        guard let image = UIImage(named: "Marker") else { return }
        let iconView = UIImageView(image: image)
        iconView.frame = CGRect(x: 0, y: 0, width: 48, height: 54)
        marker.iconView = iconView
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.map = mapView
    }
    
    func moveMarker(latitude: Double, longitude: Double, angle: Double) {
        marker.iconView?.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
        marker.position = CLLocationCoordinate2D(latitude: latitude, 
                                                 longitude: longitude)
    }
    
    func moveCamera(latitude: Double, longitude: Double) {
        mapView.animate(to: GMSCameraPosition(latitude: latitude,
                                              longitude: longitude,
                                              zoom: mapView.camera.zoom))
    }
    
    func zoomCamera(multiplier: Float) {
        mapView.animate(toZoom: mapView.camera.zoom * multiplier)
    }
}
