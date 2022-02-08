# Description

Given a series of constraints, the program must find an optimal assignment of each given insurance referee to each given case. Each referee and case are given with a set of attributes:

## Referee Attributes
Referees are given in the form *referee(rid, type, maximum workload, previous workload, previous payment)*
- Referee Identification Number (rid): A nonnegative integer unique to each adjudicator.
- Type: A String denoting the type of referee, this can either be *internal* or *external*.
- Maximum Workload: An integer in the range of [0, 720], setting a limit to the number of minutes worked a day.
- Previous Workload: An integer representing the number of minutes worked thus far.
- Previous Payment: An integer representing the sum of payments made to this referee (only for *external* referees, 0 for *internal*).

## Case Attributes
Cases are given in the form *case(cid, type, effort, damage, postal code, payment)*
- Case Identification Number (cid): A unique nonnegative integer for each case.
- Type: A String denoting the type of vehicle involved in the case (e.g. *truck*, *van*, etc.).
- Effort: Expected number of minutes needed to work a case.
- Damage: An integer that defines the amount of damage (in Euros).
- Postal Code: Location of the case.
- Payment: How much an *external* referee would be paid for working this case.

There is also a set maximum for the damage sustained in a case. Should the damage threshold be exceeded, the case may only be assigned to *internal* referees.

## Preferences
Additionally, there are Preference Rules we may specify:
### Location Preference
Given in the form *prefRegion(rid, postal code, pref)*

A referee may be given a preference of a location denoted by an integer in [0, 3]. If 0, the referee specified in rid cannot work any case in the given postal code.

### Type Preference
Given in the form *prefType(rid, case type, pref)*

A referee may be given a preference of a case vehicle type, denoted by an integer in [0, 3]. IF 0, the referee specified in rid cannot work any case with the given type.

# Constraints
A set of hard and weak constraints were vital for the completion of this solution:

## Hard Constraints
These are strict rules that cannot be violated in an optimal solution.
- A referee cannot be assigned a case if the expected effort would exceed that referee's maximum workload.
- A case cannot be assigned to a referee with preference 0 for the case's postal code location.
- A case cannot be assigned to a referee with preference 0 for the case's given type.
- Cases that exceed the maximum damage threshold must be given only to *internal* referees.

## Weak Constraints
These constraints should be followed as close as possible, but may be broken if necessary. Doing so incurs a **cost**, which is minimized in an optimal solution.
- *Internal* referees are preferred during case assignment over *external* referees.
- Case assignment to *external* referees should be done so that the overall payment between them is **balanced**.
- The assignment to all referees should be such that the overall workload is **balanced**.
- Referees with a higher preference for a given region should be considered for assignment over those with lower preference.
- Referees with a higher preference for a given case type should be considered for assignment over those with lower preference.

# Outcome
The expected result for a given instance is a set of rule(s) of the form *assign(cid, rid)*, where cid is the case identification number and rid is the referee identification number. This ruleset should be an optimal solution, minimizing costs incurred by the constraints.

