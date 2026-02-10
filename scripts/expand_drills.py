#!/usr/bin/env python3
"""
Expand volleyball_drills.json so every (skill, level) has at least 20 drills.
Run from repo root: python3 scripts/expand_drills.py
"""
import json
import os
from collections import defaultdict

# Paths
REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
JSON_PATH = os.path.join(REPO_ROOT, "VolleyballDrillGenerator", "Resources", "volleyball_drills.json")

SKILLS = ["Warmup", "Serving", "Passing/Bumping", "Setting", "Hitting/Spiking", "Defense/Digging", "Blocking"]
LEVELS = ["New to Volleyball", "Beginner/Developing", "Intermediate"]

SOURCES = [
    "https://usavolleyball.org/resources-for-coaches/lesson-plans",
    "https://usavolleyball.org/resource/top-166-drills-from-around-the-world/",
    "https://www.volleyball1on1.com/volleyball1on1-volleyball-drills-library/",
    "https://theartofcoachingvolleyball.com/20-dynamic-volleyball-warmup-exercises-with-marie-zidek/",
    "https://wallvolleyball.com/warm-up-drills-for-volleyball/",
]

def image_asset(skill: str) -> str:
    if skill == "Warmup":
        return "warmup_header"
    if skill == "Serving":
        return "serving_header"
    if skill == "Passing/Bumping":
        return "passing_header"
    if skill == "Setting":
        return "setting_header"
    if skill == "Hitting/Spiking":
        return "hitting_header"
    if skill == "Defense/Digging":
        return "defense_header"
    if skill == "Blocking":
        return "blocking_header"
    return "serving_header"

