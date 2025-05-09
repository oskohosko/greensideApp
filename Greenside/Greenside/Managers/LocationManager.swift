//
//  LocationManager.swift
//  Greenside
//
//  Created by Oskar Hosken on 20/4/2025.
//

import CoreLocation
import Foundation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate,
  Observable
{
  // Our manager
  let manager = CLLocationManager()
  @Published var currentLocation: CLLocation?
  @Published var isRequestingLocation = false
  @Published var isTrackingLocation = false

  private var locationRequestCompletion: ((CLLocation?) -> Void)?

  override init() {
    super.init()

    manager.delegate = self
    manager.requestWhenInUseAuthorization()
    manager.desiredAccuracy = kCLLocationAccuracyBest

    // Requesting location when initialised
    self.requestCurrentLocation { [weak self] location in
      guard let self = self else { return }
      self.isRequestingLocation = true
    }
  }
  
  func startTrackingLocation() {
    guard !isTrackingLocation else { return }
    isTrackingLocation = true
    manager.startUpdatingLocation()
  }
  
  func stopTrackingLocation() {
    guard isTrackingLocation else { return }
    isTrackingLocation = false
    manager.stopUpdatingLocation()
  }

  func requestCurrentLocation(completion: @escaping (CLLocation?) -> Void) {
    isRequestingLocation = true
    locationRequestCompletion = completion
    manager.requestLocation()
  }

  // When location changes, this method is called and we update the user's location
  func locationManager(
    _ manager: CLLocationManager,
    didUpdateLocations locations: [CLLocation]
  ) {
    let location = locations.last

    DispatchQueue.main.async {
      self.currentLocation = location
      self.locationRequestCompletion?(location)
      self.locationRequestCompletion = nil
    }

    // This means we will always have at least a second when isRequestingLocation is true
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.isRequestingLocation = false
    }
  }

  func locationManager(
    _ manager: CLLocationManager,
    didFailWithError error: Error
  ) {
    print("Location error: \(error.localizedDescription)")
  }
}
