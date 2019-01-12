---
title: Belief Semantics Authorization Logic
---

Authorization logics are logics for describing authorization in (distributed) computing systems.
In particular, authorization logics have *principals*, which represent the different parts of the computing system,
and a modality for each, often written with `A says`, where `A` is a principal.
Thus, we can say `A says φ` when `φ` is a sentence that `A` believes to be true.
What makes authorization logics different from standard modal logics in the inclusion of a `speaks for` connective
among principals, where `A speaks for B` if, whenever `A` believes a sentence, so does `B`.
This allows for delegation among principals in a system.

My work in authorization logics is listed below:

- [Nexus Authorization Logic (NAL): Logical Results](/pubs/nal_logical_results.html)
With Michael Clarkson.
Published as a George Washington Unviersity Technical Report, 2012.

- [Belief Semantics of Authorization Logics](/pubs/belief_semantics_authorization_logics.html)
With Michael Clarkson
Published in Computer and Communication Security, 2013.
