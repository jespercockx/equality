------------------------------------------------------------------------
-- Support for sized types
------------------------------------------------------------------------

{-# OPTIONS --without-K --safe --sized-types #-}

module Prelude.Size where

open import Prelude

-- Size primitives.

open import Agda.Builtin.Size public
  using (Size; Size<_; ∞)
  renaming (SizeUniv to Size-universe; ↑_ to ssuc)

-- If S is a type in the size universe, then S in-type is a type in
-- Type.

record _in-type (S : Size-universe) : Type where
  field
    size : S

open _in-type public
