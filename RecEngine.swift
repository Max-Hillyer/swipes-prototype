import Foundation
import SwiftUI

struct SwipeRecord: Codable, Equatable {
    let program: Program
    let liked: Bool
    let timestamp: Date
    let swipeOrder: Int


    init(program: Program, liked: Bool, swipeOrder: Int) {
        self.program = program
        self.liked = liked
        self.timestamp = Date()
        self.swipeOrder = swipeOrder
    }
}

struct UserProfile: Codable {
    var preferredCategories: [String: Double] = [:]
    var preferredLocations: [String: Double] = [:]
    var preferredDuration: [String: Double] = [:]
    var preferredCost: [String: Double] = [:]
    var preferredSelectivity: [String: Double] = [:]
    var preferredRestrictions: [String: Double] = [:]
    var totalSwipes: Int = 0
    var totalLikes: Int = 0
    var likeRate: Double = 0.0

    var categoryConfidence: [String: Int] = [:]
    var locationConfidence: [String: Int] = [:]
    var durationConfidence: [String: Int] = [:]
    var costConfidence: [String: Int] = [:]
    var selectivityConfidence: [String: Int] = [:]
    var restrictionsConfidence: [String: Int] = [:]

    mutating func updateProfile(from records: [SwipeRecord]) {
        totalSwipes = records.count
        totalLikes = records.filter { $0.liked }.count
        likeRate =
            totalSwipes > 0 ? Double(totalLikes) / Double(totalSwipes) : 0.0

        preferredCategories.removeAll()
        preferredLocations.removeAll()
        preferredDuration.removeAll()
        preferredCost.removeAll()
        preferredSelectivity.removeAll()
        preferredRestrictions.removeAll()

        categoryConfidence.removeAll()
        locationConfidence.removeAll()
        durationConfidence.removeAll()
        costConfidence.removeAll()
        selectivityConfidence.removeAll()
        restrictionsConfidence.removeAll()

        analyzePreferences(records: records)
    }
    mutating func reset() {
        preferredCategories.removeAll()
        preferredLocations.removeAll()
        preferredDuration.removeAll()
        preferredCost.removeAll()
        preferredSelectivity.removeAll()
        preferredRestrictions.removeAll()

        categoryConfidence.removeAll()
        locationConfidence.removeAll()
        durationConfidence.removeAll()
        costConfidence.removeAll()
        selectivityConfidence.removeAll()
        restrictionsConfidence.removeAll()

        totalSwipes = 0
        totalLikes = 0
        likeRate = 0.0
    }

    private mutating func analyzePreferences(records: [SwipeRecord]) {
        /**
        all programs begin with a base rating of 0.5
        a like pulls the rating towards 1 and a skip pulls it towards 0
         the list of remaining programs is reordered based primarily or cateogry ratings but also on all other factors
         confidence adds more on top if the user expresses profuse preference of a certain thing
         skips weigh more than likes
         diversity is applied in order to prevent feedback loops where the user never discorvers programs they may have been looking for in the first place
         **/
        let likedRecords = records.filter { $0.liked }
        let dislikedRecords = records.filter { !$0.liked }
        let skipWeight = 2.0

        updateCategoryPreferences(
            liked: likedRecords, disliked: dislikedRecords,
            skipWeight: skipWeight)
        updateLocationPreferences(
            liked: likedRecords, disliked: dislikedRecords,
            skipWeight: skipWeight)
        updateDurationPreferences(
            liked: likedRecords, disliked: dislikedRecords,
            skipWeight: skipWeight)
        updateCostPreferences(
            liked: likedRecords, disliked: dislikedRecords,
            skipWeight: skipWeight)
        updateSelectivityPreferences(
            liked: likedRecords, disliked: dislikedRecords,
            skipWeight: skipWeight)
        updateRestrictionsPreferences(
            liked: likedRecords, disliked: dislikedRecords,
            skipWeight: skipWeight)
    }

