---
title: Parsing Without Tying the Recursive Knot
author: Andrew Hirsch
---

I'm continuing in my exploration of fully-functional extensible parsing. In particular, I've spent some time diving in to the Parser monad from Parsec 2, and I've defined the problem I've been having.

If you've ever taken a look at _Data Types a la Carte_ by Wouter Sweirstra, then you know that it defines /Terms/ as follows:

```haskell
-- Term f :: (* -> *) -> *
data Term f = f (Term f)
```

In other words, `Term` calculates the fixed point of the functor `f`. Sweirstra refers to this as "tying the recursive knot". The secret to the paper, is to give ADTs as sums of functors (where the sum of two functors is a functor), then tie the recursive know over the entire structure. The sum of two functors is given as 

```haskell
data f :+: g = inl f
             | inr g

instance (Functor f, Functor g) => Functor f :+: g where
  fmap (inl f) e = inl (fmap f e)
  fmap (inr g) e = inr (fmap g e)
```

The difficulty comes when parsing. In particular, we need to parse into some closed datatype. In particular, you can think of the "untied" ADTs as not having a shape, and tying the knot as giving them shape. Parsing gives a shape to some text as data, and thus it needs some shaped data structure to parse into. However, if we give a shape to the data structure, then we cannot then add more pieces to it.

Then, the question becomes, can we parse into an unshaped data structure? It's easy enough to imagine a parser for the `Add` functor:

```haskell
   ParseAdd :: Parser e -> Parser (Add e)
   ParseAdd p = do
     char '+'
     spaces
     s1 <- p
     spaces
     s2 <- p
     spaces
     return $ Add s1 s2
```

Then, the question becomes, can we define a parser for `Term Add` using this parser for `Add e`? One can imagine it might look something like

```haskell
 AddParser :: Parser (Term Add)
 AddParser = fix ParseAdd
```

However, this would give an error: `fix` has the type `(a -> a) -> a`, however, `Parser e` obviously does not equal `Parser (Add e)`. What can we do then?

It is this question that I'm currently working on.