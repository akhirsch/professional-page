---
papertitle: Gradual Typing for Functional Languages
pdfurl: http://www.cs.colorado.edu/~siek/pubs/pubs/2006/siek06:_gradual.pdf
paperauthor: Jeremy G. Siek and Walid Taha
leader: Fabian Mühlböck
semester: 2014sp
date: February 24, 2014
---

Static and dynamic type systems have well-known strengths and weaknesses, and each is better suited for different programming tasks. 
There have been many efforts to integrate static and dynamic typing and thereby combine the benefits of both typing disciplines in the same language. 
The flexibility of static typing can be improved by adding a type Dynamic and a typecase form. 
The safetyand performance of dynamic typing can be improved by adding optional type annotations or by performing type inference (as in soft typing). 
However, there has been little formal work on type systems that allow a programmer-controlled migration between dynamic and static typing. 
Thatte proposed Quasi-Static Typing, but it does not statically catch all type errors in completely annotated programs. 
Anderson and Drossopoulou defined a nominal type system for an object-oriented language with optional type annotations. 
However, developing a sound, gradual type system for functional languages with structural types is an open problem.
In this paper we present a solution based on the intuition that the structure of a type may be partially known/unknown at compile-time 
and the job of the type system is to catch incompatibilities between the known parts of types. 
We define the static and dynamic semantics of a λ-calculus with optional type annotations 
and we prove that its type system is sound with respect to the simply-typed λ-calculus for fully-annotated terms. 
We prove that this calculus is type safe and that the cost of dynamism is “pay-as-you-go”.