    private mutating func updateCategoryPreferences(
        liked: [SwipeRecord], disliked: [SwipeRecord], skipWeight: Double
    ) {
        var categoryScores: [String: (likes: Int, dislikes: Int)] = [:]

        for record in liked {
            let categories = record.program.category.components(
                separatedBy: ",")
            for category in categories {
                let trimmed = category.trimmingCharacters(in: .whitespaces)
                categoryScores[trimmed, default: (0, 0)].likes += 1
                categoryConfidence[trimmed, default: 0] += 1
            }
        }

        for record in disliked {
            let categories = record.program.category.components(
                separatedBy: ",")
            for category in categories {
                let trimmed = category.trimmingCharacters(in: .whitespaces)
                categoryScores[trimmed, default: (0, 0)].dislikes += Int(
                    skipWeight)
                categoryConfidence[trimmed, default: 0] += 1
            }
        }

        for (category, counts) in categoryScores {
            let total = counts.likes + counts.dislikes
            if total > 0 {
                let rawScore = Double(counts.likes) / Double(total)
                let confidence =
                    min(Double(categoryConfidence[category] ?? 1), 5.0) / 5.0
                preferredCategories[category] = applyConfidenceScaling(
                    rawScore: Double(rawScore), confidence: confidence)
            }
        }
    }

    private mutating func updateLocationPreferences(
        liked: [SwipeRecord], disliked: [SwipeRecord], skipWeight: Double
    ) {
        var locationScores: [String: (likes: Int, dislikes: Int)] = [:]

        for record in liked {
            let location = record.program.location.trimmingCharacters(
                in: .whitespaces)
            locationScores[location, default: (0, 0)].likes += 1
            locationConfidence[location, default: 0] += 1
        }

        for record in disliked {
            let location = record.program.location.trimmingCharacters(
                in: .whitespaces)
            locationScores[location, default: (0, 0)].dislikes += Int(
                skipWeight)
            locationConfidence[location, default: 0] += 1
        }

        for (location, counts) in locationScores {
            let total = counts.likes + counts.dislikes
            if total > 0 {
                let rawScore = Double(counts.likes) / Double(total)
                let confidence =
                    min(Double(locationConfidence[location] ?? 1), 5, 0) / 5.0
                preferredLocations[location] = applyConfidenceScaling(
                    rawScore: Double(rawScore), confidence: confidence)
            }
        }
    }

    private mutating func updateDurationPreferences(
        liked: [SwipeRecord], disliked: [SwipeRecord], skipWeight: Double
    ) {
        var durationScores: [String: (likes: Int, dislikes: Int)] = [:]

        for record in liked {
            let duration = record.program.duration.trimmingCharacters(
                in: .whitespaces)
            durationScores[duration, default: (0, 0)].likes += 1
            durationConfidence[duration, default: 0] += 1
        }

        for record in disliked {
            let duration = record.program.duration.trimmingCharacters(
                in: .whitespaces)
            durationScores[duration, default: (0, 0)].dislikes += Int(
                skipWeight)
            durationConfidence[duration, default: 0] += 1
        }

        for (duration, counts) in durationScores {
            let total = counts.likes + counts.dislikes
            if total > 0 {
                let rawScore = Double(counts.likes) / Double(total)
                let confidence =
                    min(Double(durationConfidence[duration] ?? 1), 5.0) / 5.0
                preferredDuration[duration] = applyConfidenceScaling(
                    rawScore: Double(rawScore), confidence: confidence)
            }
        }
    }

