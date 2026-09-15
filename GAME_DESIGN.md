# THE TENANT — Game Design Document

## 1. Theme & Concept

**Genre:** First-person psychological horror  
**Target audience:** Young-adult horror players, primarily 18+  
**Tone:** Mature psychological dread, identity horror, implied death, unsettling imagery, and occasional strong language. No sexual content and no reliance on graphic gore.

The entire game takes place inside one apartment. The player is not being hunted by a conventional monster. They are a ghost reliving the final ten minutes of their life on a loop without realizing they are dead.

The horror comes from confusion about identity, memory, and ownership. Across five loops the apartment becomes increasingly wrong and decayed. A second entity, **the Figure**, appears and initially seems to be the antagonist. The truth is that the Figure is the apartment's actual living tenant, defending their home from an intruder they can sense but cannot fully understand.

The mature direction should come from disturbing implications, psychological pressure, stronger dialogue, and unsettling visual/audio design rather than constant blood or jump scares.

## 2. Core Gameplay Loop

The game is explored in first person. There is no combat, health bar, chase system, or traditional inventory.

The player explores a small apartment consisting of:
- Living room
- Kitchen
- Hallway
- Bedroom
- Closet

The player can inspect clues, interact with doors and objects, and observe environmental changes.

Whenever the player reaches the front door and attempts to leave, the apartment resets to roughly ten minutes earlier. Each reset changes subtle details: an object moves, a door changes state, a sound appears, lighting shifts, or a clue becomes available.

The game never explicitly announces that a loop has occurred. The player must notice it.

## 3. Five-Loop Structure

### Loop 1 — Arrival
The player wakes on the apartment floor with no memory of arriving. The apartment appears normal and almost boring. The player eventually tries the front door, hears a disembodied Voice, and the loop resets.

Purpose: establish a strong visual and audio baseline.

### Loop 2 — The Details
Small inconsistencies appear. A photograph is turned around. A previously closed door is open. A phone appears with a message suggesting the player has been missing for three days.

Purpose: make the player question time and memory.

### Loop 3 — The Mirror
The hallway mirror begins behaving incorrectly. The reflection first lags behind the player, then performs movements or expressions the player never made.

Footsteps begin appearing without an obvious source. The Figure appears for the first time and asks why the player is still inside **their** home.

Purpose: first direct confrontation and strongest early horror sequence.

### Loop 4 — Truth in Pieces
The apartment is visibly deteriorating. Wallpaper is damaged, moisture stains spread, lights become unreliable, and familiar objects appear misplaced.

The player can discover:
- A damaged newspaper clipping about an incident at the address
- A child's drawing implying something happened to a parent
- Additional environmental evidence connecting the hallway to a death

The Figure confronts the player directly and states that the player died in the hallway.

### Loop 5 — Final Confrontation
The player finds a police photograph showing their own body on the apartment floor, confirming they are dead.

The Figure appears clearly and the game resolves into one of several endings depending on the player's behavior throughout all five loops.

## 4. Priority Horror Mechanics

### Mirror Sequence
This is the game's most important horror mechanic and should receive the most polish.

The reflection should gradually become unreliable:
1. Slight visual delay
2. Incorrect head movement
3. Expression mismatch
4. Independent movement while the player is still
5. Final loop behavior that suggests the reflection understands the truth before the player does

### Environmental Changes
Changes between loops should be subtle enough that attentive players notice them before the game confirms anything is wrong.

Examples:
- A family photograph facing the wall
- One dining chair slightly moved
- A cabinet left open
- A clock showing an impossible time
- A doorway appearing fractionally wider
- The hallway becoming slightly longer in Loop 5

### Scare Philosophy
Avoid jump-scare spam. Use at most one or two major hard scares in the full game.

The Figure's first unmistakable appearance should be one of them.

### Sound Design
Long periods of silence are intentional.

