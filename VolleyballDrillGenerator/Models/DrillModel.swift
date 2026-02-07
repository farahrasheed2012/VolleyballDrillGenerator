import SwiftUI

// MARK: - Skill Category

/// The seven volleyball skill categories (including Warmup)
enum SkillCategory: String, CaseIterable, Codable, Identifiable {
    case warmup = "Warmup"
    case serving = "Serving"
    case passing = "Passing/Bumping"
    case setting = "Setting"
    case hitting = "Hitting/Spiking"
    case defense = "Defense/Digging"
    case blocking = "Blocking"

    var id: String { rawValue }

    /// SF Symbol icon for each skill
    var icon: String {
        switch self {
        case .warmup:   return "flame.fill"
        case .serving:  return "figure.volleyball"
        case .passing:  return "arrow.left.arrow.right"
        case .setting:  return "hands.sparkles"
        case .hitting:  return "bolt.fill"
        case .defense:  return "shield.fill"
        case .blocking: return "hand.raised.fill"
        }
    }

    /// Theme colour for each skill
    var color: Color {
        switch self {
        case .warmup:   return .pink
        case .serving:  return .blue
        case .passing:  return .green
        case .setting:  return .purple
        case .hitting:  return .red
        case .defense:  return .orange
        case .blocking: return .indigo
        }
    }
}

// MARK: - Player Level

/// Three experience tiers for middle school players
enum PlayerLevel: String, CaseIterable, Codable, Identifiable {
    case newToVolleyball = "New to Volleyball"
    case beginner = "Beginner/Developing"
    case intermediate = "Intermediate"

    var id: String { rawValue }

    /// SF Symbol icon for each level
    var icon: String {
        switch self {
        case .newToVolleyball: return "star"
        case .beginner:       return "star.leadinghalf.filled"
        case .intermediate:   return "star.fill"
        }
    }

    /// Theme colour for each level
    var color: Color {
        switch self {
        case .newToVolleyball: return .green
        case .beginner:       return .blue
        case .intermediate:   return .purple
        }
    }

    /// Short label for badges
    var shortLabel: String {
        switch self {
        case .newToVolleyball: return "New"
        case .beginner:       return "Beginner"
        case .intermediate:   return "Intermediate"
        }
    }
}

// MARK: - Drill

/// A single volleyball drill loaded from the JSON database
struct Drill: Codable, Identifiable, Equatable {
    var id: String { name }

    let name: String
    let skill: String
    let level: String
    let description: String
    let equipment: [String]
    let source: String
    let image: String

    /// Convenience to get the typed SkillCategory
    var skillCategory: SkillCategory? {
        SkillCategory(rawValue: skill)
    }

    /// Convenience to get the typed PlayerLevel
    var playerLevel: PlayerLevel? {
        PlayerLevel(rawValue: level)
    }

    static func == (lhs: Drill, rhs: Drill) -> Bool {
        lhs.name == rhs.name
    }
}