    private mutating func updateCostPreferences(
        liked: [SwipeRecord], disliked: [SwipeRecord], skipWeight: Double
    ) {
        var costScores: [String: (likes: Int, dislikes: Int)] = [:]

        for record in liked {
            let cost = normalizeCost(record.program.cost)
            costScores[cost, default: (0, 0)].likes += 1
            costConfidence[cost, default: 0] += 1
        }

        for record in disliked {
            let cost = normalizeCost(record.program.cost)
            costScores[cost, default: (0, 0)].dislikes += Int(skipWeight)
            costConfidence[cost, default: 0] += 1
        }

        for (cost, counts) in costScores {
            let total = counts.likes + counts.dislikes
            if total > 0 {
                let rawScore = Double(counts.likes) / Double(total)
                let confidence =
                    min(Double(costConfidence[cost] ?? 1), 5.0) / 5.0
                preferredCost[cost] = applyConfidenceScaling(
                    rawScore: Double(rawScore), confidence: confidence)
            }
        }
    }
    private mutating func updateSelectivityPreferences(
        liked: [SwipeRecord], disliked: [SwipeRecord], skipWeight: Double
    ) {
        var selectivityScores: [String: (likes: Int, dislikes: Int)] = [:]

        for record in liked {
            let selectivity = normalizeSelectivity(record.program.selectivity)
            selectivityScores[selectivity, default: (0, 0)].likes += 1
            selectivityConfidence[selectivity, default: 0] += 1
        }

        for record in disliked {
            let selectivity = normalizeSelectivity(record.program.selectivity)
            selectivityScores[selectivity, default: (0, 0)].dislikes += Int(
                skipWeight)
            selectivityConfidence[selectivity, default: 0] += 1
        }

        for (selectivity, counts) in selectivityScores {
            let total = counts.likes + counts.dislikes
            if total > 0 {
                let rawScore = Double(counts.likes) / Double(total)
                let confidence =
                    min(Double(selectivityConfidence[selectivity] ?? 1), 5.0)
                    / 5.0
                preferredSelectivity[selectivity] = applyConfidenceScaling(
                    rawScore: Double(rawScore), confidence: confidence)
            }
        }
    }
    private mutating func updateRestrictionsPreferences(
        liked: [SwipeRecord], disliked: [SwipeRecord], skipWeight: Double
    ) {
        var restrictionScores: [String: (likes: Double, dislikes: Double)] = [:]

        for record in liked {
            let restrictions = normalizeRestrictions(
                record.program.restrictions)
            for restriction in restrictions {
                restrictionScores[restriction, default: (0, 0)].likes += 1
                restrictionsConfidence[restriction, default: 0] += 1
            }
        }

        for record in disliked {
            let restrictions = normalizeRestrictions(
                record.program.restrictions)
            for restriction in restrictions {
                restrictionScores[restriction, default: (0, 0)].dislikes +=
                    skipWeight
            }
        }

        for (restriction, counts) in restrictionScores {
            let total = counts.likes + counts.dislikes
            if total > 0 {
                let rawScore = Double(counts.likes) / Double(total)
                let confidence =
                    min(Double(restrictionsConfidence[restriction] ?? 1), 5.0)
                    / 5.0
                preferredRestrictions[restriction] = applyConfidenceScaling(
                    rawScore: rawScore, confidence: confidence)
            }
        }
    }

    private func applyConfidenceScaling(rawScore: Double, confidence: Double)
        -> Double
    {
        let neutral = 0.5
        let deviation = rawScore - neutral
        let scaledDeviation = deviation * pow(confidence, 0.5) * 1.5
        return max(0.0, min(1.0, neutral + scaledDeviation))
    }

    func normalizeCost(_ cost: String) -> String {
        let costLower = cost.lowercased()
        if costLower.contains("free") {
            return "free"
        } else if costLower.contains("$") {
            let nums = cost.components(
                separatedBy: CharacterSet.decimalDigits.inverted
            ).joined()
            if let amount = Double(nums) {
                if amount < 1000 {
                    return "low"
                } else if amount < 5000 {
                    return "medium"
                } else {
                    return "high"
                }
            }
        }
        return "unknown"
    }

    func normalizeSelectivity(_ selectivity: String) -> String {
        if selectivity.contains("%") {
            let numbers = selectivity.components(
                separatedBy: CharacterSet.decimalDigits.inverted
            ).joined()
            if let percentage = Double(numbers) {
                if percentage < 10 {
                    return "Very_selective"
                } else if percentage < 25 {
                    return "selective"
                } else if percentage < 50 {
                    return "moderate"
                } else {
                    return "open"
                }
            }
        }
        return "unknown"
    }

    func normalizeRestrictions(_ restrictions: String) -> [String] {
        let restrictionText = restrictions.lowercased()
        var normalizedRestrictions: [String] = []

        // Check for common restriction patterns
        if restrictionText.contains("senior") {
            normalizedRestrictions.append("seniors_only")
        }
        if restrictionText.contains("junior") {
            normalizedRestrictions.append("includes_juniors")
        }
        if restrictionText.contains("rising") {
            normalizedRestrictions.append("rising_grades")
        }
        if restrictionText.contains("16") || restrictionText.contains("17")
            || restrictionText.contains("18")
        {
            normalizedRestrictions.append("age_restricted")
        }
        if restrictionText.contains("female")
            || restrictionText.contains("girls")
        {
            normalizedRestrictions.append("gender_specific")
        }
        if restrictionText.contains("underserved")
            || restrictionText.contains("minorities")
        {
            normalizedRestrictions.append("diversity_focused")
        }

        return normalizedRestrictions.isEmpty
            ? ["general"] : normalizedRestrictions
    }
}

class SmartRecommendationSystem: ObservableObject {
    var userProfile = UserProfile()

    private var diversityWeight: Double = 0.1

    func resetProfile() {
        userProfile.reset()
    }

