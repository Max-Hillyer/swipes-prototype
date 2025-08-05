import Foundation
import SwiftUI

struct SwipeView: View {
    @Binding var programs: [Program]
    @Binding var likedPrograms: [Program]
    @Binding var curIndex: Int
    @Binding var swipeRecords: [SwipeRecord]
    @StateObject private var recommendationSystem = SmartRecommendationSystem()
    @State private var sortedPrograms: [Program] = []
    @State private var recommendationCount = 0
    @State private var showingRecommendedProgram = false
    @State private var dragOffset = CGSize.zero
    @State private var swipeDirection: SwipeDirection = .none
    @State private var dragAmount: CGFloat = 0
    @State private var aiProgress: Double = 0
    @State private var showingAIAnimation = false
    @State private var hasAppliedRecommendations = false
    @State private var showHelp = false
    @State private var showingClearAlert = false

    enum SwipeDirection {
        case none, left, right
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                mainContentView
                    .gesture(swipeGesture)

                // Swipe Instructions (first 5 cards only)
                if shouldShowInstructions {
                    swipeInstructions
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showHelp.toggle() }) {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.brown)
                            .font(.title3)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingClearAlert.toggle() }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.brown)
                            .font(.title3)
                    }
                }
            }
            .background(backgroundGradient.ignoresSafeArea(.container, edges: .bottom))
            .navigationTitle("Discover Programs")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(alignment: .top) {
                if showHelp {
                    howItWorksDropdown
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .top).combined(
                                    with: .opacity),
                                removal: .move(edge: .top).combined(
                                    with: .opacity)
                            )
                        )
                        .zIndex(1000)

                }
            }
        }
        

        .alert("Clear all data", isPresented: $showingClearAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                resetPrograms()
            }
        } message: {
            Text("This will clear all data, this action cannot be undone")
        }
        .onAppear {
            initializeSortedPrograms()
            updateRecommendationStatus()
        }
        .onChange(of: swipeRecords.count) { _ in
            updateRecommendations()
        }
        .onTapGesture {
            if showHelp {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showHelp = false
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var mainContentView: some View {
        ZStack {
            if hasAvailablePrograms {
                cardStackView
            } else {
                completionView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
    }

    private var cardStackView: some View {
        return ZStack {
            ForEach(Array(0..<3).indices, id: \.self) { i in
                let programIndex = curIndex + i
                if programIndex >= 0 && programIndex < sortedPrograms.count {
                    cardView(for: i)
                }
            }
        }
    }

    private func cardView(for index: Int) -> some View {
        let programIndex = curIndex + index

        guard programIndex < sortedPrograms.count && programIndex >= 0 else {
            return AnyView(EmptyView())
        }

        let isTopCard = index == 0
        let isRecommended = isTopCard && showingRecommendedProgram

        return AnyView(
            ProgramCardView(
                program: sortedPrograms[programIndex],
                isTop: isTopCard,
                stackIndex: index,
                dragOffset: isTopCard ? dragOffset : .zero,
                swipeDirection: isTopCard ? swipeDirection : .none,
                showingRecommended: isRecommended
            )
            .zIndex(Double(3 - index))
            .scaleEffect(
                isTopCard ? 1.0 : max(0.92 - Double(index) * 0.04, 0.85)
            )
            .offset(y: CGFloat(index * 8))
            .opacity(isTopCard ? 1.0 : 0.7)
        )
    }

    private var completionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)

            Text("All programs reviewed!")
                .font(.title2)
                .fontWeight(.bold)

            Text("Check your liked programs or start over")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            resetButton
        }
        .padding()
    }

    private var resetButton: some View {
        Button(action: resetPrograms) {
            HStack {
                Image(systemName: "arrow.clockwise")
                Text("Reset & Start Over")
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.blue)
            .cornerRadius(10)
        }
        .padding(.top, 10)
    }

    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(.systemBackground),
                Color(.systemGray6).opacity(0.3),
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                handleDragChanged(value)
            }
            .onEnded { value in
                handleDragEnded(value)
            }
    }

    private var hasAvailablePrograms: Bool {
        curIndex < sortedPrograms.count
    }

    private var shouldShowInstructions: Bool {
        return curIndex < 5 && curIndex < sortedPrograms.count
    }

    private var howItWorksDropdown: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("How It Works")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)

                Spacer()

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showHelp = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                HelpRow(
                    icon: "hand.point.right.fill",
                    color: .green,
                    title: "Swipe Right to Like",
                    description:
                        "Add programs you're interested in to your favorites"
                )

                HelpRow(
                    icon: "hand.point.left.fill",
                    color: .red,
                    title: "Swipe Left to Skip",
                    description: "Pass on programs that don't interest you"
                )

                HelpRow(
                    icon: "brain.head.profile",
                    color: .blue,
                    title: "Smart Recommendations",
                    description:
                        "Every few swipes, AI learns your preferences and shows better matches"
                )

                HelpRow(
                    icon: "sparkles",
                    color: .orange,
                    title: "Recommended Programs",
                    description:
                        "Cards with sparkles are AI-recommended based on your likes"
                )

                HelpRow(
                    icon: "lightbulb.min.fill",
                    color: .yellow,
                    title: "Don't be afraid!",
                    description:
                        "Liked programs help the system refine your suggestions"
                )

                HelpRow(
                    icon: "rectangle.filled.and.hand.point.up.left",
                    color: .gray,
                    title: "Keep swiping!",
                    description:
                        "The more you engage the better your recommendations become"
                )

                HelpRow(
                    icon: "light.beacon.min.fill",
                    color: .purple,
                    title: "Diverse Programs",
                    description:
                        "We occasionally show varied options to promote discovery "
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, 20)
        .padding(.vertical, 50)
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Gesture Handlers

    private func handleDragChanged(_ value: DragGesture.Value) {
        // Only allow dragging if there are programs to swipe
        guard curIndex < sortedPrograms.count else { return }

        dragOffset = value.translation
        dragAmount = abs(value.translation.width)

        if value.translation.width > 50 {
            swipeDirection = .right
        } else if value.translation.width < -50 {
            swipeDirection = .left
        } else {
            swipeDirection = .none
        }
    }

    private func handleDragEnded(_ value: DragGesture.Value) {
        // Only process swipe if there are programs to swipe
        guard curIndex < sortedPrograms.count else { return }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            if value.translation.width > 100 {
                likeCurrentProgram()
            } else if value.translation.width < -100 {
                skipCurrentProgram()
            }

            dragOffset = .zero
            swipeDirection = .none
            dragAmount = 0
        }
    }

    private var swipeInstructions: some View {
        HStack {
            VStack(spacing: 8) {
                Image(systemName: "hand.point.left")
                    .font(.title2)
                    .foregroundColor(.red)
                    .scaleEffect(swipeDirection == .left ? 1.3 : 1.0)
                    .animation(.spring(response: 0.3), value: swipeDirection)

                Text("Skip")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.red)
            }
            .opacity(swipeDirection == .left ? 1.0 : 0.6)

            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "hand.point.right")
                    .font(.title2)
                    .foregroundColor(.green)
                    .scaleEffect(swipeDirection == .right ? 1.3 : 1.0)
                    .animation(.spring(response: 0.3), value: swipeDirection)

                Text("Like")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
            }
            .opacity(swipeDirection == .right ? 1.0 : 0.6)
        }
        .padding(.horizontal, 40)
    }

    // MARK: - Helper Functions
    private func isProgramDiverse(_ program: Program) -> Bool {
        let restrictions = program.restrictions.lowercased()
        return restrictions.contains("underserved")
            || restrictions.contains("minorities")
    }

    private func initializeSortedPrograms() {
        if sortedPrograms.isEmpty {
            sortedPrograms = programs
        }
    }

    private func resetPrograms() {
        withAnimation(.easeInOut(duration: 0.5)) {
            curIndex = 0
            sortedPrograms = programs
            swipeRecords.removeAll()
            likedPrograms.removeAll()
            showingRecommendedProgram = false
            showingAIAnimation = false
            aiProgress = 0.0

            recommendationSystem.resetProfile()

            // Clear persisted data
            UserDefaults.standard.removeObject(forKey: "swipeRecords")

            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
    }

    private func updateRecommendations() {
        guard swipeRecords.count >= 5 else { return }
        recommendationSystem.updateRecommendations(with: swipeRecords)

        let remainingPrograms = curIndex < sortedPrograms.count ?
            Array(sortedPrograms.suffix(from: curIndex)) : []
        let recommendedPrograms = recommendationSystem.getTopRecommendations(
            from: remainingPrograms, count: remainingPrograms.count)

        if curIndex >= 0 && curIndex < sortedPrograms.count {
            sortedPrograms = Array(sortedPrograms.prefix(curIndex)) + recommendedPrograms
        }

        print(
            "Updated recommendations - \(recommendedPrograms.count) programs reordered"
        )

        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showingAIAnimation = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                showingAIAnimation = false
            }
        }
    }

    private func skipCurrentProgram() {
        guard curIndex < sortedPrograms.count else { return }

        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()

        // Add swipe record
        let record = SwipeRecord(
            program: sortedPrograms[curIndex], liked: false,
            swipeOrder: swipeRecords.count)
        swipeRecords.append(record)

        nextProgram()
        checkForRecommendation()
    }

    private func likeCurrentProgram() {
        guard curIndex < sortedPrograms.count else { return }

        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        if !likedPrograms.contains(where: {
            $0.name == sortedPrograms[curIndex].name
        }) {
            likedPrograms.append(sortedPrograms[curIndex])
        }

        let record = SwipeRecord(
            program: sortedPrograms[curIndex], liked: true,
            swipeOrder: swipeRecords.count)
        swipeRecords.append(record)

        nextProgram()
        checkForRecommendation()
    }

    private func nextProgram() {
        if curIndex < sortedPrograms.count {
            curIndex += 1
            updateRecommendationStatus()
        }
        print(curIndex)
    }

    private func updateRecommendationStatus() {
        guard curIndex < sortedPrograms.count else {
            showingRecommendedProgram = false
            showingAIAnimation = false
            return
        }

        showingRecommendedProgram = swipeRecords.count >= 5 && curIndex % 3 == 0
        showingAIAnimation = showingRecommendedProgram
    }

    private func checkForRecommendation() {
        if swipeRecords.count >= 5 && (swipeRecords.count - 5) % 3 == 0 {
            updateRecommendations()
        }
    }
}

// MARK: - Helper Views

struct HelpRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
            }
        }
    }
}
