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

/// A full 10-minute warmup plan for a given player level. Generated randomly each time.
struct WarmupPlan {
    let level: PlayerLevel
    let segments: [WarmupPlanSegment]

    /// Builds a new 10-minute plan for the level, randomly choosing one variant per segment each time.
    static func plan(for level: PlayerLevel) -> WarmupPlan {
        let segmentTitles: [(title: String, icon: String)] = [
            ("Stretching", "figure.flexibility"),
            ("Hands & Arms", "figure.arms.open"),
            ("Legs", "figure.run"),
            ("Movement", "figure.walk"),
            ("Ball & Coordination", "sportscourt.fill")
        ]
        let allVariants = variants(for: level)
        var start = 0
        let segments: [WarmupPlanSegment] = (0..<5).map { index in
            let variantsForSegment = allVariants[index]
            let chosen = variantsForSegment.randomElement() ?? variantsForSegment[0]
            let seg = WarmupPlanSegment(
                title: index == 4 && level != .newToVolleyball ? "Ball" : segmentTitles[index].title,
                durationMinutes: 2,
                startMinute: start,
                instructions: chosen,
                icon: segmentTitles[index].icon
            )
            start += 2
            return seg
        }
        return WarmupPlan(level: level, segments: segments)
    }

    /// Five arrays (one per segment): Stretching, Hands & Arms, Legs, Movement, Ball. Each array has 2+ instruction variants.
    private static func variants(for level: PlayerLevel) -> [[[String]]] {
        switch level {
        case .newToVolleyball:
            return newToVolleyballVariants
        case .beginner:
            return beginnerVariants
        case .intermediate:
            return intermediateVariants
        }
    }

    // MARK: New to Volleyball – variants per segment

    private static let newToVolleyballVariants: [[[String]]] = [
        [ // Stretching
            [
                "Reach arms overhead and lean side to side (10 each side).",
                "Gently roll shoulders forward and backward (10 each).",
                "Stand on one leg; hold opposite foot behind for quad stretch (15 sec each leg).",
                "Toe touches or hamstring stretch — no bouncing (hold 10 sec, 2 times)."
            ],
            [
                "Arm circles: small then large, 10 each direction.",
                "Torso twist: feet planted, rotate left and right (12 each).",
                "Quad stretch holding wall: 15 sec each leg.",
                "Hamstring stretch: sit and reach, hold 10 sec twice."
            ],
            [
                "Overhead reach and side lean (8 each side).",
                "Shoulder rolls forward 10, backward 10.",
                "Leg swings forward/back (hold wall): 8 per leg.",
                "Hip circles: 8 each direction."
            ]
        ],
        [ // Hands & Arms
            [
                "Arm circles: small forward 15 sec, small backward 15 sec.",
                "Large arm circles forward 10, backward 10.",
                "Wrist circles: 10 each direction, both hands.",
                "Light arm swings (like serving motion) without a ball — 10 each arm."
            ],
            [
                "Shoulder rolls: 10 forward, 10 backward.",
                "Wrist flex: stretch fingers back gently, 10 sec each hand.",
                "Arm swings across body: 10 each arm.",
                "Elbow circles: 8 each direction."
            ],
            [
                "Pendulum arms: swing loosely 15 sec.",
                "Overhead arm reach: alternate arms 10 each.",
                "Wrist circles and finger wiggles — 20 sec.",
                "Serving motion slow: 8 each arm."
            ]
        ],
        [ // Legs
            [
                "March in place, knees up to hip height — 30 seconds.",
                "Leg swings forward/back: 10 per leg (hold wall if needed).",
                "Leg swings side to side: 10 per leg.",
                "Body-weight squats: 8–10 slow reps (knees over toes, chest up)."
            ],
            [
                "High knees in place — 25 seconds.",
                "Butt kicks — 25 seconds.",
                "Body-weight squats: 10 reps.",
                "Single-leg balance: 8 sec each leg, 2 times."
            ],
            [
                "March then jog in place — 45 sec total.",
                "Leg swings: forward/back 8 per leg, then side 8 per leg.",
                "Squats: 8 slow, hold bottom 2 sec each.",
                "Calf raises: 12 reps."
            ]
        ],
        [ // Movement
            [
                "Light jog in place or around the court — 45 seconds.",
                "Side shuffles: 15 feet right, 15 feet left; 2 round trips.",
                "Stay on balls of feet; don't cross feet.",
                "Walk one lap to bring heart rate down slightly."
            ],
            [
                "Jog one lap, then walk half lap.",
                "Side shuffles: 2 round trips, touch the line each time.",
                "Skip forward 20 feet and back.",
                "Quick steps in place — 20 seconds."
            ],
            [
                "Light jog — 40 seconds.",
                "Shuffle right 15 ft, shuffle left 15 ft — 3 round trips.",
                "High knees 15 sec, then butt kicks 15 sec.",
                "Walk and breathe — 30 seconds."
            ]
        ],
        [ // Ball & Coordination
            [
                "Partner ball toss: catch and toss back 10 times (get used to the ball).",
                "Or: self-toss and catch, then gentle bump to self 5 times.",
                "Focus on watching the ball and moving feet to it.",
                "Finish with a few easy sets or passes if comfortable."
            ],
            [
                "Toss and catch with partner — 15 catches each.",
                "Self-bump to self: 5 in a row, then try 5 more.",
                "Set to self 5 times, then pass to partner once.",
                "Keep the ball in control; don't worry about height."
            ],
            [
                "Circle passing: one ball, pass to the next person, 2 min.",
                "Or with partner: toss, bump back, catch — 10 good contacts.",
                "Easy set to self or to partner — 10 reps.",
                "Focus on platform and watching the ball."
            ]
        ]
    ]

