import SwiftUI

struct ContentView: View {
    @State private var programs: [Program] = []
    @State private var likedPrograms: [Program] = []
    @AppStorage("curIndex") private var curIndex = 0
    @State private var swipeRecords: [SwipeRecord] = []
    @StateObject private var locationManager = OfflineLocationManager()
    @State private var recommendationSystem = SmartRecommendationSystem()
    
    var body: some View {
        TabView {
            SwipeView(
                programs: $programs, likedPrograms: $likedPrograms,
                curIndex: $curIndex, swipeRecords: $swipeRecords,
                locationManager: locationManager
            )
            .tabItem {
                Image(systemName: "rectangle.stack")
                Text("Swiper")
            }.foregroundColor(.blue)

            LikedView(likedPrograms: $likedPrograms, locationManager: locationManager)
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Liked")
                }
            StatView(numSwipes: curIndex, swipeRecords: swipeRecords, userProfile: recommendationSystem.userProfile)
                .tabItem {
                    Image(systemName: "cellularbars")
                    Text("Stats")
                }
            
        }
        .onAppear {
            loadPrograms()
            loadLikedPrograms()
            loadSwipeRecords()
            
            if locationManager.authorizationStatus == .notDetermined {
                locationManager.requestPermission()
            }
            
            if locationManager.authorizationStatus == .authorizedWhenInUse ||
                locationManager.authorizationStatus == .authorizedAlways {
                locationManager.startTracking()
            }
        }
        .onChange(of: likedPrograms) { _ in
            saveLikedPrograms()
        }
        .onChange(of: swipeRecords) { _ in
            saveSwipeRecords()
        }
        .onChange(of: locationManager.authorizationStatus) { newStatus in
                        if newStatus == .authorizedWhenInUse ||
                           newStatus == .authorizedAlways {
                            locationManager.startTracking()
                        }
        }
    }

    private func loadPrograms() {
        do {
            programs = try parseCSVData().shuffled()
        } catch {
            print("Error loading programs: \(error)")
            programs = []
        }
    }

    private func loadLikedPrograms() {
        guard let data = UserDefaults.standard.data(forKey: "likedPrograms")
        else {
            likedPrograms = []
            return
        }

        do {
            likedPrograms = try JSONDecoder().decode([Program].self, from: data)
        } catch {
            print("Error decoding liked programs: \(error)")
            likedPrograms = []
            UserDefaults.standard.removeObject(forKey: "likedPrograms")
        }
    }

    private func saveLikedPrograms() {
        do {
            let encoded = try JSONEncoder().encode(likedPrograms)
            UserDefaults.standard.set(encoded, forKey: "likedPrograms")
        } catch {
            print("Error saving liked programs: \(error)")
        }
    }

    private func loadSwipeRecords() {
        guard let data = UserDefaults.standard.data(forKey: "swipeRecords")
        else {
            swipeRecords = []
            return
        }

        do {
            swipeRecords = try JSONDecoder().decode(
                [SwipeRecord].self, from: data)
        } catch {
            print("Error decoding swipe records: \(error)")
            swipeRecords = []
            UserDefaults.standard.removeObject(forKey: "swipeRecords")
        }
    }

    private func saveSwipeRecords() {
        do {
            let encoded = try JSONEncoder().encode(swipeRecords)
            UserDefaults.standard.set(encoded, forKey: "swipeRecords")
        } catch {
            print("Error saving swipe records: \(error)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