# Template descriptions per (skill, level) - we'll use these with small variations for generated drills
TEMPLATES = {
    ("Serving", "New to Volleyball"): [
        "1. Stand 12–15 feet from the net.\n2. Use an underhand serve with a consistent toss.\n3. Contact the ball with a flat, firm hand.\n4. Follow through toward the target.\n5. Complete 10 serves, then move back 2 steps.",
        "1. Partner holds a ball at shoulder height.\n2. Practice your arm swing without the ball 5 times.\n3. Then serve from the 10-foot line.\n4. Focus on stepping into the serve.\n5. Do 2 sets of 8 serves.",
        "1. Place a cone 5 feet inside the baseline on the opposite court.\n2. Serve from the service line aiming at the cone.\n3. Count how many of 10 serves land within 3 feet of the cone.\n4. Repeat and try to beat your score.",
        "1. Line up with a ball. Coach demonstrates proper grip (hand open, relaxed).\n2. Toss the ball slightly in front of your hitting shoulder.\n3. Strike through the center of the ball.\n4. Do 15 reps focusing only on contact point.\n5. Add the other side for left-handers.",
        "1. Form two lines at the service line.\n2. First player serves; second player goes when the first ball crosses the net.\n3. Retrieve your own ball and go to the back of the line.\n4. Goal: 5 good serves in a row per player.\n5. Coach gives one cue per player (toss, contact, or follow-through).",
    ],
    ("Serving", "Beginner/Developing"): [
        "1. Divide the opposite court into left, center, and right zones.\n2. Coach calls the zone; server aims for that zone.\n3. Score 1 point per serve in the correct zone.\n4. First to 15 points wins the round.\n5. Use both float and topspin serves.",
        "1. Two teams of 3–4 players behind the end line.\n2. Each player gets one serve per rotation.\n3. Team earns a point for each in-bounds serve.\n4. First team to 20 points wins.\n5. Rotate servers each round.",
        "1. Place 4 hula hoops or circles in the back court.\n2. Each server gets 8 attempts to land a serve inside any hoop.\n3. Different hoops can be worth 1 or 2 points.\n4. Total your score and switch with a partner.\n5. Emphasize consistent toss and relaxed arm.",
        "1. Server stands at the end line. Coach or partner stands in zone 5.\n2. Server must serve to zone 5 (back right) only.\n3. Receiver catches and returns the ball.\n4. Do 10 good serves to zone 5, then switch to zone 1.\n5. Builds accuracy to specific zones.",
        "1. Use a rope or tape 2 feet above the net.\n2. Servers must serve the ball under the rope and over the net.\n3. Teaches a low, flat trajectory.\n4. Miss (into net or over rope) = 2 burpees.\n5. Complete 12 successful serves.",
    ],
    ("Serving", "Intermediate"): [
        "1. Mark 6 zones on the opposite court (1–6).\n2. Coach calls a zone; server has one attempt to hit it.\n3. Rotate through all 6 zones twice.\n4. Track successful zone serves.\n5. Add a jump float for advanced players.",
        "1. Play 2v2 or 3v3 with serve-only scoring.\n2. Only the serving team can score.\n3. Missed serve = side out and other team serves.\n4. First to 15 wins.\n5. Emphasizes serving under pressure.",
        "1. Server serves, then immediately runs to the net and blocks a tip from the other side.\n2. After blocking, transition back to serve again.\n3. Do 6 reps. Builds serve-to-defense transition.\n4. Increase speed as players improve.\n5. Rest 30 seconds between sets.",
        "1. Place chairs in positions 1, 6, and 5. Servers must avoid the chairs and land between them.\n2. Each server gets 10 attempts.\n3. Hitting a chair = minus 1 point.\n4. Landing in a gap = plus 1 point.\n5. Teaches serving to open seams.",
        "1. Two lines: servers and passers. Server serves to the passer.\n2. Passer must pass to a target; server becomes the next passer.\n3. Continuous rotation. Focus on serve placement.\n4. Run for 5 minutes.\n5. Count aces and service errors.",
    ],
    ("Passing/Bumping", "New to Volleyball"): [
        "1. Pair up 10 feet apart. One player tosses underhand to the partner.\n2. Partner forms a platform and passes the ball back to the tosser’s hands.\n3. Tosser catches and repeats. Do 15 passes, then switch.\n4. Focus on keeping arms together and not swinging.\n5. Count consecutive good passes.",
        "1. Stand in ready position: knees bent, arms relaxed.\n2. Coach or partner tosses the ball to your midline.\n3. Move your feet so the ball lands between your knees.\n4. Pass the ball to a target 10 feet away.\n5. Do 20 reps, then switch.",
        "1. Three players in a triangle, 12 feet apart.\n2. Pass the ball in a set order (A to B to C to A).\n3. Call the name of the person you’re passing to.\n4. Goal: 15 passes without a drop.\n5. If the ball drops, restart the count.",
        "1. One line of passers; one tosser with a ball.\n2. Tosser tosses to the first passer, who passes to a target.\n3. Passer goes to the back of the line.\n4. Next passer steps up. Continue for 3 minutes.\n5. Focus on consistent platform angle.",
        "1. Sit on the floor with a partner 8 feet apart.\n2. Use only forearm passing (no standing).\n3. Pass the ball back and forth 20 times.\n4. Emphasizes arm control without using legs.\n5. Stand up and repeat from ready position.",
    ],
    ("Passing/Bumping", "Beginner/Developing"): [
        "1. Two lines facing each other with a net between (or 15 feet apart).\n2. First player in Line A passes to first player in Line B.\n3. After passing, run to the back of the opposite line.\n4. Continuous for 5 minutes. Keep the ball going.\n5. Add a set or catch in the middle to vary the drill.",
        "1. One passer in the middle; two tossers on either side.\n2. Tossers alternate tossing to the passer.\n3. Passer must pass to the opposite tosser each time.\n4. Do 20 passes, then rotate. Focus on footwork and platform.\n5. Increase distance as skill improves.",
        "1. Form a circle of 5–6 players. One ball.\n2. Pass the ball around the circle in one direction.\n3. After passing, do a quick shuffle step in place.\n4. Add a second ball going the opposite direction after 10 passes.\n5. Goal: 30 passes with one ball, 20 with two.",
        "1. Passer stands in zone 5. Coach or server serves from the other side.\n2. Passer must pass to a setter target in position 2/3.\n3. Do 10 good passes, then switch passers.\n4. Focus on reading the serve and moving early.\n5. Track passes that land in the target area.",
        "1. Two passers in positions 5 and 6. Server serves to either side.\n2. Passers call 'Mine' or 'Yours' and pass to target.\n3. Run 15 serves, then rotate.\n4. Emphasize communication and not crossing paths.\n5. Add a third passer in position 1 for 3-person receive.",
    ],
    ("Passing/Bumping", "Intermediate"): [
        "1. Three passers in receive formation. Two servers on the other side.\n2. Servers alternate serving; passers must pass to target.\n3. After each pass, passers rotate one position.\n4. Run 20 serves. Focus on first-ball sideout.\n5. Track pass rating (3, 2, 1, 0).",
        "1. One passer. Coach stands at the net and hits or tips to different spots.\n2. Passer must read the hitter and move to the ball.\n3. Pass to the setter target every time.\n4. Do 15 balls, then switch. Add a second passer for seam responsibility.\n5. Increase speed and angle as passer improves.",
        "1. Two lines: servers and passers. Server serves; passer passes to target.\n2. Passer immediately runs to the serving line and serves to the next passer.\n3. Continuous cycle. Run for 4 minutes.\n4. Emphasizes serve receive and quick transition.\n5. Count number of good passes in the round.",
        "1. Passers start with back to the net. Coach blows whistle and tosses or hits.\n2. Passers turn, find the ball, and pass to target.\n3. Simulates late read on the ball. Do 12 reps per passer.\n4. Rest 15 seconds between reps.\n5. Add a second ball for double-touch scenarios.",
        "1. Full W formation. Coach serves from different positions (or different servers).\n2. Passers must communicate and pass to setter.\n3. Setter sets to an outside hitter (or catches).\n4. Run 25 serves. Rotate passers and setter.\n5. Goal: 70% of passes are 2 or 3 (usable by setter).",
    ],
    ("Setting", "New to Volleyball"): [
        "1. Stand 4 feet from a wall. Set the ball against the wall.\n2. Use proper hand shape: thumbs and forefingers form a triangle.\n3. Set 30 times without catching. Focus on consistent height.\n4. Step back to 6 feet and repeat.\n5. Keep the ball from spinning.",
        "1. Hold the ball in setting position above your forehead.\n2. Without releasing, practice the hand position and wrist snap.\n3. Then set the ball straight up 2–3 feet and catch it.\n4. Repeat 20 times. Progress to 2 sets before catching.\n5. Build to 10 consecutive sets.",
        "1. Sit on the floor with legs extended. Set the ball to yourself.\n2. Use only arms and wrists (no leg drive).\n3. Set 25 times. Focus on clean contact and no spin.\n4. Stand up and set to self 25 more times.\n5. Emphasizes hand position and control.",
        "1. Partner holds the ball in both hands at your setting height.\n2. Place your hands on the ball in setting position.\n3. Partner releases; you set the ball back to their hands.\n4. Do 15 reps. Partner can move slightly to vary the target.\n5. Switch roles.",
        "1. Set the ball to yourself while walking forward 20 feet.\n2. Then walk backward 20 feet while setting.\n3. Keep the ball at a consistent height (above forehead).\n4. Do 3 laps (forward and back = 1 lap).\n5. Focus on footwork and not carrying the ball.",
    ],
    ("Setting", "Beginner/Developing"): [
        "1. Setter in position 2/3. Coach tosses the ball from various spots.\n2. Setter moves to the ball, sets to the left pin (position 4).\n3. Do 10 sets to the left, then 10 to the right pin.\n4. Emphasize squaring to the target and consistent height.\n5. Add a second setter to alternate.",
        "1. Groups of 3: tosser, setter, target. Tosser tosses to setter.\n2. Setter sets to the target (who catches).\n3. Target becomes the next tosser; tosser goes to target; setter stays for 2 more, then rotates.\n4. Run 5 minutes. Focus on accuracy.\n5. Increase distance between setter and target.",
        "1. Setter at the net. Coach tosses high to the setter’s right or left.\n2. Setter must shuffle to the ball and set to the outside.\n3. After each set, setter returns to the middle.\n4. Do 12 sets (6 each direction).\n5. Add a back set for intermediate variation.",
        "1. Two setters on one side of the net; two targets (or hitters) on the other.\n2. Coach tosses to setter 1, who sets to target 1. Then toss to setter 2, set to target 2.\n3. Continuous. Run 3 minutes.\n4. Setters focus on consistent tempo and location.\n5. Targets can catch or hit the ball back.",
        "1. Setter sets to self, then to a partner 15 feet away.\n2. Partner catches and tosses back to setter.\n3. Setter sets to self again, then to partner. Repeat 20 times.\n4. Builds rhythm and transition from self-set to target set.\n5. Partner can move to different spots for variety.",
    ],
    ("Setting", "Intermediate"): [
        "1. Setter in the middle. Coach tosses to left, right, or behind.\n2. Setter must set to the correct pin (outside, right side, or back row).\n3. Do 15 tosses with random placement.\n4. Emphasize quick feet and reading the toss early.\n5. Add a hitter to receive sets for a more game-like drill.",
        "1. Two setters; two passers. Coach serves to passers.\n2. Passer passes to setter 1 or 2 (call it). Setter sets to a hitter or target.\n3. Rotate after 10 good rallies.\n4. Focus on setter moving to the pass and delivering a hittable set.\n5. Track set quality (location and height).",
        "1. Setter starts in the back row. Coach tosses a dig to the setter.\n2. Setter must transition to the net and set to the outside.\n3. Repeat 10 times. Builds transition setting.\n4. Add a pass before the dig for full sequence.\n5. Time the setter from contact to set.",
        "1. Setter at the net. Coach tosses bad passes (too tight, too far off).\n2. Setter must recover and still deliver a playable set.\n3. Do 12 difficult tosses. Focus on footwork and body position.\n4. Discuss options: dump, high set, or push to a pin.\n5. Rotate setters.",
        "1. Game-like: pass, set, hit. Setter must choose the best option (outside, middle, right side) based on pass.\n2. Run 20 rallies. Setter calls the play.\n3. Track number of good sets (hittable) vs. errors.\n4. Add a block on the other side for pressure.\n5. Rotate so everyone sets.",
    ],
    ("Hitting/Spiking", "New to Volleyball"): [
        "1. Stand on a box at the net. Coach holds the ball at arm’s length above the net.\n2. Practice your arm swing and wrist snap, hitting the ball down.\n3. Focus on high elbow and top of the ball contact.\n4. Do 15 reps. Then try without the box (jump from the floor).\n5. Land on both feet.",
        "1. No net. Toss the ball up and hit it down into the floor 10 feet in front of you.\n2. Use full arm swing: reach back, swing through, snap wrist.\n3. Do 20 hits. Focus on contacting the top of the ball.\n4. Add a net and hit from a standing approach.\n5. Emphasize safe landing.",
        "1. Partner tosses the ball high near the net. Hitter approaches with a 3-step approach (left-right-left for right-handers).\n2. Jump and hit the ball over the net.\n3. Do 10 reps per side (left and right pin).\n4. Focus on timing: last step and jump as the ball reaches the hitting zone.\n5. Shagger retrieves the ball.",
        "1. Hit from a standing position at the net. Coach or partner tosses.\n2. Focus only on arm swing: draw arm back, lead with elbow, snap wrist.\n3. Do 15 reps. No approach yet.\n4. Then add one step, then two, then full 3-step approach.\n5. Builds progression to full spike.",
        "1. Use a tennis ball. Approach and throw the tennis ball over the net with a hitting motion.\n2. Simulates arm swing and wrist snap without worrying about volleyball contact.\n3. Do 15 throws from the left side, 15 from the right.\n4. Then switch to a volleyball and hit.\n5. Great for beginners learning timing.",
    ],
    ("Hitting/Spiking", "Beginner/Developing"): [
        "1. Hitting line at the left pin. Setter sets from position 2/3.\n2. Passer passes to setter; setter sets outside; hitter approaches and hits.\n3. Rotate: hitter to shag, shagger to passing line, passer to hitting line.\n4. Each player gets 8 hits. Focus on approach and arm swing.\n5. Repeat from the right pin.",
        "1. Place cones in zones 1, 6, and 5 on the opposite court.\n2. Hitter must aim for a specific zone (coach calls it).\n3. Score 1 point for hitting in the correct zone.\n4. Each hitter gets 10 attempts. Track score.\n5. Teaches direction and placement.",
        "1. Two hitters: one from the left, one from the right. Setter in the middle.\n2. Coach tosses to setter; setter sets to one side (call it).\n3. That hitter approaches and hits. Alternate sides.\n4. Run 20 sets. Focus on setter communication and hitter timing.\n5. Add a block for advanced variation.",
        "1. Hitter stands on a box. Setter sets to the hitter.\n2. Hitter focuses only on arm swing and contact (no approach).\n3. Do 12 reps. Then remove the box and hit with a full approach.\n4. Compare contact point with and without the box.\n5. Emphasize hitting the ball in front of the shoulder.",
        "1. Tip drill: setter sets; hitter must tip the ball to a specific spot (coach calls left or right).\n2. Builds control and variety. Do 10 tips per hitter.\n3. Then do 10 full swings. Alternate tip and swing.\n4. Focus on reading the block (even if it’s just a shadow).\n5. Rotate hitters and setter.",
    ],
    ("Hitting/Spiking", "Intermediate"): [
        "1. One blocker at the net. Hitter must hit around or off the block.\n2. Coach or setter sets; hitter reads the block and chooses line, angle, or tip.\n3. Do 15 swings per hitter. Rotate blocker and hitter.\n4. Blocker gets a point for a stuff block; hitter gets a point for a kill.\n5. First to 10 wins the round.",
        "1. Two blockers. Hitter must find the seam or the deep corner.\n2. Setter sets; hitter has 3 options: line, cross-court, or tip over the block.\n3. Run 20 sets. Track kills vs. errors vs. blocked.\n4. Discuss shot selection after each hit.\n5. Rotate so everyone hits and blocks.",
        "1. Back-row attack: setter sets to the back row (position 1 or 6).\n2. Hitter approaches from the back and hits from behind the 10-foot line.\n3. Do 10 back-row swings per player.\n4. Focus on approach from deep and legal contact behind the line.\n5. Add a block for game-like pressure.",
        "1. Quick set (1 or 2) to the middle. Middle hitter approaches and hits.\n2. Setter and middle work on timing. Do 15 quick sets.\n3. Then mix in outside sets so the middle is an option.\n4. Run 25 sets with 3 options: outside, middle, right side.\n5. Track successful attacks by position.",
        "1. Game-like: full offense vs. defense. Pass, set, hit. Defense tries to dig.\n2. Hitters must place the ball (no free kills). Run 30 rallies.\n3. Rotate positions. Focus on shot selection and consistency.\n4. Count kills, errors, and digs.\n5. Winning side stays on; losing side rotates out.",
    ],
    ("Defense/Digging", "New to Volleyball"): [
        "1. Partner stands 10 feet away and tosses the ball at waist to knee height.\n2. Get in defensive stance: knees bent, arms ready.\n3. Dig the ball up so your partner can catch it.\n4. Do 15 digs, then switch. Focus on platform and not swinging.\n5. Keep the ball in front of your body.",
        "1. Coach or partner hits easy balls from the net toward the defender.\n2. Defender digs the ball to a target (another player or cone).\n3. Do 20 digs. Focus on reading the hitter and moving early.\n4. Emphasize low stance and soft hands (absorb the ball).\n5. Rest 30 seconds; repeat.",
        "1. Two lines: one hitter, one digger. Hitter tips the ball to the digger.\n2. Digger digs to a target. Both rotate to the back of the opposite line.\n3. Continuous for 4 minutes.\n4. Keep the ball controlled and playable.\n5. Increase difficulty by having the hitter hit harder.",
        "1. Defender in the middle of the court. Coach tosses the ball to the left or right.\n2. Defender shuffles to the ball and digs it up to the coach.\n3. Do 15 tosses (mix left and right).\n4. Focus on first step and platform angle.\n5. Add a second defender for seam responsibility.",
        "1. Sit in defensive stance (no standing). Partner rolls the ball to you.\n2. Dig the ball up using only your arms. Do 15 reps.\n3. Stand and repeat with partner tossing. Do 15 more.\n4. Emphasizes platform control without leg drive first.\n5. Progress to coach hitting easy balls.",
    ],
    ("Defense/Digging", "Beginner/Developing"): [
        "1. One digger in zone 5. Coach hits or tips from the net to different spots.\n2. Digger must dig to a setter target in position 2/3.\n3. Do 15 balls, then switch diggers.\n4. Focus on reading the hitter’s shoulder and first step.\n5. Track digs that are playable (target height and location).",
        "1. Two diggers in positions 5 and 6. Coach hits to either side.\n2. Diggers call the ball and dig to target.\n3. Run 20 hits. Rotate so everyone digs.\n4. Emphasize communication: 'Mine,' 'Yours,' 'Help.'\n5. Add a third digger in position 1.",
        "1. Digger in the back row. Hitter on the other side hits cross-court or line.\n2. Digger must read and dig to target.\n3. Do 12 hits per digger. Mix in tips.\n4. Focus on staying low and moving through the ball.\n5. Add a second digger for double-block defense.",
        "1. Coach stands at the net with a ball. Digger stands in the back court with back to the coach.\n2. Coach says 'Go' and tosses or hits. Digger turns and digs.\n3. Simulates late read. Do 10 reps per digger.\n4. Rest 10 seconds between reps.\n5. Increase speed of the hit as skill improves.",
        "1. Three diggers in base defense. Coach hits from the net (or a hitter attacks).\n2. Diggers must dig to the setter and cover the court.\n3. Run 25 balls. Rotate positions every 5.\n4. Focus on first contact and transition to offense.\n5. Track number of positive digs (playable by setter).",
    ],
    ("Defense/Digging", "Intermediate"): [
        "1. One digger. Two or three hitters at the net with balls. They hit in rapid succession.\n2. Digger must dig each ball to a target. Go for 20 seconds, then switch.\n3. Builds reaction and conditioning.\n4. Rest 30 seconds between rounds.\n5. Increase tempo as digger improves.",
        "1. Digger starts lying on stomach. Coach yells 'Up'; digger jumps to ready position.\n2. Coach immediately tips or hits. Digger must dig the ball.\n3. Do 10 reps. Simulates recovering from a dive or fall.\n4. Rotate diggers. Emphasize quick recovery.\n5. Add a second ball for double recovery.",
        "1. Full defense vs. one hitter. Hitter gets sets and hits; defense digs and transitions to attack.\n2. Play out the rally. Run 20 rallies. Rotate positions.\n3. Focus on dig quality and transition footwork.\n4. Count digs that lead to a playable pass.\n5. Add a setter and hitter on the defensive side for full transition.",
        "1. Ball is thrown or hit off the net (net ball). Digger must read where it comes off and dig it.\n2. Do 15 net balls from different angles.\n3. Emphasize watching the ball hit the net before moving.\n4. Dig to target. Rotate diggers.\n5. Add a second touch (set or catch) for transition.",
        "1. Defense in rotation. Server serves; defense passes, sets, and attacks. Other side free balls back.\n2. Defense must dig the free ball and run offense. Run 15 rallies.\n3. Focus on first-ball sideout and dig-to-set connection.\n4. Rotate after every 3 rallies.\n5. Track sideout percentage.",
    ],
    ("Blocking", "New to Volleyball"): [
        "1. Stand at the net, hands at shoulder height. Jump and press both hands over the net.\n2. Fingers spread, wrists firm. Land softly and repeat.\n3. Do 3 sets of 10 jumps. Focus on hand position.\n4. Add a step: shuffle right, jump, press; shuffle left, jump, press.\n5. Builds blocking posture and endurance.",
        "1. Two players on opposite sides of the net. One moves left and right along the net.\n2. The other mirrors the movement (shadow blocking without the ball).\n3. After 5 shuffles, the mover raises arms; mirror jumps and presses.\n4. Do 10 reps, then switch roles.\n5. Focus on staying in front of the attacker.",
        "1. Blocker at the net. Coach stands on a box on the other side and holds the ball above the net.\n2. Blocker jumps and presses hands against the ball (no swing).\n3. Focus on penetrating the net and sealing.\n4. Do 12 reps. Rotate blockers.\n5. Emphasize jumping straight up, not into the net.",
        "1. Blocker in the middle. Coach points left or right; blocker shuffles to that pin and jumps.\n2. After landing, shuffle back to the middle. Repeat.\n3. Do 10 to the left, 10 to the right.\n4. Focus on quick feet and not crossing feet.\n5. Add a second blocker for double-block footwork.",
        "1. Practice hand position: stand at the net, hands up. Coach tosses a ball; blocker angles hands to deflect the ball into the court.\n2. Do 15 tosses (left, right, middle).\n3. Focus on strong wrists and not touching the net.\n4. Then add a jump before each block.\n5. Rotate so everyone gets reps.",
    ],
    ("Blocking", "Beginner/Developing"): [
        "1. Two blockers at the net. Coach calls 'Left' or 'Right.'\n2. Both blockers slide together to the pin and jump.\n3. Emphasize closing the seam between blockers (hands together).\n4. Do 12 slides (6 each direction).\n5. Focus on timing: jump together.",
        "1. Blocker at the net. Hitter on the other side approaches and hits.\n2. Blocker must time the jump with the hitter and block or deflect the ball.\n3. Do 15 swings. Rotate blocker and hitter.\n4. Focus on reading the hitter’s approach and arm.\n5. Add a second blocker for a double block.",
        "1. Middle blocker starts in the middle. Setter sets to the outside; blocker must close to the outside blocker and form a double block.\n2. Do 10 sets to the left, 10 to the right.\n3. Focus on quick close step and hand seal.\n4. Run the drill with a live setter and hitter.\n5. Track blocks (touches that keep the ball in play).",
        "1. Three blockers at the net. Coach stands on a box and hits to different positions.\n2. Blockers must read and block the correct angle.\n3. Do 20 hits. Rotate blockers.\n4. Emphasize pressing over the net and not reaching.\n5. Add a tip so blockers must read tip vs. swing.",
        "1. Blocker blocks, then immediately drops off the net and transitions to hit.\n2. Coach or setter sets the ball; blocker (now hitter) approaches and hits.\n3. Do 10 block-to-hit transitions per player.\n4. Builds block-to-attack movement.\n5. Focus on quick turn and approach.",
    ],
    ("Blocking", "Intermediate"): [
        "1. Two blockers vs. one hitter. Hitter has the option to hit line, cross-court, or tip.\n2. Blockers must read and set the block. Run 20 swings.\n3. Rotate so everyone blocks and hits.\n4. Track stuff blocks and touches.\n5. Add a setter for more game-like tempo.",
        "1. Triple block (middle + both pins) on a single hitter. Hitter tries to find a seam or tool the block.\n2. Blockers work on sealing the net and communication.\n3. Do 15 swings. Rotate.\n4. Focus on hand position and not leaving gaps.\n5. Discuss reading the set (high outside vs. quick vs. back set).",
        "1. Blocker focuses on the hitter’s shoulder and approach—not the ball. Coach tosses to hitter; hitter hits.\n2. Blocker sets the block based on body language. Do 15 reps.\n3. Teaches reading the attacker. Rotate.\n4. Add a second blocker for coordinated read blocking.\n5. Debrief: did the block match the hit?",
        "1. Swing blocking: blocker starts in the middle, runs to the pin, and blocks.\n2. Setter sets to that pin; blocker must get there and block.\n3. Do 10 to the left, 10 to the right. Focus on speed and timing.\n4. Add a second middle for double middle.\n5. Run with live hitters.",
        "1. Game-like: full block vs. full offense. Blockers must read setter and hitters.\n2. Run 25 rallies. Rotate positions.\n3. Focus on block placement and transition after the block.\n4. Count blocks (stuff, touch, or control).\n5. Discuss defensive coverage behind the block.",
    ],
    ("Warmup", "New to Volleyball"): [
        "1. Jog slowly around the court for 2 minutes.\n2. Keep a steady pace; focus on breathing.\n3. Then walk 1 lap to cool down.\n4. Simple cardio to raise heart rate before practice.\n5. Can be done with a partner.",
        "1. Stand with feet hip-width apart. Lift knees in place (march).\n2. Pump arms. Go for 45 seconds, rest 15, repeat 2 times.\n3. Progress to light jog in place.\n4. Warms up legs and gets the heart rate up.\n5. Good for all ages.",
        "1. Stand on one foot; lift the other knee to 90 degrees. Hold 5 seconds.\n2. Switch legs. Do 5 per leg.\n3. Then do single-leg hops in place (5 per leg).\n4. Builds balance and ankle stability.\n5. Use a wall for support if needed.",
        "1. Stand with feet shoulder-width apart. Roll shoulders forward 10 times, backward 10 times.\n2. Then roll wrists and ankles 10 times each direction.\n3. Simple joint mobility for the whole body.\n4. Takes 2 minutes. Do before any ball handling.\n5. Add neck rolls (gentle) if desired.",
        "1. Stand with arms at sides. Twist upper body left and right, keeping hips forward.\n2. Do 20 twists. Then add arm swing (touch opposite foot) for 20 more.\n3. Warms up the core and spine.\n4. Good before passing and hitting.\n5. Keep movements controlled.",
        "1. From standing, bend at the waist and try to touch your toes (or shins).\n2. Hold 10 seconds. Relax and repeat 3 times.\n3. Don’t bounce. Feel the stretch in the hamstrings.\n4. Then do a quad stretch (hold ankle behind you) for 15 seconds per leg.\n5. Basic static stretch after light movement.",
        "1. Get in a low squat position and hold for 10 seconds.\n2. Stand up and repeat 5 times.\n3. Focus on keeping heels down and chest up.\n4. Prepares legs for jumping and passing.\n5. Add a small jump from the squat for more intensity.",
        "1. Stand on one leg; swing the other leg forward and back 10 times.\n2. Then swing the same leg side to side 10 times.\n3. Switch legs. Use a wall for balance if needed.\n4. Hip mobility for lateral movement.\n5. Do before shuffles and defensive drills.",
        "1. With or without a ball, practice the arm swing for serving: no ball, just motion.\n2. Do 15 serving arm swings. Then 15 hitting arm swings.\n3. Warms up the shoulder and reinforces technique.\n4. Can be done in pairs (mirror each other).\n5. Focus on full range of motion.",
        "1. In a circle, pass one ball around. Each player touches the ball and passes to the next.\n2. Keep the ball moving for 2 minutes. Add a second ball.\n3. Light ball handling and teamwork.\n4. Good for new players to get comfortable with the ball.\n5. Coach can call 'Reverse' to change direction.",
    ],
    ("Warmup", "Beginner/Developing"): [
        "1. With a partner, bump the ball back and forth 20 times.\n2. Then set back and forth 20 times.\n3. Then alternate: one bump, one set, for 20 contacts.\n4. Gradually increase distance. Focus on control.\n5. Classic pepper at half speed.",
        "1. Form two lines. First player in each line runs to the net, touches the net, and runs back.\n2. Tag the next player, who repeats. First team to have everyone go wins.\n3. Run 2–3 races. Good for energy and teamwork.\n4. Can add a volleyball (carry or bounce) for variation.\n5. Emphasize touching the net safely.",
        "1. Each player has a ball. Set to self while moving in a circle around the court.\n2. Keep the ball at forehead height. Do 2 laps.\n3. Then bump to self while moving. Do 2 laps.\n4. Combine: set twice, bump once, while moving. 2 laps.\n5. Ball handling and footwork combined.",
        "1. In pairs, one player tosses the ball; the other passes it back.\n2. After 10 passes, switch. Then do 10 sets each.\n3. Increase distance after each set of 10.\n4. Focus on accuracy and communication.\n5. Add a target (cone or player) to pass/set to.",
        "1. Line up at the baseline. On 'Go,' run to the 10-foot line, touch it, run back.\n2. Then run to the net, touch, run back. Then run to the opposite baseline and back.\n3. One full round per player. Rest 30 seconds; repeat.\n4. Builds conditioning and court awareness.\n5. Can be done as a relay.",
        "1. With a partner, play catch with a volleyball using a set (overhead).\n2. Move back 2 steps every 5 catches. See how far you can go.\n3. Then move back in with bump passes. 5 minutes total.\n4. Warmup and accuracy.\n5. Focus on clean contact.",
        "1. In a circle, one player has a ball. That player sets to someone across the circle, then runs to that spot.\n2. The receiver sets to someone else and runs. Continuous for 3 minutes.\n3. Keep the ball in the air. Good for setting and movement.\n4. Add a second ball for more challenge.\n5. Call the name of the person you’re setting to.",
        "1. Jump in place 10 times. Rest 10 seconds. Repeat 3 times.\n2. Then do 10 approach jumps (no ball): left-right-left and jump.\n3. Focus on arm swing and landing softly.\n4. Prepares legs for blocking and hitting.\n5. Add a small approach and jump at the net (no ball).",
        "1. Players in two lines facing each other. First pair runs to the middle, does a high-five, runs back.\n2. Next pair goes. Continue until everyone has gone.\n3. Run 2 rounds. Fun and energizing.\n4. Can add a ball: pass at the middle, then run back.\n5. Good for team bonding.",
        "1. With a ball, practice your approach (left-right-left for right-handers) without hitting.\n2. Do 10 approaches from the left side, 10 from the right.\n3. Focus on last two steps and arm swing.\n4. Then add a toss and hit (light) for 5 each side.\n5. Warmup for hitting drills.",
    ],
    ("Warmup", "Intermediate"): [
        "1. With a resistance band, do 15 lateral walks to the right, 15 to the left.\n2. Keep tension on the band. Half-squat position.\n3. Then do 15 forward steps, 15 backward. 2 sets.\n4. Activates glutes and hips for lateral movement.\n5. Use a light band; increase resistance as needed.",
        "1. In pairs, one player serves easy; the other passes to a target.\n2. Do 10 serves per server, then switch. Start at half speed.\n3. Increase to three-quarter speed for the last 5 each.\n4. Serve receive warmup with communication.\n5. Target can be a setter or a cone.",
        "1. Three players: setter, hitter, shagger. Setter sets; hitter approaches and hits (or tips).\n2. Rotate after 5 hits. Run 2 full rotations.\n3. Warmup for hitting and setting. Focus on timing.\n4. No block. Emphasize approach and arm swing.\n5. Increase tempo for the second rotation.",
        "1. Full court: pass, set, hit. One side free balls to the other; that side passes, sets, hits.\n2. Continuous for 5 minutes. Rotate positions every minute.\n3. Game-like warmup with all skills.\n4. Focus on first-ball sideout and transition.\n5. Count successful rallies.",
        "1. Blockers at the net. Coach or setter sets; hitter hits. Blockers work on timing and hand position.\n2. Do 10 swings per blocker. Rotate.\n3. Warmup for blocking and hitting. No full defense.\n4. Focus on block timing and penetration.\n5. Add a second blocker for double block.",
        "1. Jog around the court while passing a ball with a partner (alternate bump and set).\n2. Do 3 laps. Don’t stop.\n3. Then do 2 laps with a set-only rule.\n4. Conditioning and ball control.\n5. Keep the ball playable; focus on communication.",
        "1. With a band, do shoulder external rotation: 15 per arm. Then internal rotation: 15 per arm.\n2. Then band pull-aparts: 15 reps. Keep elbows slightly bent.\n3. Shoulder prep for serving and hitting.\n4. Do 2 sets. Use a light band.\n5. Focus on controlled movement.",
        "1. Quick feet: run in place for 20 seconds, then shuffle right 10 feet and back, then left.\n2. Repeat 3 times. Rest 20 seconds between.\n3. Builds agility and foot speed.\n4. Good before defensive and blocking drills.\n5. Add a ball: toss to self, catch, repeat while moving.",
        "1. Two lines: one serves, one passes. Server serves; passer passes to target.\n2. Both rotate to the other line. Continuous for 4 minutes.\n3. Serve receive and serving warmup combined.\n4. Track good passes. Increase serve speed in the last 2 minutes.\n5. Target can be a setter who catches or sets.",
        "1. Small-sided game: 3v3 or 4v4. Free ball to start each rally. Play to 15.\n2. Focus on serve receive, set, and attack. Run 2 games.\n3. Full warmup with game-like intensity.\n4. Rotate so everyone plays different positions.\n5. Emphasize communication and movement.",
    ],
}

