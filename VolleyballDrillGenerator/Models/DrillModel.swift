import Foundation

// MARK: - Skill Category

/// The six core volleyball skill categories
enum SkillCategory: String, CaseIterable, Codable, Identifiable {
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
        case .serving:  return "figure.volleyball"
        case .passing:  return "arrow.left.arrow.right"
        case .setting:  return "hands.sparkles"
        case .hitting:  return "bolt.fill"
        case .defense:  return "shield.fill"
        case .blocking: return "hand.raised.fill"
        }
    }

    /// Theme colour for each skill
    var colorName: String {
        switch self {
        case .serving:  return "blue"
        case .passing:  return "green"
        case .setting:  return "purple"
        case .hitting:  return "red"
        case .defense:  return "orange"
        case .blocking: return "indigo"
        }
    }
}

// MARK: - Drill

/// A single volleyball drill loaded from the JSON database
struct Drill: Codable, Identifiable, Equatable {
    var id: String { name }

    let name: String
    let skill: String
    let description: String
    let equipment: [String]
    let source: String
    let image: String

    /// Convenience to get the typed SkillCategory
    var skillCategory: SkillCategory? {
        SkillCategory(rawValue: skill)
    }

    static func == (lhs: Drill, rhs: Drill) -> Bool {
        lhs.name == rhs.name
    }
}
