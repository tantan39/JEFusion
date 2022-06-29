//
//  HomeViewModel.swift
//  JEFusion
//
//  Created by Tan Tan on 6/29/22.
//

import Foundation

class HomeViewModel: ObservableObject {
    let cities: [City] = [
        City(title: "Los Angeles"),
        City(title: "San Francisco"),
        City(title: "NYC"),
        City(title: "Richmond"),
        City(title: "Houston")
    ]
    
}