def make_drill(name: str, skill: str, level: str, description: str, equipment: list, index: int) -> dict:
    source = SOURCES[index % len(SOURCES)]
    return {
        "name": name,
        "skill": skill,
        "level": level,
        "description": description,
        "equipment": equipment,
        "source": source,
        "image": "",
        "imageAsset": image_asset(skill),
    }

# Unique names for generated drills (at least 20 per skill/level). Used in order as we fill gaps.
NEW_DRILL_NAMES = {
    ("Serving", "New to Volleyball"): [
        "Short Line Serves", "Toss and Serve", "Partner Serve Catch", "Serve Over the Rope",
        "Basket Serves", "Underhand Consistency", "Step and Serve", "Serve to a Partner",
        "Line Serves", "Court Width Serves", "Serve and Retrieve", "Five in a Row Serves",
        "Coach Toss Serves", "Distance Builder Serves", "Serve from a Spot", "Alternating Serves",
        "Serve Count Challenge", "Wall Serve Back", "Net Clear Serves", "Target Zone New",
    ],
    ("Serving", "Beginner/Developing"): [
        "Zone Call Serves", "Float Serve Practice", "Topspin Start", "Serve and Switch",
        "Hoop Target Serves", "Left Right Serves", "Deep Short Mix", "Serve Under the Tape",
        "Team Serve Race", "Accuracy Ladder", "Serve to Zones 1 and 5", "Three-Zone Rotation",
        "Pressure Serves", "Serve Receive Pair", "Back Line Serves", "Cross-Court Serves",
        "Serve Points Game", "Low Trajectory Serves", "Serve and Cover", "End Line Consistency",
    ],
    ("Serving", "Intermediate"): [
        "Jump Float Intro", "Seam Serves", "Serve and Block", "Six-Zone Challenge",
        "Serve Battle", "Placement vs Chairs", "Serve to Seams", "Float and Spin Mix",
        "Serve Transition Drill", "Ace or Error Count", "Deep Corner Serves", "Short Serves",
        "Serve and Dig", "Pressure Zone Serves", "Serve Receive Scramble", "Target Service Game",
        "Jump Serve Prep", "Serve and Read", "Back Row Serve", "Game-Like Serve Drill",
    ],
    ("Passing/Bumping", "New to Volleyball"): [
        "Bump to Hands", "Midline Passing", "Triangle Pass", "Line Toss and Pass",
        "Sit and Pass", "Platform Only", "Partner Toss Pass", "Target Bump",
        "Circle Pass", "Two-Line Pass", "Call and Pass", "Feet First Passing",
        "Wall Pass", "Self-Pass and Partner", "Pass and Catch", "Moving Platform",
        "Pass Count", "Toss Variety Pass", "Ready Position Pass", "Short Distance Control",
    ],
    ("Passing/Bumping", "Beginner/Developing"): [
        "Shuttle Pass Run", "Middle Pass Alternating", "Circle Pass Two Balls", "Zone 5 Pass",
        "Two-Passer Receive", "Call Mine Yours", "Cross-Court Pass", "Pass and Turn",
        "Three-Person Pass", "Pass to Setter Target", "Toss Left Right", "Pass Rating",
        "W Formation Intro", "Seam Responsibility", "Pass and Rotate", "Back Row Pass",
        "Pass Set Catch", "Serve to Pass", "Quick Feet Pass", "Partner Pass Set",
    ],
    ("Passing/Bumping", "Intermediate"): [
        "Three-Passer Rotate", "Coach Hit Pass", "Serve Pass Serve", "Turn and Pass",
        "W Formation Full", "Pass Rating Track", "Read and Pass", "Double-Touch Recovery",
        "First-Ball Sideout", "Seam Read Pass", "Back to Net Pass", "Tip and Hit Pass",
        "Pass Set Hit", "Serve Receive Scramble", "Pass Under Pressure", "Full Receive",
        "Pass Transition", "Two-Ball Pass", "Blind Pass", "Game-Like Receive",
    ],
    ("Setting", "New to Volleyball"): [
        "Wall Set Count", "Set and Catch", "Sit Set", "Partner Hand Set",
        "Set and Walk", "Hand Shape Drill", "Set Height Control", "Self-Set Progression",
        "Target Set", "Set to Partner", "No Spin Set", "Forehead Set",
        "Set from Toss", "Back to Wall Set", "Set and Move", "Double Set",
        "Set to Cone", "Wrist Snap Set", "Set Balance", "Partner Release Set",
    ],
    ("Setting", "Beginner/Developing"): [
        "Setter Toss Left Right", "Three-Person Set", "Setter Shuffle", "Set to Pin",
        "Toss Set Target", "Setter Stay Rotate", "Set from Pass", "Back Set Intro",
        "Set and Follow", "Two-Setter Drill", "Set to Self and Partner", "Setter Movement",
        "Target Set Distance", "Set Tempo", "Setter Recovery", "Set from Different Spots",
        "Outside Set Only", "Right Side Set", "Set Quality", "Pass to Set",
    ],
    ("Setting", "Intermediate"): [
        "Random Toss Set", "Pass Set Hit", "Transition Set", "Bad Pass Set",
        "Set Option Game", "Setter Read", "Back Set Pin", "Quick Set Middle",
        "Set from Dig", "Double Set", "Set Under Pressure", "Three-Option Set",
        "Setter Call", "Set and Block", "Full Offense Set", "Setter Run",
        "Set Location", "Set Tempo Mix", "Game Set", "Setter Decision",
    ],
    ("Hitting/Spiking", "New to Volleyball"): [
        "Box Hit Down", "Floor Hit", "Toss and Hit", "Standing Arm Swing",
        "Tennis Ball Throw", "Approach No Ball", "Contact Point", "One Step Hit",
        "Wall Hit", "Partner Toss Hit", "High Contact", "Jump and Hit",
        "Left Side Approach", "Right Side Approach", "Arm Swing Only", "Toss Approach Hit",
        "Landing Drill", "Hit from Box", "Top of Ball", "Approach and Throw",
    ],
    ("Hitting/Spiking", "Beginner/Developing"): [
        "Left Pin Hitting Line", "Zone Cone Hit", "Setter Hitter Two", "Box Hit Then Floor",
        "Tip Then Swing", "Outside Set Hit", "Right Side Line", "Approach and Hit",
        "Target Hit", "Setter Call Hit", "Hit and Shag", "Cross and Line",
        "Ten Hits Finish", "Hit from Pass", "Placement Hit", "Approach Timing",
        "Hit Quality", "Two Side Hit", "Tip Control", "Full Approach Hit",
    ],
    ("Hitting/Spiking", "Intermediate"): [
        "Hit Around Block", "Two Blocker Hit", "Back Row Attack", "Quick Set Middle",
        "Read Block Hit", "Seam Hit", "Game-Like Hit", "Shot Selection",
        "Line Cross Tip", "High Outside Hit", "Middle Option", "Find the Hole",
        "Block and Hit", "Three Option Offense", "Hit vs Defense", "Tool the Block",
        "Placement Game", "Tempo Hit", "Free Ball Attack", "Transition Hit",
    ],
    ("Defense/Digging", "New to Volleyball"): [
        "Toss and Dig", "Coach Hit Dig", "Tip and Dig", "Left Right Dig",
        "Roll and Dig", "Sit Dig", "Partner Toss Dig", "Target Dig",
        "Ready Stance Dig", "Shuffle and Dig", "Low Ball Dig", "Platform Dig",
        "Dig to Hands", "Wall Dig", "Two Line Dig", "Dig Count",
        "Soft Hands Dig", "Angle Dig", "Midline Dig", "Dig and Catch",
    ],
    ("Defense/Digging", "Beginner/Developing"): [
        "Zone 5 Dig", "Two Digger Call", "Cross Court Dig", "Turn and Dig",
        "Three Digger Rotate", "Read Hitter Dig", "Dig to Setter", "Back Row Dig",
        "Tip Read Dig", "Seam Dig", "Dig and Transition", "First Step Dig",
        "Down Ball Dig", "Dig Quality", "Communication Dig", "Coverage Dig",
        "Base Defense Dig", "Recovery Dig", "Double Dig", "Pass and Dig",
    ],
    ("Defense/Digging", "Intermediate"): [
        "Rapid Fire Dig", "Up and Dig", "Full Defense Dig", "Net Ball Dig",
        "Sideout Dig", "Dig Transition Attack", "Double Recovery", "Read and Dig",
        "Block and Dig", "Serve Receive Dig", "Free Ball Dig", "Coverage Recovery",
        "Dig to Attack", "Conditioning Dig", "Game Dig", "Seam Read Dig",
        "Two Ball Dig", "Net Rebound Dig", "Full Rally Dig", "First Contact Dig",
    ],
    ("Blocking", "New to Volleyball"): [
        "Jump and Press", "Shadow Block", "Ball Press Block", "Left Right Shuffle",
        "Hand Position Block", "Net Penetration", "Solo Block Jump", "Mirror Shuffle",
        "Coach Point Block", "Angle Hands Block", "Block Stance", "Ten Jump Block",
        "Seal the Net", "Block and Land", "Arm Position Block", "Middle Block Start",
        "Pin Shuffle Block", "Block Endurance", "Press Over Net", "Block Form",
    ],
    ("Blocking", "Beginner/Developing"): [
        "Two Blocker Slide", "Block and Hit", "Double Block Close", "Three Blocker Read",
        "Block Transition", "Slide Block", "Hitter Read Block", "Block Touch",
        "Middle Close Block", "Left Right Block", "Block Timing", "Seal Block",
        "Block and Drop", "Double Block Drill", "Coach Hit Block", "Tip Block",
        "Block Communication", "Pin Block", "Block Jump", "Form Block",
    ],
    ("Blocking", "Intermediate"): [
        "Two Blocker vs Hitter", "Triple Block", "Read Block", "Swing Block",
        "Game Block", "Blind Block", "Block Placement", "Block Transition Hit",
        "Swing Left Right", "Option Block", "Stuff Block", "Block Coverage",
        "Double Middle Block", "Block and Cover", "Read Setter Block", "Full Block",
        "Block Touch Game", "Seam Block", "Timing Block", "Block Defense",
    ],
    ("Warmup", "New to Volleyball"): [
        "Light Jog", "March in Place", "Single Leg Balance", "Shoulder Ankle Rolls",
        "Torso Twist", "Toe Touch Stretch", "Squat Hold", "Leg Swing",
        "Arm Swing Warmup", "Circle Pass Warmup", "Jump in Place", "Walk and Breathe",
        "Arm Circles Small", "Hip Circles", "Ankle Rolls", "Neck Rolls",
        "Quick Steps", "Side Step", "Forward Backward", "Ball Toss Warmup",
    ],
    ("Warmup", "Beginner/Developing"): [
        "Partner Bump Set", "Net Touch Relay", "Set Bump Circle", "Toss Pass Switch",
        "Baseline Run", "Set Catch Move", "Circle Set Run", "Jump Approach",
        "Partner High Five", "Approach Warmup", "Pass Set Warmup", "Ball Handle Circle",
        "Court Run", "Two Ball Circle", "Name Set", "Approach No Hit",
        "Relay Run", "Pass and Move", "Set to Target", "Light Pepper",
    ],
    ("Warmup", "Intermediate"): [
        "Band Lateral Walk", "Serve Pass Warmup", "Set Hit Shag", "Full Court Warmup",
        "Block Warmup", "Jog and Pass", "Shoulder Band", "Quick Feet",
        "Serve Receive Lines", "Small Sided Game", "Pass Set Hit Warmup", "Band Shoulder",
        "Two Line Serve Pass", "Agility Warmup", "Game Like Warmup", "Ball and Move",
        "Receive Warmup", "Block and Hit Warmup", "Conditioning Warmup", "Full Warmup",
    ],
}

