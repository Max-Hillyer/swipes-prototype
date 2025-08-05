import SwiftUI

struct CompactProgram: View {
    let program: Program
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(program.name)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            HStack(spacing: 12) {
                Label(program.location, systemImage: "location")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if !program.category.isEmpty {
                    Label(program.category, systemImage: "tag")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .lineLimit(1)
            HStack(spacing: 12) {
                if !program.applicationDate.isEmpty {
                    Label(program.applicationDate, systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                if !program.duration.isEmpty {
                    Label(program.duration, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .lineLimit(1)
            if !program.cost.isEmpty {
                Text(program.cost)
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.top, 2)
            }
            if !program.link.isEmpty && program.link != "No link" {
                Link("View Details", destination: URL(string: program.link)!)
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.top,2)
            }
        }
        .padding(.vertical, 4)
    }
}

struct LikedView_Previews: PreviewProvider{
    static var previews: some View {
        LikedView(likedPrograms: .constant([]))
    }
}
