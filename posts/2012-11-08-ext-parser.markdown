---
title: Fully Functional Extensible Parsers
author: Andrew Hirsch
---

For my senior design project, I have taken over a code base known as Pony. 
Pony is a compiler; but there's a twist: Pony doesn't compile a single language, rather it compiles _to_ a single language: ANSI C. 
The idea is that Pony would, by default, compile ANSI C to ANSI C, but allow users to specify additions and changes to C, and compile those back into C itself. 
Pony should also allow users to specify how to compile a completely different language, say scheme, into C.

Two years ago, Patrick Thompson (now of Apple Computers), created Pony and defined how transformations into C could be written. 
He has also written a parser for ANSI C, with the possibility of adding in new operators. 
The problem comes when more complex syntactic transformations need to take place: for example when we want to add class-based objects to C. 
For this, we need some form of extensible compiler.

For various reasons (not excluding preferences, but including ease of verification), Pony is entirely written in Haskell. 
After some searching, my professor and I have not discovered anybody who claims to have written an extensible parser in Haskell. 
So, this has become the first job of my senior design.

We have decided to make the Abstract Syntax Trees that we parse into composable, using the [Compdata library](http://hackage.haskell.org/package/compdata). 
This allows us to extend the AST in exactly the way that we want. Now, we simply have to write a parser for these trees.

There are generally two standard ways to write parsers in Haskell: [Happy](http://www.haskell.org/happy/), which is a standard parser generator like yacc; and [Parsec](http://www.haskell.org/haskellwiki/Parsec), which is a parser combinator library. 
Since we want to build things on the fly, Parsec seemed the obvious choice.

The first attempt at a parser seemed to go well. 
We were able to write a simple calculator, with AST `Sig`, and an extension, with AST `Sig'`. 
Then, we were able to write a parser for `Term Sig` rather easily, and then we were able to write a parser for `Term Sig'` as follows:

```haskell
Sig'Parser :: Parser (Term Sig')  
Sig'Parser = MultParser <|> do  
  sig <- SigParser  
  return $ deepInject2 sig  
```

Where `SigParser` was the parser for `Term Sig` and `MultParser` was the parser for the extension.

Perhaps, you can already see the problem here. 
We did not at first, as it compiled and ran fine on the input we were giving it. 
We gave it the input "* + 3 2 4", because the parser was pre-order. 
In this case it worked perfectly, but then we gave it slightly different input: "+ * 3 2 4". The result?

No parse.

To see why this is, you must look at the definition of `Sig'Parser`. 
Since we are parsing something that is not a multiplication, it must be something of type `Sig`. 
Since `Sig` only knows how to add, the `Sig` parser choked when given something that had a multiplaction symbol.

Now, I am playing with solutions to this problem. 
I think that the solution is going to be to go into the Parsec monad and see if we can build something that is compositional within the monad. 
This will probably spawn more posts as I work on it. 
However, even in the case where that doesn't happen, we still have the step-aside solution of Template Haskell.

Long story short, programming fully functional extensible parsers is not easy.