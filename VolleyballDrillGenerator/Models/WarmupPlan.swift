import SwiftUI

// MARK: - Warmup Plan Segment

/// One segment of a 10-minute warmup (e.g. stretching, hands & arms, legs).
struct WarmupPlanSegment: Identifiable {
    let id = UUID()
    let title: String
    let durationMinutes: Int
    let startMinute: Int
    let instructions: [String]
    let icon: String

    var endMinute: Int { startMinute + durationMinutes }
    var timeRange: String { "\(startMinute):00–\(endMinute):00" }
}

// MARK: - Warmup Plan

/// A full 10-minute warmup plan for a given player level.
struct WarmupPlan {
    let level: PlayerLevel
    let segments: [WarmupPlanSegment]

    static func plan(for level: PlayerLevel) -> WarmupPlan {
        switch level {
        case .newToVolleyball:
            return newToVolleyballPlan
        case .beginner:
            return beginnerPlan
        case .intermediate:
            return intermediatePlan
        }
    }

    // MARK: New to Volleyball – 10 min

    private static let newToVolleyballPlan = WarmupPlan(level: .newToVolleyball, segments: [
        WarmupPlanSegment(
            title: "Stretching",
            durationMinutes: 2,
            startMinute: 0,
            instructions: [
                "Reach arms overhead and lean side to side (10 each side).",
                "Gently roll shoulders forward and backward (10 each).",
                "Stand on one leg; hold opposite foot behind for quad stretch (15 sec each leg).",
                "Toe touches or hamstring stretch — no bouncing (hold 10 sec, 2 times)."
            ],
            icon: "figure.flexibility"
        ),
        WarmupPlanSegment(
            title: "Hands & Arms",
            durationMinutes: 2,
            startMinute: 2,
            instructions: [
                "Arm circles: small forward 15 sec, small backward 15 sec.",
                "Large arm circles forward 10, backward 10.",
                "Wrist circles: 10 each direction, both hands.",
                "Light arm swings (like serving motion) without a ball — 10 each arm."
            ],
            icon: "figure.arms.open"
        ),
        WarmupPlanSegment(
            title: "Legs",
            durationMinutes: 2,
            startMinute: 4,
            instructions: [
                "March in place, knees up to hip height — 30 seconds.",
                "Leg swings forward/back: 10 per leg (hold wall if needed).",
                "Leg swings side to side: 10 per leg.",
                "Body-weight squats: 8–10 slow reps (knees over toes, chest up)."
            ],
            icon: "figure.run"
        ),
        WarmupPlanSegment(
            title: "Light Cardio & Movement",
            durationMinutes: 2,
            startMinute: 6,
            instructions: [
                "Light jog in place or around the court — 45 seconds.",
                "Side shuffles: 15 feet right, 15 feet left; 2 round trips.",
                "Stay on balls of feet; don’t cross feet.",
                "Walk one lap to bring heart rate down slightly."
            ],
            icon: "figure.walk"
        ),
        WarmupPlanSegment(
            title: "Ball & Coordination",
            durationMinutes: 2,
            startMinute: 8,
            instructions: [
                "Partner ball toss: catch and toss back 10 times (get used to the ball).",
                "Or: self-toss and catch, then gentle bump to self 5 times.",
                "Focus on watching the ball and moving feet to it.",
                "Finish with a few easy sets or passes if comfortable."
            ],
            icon: "sportscourt.fill"
        )
    ])

    // MARK: Beginner/Developing – 10 min

