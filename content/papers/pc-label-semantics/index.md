+++
title = "Giving Semantics to Program-Counter Labels via Secure Effects"
authors = ["Andrew K. Hirsch"]
date= 2021-01-04
[taxonomies]
area=["Effects", "IFC"]
awards=[]
projects=[]
[extra]
publishedin="POPL 2021"
paperauthors=["<b>Andrew K. Hirsch</b>", "Ethan Cecchetti"]
abstract="Type systems designed for information-flow control commonly use a program-counter label to track the sensitivity of the context and rule out data leakage arising from effectful computation in a sensitive context. Currently, type-system designers reason about this label informally except in security proofs, where they use ad-hoc techniques. We develop a framework based on monadic semantics for effects to give semantics to program-counter labels. This framework leads to three results about program-counter labels. First, we develop a new proof technique for noninterference, the core security theorem for information-flow control in effectful languages. Second, we unify notions of security for different types of effects, including state, exceptions, and nontermination. Finally, we formalize the folklore that program-counter labels are a lower bound on effects. We show that, while not universally true, this folklore has a good semantic foundation."
+++

# Talk Video 
<iframe width="560" height="315" src="https://www.youtube.com/embed/FdTOpn973os?si=kWomGOSJy0cUlxfh" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

# Links
* [Official Version](https://dl.acm.org/doi/10.1145/3434316)
* [Preprint](Giving_Semantics_to_Program-Counter_Labels_via_Secure_Effects.pdf)
* [Technical Report](Giving_Semantics_to_Program-Counter_Labels_via_Secure_Effects_TR.pdf)