Primary ambient sounds:
- Clock ticking
- Refrigerator hum
- Building pipes
- Wind outside
- Floorboard creaks
- Distant neighboring-apartment noise

Any interruption of these sounds should feel significant.

## 5. Invisible Ending Tracking

The player never sees a score or morality meter.

Track these variables internally:
- `clues_found`
- `door_force_attempts`
- `mirror_engaged`
- `ring_found`
- `total_optional_interactions`

### Ending 1 — Acceptance
**Condition:** Most major clues discovered + meaningful mirror engagement.

The player and Figure both understand what happened. The apartment becomes quiet and stable. The loop ends peacefully.

### Ending 2 — Endless Loop
**Condition:** Five or more aggressive door attempts + zero or one major clue.

The player never understands what is happening. The final sequence implies the apartment has trapped many confused spirits before them and will continue doing so.

### Ending 3 — Borrowed Face
**Condition:** Strong mirror engagement + insufficient clues.

The player realizes their identity is unstable but never learns enough to understand why. The Figure gradually assumes the player's identity while the player's reflection disappears.

### Ending 4 — Silence
**Condition:** Very low optional interaction count and minimal clue engagement.

There is no dramatic confrontation. The front door simply refuses to open. The apartment becomes completely silent and remains that way for an intentionally uncomfortable period before the game ends.

### Ending 5 — True Ending
**Condition:** Hidden wedding ring discovered.

This ending overrides all others.

The ring reveals that the Figure is not simply the player's past self or present tenant, but another victim connected to an older incident.

The apartment door finally opens — but not into the building hallway.

Instead, it opens onto a dark, rain-soaked forest.

## 6. Hidden Wedding Ring

The wedding ring is hidden beneath a loose floorboard near the bed and is not required to progress.

It should not glow, sparkle, or receive an objective marker. Discovery should reward careful observation.

Finding it permanently sets:

`ring_found = true`

This guarantees the true ending in Loop 5.

## 7. Sequel Hook

The true ending transitions from the claustrophobic apartment into an impossible jungle/forest environment.

The door opens to:
- Heavy rain
- Dense trees
- Low visibility
- No visible city
- A distant artificial light source
- The same unexplained mystery continuing outside the apartment

The sequel shifts from confined psychological dread to vast environmental fear while remaining connected to the same supernatural event.

## 8. Character and Voice Direction

### The Figure
The Figure should never sound like a conventional monster.

Voice direction:
- Tired
- Sad
- Controlled
- Matter-of-fact
- Occasionally frustrated, but rarely shouting

Its sympathy should make the encounter more uncomfortable, not less.

### Player Inner Voice
The player's inner voice becomes progressively fragmented:
- Loop 1: confident but confused
- Loop 2: uncertain
- Loop 3: defensive
- Loop 4: fragmented
- Loop 5: quiet, frightened, and increasingly self-aware

Stronger language can appear sparingly where emotionally appropriate, but dialogue should not become edgy for its own sake.

## 9. Mature Horror Direction

The 18+ positioning should come from subject matter and atmosphere, not explicit sexual content or excessive gore.

Allowed mature elements include:
- Death and post-death identity themes
- Disturbing crime-scene implications
- Blood stains or dried stains used sparingly
- Police evidence
- Strong psychological distress
- Occasional strong language
- Unsettling body/reflection behavior
- Themes of grief, disappearance, and memory loss

Avoid:
- Graphic dismemberment
- Torture-focused imagery
- Sexual violence
- Shock content with no narrative purpose
- Excessive gore that undermines the psychological tone

## 10. Development Priority

1. Stable first-person controller
2. Complete apartment blockout and collision
3. Loop manager
4. Door-reset system
5. Environmental state changes
6. Interaction/clue framework
7. Mirror system
8. Figure implementation
9. Audio system
10. Ending tracker and five ending sequences
11. Visual polish and apartment decay
12. True-ending forest transition

This document is the project's current creative source of truth.