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
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startTracking() {
        // Explicitly check for denied/restricted first
        if authorizationStatus == .denied || authorizationStatus == .restricted {
            print("🚫 Location tracking explicitly denied or restricted")
            isTracking = false
            stopTracking() // Make sure we're stopped
            return
        }
        
        guard authorizationStatus == .authorizedWhenInUse ||
              authorizationStatus == .authorizedAlways else {
            print("🚫 Location tracking not authorized")
            isTracking = false
            return
        }
        
        locationManager.startUpdatingLocation()
        isTracking = true
        print("📍 Location tracking started")
    }
    
    func stopTracking() {
        // Force stop regardless of state
        print("🛑 FORCE STOPPING location tracking")
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        isTracking = false
    }
    
    func requestSingleLocation() {
        // Explicitly check for denied/restricted first
        if authorizationStatus == .denied || authorizationStatus == .restricted {
            print("🚫 Cannot request location - permission explicitly denied or restricted")
            return
        }
        
        guard authorizationStatus == .authorizedWhenInUse ||
              authorizationStatus == .authorizedAlways else {
            print("🚫 Cannot request location - permission not granted")
            return
        }
        
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
        // Reject updates if not authorized
        let status = manager.authorizationStatus
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            print("🚫 Rejecting location update - not authorized (status: \(status.rawValue))")
            return
        }
        
        guard let location = locations.last, location.horizontalAccuracy > 0 else { return }
        
        Task { @MainActor in
            self.currentLocation = location
            print("📍 Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error)")
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        Task { @MainActor in
            self.authorizationStatus = status
            
            // Immediately and aggressively stop tracking if permission is denied or restricted
            if status == .denied || status == .restricted {
                print("🚫 Location permission denied/restricted - FORCE STOPPING all tracking")
                self.isTracking = false
                self.stopTracking()
            } else if status == .authorizedWhenInUse || status == .authorizedAlways {
                print("✅ Location permission granted")
            } else if status == .notDetermined {
                print("❓ Location permission not yet determined")
            }
        }
    }
}
