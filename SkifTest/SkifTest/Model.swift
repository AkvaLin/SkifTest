//
//  Model.swift
//  SkifTest
//
//  Created by Никита Пивоваров on 20.11.2023.
//

import Foundation

struct Model: Decodable {
    let date: String
    let x: Double
    let y: Double
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let date = try container.decode(String.self)
        let x = try container.decode(Double.self)
        let y = try container.decode(Double.self)
        self.date = date
        self.x = x
        self.y = y
    }
}
