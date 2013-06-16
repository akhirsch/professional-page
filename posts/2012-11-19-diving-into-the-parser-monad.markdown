---
title: Diving Into the Parser Monad
author: Andrew Hirsch
---

So, in my other post today I've noted that I've spent some time diving into the Parser monad. 
In particular, I have two ADTs, `Sig` and `Sig'`, with `Sig :<: Sig'`, and I want to use a parser for `Sig`s to define a parser for `Sig'`s. 
So, let's take a look at the definitions for `Parser` in Parsec2.

```haskell
data Parser a = GenParser Char () a
    
newtype GenParser tok st a = Parser (State tok st -> Consumed (Reply tok st a))
   
data Consumed a = Consumed a
                | Empty !a
		    
data Reply tok st a = Ok !a !(State tok st) ParseError
                    | Error ParseError

data State tok st = State { stateInput :: [tok]
                          , statePos   :: !SourcePos
                          , stateUser  :: !st
                          }
```

So what does this mean? A Parser is a parser for characters, that holds no state structure, and returns an `a`. A generic parser is a function from a state to a reply. A reply carries an `a` and some state. State has a stream of tokens and a position in that stream, as well as a piece of state structure.

So, is it possible to use this to create a parser the way I want to? There doesn't seem to be a simple solution. However, the state data structure is unused in most parsers: it may very well be possible to use it in creating this sort of parser.