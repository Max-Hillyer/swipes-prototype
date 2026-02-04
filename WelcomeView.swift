import SwiftUI

struct WelcomeView: View {
    @Binding var hasSeenWelcome: Bool
    @Binding var showPopup: Bool
    @State private var currentPage = 0
    @Environment(\.colorScheme) private var colorScheme
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "graduationcap.fill",
            title: "Your Summers Matter",
            description: "Summer programs, internships, and experiences can transform your college applications and future—but finding them shouldn't require expensive counselors",
            color: .indigo,
            systemImage: "graduationcap.fill"
        ),
        OnboardingPage(
            icon: "sparkles",
            title: "Opportunities for Everyone",
            description: "Every high school student deserves access to amazing summer programs, regardless of their resources or connections",
            color: .orange,
            systemImage: "hand.point.up.left.and.text.fill"
        ),
        OnboardingPage(
            icon: "hand.draw",
            title: "Swipe to Explore",
            description: "Swipe right on programs you love, left on ones that don't fit. It's that simple!",
            color: .green,
            systemImage: "arrow.left.arrow.right"
        ),
        OnboardingPage(
            icon: "brain.head.profile",
            title: "Smart Recommendations",
            description: "After just 5 swipes, Swipes learns from your actions to suggest programs that match your interests and goals",
            color: .purple,
            systemImage: "sparkles"
        ),
        OnboardingPage(
            icon: "heart.fill",
            title: "Save Your Favorites",
            description: "All your liked programs are saved in one place, with deadlines and details ready when you need them",
            color: .pink,
            systemImage: "heart.fill"
        ),
        OnboardingPage(
            icon: "chart.bar.fill",
            title: "Track Your Journey",
            description: "View stats and insights about your program preferences as you discover what you're truly passionate about",
            color: .blue,
            systemImage: "chart.bar.fill"
        )
    ]
    
    var body: some View {
        ZStack {
            // Dynamic background gradient based on current page
            LinearGradient(
                colors: [
                    pages[currentPage].color.opacity(colorScheme == .dark ? 0.15 : 0.08),
                    colorScheme == .dark ? Color.black : Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button(action: {
                        completeOnboarding()
                    }) {
                        Text("Skip")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                .opacity(currentPage < pages.count - 1 ? 1 : 0)
                
                Spacer()
                
                // Main content with page transitions
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 500)
                
                // Custom page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? pages[currentPage].color : Color.gray.opacity(0.3))
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.vertical, 20)
                
                Spacer()
                
                // Bottom action button
                VStack(spacing: 16) {
                    if currentPage == pages.count - 1 {
                        // Get Started button on last page
                        Button(action: {
                            completeOnboarding()
                        }) {
                            HStack {
                                Text("Get Started")
                                    .fontWeight(.bold)
                                Image(systemName: "arrow.right")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(pages[currentPage].color)
                            )
                            .foregroundColor(.white)
                        }
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        // Next button on other pages
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                currentPage += 1
                            }
                        }) {
                            HStack {
                                Text("Next")
                                    .fontWeight(.semibold)
                                Image(systemName: "arrow.right")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
                            )
                            .foregroundColor(.primary)
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentPage)
    }
    
    private func completeOnboarding() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            hasSeenWelcome = true
            showPopup = false
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let systemImage: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @Environment(\.colorScheme) private var colorScheme
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 32) {
            // Animated icon with background
            ZStack {
                // Outer glow ring
                Circle()
                    .fill(page.color.opacity(0.15))
                    .frame(width: 160, height: 160)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .opacity(isAnimating ? 0.5 : 0.8)
                
                // Inner circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                page.color.opacity(colorScheme == .dark ? 0.3 : 0.2),
                                page.color.opacity(colorScheme == .dark ? 0.15 : 0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                // Icon
                Image(systemName: page.icon)
                    .font(.system(size: 50, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [page.color, page.color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
            
            VStack(spacing: 16) {
                // Title
                Text(page.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                // Description
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 32)
            }
            
            // Visual demonstration based on page type
            if page.systemImage == "arrow.left.arrow.right" {
                SwipeGestureDemo(color: page.color)
            } else if page.systemImage == "heart.fill" {
                HeartIconsDemo(color: page.color)
            } else if page.systemImage == "graduationcap.fill" {
                SummerIconsDemo(color: page.color)
            } else if page.icon == "sparkles" && page.color == .orange {
                OpportunityIconsDemo(color: page.color)
            }
        }
        .padding()
    }
}

// Demo component for swipe gesture
struct SwipeGestureDemo: View {
    let color: Color
    @State private var offset: CGFloat = 0
    @State private var isRight = true
    
    var body: some View {
        HStack(spacing: 20) {
            // Left arrow
            Image(systemName: "arrow.left.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.red.opacity(isRight ? 0.3 : 1.0))
                .scaleEffect(isRight ? 0.8 : 1.0)
            
            // Card representation
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.2))
                .frame(width: 80, height: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color, lineWidth: 2)
                )
                .offset(x: offset)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: offset)
            
            // Right arrow
            Image(systemName: "arrow.right.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.green.opacity(isRight ? 1.0 : 0.3))
                .scaleEffect(isRight ? 1.0 : 0.8)
        }
        .onAppear {
            animateSwipe()
        }
    }
    
    private func animateSwipe() {
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            Task { @MainActor in
                withAnimation {
                    offset = isRight ? 30 : -30
                }
                
                try? await Task.sleep(nanoseconds: 800_000_000)
                
                withAnimation {
                    offset = 0
                    isRight.toggle()
                }
            }
        }
    }
}