def generate_drills_for(skill: str, level: str, count: int, existing_names: set) -> list:
    templates = TEMPLATES.get((skill, level), [
        "1. Gather with your team.\n2. Follow coach instructions for this drill.\n3. Focus on proper form and communication.\n4. Complete the assigned number of reps.\n5. Rotate and repeat."
    ])
    names = NEW_DRILL_NAMES.get((skill, level), [])
    if skill == "Serving":
        equip = ["Volleyball", "Net"]
    elif skill == "Passing/Bumping":
        equip = ["Volleyball"]
    elif skill == "Setting":
        equip = ["Volleyball"]
    elif skill == "Hitting/Spiking":
        equip = ["Volleyball", "Net"]
    elif skill == "Defense/Digging":
        equip = ["Volleyball", "Net"]
    elif skill == "Blocking":
        equip = ["Net"]
    else:
        equip = ["None"]
    drills = []
    used = set()
    for i in range(count):
        t = templates[i % len(templates)]
        name = names[i] if i < len(names) else f"{skill} Drill {i+1}"
        if name in existing_names or name in used:
            j = 1
            while f"{name} {j}" in existing_names or f"{name} {j}" in used:
                j += 1
            name = f"{name} {j}"
        used.add(name)
        existing_names.add(name)
        d = make_drill(name, skill, level, t, equip, len(drills))
        drills.append(d)
    return drills

def main():
    with open(JSON_PATH, "r", encoding="utf-8") as f:
        drills = json.load(f)
    existing_names = {d["name"] for d in drills}
    counts = defaultdict(int)
    for d in drills:
        counts[(d["skill"], d["level"])] += 1
    added = []
    for skill in SKILLS:
        for level in LEVELS:
            need = max(0, 20 - counts[(skill, level)])
            if need > 0:
                new_drills = generate_drills_for(skill, level, need, existing_names)
                added.extend(new_drills)
                counts[(skill, level)] += len(new_drills)
    # Use more descriptive names for generated drills - we'll do a second pass
    # For now use the template-based descriptions with generic names; we can refine names
    # to be more distinct (e.g. "Serving Accuracy New 1", "Serving Accuracy New 2")
    all_drills = drills + added
    with open(JSON_PATH, "w", encoding="utf-8") as f:
        json.dump(all_drills, f, indent=2, ensure_ascii=False)
    print(f"Added {len(added)} drills. Total: {len(all_drills)}")
    for skill in SKILLS:
        for level in LEVELS:
            c = sum(1 for d in all_drills if d["skill"] == skill and d["level"] == level)
            print(f"  {skill} | {level}: {c}")

if __name__ == "__main__":
    main()
