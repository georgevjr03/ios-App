//
//  RideType.swift
//  UberSwiftUI
//
//  Created by george kaimoottil on 28/07/23.
//

import Foundation

enum RideType: Int,CaseIterable,Identifiable{
    case UberX
    case black
    case UberXL
    
    
    var id: Int{return rawValue}
    
    var description:String{
        switch self{
        case .UberX:return "UberX"
        case .black:return "UberBlack"
        case .UberXL:return "UberXL"
        }
    }
    
    var imageName:String{
        switch self{
        case .UberX:return "uber-x"
        case .black:return "uber-black"
        case .UberXL:return "uber-x"
        }
    }
    
    var baseFare:Double{
        switch self{
        case .UberX:return 5
        case .black:return 20
        case .UberXL:return 10
        }
    }
    
    func computePrice(for distanceInMeters:Double) -> Double {
        let distanceInMiles = distanceInMeters / 1600
        
        switch self{
        case .UberX:return distanceInMiles * 1.5 + baseFare
        case .black:return distanceInMiles * 2.0 + baseFare
        case .UberXL:return distanceInMiles * 1.75 + baseFare
        }
    }
}
