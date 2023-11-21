//
//  Model.swift
//  SkifTest
//
//  Created by Никита Пивоваров on 20.11.2023.
//

import Foundation

struct Model: Decodable {
    let date: String
    let longitude: Double
    let latitude: Double
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let date = try container.decode(String.self)
        let longitude = try container.decode(Double.self)
        let latitude = try container.decode(Double.self)
        self.date = date
        self.longitude = longitude
        self.latitude = latitude
    }
}

extension Model: Equatable {}
