------------------------------------------------------------------------
-- The "circle"
------------------------------------------------------------------------

{-# OPTIONS --cubical --safe #-}

-- Partly following the HoTT book.

-- The module is parametrised by a notion of equality. The higher
-- constructor of the HIT defining the circle uses path equality, but
-- the supplied notion of equality is used for many other things.

import Equality.Path as P

module Circle {e⁺} (eq : ∀ {a p} → P.Equality-with-paths a p e⁺) where

open P.Derived-definitions-and-properties eq hiding (elim)

open import Prelude

open import Bijection equality-with-J as Bijection using (_↔_)
import Bijection P.equality-with-J as PB
open import Equality.Groupoid equality-with-J
open import Equality.Path.Isomorphisms eq
import Equality.Path.Isomorphisms P.equality-with-paths as PI
open import Equality.Tactic equality-with-J hiding (module Eq)
open import Equivalence equality-with-J as Eq using (_≃_)
open import Function-universe equality-with-J as F hiding (id; _∘_)
open import H-level equality-with-J
open import H-level.Closure equality-with-J
open import H-level.Truncation.Propositional eq as Trunc
  using (∥_∥; ∣_∣)
open import Integer equality-with-J as Int using (ℤ; +_; -[1+_])
open import Nat equality-with-J
open import Sphere eq as Sphere using (𝕊)
open import Suspension eq as Suspension
  using (Susp; north; south; meridian)
import Univalence-axiom equality-with-J as Univ

private
  variable
    a p   : Level
    A     : Type p
    P     : A → Type p
    f     : (x : A) → P x
    b ℓ x : A

------------------------------------------------------------------------
-- The type and some eliminators

-- The circle.

data 𝕊¹ : Type where
  base  : 𝕊¹
  loopᴾ : base P.≡ base

loop : base ≡ base
loop = _↔_.from ≡↔≡ loopᴾ

-- A dependent eliminator, expressed using paths.

elimᴾ :
  (P : 𝕊¹ → Type p)
  (b : P base) →
  P.[ (λ i → P (loopᴾ i)) ] b ≡ b →
  (x : 𝕊¹) → P x
elimᴾ P b ℓ base      = b
elimᴾ P b ℓ (loopᴾ i) = ℓ i

-- A non-dependent eliminator, expressed using paths.

recᴾ : (b : A) → b P.≡ b → 𝕊¹ → A
recᴾ = elimᴾ _

-- A dependent eliminator.

elim :
  (P : 𝕊¹ → Type p)
  (b : P base) →
  subst P loop b ≡ b →
  (x : 𝕊¹) → P x
elim P b ℓ = elimᴾ P b (subst≡→[]≡ ℓ)

-- A "computation" rule.

elim-loop : dcong (elim P b ℓ) loop ≡ ℓ
elim-loop = dcong-subst≡→[]≡ (refl _)

-- Every dependent function of type (x : 𝕊¹) → P x can be expressed
-- using elim.

η-elim : f ≡ elim P (f base) (dcong f loop)
η-elim {P = P} {f = f} =
  ⟨ext⟩ $ elim _ (refl _)
    (subst (λ x → f x ≡ elim P (f base) (dcong f loop) x) loop (refl _)  ≡⟨ subst-in-terms-of-trans-and-dcong ⟩

     trans (sym (dcong f loop))
       (trans (cong (subst P loop) (refl _))
          (dcong (elim P (f base) (dcong f loop)) loop))                 ≡⟨ cong (trans (sym (dcong f loop))) $
                                                                            trans (cong (flip trans _) $ cong-refl _) $
                                                                            trans-reflˡ _ ⟩
     trans (sym (dcong f loop))
       (dcong (elim P (f base) (dcong f loop)) loop)                     ≡⟨ cong (trans (sym (dcong f loop))) elim-loop ⟩

     trans (sym (dcong f loop)) (dcong f loop)                           ≡⟨ trans-symˡ _ ⟩∎

     refl _                                                              ∎)

-- A non-dependent eliminator.

rec : (b : A) → b ≡ b → 𝕊¹ → A
rec b ℓ = recᴾ b (_↔_.to ≡↔≡ ℓ)

-- A "computation" rule.

rec-loop : cong (rec b ℓ) loop ≡ ℓ
rec-loop = cong-≡↔≡ (refl _)

-- Every function from 𝕊¹ to A can be expressed using rec.

η-rec : f ≡ rec (f base) (cong f loop)
η-rec {f = f} =
  ⟨ext⟩ $ elim _ (refl _)
    (subst (λ x → f x ≡ rec (f base) (cong f loop) x) loop (refl _)      ≡⟨ subst-in-terms-of-trans-and-cong ⟩

     trans (sym (cong f loop))
       (trans (refl _) (cong (rec (f base) (cong f loop)) loop))         ≡⟨ cong (trans (sym (cong f loop))) $ trans-reflˡ _ ⟩

     trans (sym (cong f loop)) (cong (rec (f base) (cong f loop)) loop)  ≡⟨ cong (trans (sym (cong f loop))) rec-loop ⟩

     trans (sym (cong f loop)) (cong f loop)                             ≡⟨ trans-symˡ _ ⟩∎

     refl _                                                              ∎)

-- An alternative non-dependent eliminator.

rec′ : (b : A) → b ≡ b → 𝕊¹ → A
rec′ {A = A} b ℓ = elim
  (const A)
  b
  (subst (const A) loop b  ≡⟨ subst-const _ ⟩
   b                       ≡⟨ ℓ ⟩∎
   b                       ∎)

-- A "computation" rule.

rec′-loop : cong (rec′ b ℓ) loop ≡ ℓ
rec′-loop = dcong≡→cong≡ elim-loop

------------------------------------------------------------------------
-- Some equivalences

-- The circle can be expressed as a suspension.

𝕊¹≃Susp-Bool : 𝕊¹ ≃ Susp Bool
𝕊¹≃Susp-Bool = Eq.↔→≃ to from to∘from from∘to
  where
  north≡north =
    north  ≡⟨ meridian false ⟩
    south  ≡⟨ sym $ meridian true ⟩∎
    north  ∎

  to : 𝕊¹ → Susp Bool
  to = rec north north≡north

  module From = Suspension.Rec base base (if_then refl base else loop)

  from : Susp Bool → 𝕊¹
  from = From.rec

  to∘from : ∀ x → to (from x) ≡ x
  to∘from = Suspension.elim _
    (to (from north)  ≡⟨⟩
     north            ∎)
    (to (from south)  ≡⟨⟩
     north            ≡⟨ meridian true ⟩∎
     south            ∎)
    (λ b →
       subst (λ x → to (from x) ≡ x) (meridian b) (refl north)  ≡⟨ subst-in-terms-of-trans-and-cong ⟩

       trans (sym (cong (to ∘ from) (meridian b)))
         (trans (refl _) (cong id (meridian b)))                ≡⟨ cong₂ (trans ∘ sym)
                                                                     (trans (sym $ cong-∘ _ _ _) $
                                                                      cong (cong to) From.rec-meridian)
                                                                     (trans (trans-reflˡ _) $
                                                                      sym $ cong-id _) ⟩
       trans (sym (cong to (if b then refl base else loop)))
             (meridian b)                                       ≡⟨ lemma b ⟩∎

       meridian true                                            ∎)
    where
    lemma : (b : Bool) → _ ≡ _
    lemma true  =
      trans (sym (cong to (if true ⦂ Bool then refl base else loop)))
            (meridian true)                                            ≡⟨⟩

      trans (sym (cong to (refl base))) (meridian true)                ≡⟨ prove (Trans (Sym (Cong _ Refl)) (Lift _)) (Lift _) (refl _) ⟩∎

      meridian true                                                    ∎

    lemma false =
      trans (sym (cong to (if false ⦂ Bool then refl base else loop)))
            (meridian false)                                            ≡⟨⟩

      trans (sym (cong to loop)) (meridian false)                       ≡⟨ cong (λ p → trans (sym p) (meridian false)) rec-loop ⟩

      trans (sym north≡north) (meridian false)                          ≡⟨ prove (Trans (Sym (Trans (Lift _) (Sym (Lift _)))) (Lift _))
                                                                                 (Trans (Trans (Lift _) (Sym (Lift _))) (Lift _))
                                                                                 (refl _) ⟩
      trans (trans (meridian true) (sym $ meridian false))
            (meridian false)                                            ≡⟨ trans-[trans-sym]- _ _ ⟩∎

      meridian true                                                     ∎

  from∘to : ∀ x → from (to x) ≡ x
  from∘to = elim _
    (from (to base)  ≡⟨⟩
     base            ∎)
    (subst (λ x → from (to x) ≡ x) loop (refl base)                  ≡⟨ subst-in-terms-of-trans-and-cong ⟩

     trans (sym (cong (from ∘ to) loop))
           (trans (refl base) (cong id loop))                        ≡⟨ cong₂ (trans ∘ sym)
                                                                          (trans (sym $ cong-∘ _ to _) $
                                                                           cong (cong from) rec-loop)
                                                                          (trans (trans-reflˡ _) $
                                                                           sym $ cong-id _) ⟩

     trans (sym (cong from north≡north)) loop                        ≡⟨ prove (Trans (Sym (Cong _ (Trans (Lift _) (Sym (Lift _))))) (Lift _))
                                                                              (Trans (Trans (Cong from (Lift (meridian true)))
                                                                                            (Sym (Cong from (Lift (meridian false)))))
                                                                                     (Lift _))
                                                                              (refl _) ⟩
     trans (trans (cong from (meridian true))
                  (sym $ cong from (meridian false)))
           loop                                                      ≡⟨ cong₂ (λ p q → trans (trans p (sym q)) loop)
                                                                          From.rec-meridian
                                                                          From.rec-meridian ⟩
     trans (trans (if true ⦂ Bool then refl base else loop)
                  (sym $ if false ⦂ Bool then refl base else loop))
           loop                                                      ≡⟨⟩

     trans (trans (refl base) (sym loop)) loop                       ≡⟨ trans-[trans-sym]- _ _ ⟩∎

     refl base                                                       ∎)

-- The circle is equivalent to the 1-dimensional sphere.

𝕊¹≃𝕊¹ : 𝕊¹ ≃ 𝕊 1
𝕊¹≃𝕊¹ =
  𝕊¹          ↝⟨ 𝕊¹≃Susp-Bool ⟩
  Susp Bool   ↔⟨ Suspension.cong-↔ Sphere.Bool↔𝕊⁰ ⟩
  Susp (𝕊 0)  ↔⟨⟩
  𝕊 1         □

------------------------------------------------------------------------
-- The loop space of the circle

-- The function trans is commutative for the loop space of the circle.

trans-commutative : (p q : base ≡ base) → trans p q ≡ trans q p
trans-commutative =
  flip $ Transitivity-commutative.commutative base _∙_ ∙-base base-∙
  where
  _∙_ : 𝕊¹ → 𝕊¹ → 𝕊¹
  x ∙ y = rec x (elim (λ x → x ≡ x) loop lemma x) y
    where
    lemma : subst (λ x → x ≡ x) loop loop ≡ loop
    lemma = ≡⇒↝ _ (sym [subst≡]≡[trans≡trans]) (refl _)

  base-∙ : ∀ x → x ∙ base ≡ x
  base-∙ _ = refl _

  ∙-base : ∀ y → base ∙ y ≡ y
  ∙-base =
    elim _ (refl _)
      (subst (λ x → rec base loop x ≡ x) loop (refl _)         ≡⟨ subst-in-terms-of-trans-and-cong ⟩

       trans (sym (cong (rec base loop) loop))
         (trans (refl _) (cong id loop))                       ≡⟨ cong (trans _) $ trans-reflˡ _ ⟩

       trans (sym (cong (rec base loop) loop)) (cong id loop)  ≡⟨ cong₂ (trans ∘ sym)
                                                                    rec-loop
                                                                    (sym $ cong-id _) ⟩

       trans (sym loop) loop                                   ≡⟨ trans-symˡ _ ⟩∎

       refl _                                                  ∎)

-- The loop space is equivalent to x ≡ x, for any x : 𝕊¹.

base≡base≃≡ : {x : 𝕊¹} → (base ≡ base) ≃ (x ≡ x)
base≡base≃≡ = elim
  (λ x → (base ≡ base) ≃ (x ≡ x))
  Eq.id
  (Eq.lift-equality ext $ ⟨ext⟩ λ eq →
   _≃_.to (subst (λ x → (base ≡ base) ≃ (x ≡ x)) loop Eq.id) eq        ≡⟨ cong (_$ eq) Eq.to-subst ⟩
   subst (λ x → base ≡ base → x ≡ x) loop id eq                        ≡⟨ subst-→ ⟩
   subst (λ x → x ≡ x) loop (subst (λ _ → base ≡ base) (sym loop) eq)  ≡⟨ cong (subst (λ x → x ≡ x) loop) $ subst-const _ ⟩
   subst (λ x → x ≡ x) loop eq                                         ≡⟨ ≡⇒↝ _ (sym [subst≡]≡[trans≡trans]) $
                                                                          trans-commutative _ _ ⟩∎
   eq                                                                  ∎)
  _

-- The loop space of the circle is equivalent to the type of integers.
--
-- The proof is based on the one presented by Licata and Shulman in
-- "Calculating the Fundamental Group of the Circle in Homotopy Type
-- Theory".

base≡base≃ℤ : (base ≡ base) ≃ ℤ
base≡base≃ℤ =
  Eq.↔→≃ (to univ) (loops univ) (to-loops univ) (from-to univ)
  where
  module _ (univ : Univ.Univalence lzero) where

    -- The universal cover of the circle.

    Cover : 𝕊¹ → Type
    Cover = rec ℤ (Univ.≃⇒≡ univ Int.successor)

    to : base ≡ x → Cover x
    to = flip (subst Cover) (+ 0)

    loops : ℤ → base ≡ base
    loops (+ zero)     = refl _
    loops (+ suc n)    = trans (loops (+ n)) loop
    loops -[1+ zero  ] = sym loop
    loops -[1+ suc n ] = trans (loops -[1+ n ]) (sym loop)

    ≡⇒≃-cong-Cover-loop : Univ.≡⇒≃ (cong Cover loop) ≡ Int.successor
    ≡⇒≃-cong-Cover-loop =
      Univ.≡⇒≃ (cong Cover loop)              ≡⟨ cong Univ.≡⇒≃ rec-loop ⟩
      Univ.≡⇒≃ (Univ.≃⇒≡ univ Int.successor)  ≡⟨ _≃_.right-inverse-of (Univ.≡≃≃ univ) _ ⟩∎
      Int.successor                           ∎

    subst-Cover-loop :
      ∀ i → subst Cover loop i ≡ _≃_.to Int.successor i
    subst-Cover-loop i =
      subst Cover loop i            ≡⟨ subst-in-terms-of-≡⇒↝ equivalence _ _ _ ⟩
      Univ.≡⇒→ (cong Cover loop) i  ≡⟨ cong (λ eq → _≃_.to eq _) ≡⇒≃-cong-Cover-loop ⟩∎
      _≃_.to Int.successor i        ∎

    subst-Cover-sym-loop :
      ∀ i → subst Cover (sym loop) i ≡ _≃_.from Int.successor i
    subst-Cover-sym-loop i =
      subst Cover (sym loop) i                 ≡⟨ subst-in-terms-of-inverse∘≡⇒↝ equivalence _ _ _ ⟩
      _≃_.from (Univ.≡⇒≃ (cong Cover loop)) i  ≡⟨ cong (λ eq → _≃_.from eq _) ≡⇒≃-cong-Cover-loop ⟩∎
      _≃_.from Int.successor i                 ∎

    to-loops : ∀ i → to (loops i) ≡ i
    to-loops (+ zero) =
      subst Cover (refl _) (+ 0)  ≡⟨ subst-refl _ _ ⟩∎
      + 0                         ∎
    to-loops (+ suc n) =
      subst Cover (trans (loops (+ n)) loop) (+ 0)        ≡⟨ sym $ subst-subst _ _ _ _ ⟩
      subst Cover loop (subst Cover (loops (+ n)) (+ 0))  ≡⟨⟩
      subst Cover loop (to (loops (+ n)))                 ≡⟨ cong (subst Cover loop) $ to-loops (+ n) ⟩
      subst Cover loop (+ n)                              ≡⟨ subst-Cover-loop _ ⟩∎
      + suc n                                             ∎
    to-loops -[1+ zero ] =
      subst Cover (sym loop) (+ 0)  ≡⟨ subst-Cover-sym-loop _ ⟩∎
      -[1+ 0 ]                      ∎
    to-loops -[1+ suc n ] =
      subst Cover (trans (loops -[1+ n ]) (sym loop)) (+ 0)        ≡⟨ sym $ subst-subst _ _ _ _ ⟩
      subst Cover (sym loop) (subst Cover (loops -[1+ n ]) (+ 0))  ≡⟨⟩
      subst Cover (sym loop) (to (loops -[1+ n ]))                 ≡⟨ cong (subst Cover (sym loop)) $ to-loops -[1+ n ] ⟩
      subst Cover (sym loop) -[1+ n ]                              ≡⟨ subst-Cover-sym-loop _ ⟩∎
      -[1+ suc n ]                                                 ∎

    loops-pred-loop :
      ∀ i → trans (loops (_≃_.from Int.successor i)) loop ≡ loops i
    loops-pred-loop (+ suc _) = refl _
    loops-pred-loop (+ zero)  =
      trans (sym loop) loop  ≡⟨ trans-symˡ _ ⟩∎
      refl _                 ∎
    loops-pred-loop -[1+ zero ] =
      trans (trans (sym loop) (sym loop)) loop  ≡⟨ trans-[trans-sym]- _ _ ⟩∎
      sym loop                                  ∎
    loops-pred-loop -[1+ suc n ] =
      trans (trans (trans (loops -[1+ n ]) (sym loop)) (sym loop)) loop  ≡⟨ trans-[trans-sym]- _ _ ⟩∎
      trans (loops -[1+ n ]) (sym loop)                                  ∎

    from : ∀ x → Cover x → base ≡ x
    from = elim _
      loops
      (⟨ext⟩ λ i →
       subst (λ x → Cover x → base ≡ x) loop loops i            ≡⟨ subst-→ ⟩
       subst (base ≡_) loop (loops (subst Cover (sym loop) i))  ≡⟨ sym trans-subst ⟩
       trans (loops (subst Cover (sym loop) i)) loop            ≡⟨ cong (flip trans _ ∘ loops) $ subst-Cover-sym-loop _ ⟩
       trans (loops (_≃_.from Int.successor i)) loop            ≡⟨ loops-pred-loop i ⟩∎
       loops i                                                  ∎)

    from-to : (eq : base ≡ x) → from x (to eq) ≡ eq
    from-to = elim¹
      (λ {x} eq → from x (to eq) ≡ eq)
      (from base (to (refl base))             ≡⟨⟩
       loops (subst Cover (refl base) (+ 0))  ≡⟨ cong loops $ subst-refl _ _ ⟩
       loops (+ 0)                            ≡⟨⟩
       refl base                              ∎)

-- The circle is a groupoid.

𝕊¹-groupoid : H-level 3 𝕊¹
𝕊¹-groupoid {x = x} {y = y} =
                        $⟨ (λ {_ _} → Int.ℤ-set) ⟩
  Is-set ℤ              ↝⟨ H-level-cong _ 2 (inverse base≡base≃ℤ) ⦂ (_ → _) ⟩
  Is-set (base ≡ base)  ↝⟨ (λ s →
                              elim
                                (λ x → ∀ y → Is-set (x ≡ y))
                                (elim _ s (H-level-propositional ext 2 _ _))
                                ((Π-closure ext 1 λ _ →
                                  H-level-propositional ext 2)
                                   _ _)
                                x y) ⟩□
  Is-set (x ≡ y)        □

-- The type of endofunctions on 𝕊¹ is equivalent to
-- ∃ λ (x : 𝕊¹) → x ≡ x.

𝕊¹→𝕊¹≃Σ𝕊¹≡ : (𝕊¹ → 𝕊¹) ≃ ∃ λ (x : 𝕊¹) → x ≡ x
𝕊¹→𝕊¹≃Σ𝕊¹≡ = Eq.↔→≃ to from to-from from-to
  where
  to : (𝕊¹ → 𝕊¹) → ∃ λ (x : 𝕊¹) → x ≡ x
  to f = f base , cong f loop

  from : (∃ λ (x : 𝕊¹) → x ≡ x) → (𝕊¹ → 𝕊¹)
  from = uncurry rec

  to-from : ∀ p → to (from p) ≡ p
  to-from (x , eq) = cong (x ,_)
    (cong (rec x eq) loop  ≡⟨ rec-loop ⟩∎
     eq                    ∎)

  from-to : ∀ f → from (to f) ≡ f
  from-to f =
    rec (f base) (cong f loop)  ≡⟨ sym η-rec ⟩∎
    f                           ∎

-- The type of endofunctions on 𝕊¹ is equivalent to 𝕊¹ × ℤ.
--
-- This result was pointed out to me by Paolo Capriotti.

𝕊¹→𝕊¹≃𝕊¹×ℤ : (𝕊¹ → 𝕊¹) ≃ (𝕊¹ × ℤ)
𝕊¹→𝕊¹≃𝕊¹×ℤ =
  (𝕊¹ → 𝕊¹)               ↝⟨ 𝕊¹→𝕊¹≃Σ𝕊¹≡ ⟩
  (∃ λ (x : 𝕊¹) → x ≡ x)  ↝⟨ (∃-cong λ _ → inverse base≡base≃≡) ⟩
  𝕊¹ × base ≡ base        ↝⟨ (∃-cong λ _ → base≡base≃ℤ) ⟩□
  𝕊¹ × ℤ                  □

-- The forward direction of 𝕊¹→𝕊¹≃𝕊¹×ℤ maps the identity function to
-- base , + 1.

𝕊¹→𝕊¹≃𝕊¹×ℤ-id : _≃_.to 𝕊¹→𝕊¹≃𝕊¹×ℤ id ≡ (base , + 1)
𝕊¹→𝕊¹≃𝕊¹×ℤ-id = _≃_.from-to 𝕊¹→𝕊¹≃𝕊¹×ℤ
  (rec base (trans (refl base) loop)  ≡⟨ cong (rec base) $ trans-reflˡ _ ⟩
   rec base loop                      ≡⟨ cong (rec base) $ cong-id _ ⟩
   rec base (cong id loop)            ≡⟨ sym η-rec ⟩∎
   id                                 ∎)

-- The forward direction of 𝕊¹→𝕊¹≃𝕊¹×ℤ maps the constant function
-- returning base to base , + 0.

𝕊¹→𝕊¹≃𝕊¹×ℤ-const : _≃_.to 𝕊¹→𝕊¹≃𝕊¹×ℤ (const base) ≡ (base , + 0)
𝕊¹→𝕊¹≃𝕊¹×ℤ-const = _≃_.from-to 𝕊¹→𝕊¹≃𝕊¹×ℤ
  (rec base (refl base)               ≡⟨ cong (rec base) $ sym $ cong-const _ ⟩
   rec base (cong (const base) loop)  ≡⟨ sym η-rec ⟩∎
   const base                         ∎)

------------------------------------------------------------------------
-- Some negative results

-- The equality loop is not equal to refl base.

loop≢refl : loop ≢ refl base
loop≢refl loop≡refl = Univ.¬-Type-set univ Type-set
  where
  refl≡ : (A : Type) (A≡A : A ≡ A) → refl A ≡ A≡A
  refl≡ A A≡A =
    refl A                        ≡⟨⟩
    refl (rec A A≡A base)         ≡⟨ sym $ cong-refl _ ⟩
    cong (rec A A≡A) (refl base)  ≡⟨ cong (cong (rec A A≡A)) $ sym loop≡refl ⟩
    cong (rec A A≡A) loop         ≡⟨ rec-loop ⟩∎
    A≡A                           ∎

  Type-set : Is-set Type
  Type-set {x = A} {y = B} =
    elim¹ (λ p → ∀ q → p ≡ q)
          (refl≡ A)

-- Thus the circle is not a set.

¬-𝕊¹-set : ¬ Is-set 𝕊¹
¬-𝕊¹-set =
  Is-set 𝕊¹                     ↝⟨ (λ h → h) ⟩
  Is-proposition (base ≡ base)  ↝⟨ (λ h → h _ _) ⟩
  loop ≡ refl base              ↝⟨ loop≢refl ⟩□
  ⊥                             □

-- A function with the type of refl (for 𝕊¹) that is not equal to
-- refl.

not-refl : (x : 𝕊¹) → x ≡ x
not-refl = elim _
  loop
  (subst (λ z → z ≡ z) loop loop  ≡⟨ ≡⇒↝ _ (sym [subst≡]≡[trans≡trans]) (refl _) ⟩∎
   loop                           ∎)

-- The function not-refl is not equal to refl.

not-refl≢refl : not-refl ≢ refl
not-refl≢refl =
  not-refl ≡ refl   ↝⟨ cong (_$ _) ⟩
  loop ≡ refl base  ↝⟨ loop≢refl ⟩□
  ⊥                 □

-- There is a value with the type of refl that is not equal to refl.

∃≢refl : ∃ λ (f : (x : 𝕊¹) → x ≡ x) → f ≢ refl
∃≢refl = not-refl , not-refl≢refl

-- For every universe level there is a type A such that
-- (x : A) → x ≡ x is not a proposition.

¬-type-of-refl-propositional :
  ∃ λ (A : Type a) → ¬ Is-proposition ((x : A) → x ≡ x)
¬-type-of-refl-propositional {a = a} =
    ↑ _ 𝕊¹
  , (Is-proposition (∀ x → x ≡ x)                                 ↝⟨ (λ prop → prop _ _) ⟩

     cong lift ∘ proj₁ ∃≢refl ∘ lower ≡ cong lift ∘ refl ∘ lower  ↝⟨ cong (_∘ lift) ⟩

     cong lift ∘ proj₁ ∃≢refl ≡ cong lift ∘ refl                  ↝⟨ cong (cong lower ∘_) ⟩

     cong lower ∘ cong lift ∘ proj₁ ∃≢refl ≡
     cong lower ∘ cong lift ∘ refl                                ↝⟨ ≡⇒↝ _ (cong₂ _≡_ (⟨ext⟩ λ _ → cong-∘ _ _ _) (⟨ext⟩ λ _ → cong-∘ _ _ _)) ⟩

     cong id ∘ proj₁ ∃≢refl ≡ cong id ∘ refl                      ↝⟨ ≡⇒↝ _ (sym $ cong₂ _≡_ (⟨ext⟩ λ _ → cong-id _) (⟨ext⟩ λ _ → cong-id _)) ⟩

     proj₁ ∃≢refl ≡ refl                                          ↝⟨ proj₂ ∃≢refl ⟩□

     ⊥                                                            □)

-- Every element of the circle is /merely/ equal to the base point.
--
-- This lemma was mentioned by Mike Shulman in a blog post
-- (http://homotopytypetheory.org/2013/07/24/cohomology/).

all-points-on-the-circle-are-merely-equal :
  (x : 𝕊¹) → ∥ x ≡ base ∥
all-points-on-the-circle-are-merely-equal =
  elim _
       ∣ refl base ∣
       (Trunc.truncation-is-proposition _ _)

-- Thus every element of the circle is not not equal to the base
-- point.

all-points-on-the-circle-are-¬¬-equal :
  (x : 𝕊¹) → ¬ ¬ x ≡ base
all-points-on-the-circle-are-¬¬-equal x =
  x ≢ base        ↝⟨ Trunc.rec ⊥-propositional ⟩
  ¬ ∥ x ≡ base ∥  ↝⟨ _$ all-points-on-the-circle-are-merely-equal x ⟩□
  ⊥               □

-- It is not the case that every point on the circle is equal to the
-- base point.

¬-all-points-on-the-circle-are-equal :
  ¬ ((x : 𝕊¹) → x ≡ base)
¬-all-points-on-the-circle-are-equal =
  ((x : 𝕊¹) → x ≡ base)  ↝⟨ (λ hyp x y → x     ≡⟨ hyp x ⟩
                                         base  ≡⟨ sym (hyp y) ⟩∎
                                         y     ∎) ⟩
  Is-proposition 𝕊¹      ↝⟨ mono₁ 1 ⟩
  Is-set 𝕊¹              ↝⟨ ¬-𝕊¹-set ⟩□
  ⊥                      □

-- Thus double-negation shift for Type-valued predicates over 𝕊¹ does
-- not hold in general.

¬-double-negation-shift :
  ¬ ({P : 𝕊¹ → Type} → ((x : 𝕊¹) → ¬ ¬ P x) → ¬ ¬ ((x : 𝕊¹) → P x))
¬-double-negation-shift =
  ({P : 𝕊¹ → Type} → ((x : 𝕊¹) → ¬ ¬ P x) → ¬ ¬ ((x : 𝕊¹) → P x))  ↝⟨ _$ all-points-on-the-circle-are-¬¬-equal ⟩
  ¬ ¬ ((x : 𝕊¹) → x ≡ base)                                        ↝⟨ _$ ¬-all-points-on-the-circle-are-equal ⟩□
  ⊥                                                                □

-- Furthermore excluded middle for arbitrary types (in Type) does not
-- hold.

¬-excluded-middle : ¬ ({A : Type} → Dec A)
¬-excluded-middle =
  ({A : Type} → Dec A)                                             ↝⟨ (λ em ¬¬a → [ id , ⊥-elim ∘ ¬¬a ] em) ⟩
  ({A : Type} → ¬ ¬ A → A)                                         ↝⟨ (λ dne → flip _$_ ∘ (dne ∘_)) ⟩
  ({P : 𝕊¹ → Type} → ((x : 𝕊¹) → ¬ ¬ P x) → ¬ ¬ ((x : 𝕊¹) → P x))  ↝⟨ ¬-double-negation-shift ⟩□
  ⊥                                                                □

-- H-level.Closure.proj₁-closure cannot be generalised by replacing
-- the assumption ∀ a → B a with ∀ a → ∥ B a ∥.
--
-- This observation is due to Andrea Vezzosi.

¬-generalised-proj₁-closure :
  ¬ ({A : Type} {B : A → Type} →
     (∀ a → ∥ B a ∥) →
     ∀ n → H-level n (Σ A B) → H-level n A)
¬-generalised-proj₁-closure generalised-proj₁-closure =
                                 $⟨ singleton-contractible _ ⟩
  Contractible (Σ 𝕊¹ (_≡ base))  ↝⟨ generalised-proj₁-closure
                                      all-points-on-the-circle-are-merely-equal
                                      0 ⟩
  Contractible 𝕊¹                ↝⟨ mono (zero≤ 2) ⟩
  Is-set 𝕊¹                      ↝⟨ ¬-𝕊¹-set ⟩□
  ⊥                              □

------------------------------------------------------------------------
-- An alternative approach to defining eliminators and proving
-- computation rules for arbitrary notions of equality, based on an
-- anonymous reviewer's suggestion

-- Circle eq p is an axiomatisation of the circle, for the given
-- notion of equality eq, eliminating into Type p.
--
-- Note that the statement of the computation rule for "loop" is more
-- complicated than above (elim-loop). The reason is that the
-- computation rule for "base" does not hold definitionally.

Circle :
  ∀ {e⁺} →
  (∀ {a p} → P.Equality-with-paths a p e⁺) →
  (p : Level) → Type (lsuc p)
Circle eq p =
  ∃ λ (𝕊¹ : Type) →
  ∃ λ (base : 𝕊¹) →
  ∃ λ (loop : base E.≡ base) →
    (P : 𝕊¹ → Type p)
    (b : P base)
    (ℓ : E.subst P loop b E.≡ b) →
    ∃ λ (elim : (x : 𝕊¹) → P x) →
    ∃ λ (elim-base : elim base E.≡ b) →
      E.subst (λ b → E.subst P loop b E.≡ b)
              elim-base
              (E.dcong elim loop)
        E.≡
      ℓ
  where
  module E = P.Derived-definitions-and-properties eq

-- A circle defined for paths (P.equality-with-J) is equivalent to one
-- defined for eq.

Circle≃Circle : Circle P.equality-with-paths p ≃ Circle eq p
Circle≃Circle =
  ∃-cong λ _ →
  ∃-cong λ _ →
  Σ-cong (inverse ≡↔≡) λ loop →
  ∀-cong ext λ P →
  ∀-cong ext λ b →
  Π-cong-contra ext subst≡↔subst≡ λ ℓ →
  ∃-cong λ f →
  Σ-cong (inverse ≡↔≡) λ f-base →
  let lemma = P.elim¹
        (λ eq → _↔_.from subst≡↔subst≡
                  (P.subst
                     (λ b → P.subst P loop b P.≡ b)
                     eq
                     (P.dcong f loop)) ≡
                P.subst
                  (λ b → subst P (_↔_.from ≡↔≡ loop) b ≡ b)
                  eq
                  (_↔_.from subst≡↔subst≡ (P.dcong f loop)))
        (_↔_.from subst≡↔subst≡
           (P.subst
              (λ b → P.subst P loop b P.≡ b)
              P.refl
              (P.dcong f loop))                       ≡⟨ cong (_↔_.from subst≡↔subst≡) $ _↔_.from ≡↔≡ $
                                                         P.subst-refl (λ b → P.subst P loop b P.≡ b) _ ⟩

         _↔_.from subst≡↔subst≡ (P.dcong f loop)      ≡⟨ sym $ _↔_.from ≡↔≡ $
                                                         P.subst-refl (λ b → subst P (_↔_.from ≡↔≡ loop) b ≡ b) _ ⟩∎
         P.subst
           (λ b → subst P (_↔_.from ≡↔≡ loop) b ≡ b)
           P.refl
           (_↔_.from subst≡↔subst≡ (P.dcong f loop))  ∎)
        _
  in
  P.subst
    (λ b → P.subst P loop b P.≡ b)
    f-base
    (P.dcong f loop) P.≡
  _↔_.to subst≡↔subst≡ ℓ                           ↔⟨ ≡↔≡ F.∘ inverse (from≡↔≡to (Eq.↔⇒≃ subst≡↔subst≡)) F.∘ inverse ≡↔≡ ⟩

  _↔_.from subst≡↔subst≡
    (P.subst
       (λ b → P.subst P loop b P.≡ b)
       f-base
       (P.dcong f loop)) P.≡
  ℓ                                                ↝⟨ ≡⇒↝ _ (cong (P._≡ _) lemma) ⟩

  P.subst
    (λ b → subst P (_↔_.from ≡↔≡ loop) b ≡ b)
    f-base
    (_↔_.from subst≡↔subst≡ (P.dcong f loop)) P.≡
  ℓ                                                ↝⟨ ≡⇒↝ _ $ cong (λ eq → P.subst (λ b → subst P (_↔_.from ≡↔≡ loop) b ≡ b) f-base eq P.≡ ℓ) $
                                                      _↔_.from-to (inverse subst≡↔subst≡) dcong≡dcong ⟩
  P.subst
    (λ b → subst P (_↔_.from ≡↔≡ loop) b ≡ b)
    f-base
    (dcong f (_↔_.from ≡↔≡ loop)) P.≡
  ℓ                                                ↔⟨ inverse subst≡↔subst≡ ⟩□

  subst
    (λ b → subst P (_↔_.from ≡↔≡ loop) b ≡ b)
    (_↔_.from ≡↔≡ f-base)
    (dcong f (_↔_.from ≡↔≡ loop)) ≡
  ℓ                                                □

-- An implemention of the circle for paths (P.equality-with-paths).

circleᴾ : Circle P.equality-with-paths p
circleᴾ =
    𝕊¹
  , base
  , loopᴾ
  , λ P b ℓ →
      let elim = elimᴾ P b (PI.subst≡→[]≡ {B = P} ℓ)
      in
        elim
      , P.refl
      , (P.subst (λ b → P.subst P loopᴾ b P.≡ b) P.refl
           (P.dcong elim loopᴾ)                          P.≡⟨ P.subst-refl (λ b → P.subst P loopᴾ b P.≡ b) _ ⟩

         P.dcong elim loopᴾ                              P.≡⟨ PI.dcong-subst≡→[]≡ {f = elim} P.refl ⟩∎

         ℓ                                               ∎)

-- An implementation of the circle for eq.

circle : Circle eq p
circle = _≃_.to Circle≃Circle circleᴾ

-- The latter implementation computes in the right way for "base".

_ :
  let _ , base′ , _ , elim′ = circle {p = p} in
  ∀ {P b ℓ} →
  proj₁ (elim′ P b ℓ) base′ ≡ b
_ = refl _

-- The usual computation rule for "loop" can be derived.

elim-loop-circle :
  let _ , _ , loop′ , elim′ = circle {p = p} in
  ∀ {P b ℓ} →
  dcong (proj₁ (elim′ P b ℓ)) loop′ ≡ ℓ
elim-loop-circle {P = P} {b = b} {ℓ = ℓ} =
  let _ , _ , loop′ , elim′           = circle
      elim″ , elim″-base , elim″-loop = elim′ P b ℓ

      lemma =
        refl _               ≡⟨ sym from-≡↔≡-refl ⟩
        _↔_.from ≡↔≡ P.refl  ≡⟨⟩
        elim″-base           ∎
  in
  dcong elim″ loop′                                                 ≡⟨ sym $ subst-refl _ _ ⟩
  subst (λ b → subst P loop′ b ≡ b) (refl _) (dcong elim″ loop′)    ≡⟨ cong (λ eq → subst (λ b → subst P loop′ b ≡ b) eq (dcong elim″ loop′)) lemma ⟩
  subst (λ b → subst P loop′ b ≡ b) elim″-base (dcong elim″ loop′)  ≡⟨ elim″-loop ⟩∎
  ℓ                                                                 ∎

-- An alternative to Circle≃Circle that does not give the "right"
-- computational behaviour for circle′ below.

Circle≃Circle′ : Circle P.equality-with-paths p ≃ Circle eq p
Circle≃Circle′ =
  ∃-cong λ _ →
  ∃-cong λ _ →
  Σ-cong (inverse ≡↔≡) λ loop →
  ∀-cong ext λ P →
  ∀-cong ext λ b →
  Π-cong ext (inverse subst≡↔subst≡) λ ℓ →
  ∃-cong λ f →
  Σ-cong (inverse ≡↔≡) λ f-base →
  let lemma = P.elim¹
        (λ eq → _↔_.from subst≡↔subst≡
                  (P.subst
                     (λ b → P.subst P loop b P.≡ b)
                     eq
                     (P.dcong f loop)) ≡
                P.subst
                  (λ b → subst P (_↔_.from ≡↔≡ loop) b ≡ b)
                  eq
                  (_↔_.from subst≡↔subst≡ (P.dcong f loop)))
        (_↔_.from subst≡↔subst≡
           (P.subst
              (λ b → P.subst P loop b P.≡ b)
              P.refl
              (P.dcong f loop))                       ≡⟨ cong (_↔_.from subst≡↔subst≡) $ _↔_.from ≡↔≡ $
                                                         P.subst-refl (λ b → P.subst P loop b P.≡ b) _ ⟩

         _↔_.from subst≡↔subst≡ (P.dcong f loop)      ≡⟨ sym $ _↔_.from ≡↔≡ $
                                                         P.subst-refl (λ b → subst P (_↔_.from ≡↔≡ loop) b ≡ b) _ ⟩∎
         P.subst
           (λ b → subst P (_↔_.from ≡↔≡ loop) b ≡ b)
           P.refl
           (_↔_.from subst≡↔subst≡ (P.dcong f loop))  ∎)
        _
  in
  P.subst
    (λ b → P.subst P loop b P.≡ b)
    f-base
    (P.dcong f loop) P.≡
  ℓ                                                ↔⟨ ≡↔≡ F.∘ from-isomorphism (inverse $ Eq.≃-≡ $ Eq.↔⇒≃ $ inverse subst≡↔subst≡) F.∘ inverse ≡↔≡ ⟩

  _↔_.from subst≡↔subst≡
    (P.subst
       (λ b → P.subst P loop b P.≡ b)
       f-base
       (P.dcong f loop)) P.≡
  _↔_.from subst≡↔subst≡ ℓ                         ↝⟨ ≡⇒↝ _ (cong (P._≡ _↔_.from subst≡↔subst≡ ℓ) lemma) ⟩

  P.subst
    (λ b → subst P (_↔_.from ≡↔≡ loop) b ≡ b)
    f-base
    (_↔_.from subst≡↔subst≡ (P.dcong f loop)) P.≡
  _↔_.from subst≡↔subst≡ ℓ                         ↝⟨ ≡⇒↝ _ $ cong (λ eq → P.subst (λ b → subst P (_↔_.from ≡↔≡ loop) b ≡ b) f-base eq P.≡ _↔_.from subst≡↔subst≡ ℓ) $
                                                      _↔_.from-to (inverse subst≡↔subst≡) dcong≡dcong ⟩
  P.subst
    (λ b → subst P (_↔_.from ≡↔≡ loop) b ≡ b)
    f-base
    (dcong f (_↔_.from ≡↔≡ loop)) P.≡
  _↔_.from subst≡↔subst≡ ℓ                         ↔⟨ inverse subst≡↔subst≡ ⟩□

  subst
    (λ b → subst P (_↔_.from ≡↔≡ loop) b ≡ b)
    (_↔_.from ≡↔≡ f-base)
    (dcong f (_↔_.from ≡↔≡ loop)) ≡
  _↔_.from subst≡↔subst≡ ℓ                         □

-- An alternative implementation of the circle for eq.

circle′ : Circle eq p
circle′ = _≃_.to Circle≃Circle′ circleᴾ

-- This implementation does not compute in the right way for "base".
-- The following code is (at the time of writing) rejected by Agda.

-- _ :
--   let _ , base′ , _ , elim′ = circle′ {p = p} in
--   ∀ {P b ℓ} →
--   proj₁ (elim′ P b ℓ) base′ ≡ b
-- _ = refl _