// Demo component for liked programs
struct HeartIconsDemo: View {
    let color: Color
    @State private var floatingHearts: [FloatingHeart] = []
    
    var body: some View {
        ZStack {
            ForEach(floatingHearts) { heart in
                Image(systemName: heart.isFilled ? "heart.fill" : "heart")
                    .font(.system(size: heart.size))
                    .foregroundColor(color)
                    .offset(x: heart.offsetX, y: heart.offsetY)
                    .opacity(heart.opacity)
                    .scaleEffect(heart.scale)
            }
        }
        .frame(width: 200, height: 80)
        .onAppear {
            startFloatingHearts()
        }
    }
    
    private func startFloatingHearts() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            Task { @MainActor in
                let newHeart = FloatingHeart()
                floatingHearts.append(newHeart)
                
                // Animate the heart floating up and fading
                withAnimation(.easeOut(duration: 2.0)) {
                    if let index = floatingHearts.firstIndex(where: { $0.id == newHeart.id }) {
                        floatingHearts[index].offsetY = -60
                        floatingHearts[index].offsetX = Double.random(in: -30...30)
                        floatingHearts[index].opacity = 0.0
                        floatingHearts[index].scale = 1.3
                    }
                }
                
                // Remove after animation completes
                try? await Task.sleep(nanoseconds: 2_100_000_000)
                floatingHearts.removeAll(where: { $0.id == newHeart.id })
                
                // Keep array size manageable
                if floatingHearts.count > 8 {
                    floatingHearts.removeFirst()
                }
            }
        }
    }
}

struct FloatingHeart: Identifiable {
    let id = UUID()
    var offsetX: Double = Double.random(in: -20...20)
    var offsetY: Double = 20
    var opacity: Double = 1.0
    var scale: CGFloat = 0.5
    var size: CGFloat = CGFloat.random(in: 20...32)
    var isFilled: Bool = Bool.random()
}

// Demo component for summer opportunities
struct SummerIconsDemo: View {
    let color: Color
    @State private var rotation: Double = 0
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 32))
                .foregroundColor(.yellow)
                .rotationEffect(.degrees(rotation))
            
            Image(systemName: "briefcase.fill")
                .font(.system(size: 28))
                .foregroundColor(color)
            
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 28))
                .foregroundColor(.orange)
            
            Image(systemName: "star.fill")
                .font(.system(size: 28))
                .foregroundColor(.yellow)
        }
        .onAppear {
            withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// Demo component for equal opportunities
struct OpportunityIconsDemo: View {
    let color: Color
    @State private var currentIcon = 0
    let icons = ["person.fill", "person.2.fill", "person.3.fill"]
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: icons[index])
                    .font(.system(size: 32))
                    .foregroundColor(currentIcon >= index ? color : Color.gray.opacity(0.3))
                    .scaleEffect(currentIcon == index ? 1.2 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: currentIcon)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in
                Task { @MainActor in
                    withAnimation {
                        currentIcon = (currentIcon + 1) % 4
                    }
                }
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(hasSeenWelcome: .constant(false), showPopup: .constant(true))
    }
}
