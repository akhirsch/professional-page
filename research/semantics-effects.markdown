---
title: Semantics of Type-And-Effect Systems
---

Effects are ubiquitous in programming languages.
Ever since Moggi introduced monads in his computational lambda calculus,
there have been generalizations and reformulations of categorical semantics of effect systems.
Ross Tate discovered productors, the most general semantics for a large class of effects.
I have been working on expanding the theory of productors (and consumptors, their dual).

I recently submitted my first paper in this project.
A preprint can be found in my [publications](/publications.html).
It describes how evaluation order can be derived from effects.
In particular, the outcome of competition of the effects of discarding input and refusing to output create strictness and laziness.
