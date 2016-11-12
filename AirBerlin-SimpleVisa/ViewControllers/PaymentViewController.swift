//
//  PaymentViewController.swift
//  AirBerlin-SimpleVisa
//
//  Created by Loris Mazloum on 11/11/16.
//  Copyright © 2016 Maz Labs. All rights reserved.
//

import UIKit
import Eureka
import EurekaCreditCard
import Alamofire

class PaymentViewController: FormViewController {
    
    let activityIndicator = UIActivityIndicatorView()
    var spinner = UIBarButtonItem()
    
    @IBOutlet weak var confirmButton: UIBarButtonItem!
    
    @IBAction func confirmButtonTapped(_ sender: UIBarButtonItem) {
        
        let passenger = ABPassenger(type: .adult, salutation: "MR", firstName: "Loris", lastName: "Mazloum", dateOfBirth: "1983-06-29")
        passenger.pId = "d1d1593c-6227-4cb0-96e8-b03221c2fce6"
        
        let creditCard = ABCreditCard(number: "4111111111111111", type: .visa, holdersName: "Loris Mazloum", cvc: "123", expiryDate: "2019-03-21")
        creditCard.ccId = "f7ab0a71-d528-4276-9ce0-dcec862fa81d"
        
        let customerAddress = ABCustomerAddress(name: "Loris Mazloum", email: "loris.mazloum@gmail.com", languageCode: "EN", address1: "12345 street name", city: "Berlin", zip: "10405", countryCode: "DE")
        customerAddress.cId = "3116d49f-2363-4b3c-8243-8cef715d9d50"
        
        let flightSegment = ABFlightSegment(direction: "onward", fareCode: "NNYOW", date: "2016-11-11", number: "30BOPC8MG_20BPRT6VA")
        flightSegment.fsId = "b87a61bc-b098-4142-afb5-3d1f54875f85"
        
        let booking = Booking(passengers: passenger, creditCard: creditCard, customerAddress: customerAddress, flightSegments: flightSegment)
        
        if let bookingJson = booking.toJSON() {
            print("Got Json")
            
            createNewBooking(with: bookingJson)
        }

        
        //showConfirmationView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        spinner = UIBarButtonItem(customView: activityIndicator)
        
        addPaymentForm(toForm: form)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func addPaymentForm(toForm form: Form) {
        
        let today = NSDate()
        // format dates: http://mityugin.com/?p=244
        let twentyYearsFromNow = NSCalendar.current.date(byAdding: .year, value: 20, to: today as Date)
        
        form +++ Section("Customer Info")
            <<< NameRow(){ row in
                row.title = "Full Name"
                row.tag = "fullName"
                row.placeholder = "Customer's full name"
            }
            <<< EmailRow(){ row in
                row.title = "Email"
                row.tag = "email"
                row.placeholder = "Customer's email"
                row.add(rule: RuleRequired())
                row.add(rule: RuleEmail())
                row.validationOptions = .validatesOnChangeAfterBlurred
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            <<< PushRow<String>(){ row in
                row.title = "Preferred Language"
                row.tag = "language"
                row.selectorTitle = "Language"
                row.options = ["EN", "DE", "FR"]
            }
            +++ Section("Customer Address")
            <<< NameRow(){ row in
                row.title = "Address Line 1"
                row.tag = "addressLine1"
                row.placeholder = "Address Line 1"
            }
            <<< NameRow(){ row in
                row.title = "Address Line 2"
                row.tag = "addressLine2"
                row.placeholder = "Address Line 2"
            }
            <<< NameRow(){ row in
                row.title = "Address Line 3"
                row.tag = "addressLine3"
                row.placeholder = "Address Line 3"
            }
            <<< NameRow(){ row in
                row.title = "City"
                row.tag = "city"
                row.placeholder = "City"
            }
            <<< ZipCodeRow(){ row in
                row.title = "Zip Code"
                row.tag = "zip"
                row.placeholder = "Zip Code"
            }
            <<< PushRow<String>(){ row in
                row.title = "Country"
                row.tag = "country"
                row.selectorTitle = "Country"
                row.options = ["GB", "DE", "FR", "US"]
            }
            +++ Section("Credit Card")
            <<< NameRow(){ row in
                row.title = "Holder's Name"
                row.tag = "holdersName"
                row.placeholder = "Full name"
            }
            <<< CreditCardRow() { row in
                //$0.title = "Card"
                row.cardNumberPlaceholder = "Card Number"
                row.expirationMonthPlaceholder = "MM"
                row.expirationYearPlaceholder = "YY"
                row.cvcPlaceholder = "CVC"
//                //$0.dataSectionWidthPercentage = CGFloat(0.5)
//                //            $0.value = CreditCard()
                row.value = CreditCard(
                    cardNumber: "",
                    expirationMonth: "",
                    expirationYear: "",
                    cvc: ""
                )
        }
        
    }
    
    func createNewBooking(with bookingData: Data) {
        /**
         Create new booking
         POST https://app.xapix.io/api/v1//airberlin_lab_2016/bookings
         */
        
        // Add Headers
        
        guard let url = URL(string: "https://app.xapix.io/api/v1/airberlin_lab_2016/bookings") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("ab16_LorisMaz:yWREONJp7XKuFrPjGDo8vaHCbZMB2zm6", forHTTPHeaderField: "Authorization")
        
        
        request.httpBody = bookingData
        
        //start api call
        print("Start API Call")
        self.activityIndicator.startAnimating()
        self.navigationItem.rightBarButtonItem = spinner
        
        Alamofire.request(request)
            .responseJSON { response in
                print(response.request)  // original URL request
                print(response.response) // HTTP URL response
                print(response.data)     // server data
                print(response.result)   // result of response serialization
                
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                    
                    
                }
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.showConfirmationView()
                }
                
                
        }
        
        
    }
    
    
    // MARK: - Navigation
    
    func showConfirmationView() {
        performSegue(withIdentifier: "ToConfirmation", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
}