    func updateRecommendations(with records: [SwipeRecord]) {
        userProfile.updateProfile(from: records)
        print("updated profile with \(records.count) records")
        print("like rate \(userProfile.likeRate)")

        print("\nAll category scores:")
        for (category, score) in userProfile.preferredCategories.sorted(by: {
            $0.value < $1.value
        }) {
            print("  \(category): \(String(format: "%.3f", score))")
        }

        print("\nTop locations:")
        let topLocations = userProfile.preferredLocations.sorted {
            $0.value > $1.value
        }.prefix(3)
        for (location, score) in topLocations {
            print("  \(location): \(String(format: "%.3f", score))")
        }
    }

    func getRecommendationScore(for program: Program) -> Double {
        
        guard userProfile.totalSwipes > 0 else { return 0.5 }

        var score = 0.0
        var totalWeight = 0.0

        let categoryWeight = 0.60
        let categoryScore = calculateCategoryScore(program.category)
        score += categoryScore * categoryWeight
        totalWeight += categoryScore

        let locationWeight = 0.15
        let locationScore =
            userProfile.preferredLocations[program.location] ?? 0.5
        score += locationScore * locationWeight
        totalWeight += locationWeight

        let durationWeight = 0.10
        let durationScore =
            userProfile.preferredDuration[program.duration] ?? 0.5
        score += durationScore * durationWeight
        totalWeight += durationWeight

        let costWeight = 0.15
        let costScore =
            userProfile.preferredCost[userProfile.normalizeCost(program.cost)]
            ?? 0.5
        score += costScore * costWeight
        totalWeight += costWeight

        let selectivityWeight = 0.10
        let selectivityScore =
            userProfile.preferredSelectivity[
                userProfile.normalizeSelectivity(program.selectivity)] ?? 0.5
        score += selectivityScore * selectivityWeight
        totalWeight += selectivityWeight

        let restrictionsWeight = 0.05
        let restrictionsScore = calculateRestrictionsScore(program.restrictions)
        score += restrictionsScore * restrictionsWeight
        totalWeight += restrictionsWeight

        return score / totalWeight
    }

    private func calculateCategoryScore(_ category: String) -> Double {
        let categories = category.components(separatedBy: ",")
        var totalScore = 0.0
        var matchedCategories = 0

        for category in categories {
            let trimmed = category.trimmingCharacters(in: .whitespaces)
            if let preference = userProfile.preferredCategories[trimmed] {
                totalScore += preference
                matchedCategories += 1
            }
        }
        return matchedCategories > 0
            ? totalScore / Double(matchedCategories) : 0.5
    }

    private func calculateRestrictionsScore(_ restrictions: String) -> Double {
        let normalizedRestrictions = userProfile.normalizeRestrictions(
            restrictions)
        var totalScore = 0.0
        var matchedRestrictions = 0

        for restriction in normalizedRestrictions {
            if let preference = userProfile.preferredRestrictions[restriction] {
                totalScore += preference
                matchedRestrictions += 1
            }
        }
        return matchedRestrictions > 0
            ? totalScore / Double(matchedRestrictions) : 0.5
    }

    func getRecommendationsWithDiversity(
        from programs: [Program], count: Int = 5
    ) -> [Program] {
        let scoredPrograms = programs.map { program in
            (program, getRecommendationScore(for: program))
        }

        let sorted = scoredPrograms.sorted { $0.1 > $1.1 }
        var selected: [Program] = []
        var selectedCategories: Set<String> = []

        let adaptiveDiversityWeight =
            userProfile.totalSwipes < 10 ? 0.5 : diversityWeight

        for (program, score) in sorted {
            if selected.count >= count { break }

            let categories = Set(
                program.category.components(separatedBy: ",")
                    .map { $0.trimmingCharacters(in: .whitespaces) })

            let hasNewCategory = selectedCategories.intersection(categories)
                .isEmpty
            let shouldInclude =
                hasNewCategory || score > (0.75 - adaptiveDiversityWeight * 0.1)

            if shouldInclude {
                selected.append(program)
                selectedCategories.formUnion(categories)
            }
        }

        if selected.count < count {
            for (program, _) in sorted {
                if selected.count >= count { break }
                if !selected.contains(where: { $0.name == program.name }) {
                    selected.append(program)
                }
            }
        }

        return selected
    }

    func getTopRecommendations(from programs: [Program], count: Int = 5)
        -> [Program]
    {
        return getRecommendationsWithDiversity(from: programs, count: count)
    }
}
