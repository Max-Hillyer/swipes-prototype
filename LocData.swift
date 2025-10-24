import Foundation
import CoreLocation
import SwiftUI

@MainActor
class OfflineLocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published private(set) var currentLocation: CLLocation?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published private(set) var isTracking = false
        
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        authorizationStatus = locationManager.authorizationStatus
        
    #if DEBUG
    // Default location for previews
    currentLocation = CLLocation(latitude: 39.94064779930916, longitude: -75.15276066459604)
    #endif
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startTracking() {
        guard authorizationStatus == .authorizedWhenInUse ||
              authorizationStatus == .authorizedAlways else {
            return
        }
        
        locationManager.startUpdatingLocation()
        isTracking = true
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        isTracking = false
    }
    
    func requestSingleLocation() {
        print("📍 Requesting single location fix")
        locationManager.requestLocation()
    }
    
    func distanceToProgram(programLat: Double, programLon: Double) -> Double? {
        let snapshot = currentLocation
        guard let currentLoc = snapshot else { return nil }
        
        let programLocation = CLLocation(latitude: programLat, longitude: programLon)
        return currentLoc.distance(from: programLocation)
    }
    
    func distanceToProgramFormatted(programLat: Double, programLon: Double) -> String? {
        guard let meters = distanceToProgram(programLat: programLat, programLon: programLon) else {
            return nil
        }
        
        let miles = meters / 1609.34  // 1 mile = 1609.34 meters
        if miles < 50 {
            return String(format: "%.1f miles away", miles)
        } else {
            return String(format: "%.0f miles away", miles)
        }
    }
    
    func isProgramNearby(programLat: Double, programLon: Double, withinKm: Double) -> Bool {
        guard let distance = distanceToProgram(programLat: programLat, programLon: programLon) else {
            return false
        }
        return distance <= (withinKm * 1000)
    }
}

extension OfflineLocationManager: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, location.horizontalAccuracy > 0 else { return }
        
        Task { @MainActor in
            self.currentLocation = location
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        Task { @MainActor in
            self.authorizationStatus = status
        }
    }
}
