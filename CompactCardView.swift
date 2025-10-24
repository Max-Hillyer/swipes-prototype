import SwiftUI

struct CompactProgram: View {
    let program: Program
    @EnvironmentObject var locationManager: OfflineLocationManager
    
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
            HStack {
                if !program.cost.isEmpty {
                    Label(program.cost, systemImage: "dollarsign.circle")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.top, 2)
                }
                if let distanceStr = locationManager.distanceToProgramFormatted(programLat: program.latitude, programLon: program.longitude) {
                    Label(distanceStr, systemImage: "location.circle")
                        .font(.caption)
                        .foregroundColor(.indigo)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

