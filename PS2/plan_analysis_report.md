# PS2 — Plan Analysis Report

**Domain:** Mars Rover (`Domain.pddl`)  
**Planner:** Custom Python BFS (optimal), A* with an admissible heuristic (optimal), and Greedy Best-First Search (satisficing)  
**Scenarios:** Base (5 rocks) · Extended (7 rocks, dust-storm topology)

---

## Task 6 — Plan Analysis Questions

---

### Q1. Compare satisficing vs. optimal plan lengths for both scenarios. Explain the difference.

#### Base Scenario

| Algorithm | Plan Length | States Expanded | Time |
|-----------|------------|-----------------|------|
| BFS (optimal) | **25 actions** | 319,391 | ~4.2 s |
| A* (optimal) | **25 actions** | 1,497 | ~4.7 ms |
| Greedy BFS (satisficing) | **33 actions** | 159 | ~7 ms |】【：】【“】【}eriwa

**Difference: 8 extra actions in the satisficing plan.**

The optimal plan is shorter because BFS and A* both guarantee a minimum-action plan. The retained A* plan first batches Rock2 and Rock4 into one trip, then collects both hard rocks on one excursion after picking up the drill at SiteE. It uses both bays for each pair. GBFS collects rocks in a less efficient order and has a 33-action plan, eight actions longer than the optimal 25-action plan. GBFS expands far fewer states (159 vs. 1,497 for A*) and runs faster, trading optimality for search speed.

---

#### Extended Scenario

An optimal A* search with an admissible heuristic was run for the extended scenario. Its complete action sequence and search statistics are included in `planner_output.txt` under “Optimal A* Plan Outputs.”

| Algorithm | Plan Length | States Expanded | Time |
|-----------|------------:|----------------:|-----:|
| A* (optimal) | **40 actions** | 12,861 | ~40 ms |
| GBFS (satisficing) | **61 actions** | 802 | ~14 ms |

The satisficing plan is 21 actions longer. It handles several rocks individually, whereas the optimal plan batches Rock2 and Rock4 together, Rock5 and Rock7 together, then Rock6 and Rock3 together. The optimal plan costs more search than GBFS but substantially fewer plan actions. The extended plan is also longer than the base optimal plan (40 vs. 25 actions) because it includes two additional rocks and the storm detour to SiteB/SiteD.

---

### Q2. How does the optimal plan use the two storage bays, and when is the drill picked up?

**Drill acquisition (base A* plan, steps 9–12):**  
The optimal base plan visits SiteE via Base→SiteA→SiteC→SiteE and picks up the drill at step 12 (the A* plan shown in `planner_output.txt`). Both hard rocks require the drill before collection; acquiring it before visiting SiteF and SiteC avoids a separate trip to SiteE.

**Two-bay utilisation:**

| Steps | Bay1 | Bay2 | Description |
|-------|------|------|-------------|
| 2 | Rock2 | — | collect-soft Rock2 at SiteB |
| 4 | Rock2 | Rock4 | collect-soft Rock4 at SiteD → both bays full |
| 7–8 | ∅ | ∅ | deposit Rock2 and Rock4 at Base |
| 14 | Rock5 | — | collect-hard Rock5 at SiteF after picking up the drill |
| 17 | Rock5 | Rock3 | collect-hard Rock3 at SiteC → both bays full |
| 20, 25 | ∅ | ∅ | deposit Rock5 and Rock3 at Base |

The action numbers above refer to the optimal A* plan in `planner_output.txt`.

**Key insight:** The optimal base plan uses both bays to carry Rock2 and Rock4 in one trip, then Rock5 and Rock3 in another. It also collects the two hard rocks in a single excursion after picking up the drill.

---

### Q3. Extended scenario: how does the rover reach SiteB and SiteD after the dust storm? Is the one-way SiteC→SiteD slope used?

#### Topology change

The dust storm removes the **Base↔SiteB** bidirectional link. In the base scenario, SiteB and SiteD are reached cheaply:
- SiteB: Base→SiteB (1 move)
- SiteD: Base→SiteB→SiteD (2 moves)

In the extended scenario neither of these paths exists.

#### How the rover reaches SiteD

The extended A* plan uses the **one-way SiteC→SiteD slope** at step 3 of the extended A* action sequence:

```
Base → SiteA → SiteC → SiteD    (3 moves, using the one-way slope)
```

This is the route used by the submitted plan. The slope is strictly one-way (SiteC→SiteD only), so the rover **cannot return via SiteD→SiteC**. Instead, it exits via:

```
SiteD → SiteE → SiteC    (2 moves back toward the main network)
```

The slope is not the only possible route to SiteD: the map also allows SiteC→SiteE→SiteD using the two bidirectional links SiteC↔SiteE and SiteD↔SiteE. The slope gives the submitted plan a shorter route.

#### How the rover reaches SiteB

Since Base↔SiteB is blocked, the submitted extended A* plan reaches SiteB through SiteD (steps 1–6 in its action sequence):

```
Base → SiteA → SiteC → SiteD → SiteB    (4 moves)
```

The one-way SiteC→SiteD slope is used here as well (step 3). After collecting Rock2 at SiteB, the rover exits via:

```
SiteB → SiteD → SiteE → SiteC → SiteA → Base    (5 moves)
```

#### Summary

| Route | Base Scenario | Extended Scenario |
|-------|--------------|-------------------|
| Base → SiteB | Base→SiteB (1 move) | Base→SiteA→SiteC→SiteD→SiteB (4 moves) |
| Base → SiteD | Base→SiteB→SiteD (2 moves) | Base→SiteA→SiteC→SiteD (3 moves, one-way slope) |
| Return after collecting SiteD and SiteB rocks | SiteD→SiteB→Base (2 moves) | SiteB→SiteD→SiteE→SiteC→SiteA→Base (5 moves) |

The one-way SiteC→SiteD slope is **used by the submitted plan** and shortens its route to SiteD and SiteB. It is not strictly necessary for reachability: without it, the rover could travel Base→SiteA→SiteC→SiteE→SiteD→SiteB, then return through SiteD→SiteE→SiteC→SiteA→Base. Thus Rock2 and Rock4 remain reachable via the two-way SiteC↔SiteE and SiteD↔SiteE links.

---

## Planner Notes

- **BFS** (base scenario) and **A*** with an admissible heuristic (both scenarios) provide optimal plans; the full results are in `planner_output.txt`.
- **Greedy BFS (GBFS)** is satisficing, not optimal; its plans are included for comparison.
- Goal checks for each planner run are recorded in `planner_output.txt`.
