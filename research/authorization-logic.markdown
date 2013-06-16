---
Title: Authorization Logic
---

Authorization logics are logics for describing authorization in (distributed) computing systems.
In particular, authorization logics have *principals*, which represent the different parts of the computing system,
and a modality for each, often written with `A says`, where `A` is a principal.
Thus, we can say `A says φ` when `φ` is a sentence that `A` believes to be true.
What makes authorization logics different from standard modal logics in the inclusion of a `speaks for` connective
among principals, where `A speaks for B` if, whenever `A` believes a sentence, so does `B`.
This allows for delegation among principals in a system.

My work in authorization logics, all with Michael Clarkson, is listed below:

- [Nexus Authorization Logic (NAL): Logical Results](http://arxiv.org/abs/1211.3700)

Here, we work to give formal Kripke semantics to the Nexus Authorization Logic (NAL).
NAL is used in the Nexus Operating System, developed at Cornell University.
The Kripke semantics is also formalized in Coq.
This is a technical report.

- [Belief Semantics of Authorization Logics](http://arxiv.org/abs/1302.2123)

Here, we work to give a more intuitive semantics to authorization logics.
We equip each principal with a set of beliefs that it has. 
We show that this is equivalent to Kripke semantics, in the sense that it is 
always possible to construct a belief structure for any Kripke structure,
such that they validate the same formulas.

An updated version of this is under submission.