(define (domain mars-rover)
  (:requirements :strips :typing)
  (:types rover loc rock bay drill)

  (:predicates
    (at-rover ?r - rover ?l - loc)
    (at-rock ?k - rock ?l - loc)
    (at-drill ?d - drill ?l - loc)
    (linked ?x - loc ?y - loc)
    (empty ?b - bay)
    (in-bay ?k - rock ?b - bay)
    (has-drill ?r - rover)
    (soft ?k - rock)
    (hard ?k - rock)
  )

  (:action move
    :parameters (?r - rover ?x - loc ?y - loc)
    :precondition (and (at-rover ?r ?x) (linked ?x ?y))
    :effect (and (at-rover ?r ?y) (not (at-rover ?r ?x)))
  )

  (:action pick-drill
    :parameters (?r - rover ?d - drill ?l - loc)
    :precondition (and (at-rover ?r ?l) (at-drill ?d ?l))
    :effect (and (has-drill ?r) (not (at-drill ?d ?l)))
  )

  (:action collect-soft
    :parameters (?r - rover ?k - rock ?b - bay ?l - loc)
    :precondition (and (at-rover ?r ?l) (at-rock ?k ?l) (empty ?b) (soft ?k))
    :effect (and (in-bay ?k ?b) (not (at-rock ?k ?l)) (not (empty ?b)))
  )

  (:action collect-hard
    :parameters (?r - rover ?k - rock ?b - bay ?l - loc)
    :precondition (and (at-rover ?r ?l) (at-rock ?k ?l) (empty ?b) (hard ?k) (has-drill ?r))
    :effect (and (in-bay ?k ?b) (not (at-rock ?k ?l)) (not (empty ?b)))
  )

  (:action deposit
    :parameters (?r - rover ?k - rock ?b - bay ?l - loc)
    :precondition (and (at-rover ?r ?l) (in-bay ?k ?b))
    :effect (and (at-rock ?k ?l) (empty ?b) (not (in-bay ?k ?b)))
  )
)
