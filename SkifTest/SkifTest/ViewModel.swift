//
//  ViewModel.swift
//  SkifTest
//
//  Created by Никита Пивоваров on 20.11.2023.
//

import Foundation
import Combine
import GoogleMaps

class ViewModel: ObservableObject {
    
    @Published var slider: Double = 0
    @Published var liderText = ""
    @Published var data = [Model]()
    @Published var dateRange = ""
    
    @Published var totalDistance: Double = 0
    @Published var ditances = [Double]()
    
    @Published var maxSpeed: Int = 0
    @Published var speed = [Double]()
    
    @Published var multiplier = 1
    @Published var isPlaying = false
    @Published var showInfo = false
    @Published var isFocused = false
    
    @Published var speedCalculated = false
    
    private var multipliers = [1, 4, 8]
    private var multiplierIndex = 0
    public var timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    private let semaphore = DispatchSemaphore(value: 1)
    private var storage = Set<AnyCancellable>()
    
    public func getData() async {
        
        guard let url = URL(string: "https://dev5.skif.pro/coordinates.json") else { return }
        
        URLSession.shared
            .dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: [Model].self, decoder: JSONDecoder())
            .sink(receiveCompletion: { print ("Received completion: \($0).") },
                  receiveValue: {
                self.data = $0
                if let firstDate = self.data.first?.date, let secondDate = self.data.last?.date {
                    self.dateRange = "\(self.formatDate(dateString: firstDate)) - \(self.formatDate(dateString: secondDate))"
                    self.calculateDistanceAndSpeed(points: self.data.map({ model in
                        return CLLocationCoordinate2D(latitude: model.latitude, longitude: model.longitude)
                    }))
                }
            })
            .store(in: &storage)
    }
    
    private func formatDate(dateString: String) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        guard let date = df.date(from: dateString) else { return "" }
        df.dateStyle = .short
        df.timeStyle = .none
        df.locale = .autoupdatingCurrent
        return df.string(from: date)
    }
    
    private func calculateDistance(points: [CLLocationCoordinate2D]) {
        
        self.totalDistance = 0
        self.ditances = []
        
        var totalDistance: Double = 0
        var distances = [Double]()
        
        guard points.count > 1 else { return }
        
        DispatchQueue.global().async {
            self.semaphore.wait()
            for i in 0..<points.count-1 {
                let distance = self.getDistanceFromLatLonInKm(longitude1: points[i].longitude,
                                                         latitude1: points[i].latitude,
                                                         longitude2: points[i+1].longitude,
                                                         latitude2: points[i+1].latitude)
                totalDistance += distance
                distances.append(distance)
            }
            
            DispatchQueue.main.async {
                self.totalDistance = totalDistance
                self.ditances = distances
            }
            
            self.semaphore.signal()
        }
    }
    
    private func calculateSpeed() {
        
        speedCalculated = false
        maxSpeed = 0
        speed = []
        
        DispatchQueue.global().async {
            self.semaphore.wait()

            guard self.data.count == self.ditances.count + 1 else { return }
            
            for i in 0..<self.ditances.count {
                var hours: Double = 0
                
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                guard let firstDate = df.date(from: self.data[i].date) else { return }
                guard let secondDate = df.date(from: self.data[i+1].date) else { return }
                
                hours = firstDate.distance(to: secondDate) / 60 / 60
                
                let speed = self.ditances[i] / hours
                
                DispatchQueue.main.async {
                    if Int(speed) > self.maxSpeed {
                        self.maxSpeed = Int(speed)
                    }
                    
                    self.speed.append(speed)
                }
            }
            self.semaphore.signal()
            
            DispatchQueue.main.async {
                self.speedCalculated = true
            }
        }
    }
    
    private func calculateDistanceAndSpeed(points: [CLLocationCoordinate2D]) {
        calculateDistance(points: points)
        calculateSpeed()
    }
    
    private func getDistanceFromLatLonInKm(longitude1: Double, latitude1: Double, longitude2: Double, latitude2: Double) -> Double {
        let radius: Double = 6371
        
        let dLat = deg2rad(deg: latitude2 - latitude1)
        let dLon = deg2rad(deg: longitude2 - longitude1)
        
        let a = sin(dLat/2) * sin(dLat/2) + cos(deg2rad(deg: latitude1)) * cos(deg2rad(deg: latitude2)) * sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        let distance = radius * c
        
        return distance
    }
    
    private func deg2rad(deg: Double) -> Double {
        return deg * ( Double.pi / 180 )
    }
    
    public func changeMultiplier() {
        if multiplierIndex + 1 < multipliers.count {
            multiplierIndex += 1
            multiplier = multipliers[multiplierIndex]
        } else {
            multiplier = multipliers[0]
            multiplierIndex = 0
        }
        timer.upstream.connect().cancel()
        timer = Timer.publish(every: TimeInterval(0.5/Double(multiplier)), on: .main, in: .common).autoconnect()
    }
    
    public func play() {
        if isPlaying && Int(slider) < ditances.count-1 {
            slider += 1
        }
    }
    
    public func getDataForMarker() -> MarkerDataModel {
        let latitude1 = data[Int(slider)].latitude
        let longitude1 = data[Int(slider)].longitude
        let latitude2 = data[Int(slider)+1].latitude
        let longitude2 = data[Int(slider)+1].longitude
        
        let angle = calculateDegree(latitude1: latitude1, 
                                    longitude1: longitude1,
                                    latitude2: latitude2,
                                    longitude2: longitude2)
        
        return MarkerDataModel(latitude: latitude1,
                               longitude: longitude1,
                               angle: angle)
    }
    
    private func calculateDegree(latitude1: Double, longitude1: Double, latitude2: Double, longitude2: Double) -> Double {
        let dLon = (longitude2 - longitude1)
        
        let y = sin(dLon) * cos(latitude2)
        let x = cos(latitude1) * sin(latitude2) - sin(latitude1) * cos(latitude2) * cos(dLon)
        
        let brng = atan2(y, x)
        
        return brng
    }
}