    private static let beginnerPlan = WarmupPlan(level: .beginner, segments: [
        WarmupPlanSegment(
            title: "Stretching",
            durationMinutes: 2,
            startMinute: 0,
            instructions: [
                "Dynamic torso twists: 15 each direction (arms loose).",
                "Leg swings forward/back and side to side — 10 per leg.",
                "Arm circles: small then large, 10 each direction.",
                "Hip circles: 8 each direction to open hips."
            ],
            icon: "figure.flexibility"
        ),
        WarmupPlanSegment(
            title: "Hands & Arms",
            durationMinutes: 2,
            startMinute: 2,
            instructions: [
                "Shoulder rolls and arm circles (30 sec total).",
                "Serving arm swing (no ball): 10 each arm, full motion.",
                "Setting motion: hands up, wrists snap — 15 reps.",
                "Optional: light resistance band pull-aparts — 15 reps."
            ],
            icon: "figure.arms.open"
        ),
        WarmupPlanSegment(
            title: "Legs",
            durationMinutes: 2,
            startMinute: 4,
            instructions: [
                "High knees: 30 seconds, then butt kicks 30 seconds.",
                "Walking lunges with twist at bottom — 10 per leg.",
                "Body-weight squats: 10 reps, controlled.",
                "Single-leg balance: 5 seconds each leg, 2 times."
            ],
            icon: "figure.run"
        ),
        WarmupPlanSegment(
            title: "Movement",
            durationMinutes: 2,
            startMinute: 6,
            instructions: [
                "Carioca (grapevine) 15 feet right, 15 feet left — 2 round trips.",
                "Side shuffles: stay low, 2 round trips.",
                "Approach steps (left-right-left) without jump — 5 each side.",
                "Quick feet in place — 20 seconds."
            ],
            icon: "figure.walk"
        ),
        WarmupPlanSegment(
            title: "Ball",
            durationMinutes: 2,
            startMinute: 8,
            instructions: [
                "Light pepper with partner: bump-set-hit at half speed — 2 min.",
                "Or: pass and set to a target; 10 good passes each.",
                "Easy serve receive: partner serves underhand; pass to target.",
                "Focus on first step and platform."
            ],
            icon: "sportscourt.fill"
        )
    ])

    // MARK: Intermediate – 10 min

    private static let intermediatePlan = WarmupPlan(level: .intermediate, segments: [
        WarmupPlanSegment(
            title: "Stretching",
            durationMinutes: 2,
            startMinute: 0,
            instructions: [
                "Dynamic hip openers: leg swings and hip circles — 45 sec.",
                "Hamstring sweep: step and reach, 8 per leg.",
                "Shoulder mobility: arm circles and cross-body stretch — 45 sec.",
                "Optional: light static hold for quads/hamstrings — 15 sec each."
            ],
            icon: "figure.flexibility"
        ),
        WarmupPlanSegment(
            title: "Hands & Arms",
            durationMinutes: 2,
            startMinute: 2,
            instructions: [
                "Resistance band: pull-aparts 15, external rotation 15 per arm.",
                "Serving and hitting arm swing (no ball): 10 each, full speed.",
                "Setting motion with quick hands — 20 reps.",
                "Band or no band: shoulder prep for spikes and serves."
            ],
            icon: "figure.arms.open"
        ),
        WarmupPlanSegment(
            title: "Legs",
            durationMinutes: 2,
            startMinute: 4,
            instructions: [
                "A-Skip across court and back (30 sec), then B-Skip (30 sec).",
                "Lateral band walks: 15 steps each direction (if band available).",
                "Body-weight squats: 12 reps, then 5 jump squats.",
                "Single-leg hop in place: 5 each leg for balance and power."
            ],
            icon: "figure.run"
        ),
        WarmupPlanSegment(
            title: "Movement",
            durationMinutes: 2,
            startMinute: 6,
            instructions: [
                "Side shuffles with low stance — 3 round trips.",
                "Approach and jump (no ball): 5 left pin, 5 right pin.",
                "Block jumps at net: 8–10, focus on hand position.",
                "Quick transition: shuffle to net, block, drop off, repeat — 4 times."
            ],
            icon: "figure.walk"
        ),
        WarmupPlanSegment(
            title: "Ball",
            durationMinutes: 2,
            startMinute: 8,
            instructions: [
                "Serve receive: 5 easy serves, then 5 at three-quarter speed.",
                "Light pepper: bump-set-hit at three-quarter speed — 1 min.",
                "Setter sets to hitter; hitter approach and tip or swing — 4–5 reps.",
                "Focus on first-ball control and transition."
            ],
            icon: "sportscourt.fill"
        )
    ])
}
