//
//  Utils.swift
//  iMusic
//
//  Created by Hector Carmona on 8/28/24.
//

import Foundation

class Utils {
    
    class func getformattedCurrentSongTimeLabel(value: Float) -> String {
        if value < 60 {
            if value < 10 {
                return "0:0\(Int(value.rounded(.toNearestOrAwayFromZero)))"
            } else {
                return "0:\(Int(value.rounded(.toNearestOrAwayFromZero)))"
            }
        } else {
            let minutes = value.rounded() / 60
            let seconds =  value.truncatingRemainder(dividingBy: 60).rounded()
            if seconds < 10 {
                return "\((Int(minutes.rounded(.down)))):0\(Int(seconds.rounded(.toNearestOrAwayFromZero)))"
            } else {
                return "\((Int(minutes.rounded(.down)))):\(Int(seconds.rounded(.toNearestOrAwayFromZero)))"
            }
        }
    }
}
