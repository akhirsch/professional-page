+++
title = "Compositional Security Definitions for Higher-Order Where Declassifcation"
authors = ["Andrew K. Hirsch"]
date= 2023-04-06
[taxonomies]
area=["IFC"]
awards=[]
projects=[]
[extra]
publishedin="OOPSLA 2023"
paperauthors=["Jan Menz", "<b>Andrew K. Hirsch</b>", "Peixuan Li", "Deepak Garg"]
abstract="To ensure programs do not leak private data, we often want to be able to provide formal guarantees ensuring such data is handled correctly. Often, we cannot keep such data secret entirely; instead programmers specify how private data may be declassified. While security definitions for declassification exist, they mostly do not handle higher-order programs. In fact, in the higher-order setting no compositional security definition exists for intensional information-flow properties such as where declassification, which allows declassification in specific parts of a program. We use logical relations to build a model (and thus security definition) of where declassification. The key insight required for our model is that we must stop enforcing indistinguishability once a relevant declassification has occurred. We show that the resulting security definition provides more security than the most related previous definition, which is for the lower-order setting."
+++

# Talk Video 
<iframe width="560" height="315" src="https://www.youtube.com/embed/NLzJOd8Hxt4?si=UN2EMfp1bfGzlDZx" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

# Links
* [Official Version](https://dl.acm.org/doi/10.1145/3586041)
* [Preprint](Compositional_Security_Definitions_for_Higher-Order_Where_Declassification.pdf)
* [Preprint (MPI-SWS Version)](https://gitlab.mpi-sws.org/FCS/lambda-whr/-/raw/main/paper.pdf)
* [Technical Report](Compositional_Security_Definitions_for_Higher-Order_Where_Declassification_TR.pdf)
* [Technical Report (MPI-SWS Version)](https://gitlab.mpi-sws.org/FCS/lambda-whr/-/raw/main/Technical_Appendix.pdf)

