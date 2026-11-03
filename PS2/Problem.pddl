(define (problem mars-mission-base)
  (:domain mars-rover)
  (:objects
    Curiosity - rover
    Base SiteA SiteB SiteC SiteD SiteE SiteF - loc
    Rock1 Rock2 Rock3 Rock4 Rock5 - rock
    Bay1 Bay2 - bay
    Drill1 - drill
  )

  (:init
    (at-rover Curiosity Base)
    (at-drill Drill1 SiteE)

    (at-rock Rock1 SiteA)
    (at-rock Rock2 SiteB)
    (at-rock Rock3 SiteC)
    (at-rock Rock4 SiteD)
    (at-rock Rock5 SiteF)

    (soft Rock1)
    (soft Rock2)
    (hard Rock3)
    (soft Rock4)
    (hard Rock5)

    (empty Bay1)
    (empty Bay2)

    (linked Base SiteA)
    (linked SiteA Base)
    (linked Base SiteB)
    (linked SiteB Base)
    (linked SiteA SiteC)
    (linked SiteC SiteA)
    (linked SiteB SiteD)
    (linked SiteD SiteB)
    (linked SiteC SiteE)
    (linked SiteE SiteC)
    (linked SiteD SiteE)
    (linked SiteE SiteD)
    (linked SiteE SiteF)
    (linked SiteF SiteE)

    (linked SiteC SiteD)
  )

  (:goal
    (and
      (at-rock Rock1 Base)
      (at-rock Rock2 Base)
      (at-rock Rock3 Base)
      (at-rock Rock4 Base)
      (at-rock Rock5 Base)
      (empty Bay1)
      (empty Bay2)
      (at-rover Curiosity Base)
    )
  )
)