    // MARK: Beginner/Developing – variants per segment

    private static let beginnerVariants: [[[String]]] = [
        [ // Stretching
            [
                "Dynamic torso twists: 15 each direction (arms loose).",
                "Leg swings forward/back and side to side — 10 per leg.",
                "Arm circles: small then large, 10 each direction.",
                "Hip circles: 8 each direction to open hips."
            ],
            [
                "Side lean and reach: 10 each side.",
                "Leg swings: 10 forward/back, 10 side-to-side per leg.",
                "Shoulder circles and arm circles — 30 sec.",
                "Walking quad stretch: 4 per leg."
            ],
            [
                "World's greatest stretch (lunge + twist): 5 per side.",
                "Arm circles and torso twist — 20 sec.",
                "Hamstring sweep: 8 per leg.",
                "Hip opener: 8 circles each direction."
            ]
        ],
        [ // Hands & Arms
            [
                "Shoulder rolls and arm circles (30 sec total).",
                "Serving arm swing (no ball): 10 each arm, full motion.",
                "Setting motion: hands up, wrists snap — 15 reps.",
                "Optional: light resistance band pull-aparts — 15 reps."
            ],
            [
                "Arm circles then serving motion — 10 each arm.",
                "Setting hand shape: form triangle, snap 20 times.",
                "Wrist circles and shoulder rolls — 45 sec.",
                "Hitting arm swing (no ball): 8 each arm."
            ],
            [
                "Band pull-aparts: 15 reps (or arm circles if no band).",
                "Serving and setting motion: 10 each.",
                "Shoulder mobility: arm across body stretch, 15 sec each.",
                "Quick hands: set to self 15 times."
            ]
        ],
        [ // Legs
            [
                "High knees: 30 seconds, then butt kicks 30 seconds.",
                "Walking lunges with twist at bottom — 10 per leg.",
                "Body-weight squats: 10 reps, controlled.",
                "Single-leg balance: 5 seconds each leg, 2 times."
            ],
            [
                "High knees 25 sec, butt kicks 25 sec.",
                "Lunges: 8 per leg, then 10 squats.",
                "Lateral lunges: 6 each side.",
                "Single-leg stand and reach: 5 sec each leg."
            ],
            [
                "A-skips: 20 feet and back (building to running).",
                "Walking lunges: 10 per leg.",
                "Squats: 12 reps, pause at bottom 1 sec.",
                "Leg swings: 10 per leg each direction."
            ]
        ],
        [ // Movement
            [
                "Carioca (grapevine) 15 feet right, 15 feet left — 2 round trips.",
                "Side shuffles: stay low, 2 round trips.",
                "Approach steps (left-right-left) without jump — 5 each side.",
                "Quick feet in place — 20 seconds."
            ],
            [
                "Side shuffles: 3 round trips, touch line each time.",
                "Carioca: 2 round trips each direction.",
                "Approach (left-right-left) from 10-ft line — 5 left, 5 right.",
                "Shuffle to net and back — 4 times."
            ],
            [
                "Grapevine right 15 ft, left 15 ft — 2 times.",
                "Low shuffle: 2 round trips.",
                "Approach and hop (no ball): 5 each side.",
                "Quick feet then sprint 10 ft — 4 reps."
            ]
        ],
        [ // Ball
            [
                "Light pepper with partner: bump-set-hit at half speed — 2 min.",
                "Or: pass and set to a target; 10 good passes each.",
                "Easy serve receive: partner serves underhand; pass to target.",
                "Focus on first step and platform."
            ],
            [
                "Pass and set to target: 10 each, then switch.",
                "Underhand serve receive: 8 serves per passer.",
                "Light pepper: 90 seconds, control over speed.",
                "Bump-set-catch with partner — 15 contacts."
            ],
            [
                "Serve receive: partner serves easy, pass to setter — 10 each.",
                "Pepper at half speed — 2 min.",
                "Pass from toss: 10 good passes to target.",
                "Set from partner toss: 10 to pin or target."
            ]
        ]
    ]

