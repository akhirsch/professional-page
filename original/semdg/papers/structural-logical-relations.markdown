---
papertitle: Structural Logical Relations with Case Analysis and Equality Reasoning
paperauthor: Ulrik Rasmussen and Andrzej Filinski
pdfurl: http://utr.dk/pubs/files/rasmussen2013a-0-paper.pdf
leader: Ulrik Rasmussen
semester: 2014sp
date: March 03, 2014
---

Formalizing proofs by logical relations in the Twelf proof assistant is known to be notoriously diffcult. 
However, as demonstrated by Schürmann and Sarnat [In Proc. of 23rd Symp. on Logic in Computer Science, 2008] 
such proofs can be represented and veriﬁed in Twelf if done so using a Gentzen-style auxiliary assertion logic which is subsequently proved consistent via cut elimination.
We demonstrate in this paper an application of the above methodology to proofs of observational equivalence between expressions in a simply typed lambda calculus with a call-by-name operational semantics. 
Our use case requires the assertion logic to be extended with reasoning principles not present in the original presentation of the formalization method. 
We address this by generalizing the assertion logic to include dependent sorts, and demonstrate that the original cut elimination proof continues to apply without modiﬁcation.
