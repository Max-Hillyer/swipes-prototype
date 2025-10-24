import SwiftUI

struct LikedView: View {
    @Binding var likedPrograms: [Program]
    @State private var showingClearAlert = false
    @State var locationManager: OfflineLocationManager
    
    var body: some View {
        NavigationStack {
            VStack {
                if likedPrograms.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "heart")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No Liked Programs Yet")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Start swiping to find programs you like!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(likedPrograms, id: \.name) { program in
                            CompactProgram(program: program)
                                .environmentObject(locationManager)
                                .swipeActions(edge: .trailing) {
                                    Button("Remove") {
                                        if let index = likedPrograms.firstIndex(where: { $0.name == program.name }) {
                                            likedPrograms.remove(at: index)
                                        }
                                    }
                                    .tint(.red)
                                }
                        }
                    }
                }
            }
            .navigationTitle("Liked Programs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !likedPrograms.isEmpty {
                        Button(action: {
                            showingClearAlert = true
                        }) {
                            Image(systemName: "trash")
                                .font(.title3)
                                .foregroundColor(.red)
                        }
                        .accessibilityLabel("Clear All")
                    }
                }
            }
            .alert("Clear All Liked Programs", isPresented: $showingClearAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    likedPrograms.removeAll()
                }
            } message: {
                Text("Are you sure you want to clear all liked programs? This action cannot be undone.")
            }
        }
    }
}
