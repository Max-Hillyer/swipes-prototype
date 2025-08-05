import SwiftUI

struct ProgramCardView: View {

    let program: Program
    let isTop: Bool
    let stackIndex: Int
    let dragOffset: CGSize
    let swipeDirection: SwipeView.SwipeDirection
    let showingRecommended: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            categoryBadge
            ProgramCard(program: program)
                
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
        .modifier(
            CardEffectsModifier(
                isTop: isTop,
                dragOffset: dragOffset,
                swipeDirection: swipeDirection,
                showingRecommended: showingRecommended
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
                        .foregroundColor(.black)
                    Text(program.location)
                        .font(.subheadline)
                        .foregroundColor(.black)
                }
                .padding(.leading)
            }
            Spacer()
            if showingRecommended {
                VStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundColor(.orange)
                        .scaleEffect(1.2)
                    Text("AI Pick")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                .padding()
            }
                
        
            
        }
    }

    private var categoryBadge: some View {
        HStack {
            Text(program.category)
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(20)
            Spacer()
        }
        .padding(.leading)
    }
}
struct ProgramCard: View {
    let program: Program

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            if !program.applicationDate.isEmpty {
                DetailRow(
                    icon: "calendar", text: program.applicationDate,
                    color: .orange)
            }
            if !program.duration.isEmpty {
                DetailRow(icon: "clock", text: program.duration, color: .blue)
            }
            if !program.cost.isEmpty {
                DetailRow(
                    icon: "dollarsign.circle", text: program.cost, color: .green
                )
            }
            if !program.restrictions.isEmpty {
                DetailRow(
                    icon: "info.circle", text: program.restrictions,
                    color: .secondary)
            }
            if !program.link.isEmpty && program.link != "No Link" {
                Button(action: {
                    if let url = URL(string: program.link), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }

                }) {
                    HStack {
                        Image(systemName: "safari")
                        Text("View Details")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(20)
                }
            }
        }
        .padding(20)
        
    }
}

struct CardEffectsModifier: ViewModifier {
    let isTop: Bool
    let dragOffset: CGSize
    let swipeDirection: SwipeView.SwipeDirection
    let showingRecommended: Bool

    func body(content: Content) -> some View {
        let dragWidth = Double(dragOffset.width)
        let dragAbs = abs(dragWidth)

        return content
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        showingRecommended ? Color.orange.opacity(0.5) : Color.clear,
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
                                ? Color.green.opacity(0.3)
                                : Color.red.opacity(0.3)
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

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
                .frame(width: 16)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(2)
        }
    }
}
