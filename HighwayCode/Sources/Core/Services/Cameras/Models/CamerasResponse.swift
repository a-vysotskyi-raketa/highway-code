//
//  CamerasResponse.swift
//  HighwayCode
//
//  Created by Andrew Visotskyy on 21.07.2020.
//  Copyright © 2020 Gagnant. All rights reserved.
//

import Foundation

struct CamerasResponse: Decodable {

    /// Cameras devices.
    let devices: [Camera]

}
