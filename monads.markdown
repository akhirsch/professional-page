---
title: A 5-Minute Monad Tutorial
author: Andrew K. Hirsch
---

In 2012, My friend and colleague Kristopher Micinski challenged folks to write a 5 minute monad tutorial in his blog ([Five Minute Monad Madness](http://www.cs.umd.edu/~micinski/posts/2012-09-22-five-minute-monad-madness.html)).
As far as I'm aware, nobody has taken him up on that challenge.
This is my attempt.

Let's start from the perspective of an effectful program.
In particular, let's think about a program `p` that takes an integer and outputs another integer, but which might return null.
That is, the type of `p` is
```haskell
p : Int -> Int
```
where `p` might return null.

What we want is some way to explicitly represent the fact that the program might return null.
We can do that by modifying only the output type: instead of returning an integer, our `p` might return an integer or some token that represents null.

In some sense, we've now captured the effect.
It's not the case that `p` takes an integer and returns an integer, but might fail and return null.
Instead, `p` takes an integer and returns a thing that might either be an integer or a token.
This is exactly the type `Maybe Int`, where `Maybe` is defined as
```haskell
data Maybe a = Just a
             | Nothing
```
That is, the type of `p` is now
```haskell
p : Int -> Maybe Int.
```

Now, what if we had two programs, `p` and `q`.
As before the type of `p` is
```haskell
p : Int -> Int.
```
`q` has the same type:
```haskell
q : Int -> Int.
```
Either `p` or `q` might return null, however.

Certainly, we can compose `p` and `q`:
```haskell
p;q : Int -> Int.
```
This composed program runs `p` on its input, gets its output (if any) and then runs `q` on that output.
If either `p` or `q` return null, then so does the whole thing.

Now, suppose that we had `p` and `q` with their effects captured.
We want to compose them.
How do we do that?


Note that after capturing the effects of `p` and `q`, we get that they have the types
```haskell
p : Int -> Maybe Int
```
and
```haskell
q : Int -> Maybe Int
```
So we can't feed the output of `p` into `q`, since `q` doesn't know what to do!
We can't compose them directly, since there's a type mismatch now.

Luckily, we can still do something.
We can write the following function, using infix notation:
```haskell
p ;; q x = match p x with
             Just y -> q y
             Nothing -> Nothing
```

Intuitively, this is the same as if we composed `p` and `q` before we captured their effects.
It runs `p`, and then if `p` outputs something that's not null, it runs `q`.

At this point, we've almost created a "world of effectful functions."
We're able to deal with effectful functions by capturing their effects.
After we do the capture, we can still compose.

However, we want to be able to deal with values in this world.
If we have an `Int`, `v`, we can write `Just v` to get a `Maybe Int`.

Now, let's abstract out.
Instead of `p : Int -> Int`
we want to consider`p : A -> B`.
Again `p` is effectful.
However, this time we don't know what effect `p` might have.

We want to be able to transform `p`'s output type.
Assume that `M` is a transformation of types.
We also assume that we can capture the effects of `p` to get `p : A -> M(B)`.

Consider `p : A -> B` and `q : B -> C`, both of which are effectful.
After capturing the effects, we have
`p : A -> M(B)`, and `q : B -> M(C)`.
We need a way to compute the composition of `p` and `q` after capturing
This means we need a function
```haskell
;; : (A -> M(B)) -> (B -> M(C)) -> A -> M(C)
```
To deal with values, we also need a `return` function
```haskell
return : A -> M(A).
```

At this point, you might be asking "So what about this `>>=` thing I keep hearing about?"
Recall the type of `>>=`:
```haskell
>>= : M(A) -> (A -> M(B)) -> M(B)
```
We can write `>>=` as
```haskell
m >>= f = (id;;f) m.
```
Conversely, we can write `;;` given `>>=`:
```haskell
p;;q x = (p x) >>= q.
```
So, Haskell's bind is equivalent to our composition operator.

Now we have a notion of composition for effectful programs.
However, we want to make sure that this notion is "right."

In particular, we want, for any appropriate `p`,`q`, and `r`,
```
(p;;q);;r = p;;(q;;r)
```
If we unfold the definition of `;;` we had above, we get
```
(\x -> r x >>= (\y -> q y >>= p)) = (\x -> (r x >>= q) >>= p),
```
which is one of the monad laws.

We also want `return` to act as an identity on `;;`.
That is, we want that
```
return;;f = f = f;;return.
```
Again, unfolding `;;` as above, we get
``` haskell
(\x -> f x >>= return) = (\x -> f x)
```
and
``` haskell
(\x -> return x >>= f) = (\x -> f x).
```
These three laws we've derived above are exactly the monad laws given in [The Haskell Wiki](https://wiki.haskell.org/Monad).

This, in my opinion, is the best way to think about monads.
They are about capturing effects, making function pure, and doing so in a composable way.
The monad laws just say that `;;` acts like composition (is associative) and that `return` is an identity for `;;`.

