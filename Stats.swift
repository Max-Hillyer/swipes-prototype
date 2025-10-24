import SwiftUI
import Charts

struct StatView: View {
    let numSwipes: Int
    let swipeRecords: [SwipeRecord]
    let userProfile: UserProfile

    private var rate: Double {
        likeRate(swipeRecords: swipeRecords)
    }

    private var totalLikes: Int {
        swipeRecords.filter { $0.liked }.count
    }

    private var totalDislikes: Int {
        swipeRecords.filter { !$0.liked }.count
    }

    private var topCategory: String {
        getMostLikedCategory()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack {
                        Text("Your Swiping Stats")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Track your program preferences")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(title: "Total Swipes", value: "\(numSwipes)", icon: "rectangle.stack", color: .blue)
                        StatCard(title: "Like Rate", value: String(format: "%.1f%%", rate * 100), icon: "heart.fill", color: .red)
                        StatCard(title: "Programs Liked", value: "\(totalLikes)", icon: "hand.thumbsup.fill", color: .green)
                        StatCard(title: "Programs Passed", value: "\(totalDislikes)", icon: "hand.thumbsdown.fill", color: .orange)
                    }
                    if #available(iOS 17 , *) {
                        chartView(data: swipeRecords, userProfile: userProfile)
                    }

                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
            }

            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray6).opacity(0.3)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        }
    }

    private func getMostLikedCategory() -> String {
        let likedRecords = swipeRecords.filter { $0.liked }
        guard !likedRecords.isEmpty else { return "No data" }

        var categoryCount: [String: Int] = [:]
        for record in likedRecords {
            let categories = record.program.category.components(separatedBy: ",")
            for category in categories {
                let normalized = userProfile.normalizeCategory(category)
                categoryCount[normalized, default: 0] += 1
            }
        }

        return categoryCount.max(by: { $0.value < $1.value })?.key ?? "No data"
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            VStack(spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

func likeRate(swipeRecords: [SwipeRecord]) -> Double {
    guard !swipeRecords.isEmpty else { return 0 }
    let likedCount = swipeRecords.filter { $0.liked }.count
    return Double(likedCount) / Double(swipeRecords.count)
}

struct CategoryData: Identifiable {
    let id = UUID()
    let category: String
    let count: Int
    let percentage: Double
}

func getLikedCategoriesData(from swipeRecords: [SwipeRecord], userProfile: UserProfile) -> [CategoryData] {
    let likedRecords = swipeRecords.filter { $0.liked }
    var categoryCount: [String: Int] = [:]

    for record in likedRecords {
        let categories = record.program.category.components(separatedBy: ",")
        for category in categories {
            let normalized = userProfile.normalizeCategory(category)
            categoryCount[normalized, default: 0] += 1
        }
    }

    let totalCount = categoryCount.values.reduce(0, +)
    return categoryCount.map { CategoryData(category: $0.key, count: $0.value, percentage: Double($0.value) / Double(totalCount) * 100) }
        .sorted { $0.count > $1.count }
}

@available(iOS 17, *)
struct chartView: View {
    let data: [SwipeRecord]
    let userProfile: UserProfile
    @State private var selectedCategory: String? = nil
    @State private var animationProgress: Double = 0.0
    @State private var showChart: Bool = false
    
    private var chartData: [(String, Int)] {
        let likedRecords = data.filter { $0.liked }
        var categoryCount: [String: Int] = [:]
        
        for record in likedRecords {
            let categories = record.program.category.components(separatedBy: ",")
            for category in categories {
                let normalized = userProfile.normalizeCategory(category)
                categoryCount[normalized, default: 0] += 1
            }
        }
        
        return categoryCount.map { (category, count) in (category, count) }
            .sorted { $0.1 > $1.1 } // Sort by count descending for better visual order
    }
    
    var totalCount: Int {
        chartData.map { $0.1 }.reduce(0, +)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Liked Categories")
                .font(.headline)
                .padding(.top)
            
            if chartData.isEmpty {
                Text("No liked programs yet")
                    .foregroundColor(.secondary)
                    .padding()
                    .opacity(showChart ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.6).delay(0.2), value: showChart)
            } else {
                Chart(chartData, id: \.0) { category, count in
                    SectorMark(
                        angle: .value("count", Double(count) * animationProgress),
                        innerRadius: .ratio(0.4),
                        angularInset: 2.0
                    )
                    .foregroundStyle(by: .value("Program", category))
                    .cornerRadius(4)
                    .opacity(selectedCategory == nil || selectedCategory == category ? 1.0 : 0.3)
                }
                .chartLegend(.hidden)
                .frame(height: 300)
                .scaleEffect(showChart ? 1.0 : 0.8)
                .opacity(showChart ? 1.0 : 0.0)
                .contentShape(Rectangle()) // Make entire area tappable
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { value in
                            let tappedCategory = getCategoryFromTapLocation(
                                tapLocation: value.location,
                                chartSize: CGSize(width: 300, height: 300),
                                chartData: chartData,
                                totalCount: totalCount
                            )
                            
                            if let category = tappedCategory {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedCategory = selectedCategory == category ? nil : category
                                }
                            }
                        }
                )
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1), value: showChart)
                
                // Selected category info
                if let selectedCategory = selectedCategory,
                   let selectedCount = chartData.first(where: { $0.0 == selectedCategory })?.1 {
                    VStack(spacing: 4) {
                        Text(selectedCategory)
                            .font(.headline)
                        Text("\(selectedCount) programs liked")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    .transition(.opacity.combined(with: .scale))
                } else if showChart {
                    Text("Tap a section to see details")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                        .opacity(animationProgress > 0.8 ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.4).delay(1.2), value: animationProgress)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6)) {
                showChart = true
            }
            
            withAnimation(.easeInOut(duration: 1.5).delay(0.3)) {
                animationProgress = 1.0
            }
        }
    }
    
    private func getCategoryFromTapLocation(
        tapLocation: CGPoint,
        chartSize: CGSize,
        chartData: [(String, Int)],
        totalCount: Int
    ) -> String? {
        let center = CGPoint(x: chartSize.width / 2, y: chartSize.height / 2)
        let radius = min(chartSize.width, chartSize.height) / 2
        
        // Calculate distance from center
        let dx = tapLocation.x - center.x
        let dy = tapLocation.y - center.y
        let distance = sqrt(dx * dx + dy * dy)
        
        // Check if tap is within the donut (between inner and outer radius)
        let innerRadius = radius * 0.4
        let outerRadius = radius * 0.9
        
        guard distance >= innerRadius && distance <= outerRadius else {
            return nil
        }
        
        // Calculate angle of tap
        var angle = atan2(dy, dx) * 180 / .pi
        // Normalize to 0-360 and adjust so 0 degrees is at top
        angle = angle + 90
        if angle < 0 {
            angle += 360
        }
        
        // Find which sector this angle falls into
        var currentAngle: Double = 0
        for (category, count) in chartData {
            let sectorAngle = 360.0 * Double(count) / Double(totalCount)
            if angle >= currentAngle && angle < currentAngle + sectorAngle {
                return category
            }
            currentAngle += sectorAngle
        }
        
        return nil
    }
}
