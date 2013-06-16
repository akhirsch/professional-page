I've recently gotten my hands on Abadi and Cardelli's "A Theory of Objects". 
In it, they produce an interesting calculus for object-oriented languages.
I give a haskell version, below.
This post is literate haskell.
Get it [here](/posts/2013-06-15-sigma-calculus.lhs).


I'm going to start out with some general haskell boilerplate.

>module Sigma where 
> 
>  import Data.List
>  import Data.Char

Now, we're going to define variables and labels.
We define both to be just strings, this makes for easier printing later.
We also define `Show` instances for both of these, for the same reason.
  
>  data Var = Var String
>           deriving Eq
>  data Label = Label String
>               deriving Eq
>  
>  instance Show Var where
>    show (Var s) = s
>    
>  instance Show Label where
>    show (Label s) = s

A method, much like a function in the lambda-calculus, is something with a variable
and a term in which that variable may be free.
The difference is, that we expect that a method is provided the object in which it resides as an argument.
That is, the heart of object orientation, from Abadi and Cardelli's point of view, is *self-application*.

We write this similarly to a lambda function as well, except we use ς instead.
This is the Greek letter sigma, in final word form.
  
>  data Method = Method Var SigmaTerm
>              deriving Eq
>  
>  instance Show Method where
>    show (Method v a) = "ς(" ++ show v ++ ")" ++ show a

Now, a Sigma term can be one of 4 things.

First, it can be a variable.
  
>  data SigmaTerm = SigmaVar Var

Secondly, it can be an object.
We view objects as a listing of methods, with labels for those methods.

>                 | Object [(Label, Method)]

We can call methods by providing the label.

>                 | MethodCall SigmaTerm Label

Finally, we can replace a method with another.
Again, we note the method with its label.

>                 | Replacement SigmaTerm Label Method

We derive an Eq form for convinience sake.

>                 deriving Eq

To write terms, we do things in much the same way as is common in object oriented languages in the wild.
The difference is in replacement, which doesn't have a standard way of doing things,
and objects themselves, which are usually not written in languages in the wild.
                          
>  instance Show SigmaTerm where

Variables are written just as strings.

>    show (SigmaVar v) = show v

Objects are written in list format.
We write `l = m` for a method `m` with label `l`.

>    show (Object ms) = "[" ++ (concat $ 
>                               (intersperse "," 
>                               (map (\(l,m) -> show l ++ "=" ++ show m) ms))) 
>                           ++ "]"

We write method calls with the standard `.` syntax. 
Since replacements are visually complicated, we wrap them in parentheses.

>    show (MethodCall a l) = (show' a) ++ "." ++ (show l)
>      where show' a'@(Replacement _ _ _) = "(" ++ show a' ++ ")"
>            show' a' = show a'

Replacements are written with the form `a.l⇐m`, where `a` is an object, `l` is a label, and `m` is a method.

>    show (Replacement a l m) = (show a) ++ "." ++ (show l) ++ "⇐" ++ (show m)

We now look at determining free variables.
We have to use two functions because we seperated methods from terms;
this is going to be a common theme in this post.

We remove all instances of the variable `v` from the free variables in a method.
This makes sense, since the method binds `v`.
The way we determine free variables for terms is obvious.
                   
>  freeVariablesInMethod :: Method -> [Var]
>  freeVariablesInMethod (Method v st) = delete v (nub . freeVariables $ st)
>                   
>  freeVariables :: SigmaTerm -> [Var]
>  freeVariables (SigmaVar v) = [v]
>  freeVariables (Object l) = concatMap (\(_,m) -> freeVariablesInMethod m) l
>  freeVariables (MethodCall a _) = freeVariables a
>  freeVariables (Replacement a _ m) = (freeVariables a) ++ (freeVariablesInMethod m)


We define the semantics of our calculus via a function outcome.
This is rather obvious, especially the first two terms.
Note that it is possible to write failing terms, which we represent by the use of `Maybe`.

>  outcome :: SigmaTerm -> Maybe SigmaTerm
>  outcome (SigmaVar v) = Just (SigmaVar v)
>  outcome (Object l) = Just (Object l)

A method call looks up the method that is being called.
Then, it performs something similar to the standard β-reduction from lambda calculus.
However, it provides the method with the object in which it is obtained.
This is the self-application I talked about earlier.
It's also where we model dynamic dispatch in the calculus.

>  outcome (MethodCall a l) = let o = outcome a in
>    case o of
>      Just (Object ms) -> case lookup l ms of
>        Just (Method v m) -> Just (subst m v (Object ms))
>        Nothing -> Nothing
>      _ -> Nothing

Replacement simply does functional replacement on methods.
That is, it looks up the label in the object, and creates a new object with the new method bound to that label.

>  outcome (Replacement a l m) = let o = outcome a in 
>    case o of
>      Just (Object ms) -> Just . Object $ map (\(li,mi) -> if li == l
>                                                           then (li, m)
>                                                           else (li, mi)) ms
>      _ -> Nothing

Note that this requires the notion of subsitution.
However, the notion of subsitution here is rather uninspiring to a student of the lambda calculus. 
I give the definition here for the code, and for interested parties to study.
  
>  substInMethod :: Method -> Var -> SigmaTerm -> Method
>  substInMethod (Method v st) v1 a = if v == v1 
>                               then let v' = Var [
>                                              (chr . sum . (concatMap 
>                                                            (\(Var v'') -> map ord v'')) 
>                                           $ freeVariablesInMethod (Method v st))]
>                                    in 
>                                     Method v' (subst (subst st v (SigmaVar v')) v1 a)
>                               else Method v (subst st v1 a)
>                                    
>  subst :: SigmaTerm -> Var -> SigmaTerm -> SigmaTerm
>  subst (SigmaVar v) v' a = if v == v' then a else SigmaVar v
>  subst (Object l) v a = Object $ map (\(label, m) -> (label, substInMethod m v a)) l
>  subst (MethodCall a l) v b = MethodCall (subst a v b) l
>  subst (Replacement a l m) v b = Replacement (subst a v b) l (substInMethod m v a)

I hope that you will see me posting more on this calculus in the near future.  
In particular, I want to continue to explore its semantics and its relationship with the lambda calculus.
I also want to explore how it models object systems in the wild.
My facts will probably either (a) not be research-level material, such as this haskell implementation, or
(b) come straight from Abadi & Cardelli.
I highly recommend looking up the details if you are interested.
