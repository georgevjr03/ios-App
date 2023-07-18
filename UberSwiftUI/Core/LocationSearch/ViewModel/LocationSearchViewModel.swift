//
//  LocationSearchViewModel.swift
//  UberSwiftUI
//
//  Created by george kaimoottil on 24/07/23.
//

import Foundation
import MapKit

class LocationSearchViewModel:NSObject,ObservableObject{
    
    //MARK: - Properties
    
    @Published var results = [MKLocalSearchCompletion]()
    @Published var selectedUberLocation : UberLocation?
    @Published var pickUpTime: String?
    @Published var dropOffTime: String?
    
    var userLocation:CLLocationCoordinate2D?
    
    
    private let searchCompleter = MKLocalSearchCompleter()
    var queryFragment:String = ""{
        didSet{
            searchCompleter.queryFragment = queryFragment
        }
    }
    
    //MARK: - Lifecycle
    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.queryFragment = queryFragment
    }
    
    //MARK: - Helpers
    func selectLocation(_ localSearch:MKLocalSearchCompletion){
        locationSearch(forLocalSearchCompletion: localSearch) { response, error in
            if let error = error{
                print("DEBUG:Location search failed with error \(error.localizedDescription)")
                return
            }
            
            guard let item = response?.mapItems.first else{return}
            let coordinate = item.placemark.coordinate
            self.selectedUberLocation = UberLocation(title: localSearch.title,
                                                     coordinate: coordinate)
            print("DEBUG:Location coordinates \(coordinate)")
        }
    }
    
    func locationSearch(forLocalSearchCompletion localSearch: MKLocalSearchCompletion,
                        completion:@escaping MKLocalSearch.CompletionHandler){
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = localSearch.title.appending(localSearch.subtitle)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start(completionHandler: completion)
    }
    
    func computeRidePrice(forType type:RideType)->Double{
        guard let destcoordinate = selectedUberLocation?.coordinate else{return 0.0}
        guard let userCoordinate = self.userLocation else {return 0.0}
        
        let userLocation = CLLocation(latitude: userCoordinate.latitude,
                                      longitude: userCoordinate.longitude)
        let destination = CLLocation(latitude: destcoordinate.latitude,
                                     longitude: destcoordinate.longitude)
        
        let tripDistanceInMeters = userLocation.distance(from: destination)
        return type.computePrice(for: tripDistanceInMeters)
    }
    
    func getDestinationRoute(from userLocation:CLLocationCoordinate2D,
                             to destination :CLLocationCoordinate2D,
                             completion: @escaping (MKRoute)->Void){
        let userPlacemark = MKPlacemark(coordinate: userLocation)
        let destPlacemark = MKPlacemark(coordinate: destination)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: userPlacemark)
        request.destination = MKMapItem(placemark: destPlacemark)
        let directions = MKDirections(request: request)
        
        directions.calculate { response, error in
            if let error = error{
                print("DEBUG:Failed to get directions with error \(error.localizedDescription)")
                return
            }
            guard let route = response?.routes.first else{return}
            self.configurePickupAndDropOffTime(with: route.expectedTravelTime)
            completion(route)
            
        }
        
    }
    
    func configurePickupAndDropOffTime(with expectedTravelTime: Double){
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        
        pickUpTime = formatter.string(from: Date())
        dropOffTime = formatter.string(from: Date() + expectedTravelTime)
    }
    
}

//MARK: -MKLocalSearchCompleterDelegate

extension LocationSearchViewModel:MKLocalSearchCompleterDelegate{
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results
    }
}
