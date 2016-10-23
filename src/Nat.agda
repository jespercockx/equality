------------------------------------------------------------------------
-- Some definitions related to and properties of natural numbers
------------------------------------------------------------------------

{-# OPTIONS --without-K #-}

open import Equality

module Nat
  {reflexive} (eq : ∀ {a p} → Equality-with-J a p reflexive) where

open import Prelude

open Derived-definitions-and-properties eq

------------------------------------------------------------------------
-- Equality of natural numbers is decidable

-- Inhabited only for zero.

Zero : ℕ → Set
Zero zero    = ⊤
Zero (suc n) = ⊥

-- Predecessor (except if the argument is zero).

pred : ℕ → ℕ
pred zero    = zero
pred (suc n) = n

abstract

  -- Zero is not equal to the successor of any number.

  0≢+ : {n : ℕ} → zero ≢ suc n
  0≢+ 0≡+ = subst Zero 0≡+ tt

-- The suc constructor is cancellative.

cancel-suc : {m n : ℕ} → suc m ≡ suc n → m ≡ n
cancel-suc = cong pred

-- Equality of natural numbers is decidable.

_≟_ : Decidable-equality ℕ
zero  ≟ zero  = yes (refl _)
suc m ≟ suc n = ⊎-map (cong suc) (λ m≢n → m≢n ∘ cancel-suc) (m ≟ n)
zero  ≟ suc n = no 0≢+
suc m ≟ zero  = no (0≢+ ∘ sym)

------------------------------------------------------------------------
-- Properties related to _+_

-- Addition is associative.

+-assoc : ∀ m {n o} → m + (n + o) ≡ (m + n) + o
+-assoc zero    = refl _
+-assoc (suc m) = cong suc (+-assoc m)

-- Zero is a right additive unit.

+-right-identity : ∀ {n} → n + 0 ≡ n
+-right-identity {zero}  = refl 0
+-right-identity {suc _} = cong suc +-right-identity

-- The successor constructor can be moved from one side of _+_ to the
-- other.

suc+≡+suc : ∀ m {n} → suc m + n ≡ m + suc n
suc+≡+suc zero    = refl _
suc+≡+suc (suc m) = cong suc (suc+≡+suc m)

-- Addition is commutative.

+-comm : ∀ m {n} → m + n ≡ n + m
+-comm zero        = sym +-right-identity
+-comm (suc m) {n} =
  suc (m + n)  ≡⟨ cong suc (+-comm m) ⟩
  suc (n + m)  ≡⟨ suc+≡+suc n ⟩∎
  n + suc m    ∎

-- A number is not equal to a strictly larger number.

≢1+ : ∀ m {n} → ¬ m ≡ suc (m + n)
≢1+ zero    p = 0≢+ p
≢1+ (suc m) p = ≢1+ m (cancel-suc p)

------------------------------------------------------------------------
-- The usual ordering of the natural numbers, along with some
-- properties

-- The ordering.

infix 4 _≤_ _<_

data _≤_ (m n : ℕ) : Set where
  ≤-refl′ : m ≡ n → m ≤ n
  ≤-step′ : ∀ {k} → m ≤ k → suc k ≡ n → m ≤ n

-- Strict inequality.

_<_ : ℕ → ℕ → Set
m < n = suc m ≤ n

-- Some abbreviations.

≤-refl : ∀ {n} → n ≤ n
≤-refl = ≤-refl′ (refl _)

≤-step : ∀ {m n} → m ≤ n → m ≤ suc n
≤-step m≤n = ≤-step′ m≤n (refl _)

-- _≤_ is transitive.

≤-trans : ∀ {m n o} → m ≤ n → n ≤ o → m ≤ o
≤-trans p (≤-refl′ eq)   = subst (_ ≤_) eq p
≤-trans p (≤-step′ q eq) = ≤-step′ (≤-trans p q) eq

-- "Equational" reasoning combinators.

infix  -1 finally-≤ _∎≤
infixr -2 step-≤ step-≡≤ _≡⟨⟩≤_ step-< _<⟨⟩_

_∎≤ : ∀ n → n ≤ n
_ ∎≤ = ≤-refl

-- For an explanation of why step-≤, step-≡≤ and step-< are defined in
-- this way, see Equality.step-≡.

step-≤ : ∀ m {n o} → n ≤ o → m ≤ n → m ≤ o
step-≤ _ n≤o m≤n = ≤-trans m≤n n≤o

syntax step-≤ m n≤o m≤n = m ≤⟨ m≤n ⟩ n≤o

step-≡≤ : ∀ m {n o} → n ≤ o → m ≡ n → m ≤ o
step-≡≤ _ n≤o m≡n = subst (_≤ _) (sym m≡n) n≤o

syntax step-≡≤ m n≤o m≡n = m ≡⟨ m≡n ⟩≤ n≤o

_≡⟨⟩≤_ : ∀ m {n} → m ≤ n → m ≤ n
_ ≡⟨⟩≤ m≤n = m≤n

finally-≤ : ∀ m n → m ≤ n → m ≤ n
finally-≤ _ _ m≤n = m≤n

syntax finally-≤ m n m≤n = m ≤⟨ m≤n ⟩∎ n ∎≤

step-< : ∀ m {n o} → n ≤ o → m < n → m ≤ o
step-< m {n} {o} n≤o m<n =
  m      ≤⟨ ≤-step ≤-refl ⟩
  suc m  ≤⟨ m<n ⟩
  n      ≤⟨ n≤o ⟩∎
  o      ∎≤

syntax step-< m n≤o m<n = m <⟨ m<n ⟩ n≤o

_<⟨⟩_ : ∀ m {n} → m < n → m ≤ n
_<⟨⟩_ m {n} m<n =
  m      <⟨ ≤-refl ⟩
  suc m  ≤⟨ m<n ⟩∎
  n      ∎≤

-- Some simple lemmas.

zero≤ : ∀ n → zero ≤ n
zero≤ zero    = ≤-refl
zero≤ (suc n) = ≤-step (zero≤ n)

suc≤suc : ∀ {m n} → m ≤ n → suc m ≤ suc n
suc≤suc (≤-refl′ eq)     = ≤-refl′ (cong suc eq)
suc≤suc (≤-step′ m≤n eq) = ≤-step′ (suc≤suc m≤n) (cong suc eq)

suc≤suc⁻¹ : ∀ {m n} → suc m ≤ suc n → m ≤ n
suc≤suc⁻¹ (≤-refl′ eq)   = ≤-refl′ (cancel-suc eq)
suc≤suc⁻¹ (≤-step′ p eq) =
  ≤-trans (≤-step ≤-refl) (subst (_ ≤_) (cancel-suc eq) p)

m≤m+n : ∀ m n → m ≤ m + n
m≤m+n zero    n = zero≤ n
m≤m+n (suc m) n = suc≤suc (m≤m+n m n)

m≤n+m : ∀ m n → m ≤ n + m
m≤n+m m zero    = ≤-refl
m≤n+m m (suc n) = ≤-step (m≤n+m m n)

-- A decision procedure for _≤_.

_≤?_ : Decidable _≤_
zero  ≤? n     = inj₁ (zero≤ n)
suc m ≤? zero  = inj₂ λ { (≤-refl′ eq)   → 0≢+ (sym eq)
                        ; (≤-step′ _ eq) → 0≢+ (sym eq)
                        }
suc m ≤? suc n = ⊎-map suc≤suc (λ m≰n → m≰n ∘ suc≤suc⁻¹) (m ≤? n)

-- If m is not smaller than or equal to n, then n is strictly smaller
-- than m.

≰→> : ∀ {m n} → ¬ m ≤ n → n < m
≰→> {zero}  {n}     p = ⊥-elim (p (zero≤ n))
≰→> {suc m} {zero}  p = suc≤suc (zero≤ m)
≰→> {suc m} {suc n} p = suc≤suc (≰→> (p ∘ suc≤suc))

-- If m is not smaller than or equal to n, then n is smaller than or
-- equal to m.

≰→≥ : ∀ {m n} → ¬ m ≤ n → n ≤ m
≰→≥ p = ≤-trans (≤-step ≤-refl) (≰→> p)

-- _≤_ is total.

total : ∀ m n → m ≤ n ⊎ n ≤ m
total m n = ⊎-map id ≰→≥ (m ≤? n)

-- A variant of total.

≤⊎> : ∀ m n → m ≤ n ⊎ n < m
≤⊎> m n = ⊎-map id ≰→> (m ≤? n)

-- A number is not strictly greater than a smaller (strictly or not)
-- number.

+≮ : ∀ m {n} → ¬ m + n < n
+≮ m {n}     (≤-refl′ q)           = ≢1+ n (n            ≡⟨ sym q ⟩
                                            suc (m + n)  ≡⟨ cong suc (+-comm m) ⟩∎
                                            suc (n + m)  ∎)
+≮ m {zero}  (≤-step′ {k = k} p q) = 0≢+ (0      ≡⟨ sym q ⟩∎
                                          suc k  ∎)
+≮ m {suc n} (≤-step′ {k = k} p q) = +≮ m {n} (suc m + n  ≡⟨ suc+≡+suc m ⟩≤
                                               m + suc n  <⟨ p ⟩
                                               k          ≡⟨ cancel-suc q ⟩≤
                                               n          ∎≤)

-- _<_ is irreflexive.

<-irreflexive : ∀ {n} → ¬ n < n
<-irreflexive = +≮ 0

-- Antisymmetry.

≤-antisymmetric : ∀ {m n} → m ≤ n → n ≤ m → m ≡ n
≤-antisymmetric         (≤-refl′ q₁)             _                        = q₁
≤-antisymmetric         _                        (≤-refl′ q₂)             = sym q₂
≤-antisymmetric {m} {n} (≤-step′ {k = k₁} p₁ q₁) (≤-step′ {k = k₂} p₂ q₂) =
  ⊥-elim (<-irreflexive (
    suc k₁  ≡⟨ q₁ ⟩≤
    n       ≤⟨ p₂ ⟩
    k₂      <⟨⟩
    suc k₂  ≡⟨ q₂ ⟩≤
    m       ≤⟨ p₁ ⟩
    k₁      ∎≤))
