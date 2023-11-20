//
//  ViewModel.swift
//  SkifTest
//
//  Created by Никита Пивоваров on 20.11.2023.
//

import Foundation
import Combine

class ViewModel: ObservableObject {
    
    private var data = [Model]()
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
                  receiveValue: { self.data = $0 })
            .store(in: &storage)
    }
}
