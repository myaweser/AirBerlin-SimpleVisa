//
//  ABBooking.swift
//  AirBerlin-SimpleVisa
//
//  Created by Loris Mazloum on 11/11/16.
//  Copyright © 2016 Maz Labs. All rights reserved.
//
//"passengers": "xxxxx",
//"credit_card": "xxxxx",
//"customer_address": "xxxxx",
//"booking_number": "5QZM9I",
//"flight_segments": "xxxxx",
//"b_id": "11111111-1111-1111-1111-11111111"

import Foundation

class ABBooking {
    let passengers: ABPassenger
    let creditCard: ABCreditCard
    let customerAddress: ABCustomerAddress
    let flightSegments: ABFlightSegment
    var bId: String? = nil
    var bookingNumber: String? = nil
    
    public init(passengers: ABPassenger, creditCard: ABCreditCard, customerAddress: ABCustomerAddress, flightSegments: ABFlightSegment) {
        self.passengers = passengers
        self.creditCard = creditCard
        self.customerAddress = customerAddress
        self.flightSegments = flightSegments
    }
    
    func toJSON() -> Data? {
        guard let passengerId = self.passengers.pId,
            let creditCardId = self.creditCard.ccId,
            let customerAddressId = self.customerAddress.cId,
            let flightSegmentId = self.flightSegments.fsId
            else { return nil }
        
        let data = [ "data":
            [
                "passengers": passengerId,
                "credit_card": creditCardId,
                "customer_address": customerAddressId,
                "flight_segments": flightSegmentId
            ]
        ]
        
        do {
            let theJSONData = try JSONSerialization.data(withJSONObject: data)
            //let theJSONData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            
            let theJSONText = NSString(data: theJSONData, encoding: String.Encoding.ascii.rawValue)
            print("JSON string = \(theJSONText!)")
            
            return theJSONData
            
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
        
    }
    
}