    // MARK: Intermediate – variants per segment

    private static let intermediateVariants: [[[String]]] = [
        [ // Stretching
            [
                "Dynamic hip openers: leg swings and hip circles — 45 sec.",
                "Hamstring sweep: step and reach, 8 per leg.",
                "Shoulder mobility: arm circles and cross-body stretch — 45 sec.",
                "Optional: light static hold for quads/hamstrings — 15 sec each."
            ],
            [
                "Leg swings and hip circles — 1 min.",
                "World's greatest stretch: 6 per side.",
                "Shoulder band or arm circles — 45 sec.",
                "Pigeon or hip opener: 15 sec each side if time."
            ],
            [
                "Dynamic stretch: leg swings, torso twist, arm circles — 90 sec.",
                "Hamstring and quad: 15 sec each.",
                "Shoulder cross-body and sleeper stretch — 30 sec total.",
                "Hip circles and lateral lunges — 30 sec."
            ]
        ],
        [ // Hands & Arms
            [
                "Resistance band: pull-aparts 15, external rotation 15 per arm.",
                "Serving and hitting arm swing (no ball): 10 each, full speed.",
                "Setting motion with quick hands — 20 reps.",
                "Band or no band: shoulder prep for spikes and serves."
            ],
            [
                "Band: pull-aparts 15, internal/external rotation 12 per arm.",
                "Full serving and hitting motion: 10 each, game speed.",
                "Quick sets to self: 25 in a row.",
                "Shoulder prep: 90 sec total."
            ],
            [
                "Band work: 15 pull-aparts, 15 overhead pull.",
                "Arm swing: serve 10, hit 10, focus on snap.",
                "Setting: 20 quick reps, then 10 back sets.",
                "Wrist and shoulder mobility — 45 sec."
            ]
        ],
        [ // Legs
            [
                "A-Skip across court and back (30 sec), then B-Skip (30 sec).",
                "Lateral band walks: 15 steps each direction (if band available).",
                "Body-weight squats: 12 reps, then 5 jump squats.",
                "Single-leg hop in place: 5 each leg for balance and power."
            ],
            [
                "A-Skip and B-Skip: 45 sec each.",
                "Squats: 12 reps, then 6 jump squats.",
                "Lateral band walks or lateral lunges: 12 each side.",
                "Single-leg balance and hop: 5 each leg."
            ],
            [
                "Skips: A-skip 30 sec, B-skip 30 sec.",
                "Squat to jump: 8 reps.",
                "Band walks or carioca: 15 each direction.",
                "Single-leg stability: 8 sec each leg, 2 times."
            ]
        ],
        [ // Movement
            [
                "Side shuffles with low stance — 3 round trips.",
                "Approach and jump (no ball): 5 left pin, 5 right pin.",
                "Block jumps at net: 8–10, focus on hand position.",
                "Quick transition: shuffle to net, block, drop off, repeat — 4 times."
            ],
            [
                "Shuffles: 4 round trips, stay low.",
                "Approach-jump: 5 left, 5 right, 3 middle.",
                "Block jump and land: 10 at net.",
                "Transition: block then approach — 5 reps."
            ],
            [
                "Lateral movement: 4 shuffle round trips.",
                "Full approach and jump (no ball): 6 each side.",
                "Block jumps: 10, hands over net.",
                "Block, drop, approach: 4 full cycles."
            ]
        ],
        [ // Ball
            [
                "Serve receive: 5 easy serves, then 5 at three-quarter speed.",
                "Light pepper: bump-set-hit at three-quarter speed — 1 min.",
                "Setter sets to hitter; hitter approach and tip or swing — 4–5 reps.",
                "Focus on first-ball control and transition."
            ],
            [
                "Serve receive: 10 serves, mix of zones.",
                "Pepper at three-quarter speed — 90 sec.",
                "Pass-set-hit: 5 good rallies.",
                "Free ball to attack: 5 transitions."
            ],
            [
                "Receive: 8 serves, pass to target.",
                "Pepper: 1 min controlled, 1 min quicker.",
                "Set and hit: setter sets; hitter goes — 6 reps.",
                "First-ball sideout focus: 5 rallies."
            ]
        ]
    ]
}
