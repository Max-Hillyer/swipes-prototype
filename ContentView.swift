import SwiftUI

struct ContentView: View {
    @State private var programs: [Program] = []
    @State private var likedPrograms: [Program] = []
    @AppStorage("curIndex") private var curIndex = 0
    @State private var swipeRecords: [SwipeRecord] = []
    @StateObject private var locationManager = OfflineLocationManager()
    @State private var recommendationSystem = SmartRecommendationSystem()
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @State private var showWelcomePopup = false
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SwipeView(
                programs: $programs, likedPrograms: $likedPrograms,
                curIndex: $curIndex, swipeRecords: $swipeRecords,
                locationManager: locationManager
            )
            .tabItem {
                Image(systemName: "hand.point.up.left.and.text.fill")
                Text("Swiper")
            }
            .tag(0)

            LikedView(likedPrograms: $likedPrograms, locationManager: locationManager)
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Liked")
                }
                .tag(1)
                
            StatView(numSwipes: curIndex, swipeRecords: swipeRecords, userProfile: recommendationSystem.userProfile)
                .tabItem {
                    Image(systemName: "cellularbars")
                    Text("Stats")
                }
                .tag(2)
            
        }
        .onAppear {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            
            // Swiper tab - Blue
            let swiperItemAppearance = UITabBarItemAppearance()
            swiperItemAppearance.selected.iconColor = .systemBlue
            swiperItemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemBlue]
            
            // Liked tab - Pink
            let likedItemAppearance = UITabBarItemAppearance()
            likedItemAppearance.selected.iconColor = .systemPink
            likedItemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemPink]
            
            // Stats tab - Purple
            let statsItemAppearance = UITabBarItemAppearance()
            statsItemAppearance.selected.iconColor = .systemPurple
            statsItemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemPurple]
            
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        .accentColor(selectedTab == 0 ? .blue : selectedTab == 1 ? .pink : .purple)

        .onAppear {
            setupOnAppear()
        }
        .sheet(isPresented: $showWelcomePopup) {
            WelcomeView(hasSeenWelcome: $hasSeenWelcome, showPopup: $showWelcomePopup)
        }
        .onChange(of: likedPrograms) { _ in
            saveLikedPrograms()
        }
        .onChange(of: swipeRecords) { _ in
            saveSwipeRecords()
        }
        .onChange(of: locationManager.authorizationStatus) { newStatus in
            // Only start tracking if authorized, stop if denied/restricted
            switch newStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.startTracking()
            case .denied, .restricted:
                locationManager.stopTracking()
            case .notDetermined:
                break
            @unknown default:
                break
            }
        }
    }
    
    private func setupOnAppear() {
        if !hasSeenWelcome {
            showWelcomePopup = true
        }
        loadPrograms()
        loadLikedPrograms()
        loadSwipeRecords()
        
        // Handle location permissions
        switch locationManager.authorizationStatus {
        case .notDetermined:
            // Just request permission, don't start tracking
            // The onChange handler will start tracking if user approves
            locationManager.requestPermission()
        case .authorizedWhenInUse, .authorizedAlways:
            // Already authorized, safe to start tracking
            locationManager.startTracking()
        case .denied, .restricted:
            // User has denied, don't do anything
            print("🚫 Location access denied or restricted")
        @unknown default:
            break
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
