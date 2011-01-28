------------------------------------------------------------------------
-- Equivalences
------------------------------------------------------------------------

{-# OPTIONS --without-K --universe-polymorphism #-}

module Equivalence where

open import Prelude as P using (_⊔_) renaming (_∘_ to _⊚_)

-- A ⇔ B means that A and B are equivalent.

record _⇔_ {f t} (From : Set f) (To : Set t) : Set (f ⊔ t) where
  constructor equivalent
  field
    to   : From → To
    from : To → From

-- _⇔_ is an equivalence relation.

id : ∀ {a} {A : Set a} → A ⇔ A
id = record
  { to   = P.id
  ; from = P.id
  }

inverse : ∀ {a b} {A : Set a} {B : Set b} → A ⇔ B → B ⇔ A
inverse A⇔B = record
  { to               = from
  ; from             = to
  } where open _⇔_ A⇔B

infixr 9 _∘_

_∘_ : ∀ {a b c} {A : Set a} {B : Set b} {C : Set c} →
      B ⇔ C → A ⇔ B → A ⇔ C
f ∘ g = record
  { to   = to   f ⊚ to   g
  ; from = from g ⊚ from f
  } where open _⇔_
