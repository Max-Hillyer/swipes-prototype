import SwiftUI

struct ProgramCardView: View {
    @EnvironmentObject var locationManager: OfflineLocationManager
    @State private var showingwhysheet = false
    @Environment(\.colorScheme) private var colorScheme
    let program: Program
    let isTop: Bool
    let stackIndex: Int
    let dragOffset: CGSize
    let swipeDirection: SwipeView.SwipeDirection
    let recommendationSystem: SmartRecommendationSystem

    var body: some View {
        let reccomendationsScore = recommendationSystem.getRecommendationScore(for: program) * 100
        VStack(alignment: .leading, spacing: 16) {
            header
            categoryBadge
            ProgramCard(program: program, stackIndex: stackIndex,recommendationSystem: recommendationSystem)
            
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.12), radius: colorScheme == .dark ? 14 : 10, x: 0, y: 6)
        )
        .modifier(
            CardEffectsModifier(
                isTop: isTop,
                dragOffset: dragOffset,
                swipeDirection: swipeDirection,
                showingRecommended: reccomendationsScore > 70,
                showingExploration: reccomendationsScore <= 60,
                stackIndex: stackIndex
            ))
    }
    
    private var header: some View {
        
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(program.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding()
                HStack {
                    Image(systemName: "map")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(program.location)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.leading)
            }
            
            
            Spacer()
            let reccomendationsScore = recommendationSystem.getRecommendationScore(for: program) * 100
            let whyStr = String(format: "%.0f",reccomendationsScore)
            if reccomendationsScore > 70 {
                VStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundColor(.orange)
                        .scaleEffect(1.2)
                    Text("Recommended")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("\(whyStr)% Match")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                    
                }
            } else if reccomendationsScore <= 60 && stackIndex >= 5 {
                VStack(spacing: 4) {
                    Image(systemName: "rays")
                        .font(.title2)
                        .foregroundColor(.purple)
                        .scaleEffect(1.2)
                    Text("Exploration Pick")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    Text("\(whyStr)% Match")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                }
            }
                    var color: Color {
                        guard let score = Int(whyStr) else {return .gray}
                        switch score {
                        case 0..<25:
                            return .red
                        case 25..<79:
                            return .orange
                        case 79..<101:
                            return .green
                        default:
                            return .gray
                        }
                    }
                    
                }
                .padding()
            }
    
    private var categoryBadge: some View {
        HStack {
            Text(program.category)
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(colorScheme == .dark ? Color.blue.opacity(0.18) : Color.blue.opacity(0.10))
                .foregroundColor(.blue)
                .cornerRadius(20)
            Spacer()
        }
        .padding(.leading)
    }
    
    struct ProgramCard: View {
        @EnvironmentObject var locationManager: OfflineLocationManager
    @Environment(\.colorScheme) private var colorScheme
        let program: Program
        let stackIndex: Int
        let recommendationSystem: SmartRecommendationSystem
        
        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                
                if !program.applicationDate.isEmpty {
                    HStack {
                        DetailRow(
                            icon: "calendar", text: program.applicationDate,
                            color: .orange, stackIndex: stackIndex)
                        if stackIndex < 5{
                            Text("Application Deadline")
                                .padding(.leading)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                if !program.duration.isEmpty {
                    HStack {
                        DetailRow(icon: "clock", text: program.duration, color: .blue, stackIndex: stackIndex)
                        if stackIndex < 5{
                            Text("Duration")
                                .padding(.leading)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
                if !program.cost.isEmpty {
                    HStack {
                        DetailRow(
                            icon: "dollarsign.circle", text: program.cost, color: .green, stackIndex: stackIndex
                        )
                        if stackIndex < 5{
                            Text("Cost")
                                .padding(.leading)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
                if !program.restrictions.isEmpty {
                    HStack {
                        DetailRow(
                            icon: "info.circle", text: program.restrictions,
                            color: .secondary, stackIndex: stackIndex)
                        if stackIndex < 5 {
                            Text("Info")
                                .padding(.leading)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
                if let distanceStr = locationManager.distanceToProgramFormatted(programLat: program.latitude, programLon: program.longitude) {
                    HStack {
                        DetailRow(icon: "location.circle", text: distanceStr, color: .indigo, stackIndex: stackIndex)
                        if stackIndex < 5 {
                            Text("Distance")
                                .padding(.leading)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? Color(.tertiarySystemBackground) : Color(.secondarySystemBackground))
                    .opacity(0.02)
            )
            
        }
    }
    
    struct CardEffectsModifier: ViewModifier {
        let isTop: Bool
        let dragOffset: CGSize
        let swipeDirection: SwipeView.SwipeDirection
        let showingRecommended: Bool
        let showingExploration: Bool
        let stackIndex: Int
    @Environment(\.colorScheme) private var colorScheme
        
        func body(content: Content) -> some View {
            let dragWidth = Double(dragOffset.width)
            let dragAbs = abs(dragWidth)
            
            return content
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            showingRecommended ? Color.orange.opacity(0.5) : showingExploration && stackIndex > 5 ? Color.purple.opacity(0.5) : Color.clear,
                            lineWidth: 2
                        )
                )
                .scaleEffect(isTop ? CGFloat(1.0 - dragAbs / 2000.0) : 1.0)
                .rotationEffect(.degrees(isTop ? dragWidth / 20.0 : 0))
                .offset(
                    x: isTop ? CGFloat(dragWidth) : 0,
                    y: isTop ? CGFloat(dragOffset.height * 0.3) : 0
                )
                .opacity(isTop ? (1.0 - dragAbs / 500.0) : 1.0)
                .overlay(
                    Group {
                        if isTop && dragAbs > 50 {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    swipeDirection == .right
                                    ? Color.green.opacity(colorScheme == .dark ? 0.28 : 0.30)
                                    : Color.red.opacity(colorScheme == .dark ? 0.28 : 0.30)
                                )
                                .overlay(
                                    Image(systemName: swipeDirection == .right ? "heart.fill" : "xmark")
                                        .font(.system(size: 50, weight: .bold))
                                        .foregroundColor(swipeDirection == .right ? .green : .red)
                                )
                        }
                    }
                )
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: dragOffset)
        }
    }
    
    
    
    struct DetailRow: View {
        let icon: String
        let text: String
        let color: Color
        let stackIndex: Int
        
        var body: some View {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                    .frame(width: 16)
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
