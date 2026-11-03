# PS2 — Plan Analysis Report

**Domain:** Mars Rover (`Domain.pddl`)  
**Planner:** Custom Python BFS (optimal) + Greedy Best-First Search (satisficing)  
**Scenarios:** Base (5 rocks) · Extended (7 rocks, dust-storm topology)

---

## Task 6 — Plan Analysis Questions

---

### Q1. Compare satisficing vs. optimal plan lengths for both scenarios. Explain the difference.

#### Base Scenario

| Algorithm | Plan Length | States Expanded | Time |
|-----------|------------|-----------------|------|
| BFS (optimal) | **25 actions** | 319 391 | ~4.2 s |
| Greedy BFS (satisficing) | **33 actions** | 159 | ~7 ms |

**Difference: 8 extra actions in the satisficing plan.**

The optimal (BFS) plan is shorter because BFS guarantees the minimum number of actions to reach the goal. It achieves this by:

1. **Picking up the drill early and batching hard-rock collection.** In the BFS plan, the rover goes straight to SiteE (3 moves), picks up the drill (step 4), then collects Rock5 (SiteF) in Bay1 and Rock3 (SiteC) in Bay2 on the same loop — both hard rocks are collected before the first deposit trip back to Base. This eliminates duplicate travel between the drill and the hard-rock sites.

2. **Using both bays simultaneously.** The optimal plan carries two rocks at once on the return trip (steps 6–11: Bay1=Rock5, Bay2=Rock3), depositing both when back at Base. The satisficing plan carries only one rock per trip in most cases, leading to extra travel.

3. **Greedy BFS picks "easy" goals first.** GBFS resolves whichever unsatisfied goal facts are easiest to reach (soft rocks near Base), collecting Rock1, Rock2, Rock4 individually before attempting hard rocks. This "greedy" one-at-a-time strategy avoids the upfront detour to SiteE for the drill and is fast to compute (159 expanded states vs. 319 391), but at the cost of more total moves.

In summary, the satisficing planner makes locally good decisions but misses global optimisations like simultaneous multi-rock transport and opportunistic drill pick-up.

---

#### Extended Scenario

BFS is computationally intractable for the extended scenario (7 rocks × 2 bays × drill state × 7 locations ≈ 10⁸+ states). Only the GBFS result is available:

| Algorithm | Plan Length | States Expanded |
|-----------|------------|-----------------|
| GBFS (satisficing) | **61 actions** | 802 |

The extended plan is significantly longer than the base (61 vs. 33 satisficing) for two reasons:
- **Two more rocks** (Rock6, Rock7) each require their own collect-and-deposit cycle.
- **Longer routes** to SiteB and SiteD after the Base↔SiteB link is removed (see Q3 below).

---

### Q2. How does the optimal plan use the two storage bays, and when is the drill picked up?

**Drill acquisition (steps 1–4):**  
The optimal BFS plan sends the rover directly to SiteE via Base→SiteA→SiteC→SiteE on the very first trip. The drill is picked up at step 4, as early as possible in the plan. This is essential because both hard rocks (Rock3 at SiteC, Rock5 at SiteF) require the drill before they can be collected; getting the drill first eliminates all future backtracking to SiteE.

**Two-bay utilisation:**

| Steps | Bay1 | Bay2 | Description |
|-------|------|------|-------------|
| 6 | Rock5 | — | collect-hard Rock5 at SiteF |
| 9 | Rock5 | Rock3 | collect-hard Rock3 at SiteC → both bays full |
| 12 | Rock5 | ∅ | deposit Rock3 at Base |
| 14 | Rock5 | Rock1 | collect-soft Rock1 at SiteA → both bays full again |
| 16–17 | ∅ | ∅ | deposit Rock1 (Bay2), deposit Rock5 (Bay1) at Base |
| 20 | Rock4 | — | collect-soft Rock4 at SiteD |
| 22 | Rock4 | Rock2 | collect-soft Rock2 at SiteB → both bays full |
| 24–25 | ∅ | ∅ | deposit Rock2 (Bay2), deposit Rock4 (Bay1) at Base |

**Key insight:** The optimal planner uses both bays simultaneously (steps 6–11 carry two hard rocks; steps 20–23 carry two soft rocks), and it staggers deposits — it deposits Bay2 first at step 12 to free it up for Rock1 on the return leg, while Bay1 (carrying Rock5) waits until step 17. This staging allows the rover to avoid an extra round trip to Base.

---

### Q3. Extended scenario: how does the rover reach SiteB and SiteD after the dust storm? Is the one-way SiteC→SiteD slope used?

#### Topology change

The dust storm removes the **Base↔SiteB** bidirectional link. In the base scenario, SiteB and SiteD are reached cheaply:
- SiteB: Base→SiteB (1 move)
- SiteD: Base→SiteB→SiteD (2 moves)

In the extended scenario neither of these paths exists.

#### How the rover reaches SiteD

The planner uses the **one-way SiteC→SiteD slope** (steps 24 and 53):

```
Base → SiteA → SiteC → SiteD    (3 moves, using the one-way slope)
```

This is the only route to SiteD when Base↔SiteB is blocked. The slope is strictly one-way (SiteC→SiteD only), so the rover **cannot return via SiteD→SiteC**. Instead, it exits via:

```
SiteD → SiteE → SiteC    (2 moves back toward the main network)
```

#### How the rover reaches SiteB

Since Base↔SiteB is blocked, the only remaining route to SiteB goes through SiteD (steps 51–54):

```
Base → SiteA → SiteC → SiteD → SiteB    (4 moves)
```

The one-way SiteC→SiteD slope is used here as well (step 53). After collecting Rock2 at SiteB, the rover exits via:

```
SiteB → SiteD → SiteE → SiteC → SiteA → Base    (5 moves)
```

#### Summary

| Route | Base Scenario | Extended Scenario |
|-------|--------------|-------------------|
| Base → SiteB | Base→SiteB (1 move) | Base→SiteA→SiteC→SiteD→SiteB (4 moves) |
| Base → SiteD | Base→SiteB→SiteD (2 moves) | Base→SiteA→SiteC→SiteD (3 moves, one-way slope) |
| Return from SiteD | SiteD→SiteB→Base (2 moves) | SiteD→SiteE→SiteC→SiteA→Base (4 moves) |

The one-way SiteC→SiteD slope is **critical** in the extended scenario — it is the only way to reach both SiteD and SiteB after the dust storm blocks the direct Base↔SiteB route. Without it, Rock2 (SiteB) and Rock4 (SiteD) would be unreachable.

---

## Planner Notes

- **BFS** explores states in breadth-first order and is guaranteed to find the shortest (action-count optimal) plan. It is used for the base scenario.
- **Greedy BFS (GBFS)** uses the heuristic `h(s) = number of unsatisfied goal facts` to guide search greedily. It is fast (sub-millisecond to seconds) but produces plans that may be longer than optimal. It is used for both scenarios, and is the only feasible approach for the extended scenario.
- All plans are **formally verified** by simulating each action on the initial state and confirming all goal facts hold in the final state (see `planner_output.txt`).
