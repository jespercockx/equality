------------------------------------------------------------------------
-- A type for values that should be erased at run-time
------------------------------------------------------------------------

-- Most of the definitions in this module are reexported, in one way
-- or another, from Erased.

-- This module imports Function-universe, but not Equivalence.Erased.

{-# OPTIONS --without-K --safe #-}

open import Equality

module Erased.Level-1
  {e⁺} (eq-J : ∀ {a p} → Equality-with-J a p e⁺) where

open Derived-definitions-and-properties eq-J

open import Logical-equivalence using (_⇔_)
open import Prelude hiding ([_,_])

open import Bijection eq-J as Bijection using (_↔_; Has-quasi-inverse)
open import Embedding eq-J as Emb using (Embedding; Is-embedding)
open import Equivalence eq-J as Eq using (_≃_; Is-equivalence)
open import Function-universe eq-J as F hiding (id; _∘_)
open import H-level eq-J as H-level
open import H-level.Closure eq-J
open import Injection eq-J using (_↣_; Injective)
open import Monad eq-J hiding (map; map-id; map-∘)
open import Preimage eq-J using (_⁻¹_)
open import Surjection eq-J using (_↠_; Split-surjective)
open import Univalence-axiom eq-J as U using (≡⇒→)

private
  variable
    a b c ℓ       : Level
    A B           : Type a
    eq k k′ p x y : A
    P             : A → Type p
    f g           : A → B
    n             : ℕ

------------------------------------------------------------------------
-- Some basic definitions

open import Erased.Basics eq-J public

------------------------------------------------------------------------
-- Erased is a monad

-- A universe-polymorphic variant of bind.

infixl 5 _>>=′_

_>>=′_ :
  {@0 A : Type a} {@0 B : Type b} →
  Erased A → (A → Erased B) → Erased B
x >>=′ f = [ erased (f (erased x)) ]

instance

  -- Erased is a monad.

  raw-monad : Raw-monad (λ (A : Type a) → Erased A)
  Raw-monad.return raw-monad = [_]→
  Raw-monad._>>=_  raw-monad = _>>=′_

  monad : Monad (λ (A : Type a) → Erased A)
  Monad.raw-monad      monad = raw-monad
  Monad.left-identity  monad = λ _ _ → refl _
  Monad.right-identity monad = λ _ → refl _
  Monad.associativity  monad = λ _ _ _ → refl _

------------------------------------------------------------------------
-- Erased preserves some kinds of functions

-- Erased preserves dependent functions.

map :
  {@0 A : Type a} {@0 P : A → Type b} →
  @0 ((x : A) → P x) → (x : Erased A) → Erased (P (erased x))
map f [ x ] = [ f x ]

-- Erased is functorial for dependent functions.

map-id : {@0 A : Type a} → map id ≡ id {A = Erased A}
map-id = refl _

map-∘ :
  {@0 A : Type a} {@0 P : A → Type b} {@0 Q : {x : A} → P x → Type c}
  (@0 f : ∀ {x} (y : P x) → Q y) (@0 g : (x : A) → P x) →
  map (f ∘ g) ≡ map f ∘ map g
map-∘ _ _ = refl _

-- Erased preserves logical equivalences.

Erased-cong-⇔ :
  {@0 A : Type a} {@0 B : Type b} →
  @0 A ⇔ B → Erased A ⇔ Erased B
Erased-cong-⇔ A⇔B = record
  { to   = map (_⇔_.to   A⇔B)
  ; from = map (_⇔_.from A⇔B)
  }

-- Erased is functorial for logical equivalences.

Erased-cong-⇔-id :
  {@0 A : Type a} →
  Erased-cong-⇔ F.id ≡ F.id {A = Erased A}
Erased-cong-⇔-id = refl _

Erased-cong-⇔-∘ :
  {@0 A : Type a} {@0 B : Type b} {@0 C : Type c}
  (@0 f : B ⇔ C) (@0 g : A ⇔ B) →
  Erased-cong-⇔ (f F.∘ g) ≡ Erased-cong-⇔ f F.∘ Erased-cong-⇔ g
Erased-cong-⇔-∘ _ _ = refl _

------------------------------------------------------------------------
-- Some isomorphisms

-- In an erased context Erased A is always isomorphic to A.

Erased↔ : {@0 A : Type a} → Erased (Erased A ↔ A)
Erased↔ = [ record
  { surjection = record
    { logical-equivalence = record
      { to   = erased
      ; from = [_]→
      }
    ; right-inverse-of = λ _ → refl _
    }
  ; left-inverse-of = λ _ → refl _
  } ]

-- The following result is based on a result in Mishra-Linger's PhD
-- thesis (see Section 5.4.4).

-- Erased (Erased A) is isomorphic to Erased A.

Erased-Erased↔Erased :
  {@0 A : Type a} →
  Erased (Erased A) ↔ Erased A
Erased-Erased↔Erased = record
  { surjection = record
    { logical-equivalence = record
      { to   = λ x → [ erased (erased x) ]
      ; from = [_]→
      }
    ; right-inverse-of = λ _ → refl _
    }
  ; left-inverse-of = λ _ → refl _
  }

-- Erased ⊤ is isomorphic to ⊤.

Erased-⊤↔⊤ : Erased ⊤ ↔ ⊤
Erased-⊤↔⊤ = record
  { surjection = record
    { logical-equivalence = record
      { to   = λ _ → tt
      ; from = [_]→
      }
    ; right-inverse-of = λ _ → refl _
    }
  ; left-inverse-of = λ _ → refl _
  }

-- Erased ⊥ is isomorphic to ⊥.

Erased-⊥↔⊥ : Erased (⊥ {ℓ = ℓ}) ↔ ⊥ {ℓ = ℓ}
Erased-⊥↔⊥ = record
  { surjection = record
    { logical-equivalence = record
      { to   = λ { [ () ] }
      ; from = [_]→
      }
    ; right-inverse-of = λ ()
    }
  ; left-inverse-of = λ { [ () ] }
  }

-- Erased commutes with Π A.

Erased-Π↔Π :
  {@0 P : A → Type p} →
  Erased ((x : A) → P x) ↔ ((x : A) → Erased (P x))
Erased-Π↔Π = record
  { surjection = record
    { logical-equivalence = record
      { to   = λ { [ f ] x → [ f x ] }
      ; from = λ f → [ (λ x → erased (f x)) ]
      }
    ; right-inverse-of = λ _ → refl _
    }
  ; left-inverse-of = λ _ → refl _
  }

-- Erased commutes with Π.

Erased-Π↔Π-Erased :
  {@0 A : Type a} {@0 P : A → Type p} →
  Erased ((x : A) → P x) ↔ ((x : Erased A) → Erased (P (erased x)))
Erased-Π↔Π-Erased = record
  { surjection = record
    { logical-equivalence = record
      { to   = λ ([ f ]) → map f
      ; from = λ f → [ (λ x → erased (f [ x ])) ]
      }
    ; right-inverse-of = λ _ → refl _
    }
  ; left-inverse-of = λ _ → refl _
  }

-- Erased commutes with Σ.

Erased-Σ↔Σ :
  {@0 A : Type a} {@0 P : A → Type p} →
  Erased (Σ A P) ↔ Σ (Erased A) (λ x → Erased (P (erased x)))
Erased-Σ↔Σ = record
  { surjection = record
    { logical-equivalence = record
      { to   = λ { [ p ] → [ proj₁ p ] , [ proj₂ p ] }
      ; from = λ { ([ x ] , [ y ]) → [ x , y ] }
      }
    ; right-inverse-of = λ _ → refl _
    }
  ; left-inverse-of = λ _ → refl _
  }

-- Erased commutes with ↑ ℓ.

Erased-↑↔↑ :
  {@0 A : Type a} →
  Erased (↑ ℓ A) ↔ ↑ ℓ (Erased A)
Erased-↑↔↑ = record
  { surjection = record
    { logical-equivalence = record
      { to   = λ { [ x ] → lift [ lower x ] }
      ; from = λ { (lift [ x ]) → [ lift x ] }
      }
    ; right-inverse-of = λ _ → refl _
    }
  ; left-inverse-of = λ _ → refl _
  }

-- Erased commutes with ¬_ (assuming extensionality).

Erased-¬↔¬ :
  {@0 A : Type a} →
  Extensionality? k a lzero →
  Erased (¬ A) ↝[ k ] ¬ Erased A
Erased-¬↔¬ {A = A} ext =
  Erased (A → ⊥)         ↔⟨ Erased-Π↔Π-Erased ⟩
  (Erased A → Erased ⊥)  ↝⟨ (∀-cong ext λ _ → from-isomorphism Erased-⊥↔⊥) ⟩□
  (Erased A → ⊥)         □

-- Erased can be dropped under ¬_ (assuming extensionality).

¬-Erased↔¬ :
  {A : Type a} →
  Extensionality? k a lzero →
  ¬ Erased A ↝[ k ] ¬ A
¬-Erased↔¬ {a = a} {A = A} =
  generalise-ext?-prop
    (record
       { to   = λ ¬[a] a → ¬[a] [ a ]
       ; from = λ ¬a ([ a ]) → _↔_.to Erased-⊥↔⊥ [ ¬a a ]
       })
    ¬-propositional
    ¬-propositional

-- The following two results are inspired by a result in
-- Mishra-Linger's PhD thesis (see Section 5.4.1).
--
-- See also Π-Erased↔Π0[], Π-Erased≃Π0[], Π-Erased↔Π0 and Π-Erased≃Π0
-- in Erased.Cubical and Erased.With-K.

-- There is a logical equivalence between
-- (x : Erased A) → P (erased x) and (@0 x : A) → P x.

Π-Erased⇔Π0 :
  {@0 A : Type a} {@0 P : A → Type p} →
  ((x : Erased A) → P (erased x)) ⇔ ((@0 x : A) → P x)
Π-Erased⇔Π0 = record
  { to   = λ f x → f [ x ]
  ; from = λ f ([ x ]) → f x
  }

-- There is a bijection between (x : Erased A) → P x and
-- (@0 x : A) → P [ x ].

Π-Erased↔Π0[] : ((x : Erased A) → P x) ↔ ((@0 x : A) → P [ x ])
Π-Erased↔Π0[] = record
  { surjection = record
    { logical-equivalence = Π-Erased⇔Π0
    ; right-inverse-of = λ _ → refl _
    }
  ; left-inverse-of = λ _ → refl _
  }

-- Erased commutes with W up to logical equivalence.

Erased-W⇔W :
  {@0 A : Type a} {@0 P : A → Type p} →
  Erased (W A P) ⇔ W (Erased A) (λ x → Erased (P (erased x)))
Erased-W⇔W {A = A} {P = P} = record { to = to; from = from }
  where
  to : Erased (W A P) → W (Erased A) (λ x → Erased (P (erased x)))
  to [ sup x f ] = sup [ x ] (λ ([ y ]) → to [ f y ])

  from : W (Erased A) (λ x → Erased (P (erased x))) → Erased (W A P)
  from (sup [ x ] f) = [ sup x (λ y → erased (from (f [ y ]))) ]

----------------------------------------------------------------------
-- Erased is a modality

-- Erased is the modal operator of a uniquely eliminating modality
-- with [_]→ as the modal unit.
--
-- The terminology here roughly follows that of "Modalities in
-- Homotopy Type Theory" by Rijke, Shulman and Spitters.

uniquely-eliminating-modality :
  {@0 P : Erased A → Type p} →
  Is-equivalence
    (λ (f : (x : Erased A) → Erased (P x)) → f ∘ [_]→ {A = A})
uniquely-eliminating-modality {A = A} {P = P} =
  _≃_.is-equivalence
    (((x : Erased A) → Erased (P x))  ↔⟨ inverse Erased-Π↔Π-Erased ⟩
     Erased ((x : A) → (P [ x ]))     ↔⟨ Erased-Π↔Π ⟩
     ((x : A) → Erased (P [ x ]))     □)

-- Two results that are closely related to
-- uniquely-eliminating-modality.
--
-- These results are based on the Coq source code accompanying
-- "Modalities in Homotopy Type Theory" by Rijke, Shulman and
-- Spitters.

-- Precomposition with [_]→ is injective for functions from Erased A
-- to Erased B.

∘-[]-injective :
  {@0 B : Type b} →
  Injective (λ (f : Erased A → Erased B) → f ∘ [_]→)
∘-[]-injective = _≃_.injective Eq.⟨ _ , uniquely-eliminating-modality ⟩

-- A rearrangement lemma for ext⁻¹ and ∘-[]-injective.

ext⁻¹-∘-[]-injective :
  {@0 B : Type b} {f g : Erased A → Erased B} {p : f ∘ [_]→ ≡ g ∘ [_]→} →
  ext⁻¹ (∘-[]-injective {x = f} {y = g} p) [ x ] ≡ ext⁻¹ p x
ext⁻¹-∘-[]-injective {x = x} {f = f} {g = g} {p = p} =
  ext⁻¹ (∘-[]-injective p) [ x ]               ≡⟨ elim₁
                                                    (λ p → ext⁻¹ p [ x ] ≡ ext⁻¹ (_≃_.from equiv p) x) (
      ext⁻¹ (refl g) [ x ]                            ≡⟨ cong-refl (_$ [ x ]) ⟩
      refl (g [ x ])                                  ≡⟨ sym $ cong-refl _ ⟩
      ext⁻¹ (refl (g ∘ [_]→)) x                       ≡⟨ cong (λ p → ext⁻¹ p x) $ sym $ cong-refl _ ⟩∎
      ext⁻¹ (_≃_.from equiv (refl g)) x               ∎)
                                                    (∘-[]-injective p) ⟩
  ext⁻¹ (_≃_.from equiv (∘-[]-injective p)) x  ≡⟨ cong (flip ext⁻¹ x) $ _≃_.left-inverse-of equiv _ ⟩∎
  ext⁻¹ p x                                    ∎
  where
  equiv = Eq.≃-≡ Eq.⟨ _ , uniquely-eliminating-modality ⟩

------------------------------------------------------------------------
-- A variant of Dec ∘ Erased

-- Dec-Erased A means that either we have A (erased), or we have ¬ A
-- (also erased).

Dec-Erased : @0 Type ℓ → Type ℓ
Dec-Erased A = Erased A ⊎ Erased (¬ A)

-- Dec-Erased A is isomorphic to Dec (Erased A) (assuming
-- extensionality).

Dec-Erased↔Dec-Erased :
  {@0 A : Type a} →
  Extensionality? k a lzero →
  Dec-Erased A ↝[ k ] Dec (Erased A)
Dec-Erased↔Dec-Erased {A = A} ext =
  Erased A ⊎ Erased (¬ A)  ↝⟨ F.id ⊎-cong Erased-¬↔¬ ext ⟩□
  Erased A ⊎ ¬ Erased A    □

-- A map function for Dec-Erased.

Dec-Erased-map :
  {@0 A : Type a} {@0 B : Type b} →
  @0 A ⇔ B → Dec-Erased A → Dec-Erased B
Dec-Erased-map A⇔B =
  ⊎-map (map (_⇔_.to A⇔B))
        (map (_∘ _⇔_.from A⇔B))

-- Dec-Erased preserves logical equivalences.

Dec-Erased-cong-⇔ :
  {@0 A : Type a} {@0 B : Type b} →
  @0 A ⇔ B → Dec-Erased A ⇔ Dec-Erased B
Dec-Erased-cong-⇔ A⇔B = record
  { to   = Dec-Erased-map A⇔B
  ; from = Dec-Erased-map (inverse A⇔B)
  }

------------------------------------------------------------------------
-- Some results that hold in erased contexts

-- In an erased context there is an equivalence between equality of
-- "boxed" values and equality of values.

@0 []≡[]≃≡ : ([ x ] ≡ [ y ]) ≃ (x ≡ y)
[]≡[]≃≡ = Eq.↔⇒≃ (record
  { surjection = record
    { logical-equivalence = record
      { to   = cong erased
      ; from = cong [_]→
      }
    ; right-inverse-of = λ eq →
        cong erased (cong [_]→ eq)  ≡⟨ cong-∘ _ _ _ ⟩
        cong id eq                  ≡⟨ sym $ cong-id _ ⟩∎
        eq                          ∎
    }
  ; left-inverse-of = λ eq →
      cong [_]→ (cong erased eq)  ≡⟨ cong-∘ _ _ _ ⟩
      cong id eq                  ≡⟨ sym $ cong-id _ ⟩∎
      eq                          ∎
  })

-- The []-cong axioms can be instantiated in erased contexts.

@0 erased-instance-of-[]-cong-axiomatisation :
  []-cong-axiomatisation a
erased-instance-of-[]-cong-axiomatisation
  .[]-cong-axiomatisation.[]-cong =
  cong [_]→ ∘ erased
erased-instance-of-[]-cong-axiomatisation
  .[]-cong-axiomatisation.[]-cong-equivalence {x = x} {y = y} =
  _≃_.is-equivalence
    (Erased (x ≡ y)  ↔⟨ erased Erased↔ ⟩
     x ≡ y           ↝⟨ inverse []≡[]≃≡ ⟩□
     [ x ] ≡ [ y ]   □)
erased-instance-of-[]-cong-axiomatisation
  .[]-cong-axiomatisation.[]-cong-[refl] {x = x} =
  cong [_]→ (erased [ refl x ])  ≡⟨⟩
  cong [_]→ (refl x)             ≡⟨ cong-refl _ ⟩∎
  refl [ x ]                     ∎

------------------------------------------------------------------------
-- Some results that follow if "[]-cong" can be defined

module []-cong₁
  ([]-cong :
     ∀ {a} {@0 A : Type a} {@0 x y : A} →
     Erased (x ≡ y) → [ x ] ≡ [ y ])
  where

  -- Erased commutes with W (assuming extensionality).

  Erased-W↔W :
    {@0 A : Type a} {@0 P : A → Type p} →
    Extensionality? k p (a ⊔ p) →
    Erased (W A P) ↝[ k ] W (Erased A) (λ x → Erased (P (erased x)))
  Erased-W↔W {a = a} {p = p} {A = A} {P = P} =
    generalise-ext?
      Erased-W⇔W
      (λ ext → record
         { surjection = record
           { logical-equivalence = Erased-W⇔W
           ; right-inverse-of    = to∘from ext }
         ; left-inverse-of = from∘to ext
         })
    where
    open _⇔_ Erased-W⇔W

    to∘from :
      Extensionality p (a ⊔ p) →
      (x : W (Erased A) (λ x → Erased (P (erased x)))) →
      to (from x) ≡ x
    to∘from ext (sup [ x ] f) =
      cong (sup [ x ]) (apply-ext ext (λ ([ y ]) →
        to∘from ext (f [ y ])))

    from∘to :
      Extensionality p (a ⊔ p) →
      (x : Erased (W A P)) → from (to x) ≡ x
    from∘to ext [ sup x f ] =
      []-cong [ cong (sup x) (apply-ext ext λ y →
        cong erased (from∘to ext [ f y ])) ]

  -- [_] can be "pushed" through subst.

  push-subst-[] :
    {@0 P : A → Type p} {@0 p : P x} {x≡y : x ≡ y} →
    subst (λ x → Erased (P x)) x≡y [ p ] ≡ [ subst P x≡y p ]
  push-subst-[] {P = P} {p = p} = elim¹
    (λ x≡y → subst (λ x → Erased (P x)) x≡y [ p ] ≡ [ subst P x≡y p ])
    (subst (λ x → Erased (P x)) (refl _) [ p ]  ≡⟨ subst-refl _ _ ⟩
     [ p ]                                      ≡⟨ []-cong [ sym $ subst-refl _ _ ] ⟩∎
     [ subst P (refl _) p ]                     ∎)
    _

  -- Erased preserves some kinds of functions.

  module _ {@0 A : Type a} {@0 B : Type b} where

    Erased-cong-↠ : @0 A ↠ B → Erased A ↠ Erased B
    Erased-cong-↠ A↠B = record
      { logical-equivalence = Erased-cong-⇔
                                (_↠_.logical-equivalence A↠B)
      ; right-inverse-of    = λ { [ x ] →
          []-cong [ _↠_.right-inverse-of A↠B x ] }
      }

    Erased-cong-↔ : @0 A ↔ B → Erased A ↔ Erased B
    Erased-cong-↔ A↔B = record
      { surjection      = Erased-cong-↠ (_↔_.surjection A↔B)
      ; left-inverse-of = λ { [ x ] →
          []-cong [ _↔_.left-inverse-of A↔B x ] }
      }

    Erased-cong-≃ : @0 A ≃ B → Erased A ≃ Erased B
    Erased-cong-≃ A≃B =
      from-isomorphism (Erased-cong-↔ (from-isomorphism A≃B))

    -- A variant of Erased-cong (which is defined below).

    Erased-cong? :
      ∀ {a b} →
      @0 (∀ {k} → Extensionality? k a b → A ↝[ k ] B) →
      @0 Extensionality? k a b → Erased A ↝[ k ] Erased B
    Erased-cong? hyp = generalise-erased-ext?
      (Erased-cong-⇔ (hyp _))
      (λ ext → Erased-cong-↔ (hyp ext))

  -- Erased commutes with _⇔_.

  Erased-⇔↔⇔ :
    {@0 A : Type a} {@0 B : Type b} →
    Erased (A ⇔ B) ↔ (Erased A ⇔ Erased B)
  Erased-⇔↔⇔ {A = A} {B = B} =
    Erased (A ⇔ B)                                 ↝⟨ Erased-cong-↔ ⇔↔→×→ ⟩
    Erased ((A → B) × (B → A))                     ↝⟨ Erased-Σ↔Σ ⟩
    Erased (A → B) × Erased (B → A)                ↝⟨ Erased-Π↔Π-Erased ×-cong Erased-Π↔Π-Erased ⟩
    (Erased A → Erased B) × (Erased B → Erased A)  ↝⟨ inverse ⇔↔→×→ ⟩□
    (Erased A ⇔ Erased B)                          □

------------------------------------------------------------------------
-- Some results that follow if "[]-cong" is an equivalence

module []-cong₂
  ([]-cong :
     ∀ {a} {@0 A : Type a} {@0 x y : A} →
     Erased (x ≡ y) → [ x ] ≡ [ y ])
  ([]-cong-equivalence :
     ∀ {a} {@0 A : Type a} {@0 x y : A} →
     Is-equivalence ([]-cong {x = x} {y = y}))
  where

  open []-cong₁ []-cong public

  -- There is a bijection between erased equality proofs and
  -- equalities between erased values.

  Erased-≡↔[]≡[] :
    {@0 A : Type a} {@0 x y : A} →
    Erased (x ≡ y) ↔ [ x ] ≡ [ y ]
  Erased-≡↔[]≡[] = _≃_.bijection Eq.⟨ _ , []-cong-equivalence ⟩

  -- The inverse of []-cong.

  []-cong⁻¹ :
    {@0 A : Type a} {@0 x y : A} →
    [ x ] ≡ [ y ] → Erased (x ≡ y)
  []-cong⁻¹ = _↔_.from Erased-≡↔[]≡[]

  ----------------------------------------------------------------------
  -- All h-levels are closed under Erased

  -- Erased commutes with H-level′ n (assuming extensionality).

  Erased-H-level′↔H-level′ :
    {@0 A : Type a} →
    Extensionality? k a a →
    ∀ n → Erased (H-level′ n A) ↝[ k ] H-level′ n (Erased A)
  Erased-H-level′↔H-level′ {A = A} ext zero =
    Erased (H-level′ zero A)                                              ↔⟨⟩
    Erased (∃ λ (x : A) → (y : A) → x ≡ y)                                ↔⟨ Erased-Σ↔Σ ⟩
    (∃ λ (x : Erased A) → Erased ((y : A) → erased x ≡ y))                ↔⟨ (∃-cong λ _ → Erased-Π↔Π-Erased) ⟩
    (∃ λ (x : Erased A) → (y : Erased A) → Erased (erased x ≡ erased y))  ↝⟨ (∃-cong λ _ → ∀-cong ext λ _ → from-isomorphism Erased-≡↔[]≡[]) ⟩
    (∃ λ (x : Erased A) → (y : Erased A) → x ≡ y)                         ↔⟨⟩
    H-level′ zero (Erased A)                                              □
  Erased-H-level′↔H-level′ {A = A} ext (suc n) =
    Erased (H-level′ (suc n) A)                                      ↔⟨⟩
    Erased ((x y : A) → H-level′ n (x ≡ y))                          ↔⟨ Erased-Π↔Π-Erased ⟩
    ((x : Erased A) → Erased ((y : A) → H-level′ n (erased x ≡ y)))  ↝⟨ (∀-cong ext λ _ → from-isomorphism Erased-Π↔Π-Erased) ⟩
    ((x y : Erased A) → Erased (H-level′ n (erased x ≡ erased y)))   ↝⟨ (∀-cong ext λ _ → ∀-cong ext λ _ → Erased-H-level′↔H-level′ ext n) ⟩
    ((x y : Erased A) → H-level′ n (Erased (erased x ≡ erased y)))   ↝⟨ (∀-cong ext λ _ → ∀-cong ext λ _ → H-level′-cong ext n Erased-≡↔[]≡[]) ⟩
    ((x y : Erased A) → H-level′ n (x ≡ y))                          ↔⟨⟩
    H-level′ (suc n) (Erased A)                                      □

  -- Erased commutes with H-level n (assuming extensionality).

  Erased-H-level↔H-level :
    {@0 A : Type a} →
    Extensionality? k a a →
    ∀ n → Erased (H-level n A) ↝[ k ] H-level n (Erased A)
  Erased-H-level↔H-level {A = A} ext n =
    Erased (H-level n A)   ↝⟨ Erased-cong? H-level↔H-level′ ext ⟩
    Erased (H-level′ n A)  ↝⟨ Erased-H-level′↔H-level′ ext n ⟩
    H-level′ n (Erased A)  ↝⟨ inverse-ext? H-level↔H-level′ ext ⟩□
    H-level n (Erased A)   □

  -- H-level n is closed under Erased.

  H-level-Erased :
    {@0 A : Type a} →
    ∀ n → @0 H-level n A → H-level n (Erased A)
  H-level-Erased n h = Erased-H-level↔H-level _ n [ h ]

  ----------------------------------------------------------------------
  -- Some properties related to "Modalities in Homotopy Type Theory"
  -- by Rijke, Shulman and Spitters

  -- Erased is a lex modality (see Theorem 3.1, case (i) in
  -- "Modalities in Homotopy Type Theory" for the definition used
  -- here).

  lex-modality :
    {x y : A} → Contractible (Erased A) → Contractible (Erased (x ≡ y))
  lex-modality {A = A} {x = x} {y = y} =
    Contractible (Erased A)        ↝⟨ _⇔_.from (Erased-H-level↔H-level _ 0) ⟩
    Erased (Contractible A)        ↝⟨ map (⇒≡ 0) ⟩
    Erased (Contractible (x ≡ y))  ↝⟨ Erased-H-level↔H-level _ 0 ⟩□
    Contractible (Erased (x ≡ y))  □

  -- A function f is Erased-connected in the sense of Rijke et al.
  -- exactly when there is an erased proof showing that f is an
  -- equivalence (assuming extensionality).
  --
  -- See also Erased-Is-equivalence↔Is-equivalence below.

  Erased-connected↔Erased-Is-equivalence :
    {A : Type a} {B : Type b} {f : A → B} →
    Extensionality? k (a ⊔ b) (a ⊔ b) →
    (∀ y → Contractible (Erased (f ⁻¹ y))) ↝[ k ]
    Erased (Is-equivalence f)
  Erased-connected↔Erased-Is-equivalence {a = a} {k = k} {f = f} ext =
    (∀ y → Contractible (Erased (f ⁻¹ y)))  ↝⟨ (∀-cong (lower-extensionality? k a lzero ext) λ _ →
                                                inverse-ext? (λ ext → Erased-H-level↔H-level ext 0) ext) ⟩
    (∀ y → Erased (Contractible (f ⁻¹ y)))  ↔⟨ inverse Erased-Π↔Π ⟩
    Erased (∀ y → Contractible (f ⁻¹ y))    ↔⟨⟩
    Erased (Is-equivalence f)               □

  ----------------------------------------------------------------------
  -- Some isomorphisms

  -- Erased "commutes" with _⁻¹_.

  Erased-⁻¹ :
    {@0 A : Type a} {@0 B : Type b} {@0 f : A → B} {@0 y : B} →
    Erased (f ⁻¹ y) ↔ map f ⁻¹ [ y ]
  Erased-⁻¹ {f = f} {y = y} =
    Erased (∃ λ x → f x ≡ y)             ↝⟨ Erased-Σ↔Σ ⟩
    (∃ λ x → Erased (f (erased x) ≡ y))  ↝⟨ (∃-cong λ _ → Erased-≡↔[]≡[]) ⟩□
    (∃ λ x → map f x ≡ [ y ])            □

  -- Erased "commutes" with Is-equivalence.

  Erased-Is-equivalence↔Is-equivalence :
    {@0 A : Type a} {@0 B : Type b} {@0 f : A → B} →
    Extensionality? k (a ⊔ b) (a ⊔ b) →
    Erased (Is-equivalence f) ↝[ k ] Is-equivalence (map f)
  Erased-Is-equivalence↔Is-equivalence {a = a} {k = k} {f = f} ext =
    Erased (∀ x → Contractible (f ⁻¹ x))           ↔⟨ Erased-Π↔Π-Erased ⟩
    (∀ x → Erased (Contractible (f ⁻¹ erased x)))  ↝⟨ (∀-cong ext′ λ _ → Erased-H-level↔H-level ext 0) ⟩
    (∀ x → Contractible (Erased (f ⁻¹ erased x)))  ↝⟨ (∀-cong ext′ λ _ → H-level-cong ext 0 Erased-⁻¹) ⟩□
    (∀ x → Contractible (map f ⁻¹ x))              □
    where
    ext′ = lower-extensionality? k a lzero ext

  -- Erased "commutes" with Split-surjective.

  Erased-Split-surjective↔Split-surjective :
    {@0 A : Type a} {@0 B : Type b} {@0 f : A → B} →
    Extensionality? k b (a ⊔ b) →
    Erased (Split-surjective f) ↝[ k ]
    Split-surjective (map f)
  Erased-Split-surjective↔Split-surjective {f = f} ext =
    Erased (∀ y → ∃ λ x → f x ≡ y)                    ↔⟨ Erased-Π↔Π-Erased ⟩
    (∀ y → Erased (∃ λ x → f x ≡ erased y))           ↝⟨ (∀-cong ext λ _ → from-isomorphism Erased-Σ↔Σ) ⟩
    (∀ y → ∃ λ x → Erased (f (erased x) ≡ erased y))  ↝⟨ (∀-cong ext λ _ → ∃-cong λ _ → from-isomorphism Erased-≡↔[]≡[]) ⟩
    (∀ y → ∃ λ x → [ f (erased x) ] ≡ y)              ↔⟨⟩
    (∀ y → ∃ λ x → map f x ≡ y)                       □

  -- Erased "commutes" with Has-quasi-inverse.

  Erased-Has-quasi-inverse↔Has-quasi-inverse :
    {@0 A : Type a} {@0 B : Type b} {@0 f : A → B} →
    Extensionality? k (a ⊔ b) (a ⊔ b) →
    Erased (Has-quasi-inverse f) ↝[ k ]
    Has-quasi-inverse (map f)
  Erased-Has-quasi-inverse↔Has-quasi-inverse
    {A = A} {B = B} {f = f} ext =

    Erased (∃ λ g → (∀ x → f (g x) ≡ x) × (∀ x → g (f x) ≡ x))            ↔⟨ Erased-Σ↔Σ ⟩

    (∃ λ g →
       Erased ((∀ x → f (erased g x) ≡ x) × (∀ x → erased g (f x) ≡ x)))  ↝⟨ (∃-cong λ _ → from-isomorphism Erased-Σ↔Σ) ⟩

    (∃ λ g →
       Erased (∀ x → f (erased g x) ≡ x) ×
       Erased (∀ x → erased g (f x) ≡ x))                                 ↝⟨ Σ-cong Erased-Π↔Π-Erased (λ g →
                                                                             lemma ext f (erased g) ×-cong lemma ext (erased g) f) ⟩□
    (∃ λ g → (∀ x → map f (g x) ≡ x) × (∀ x → g (map f x) ≡ x))           □
    where
    lemma :
      {@0 A : Type a} {@0 B : Type b} →
      Extensionality? k (a ⊔ b) (a ⊔ b) →
      (@0 f : A → B) (@0 g : B → A) → _ ↝[ k ] _
    lemma {a = a} {k = k} ext f g =
      Erased (∀ x → f (g x) ≡ x)                    ↔⟨ Erased-Π↔Π-Erased ⟩
      (∀ x → Erased (f (g (erased x)) ≡ erased x))  ↝⟨ (∀-cong (lower-extensionality? k a a ext) λ _ → from-isomorphism Erased-≡↔[]≡[]) ⟩
      (∀ x → [ f (g (erased x)) ] ≡ x)              ↔⟨⟩
      (∀ x → map (f ∘ g) x ≡ x)                     □

  -- Erased "commutes" with Injective.

  Erased-Injective↔Injective :
    {@0 A : Type a} {@0 B : Type b} {@0 f : A → B} →
    Extensionality? k (a ⊔ b) (a ⊔ b) →
    Erased (Injective f) ↝[ k ] Injective (map f)
  Erased-Injective↔Injective {a = a} {b = b} {k = k} {f = f} ext =
    Erased (∀ {x y} → f x ≡ f y → x ≡ y)                          ↔⟨ Erased-cong-↔ Bijection.implicit-Π↔Π ⟩

    Erased (∀ x {y} → f x ≡ f y → x ≡ y)                          ↝⟨ Erased-cong? (λ {k} ext → ∀-cong (lower-extensionality? k b lzero ext) λ _ →
                                                                     from-isomorphism Bijection.implicit-Π↔Π) ext ⟩

    Erased (∀ x y → f x ≡ f y → x ≡ y)                            ↔⟨ Erased-Π↔Π-Erased ⟩

    (∀ x → Erased (∀ y → f (erased x) ≡ f y → erased x ≡ y))      ↝⟨ (∀-cong ext′ λ _ → from-isomorphism Erased-Π↔Π-Erased) ⟩

    (∀ x y →
     Erased (f (erased x) ≡ f (erased y) → erased x ≡ erased y))  ↝⟨ (∀-cong ext′ λ _ → ∀-cong ext′ λ _ → from-isomorphism Erased-Π↔Π-Erased) ⟩

    (∀ x y →
     Erased (f (erased x) ≡ f (erased y)) →
     Erased (erased x ≡ erased y))                                ↝⟨ (∀-cong ext′ λ _ → ∀-cong ext′ λ _ →
                                                                      generalise-ext?-sym
                                                                        (λ {k} ext → →-cong (lower-extensionality? ⌊ k ⌋-sym a b ext)
                                                                                            (from-isomorphism Erased-≡↔[]≡[])
                                                                                            (from-isomorphism Erased-≡↔[]≡[]))
                                                                        ext) ⟩

    (∀ x y → [ f (erased x) ] ≡ [ f (erased y) ] → x ≡ y)         ↝⟨ (∀-cong ext′ λ _ → from-isomorphism $ inverse Bijection.implicit-Π↔Π) ⟩

    (∀ x {y} → [ f (erased x) ] ≡ [ f (erased y) ] → x ≡ y)       ↔⟨ inverse Bijection.implicit-Π↔Π ⟩□

    (∀ {x y} → [ f (erased x) ] ≡ [ f (erased y) ] → x ≡ y)       □
    where
    ext′ = lower-extensionality? k b lzero ext

  -- Erased preserves injections.

  Erased-cong-↣ :
    {@0 A : Type a} {@0 B : Type b} →
    @0 A ↣ B → Erased A ↣ Erased B
  Erased-cong-↣ A↣B = record
    { to        = map (_↣_.to A↣B)
    ; injective = Erased-Injective↔Injective _ [ _↣_.injective A↣B ]
    }

  ----------------------------------------------------------------------
  -- A lemma

  -- If A is a proposition, then [_]→ {A = A} is an embedding.
  --
  -- See also Erased-Is-embedding-[] and Erased-Split-surjective-[]
  -- below as well as Very-stable→Is-embedding-[] and
  -- Very-stable→Split-surjective-[] in Erased.Stability and
  -- Injective-[] and Is-embedding-[] in Erased.With-K.

  Is-proposition→Is-embedding-[] :
    Is-proposition A → Is-embedding ([_]→ {A = A})
  Is-proposition→Is-embedding-[] prop =
    _⇔_.to (Emb.Injective⇔Is-embedding
              set (H-level-Erased 2 set) [_]→)
      (λ _ → prop _ _)
    where
    set = mono₁ 1 prop

------------------------------------------------------------------------
-- More lemmas

-- In an erased context [_]→ is always an embedding.

Erased-Is-embedding-[] :
  {@0 A : Type a} → Erased (Is-embedding ([_]→ {A = A}))
Erased-Is-embedding-[] =
  [ (λ x y → _≃_.is-equivalence (
       x ≡ y          ↝⟨ inverse $ Eq.≃-≡ $ Eq.↔⇒≃ $ inverse $ erased Erased↔ ⟩□
       [ x ] ≡ [ y ]  □))
  ]

-- In an erased context [_]→ is always split surjective.

Erased-Split-surjective-[] :
  {@0 A : Type a} → Erased (Split-surjective ([_]→ {A = A}))
Erased-Split-surjective-[] = [ (λ ([ x ]) → x , refl _) ]

------------------------------------------------------------------------
-- Some results that follow if "[]-cong" is an equivalence that maps
-- [ refl x ] to refl [ x ]

-- Some consequences of the axiomatisation.

module []-cong₃ (ax : ∀ {a} → []-cong-axiomatisation a) where

  private
    module A {a} = []-cong-axiomatisation (ax {a = a})
  open A public hiding ([]-cong-[refl])
  open A renaming ([]-cong-[refl] to []-cong-[refl]′)

  open []-cong₂ []-cong []-cong-equivalence public

  ----------------------------------------------------------------------
  -- Some definitions directly related to []-cong and []-cong⁻¹

  -- Rearrangement lemmas for []-cong and []-cong⁻¹.

  []-cong-[]≡cong-[] :
    {x≡y : x ≡ y} → []-cong [ x≡y ] ≡ cong [_]→ x≡y
  []-cong-[]≡cong-[] {x = x} {x≡y = x≡y} = elim¹
    (λ x≡y → []-cong [ x≡y ] ≡ cong [_]→ x≡y)
    ([]-cong [ refl x ]  ≡⟨ []-cong-[refl]′ ⟩
     refl [ x ]          ≡⟨ sym $ cong-refl _ ⟩∎
     cong [_]→ (refl x)  ∎)
    x≡y

  []-cong⁻¹≡[cong-erased] :
    {@0 A : Type a} {@0 x y : A} {@0 x≡y : [ x ] ≡ [ y ]} →
    []-cong⁻¹ x≡y ≡ [ cong erased x≡y ]
  []-cong⁻¹≡[cong-erased] {x≡y = x≡y} = []-cong
    [ erased ([]-cong⁻¹ x≡y)      ≡⟨ cong erased (_↔_.from (from≡↔≡to $ Eq.↔⇒≃ Erased-≡↔[]≡[]) lemma) ⟩
      erased [ cong erased x≡y ]  ≡⟨⟩
      cong erased x≡y             ∎
    ]
    where
    @0 lemma : _
    lemma =
      x≡y                          ≡⟨ cong-id _ ⟩
      cong id x≡y                  ≡⟨⟩
      cong ([_]→ ∘ erased) x≡y     ≡⟨ sym $ cong-∘ _ _ _ ⟩
      cong [_]→ (cong erased x≡y)  ≡⟨ sym []-cong-[]≡cong-[] ⟩∎
      []-cong [ cong erased x≡y ]  ∎

  -- A "computation rule" for []-cong⁻¹.

  []-cong⁻¹-refl :
    {@0 A : Type a} {@0 x : A} →
    []-cong⁻¹ (refl [ x ]) ≡ [ refl x ]
  []-cong⁻¹-refl {x = x} =
    []-cong⁻¹ (refl [ x ])        ≡⟨ []-cong⁻¹≡[cong-erased] ⟩
    [ cong erased (refl [ x ]) ]  ≡⟨ []-cong [ cong-refl _ ] ⟩∎
    [ refl x ]                    ∎

  -- A stronger variant of []-cong-[refl]′.

  []-cong-[refl] :
    {@0 A : Type a} {@0 x : A} →
    []-cong [ refl x ] ≡ refl [ x ]
  []-cong-[refl] {A = A} {x = x} =
    sym $ _↔_.to (from≡↔≡to $ Eq.↔⇒≃ Erased-≡↔[]≡[]) (
      []-cong⁻¹ (refl [ x ])  ≡⟨ []-cong⁻¹-refl ⟩∎
      [ refl x ]              ∎)

  -- []-cong and []-cong⁻¹ commute (kind of) with sym.

  []-cong⁻¹-sym :
    {@0 A : Type a} {@0 x y : A} {x≡y : [ x ] ≡ [ y ]} →
    []-cong⁻¹ (sym x≡y) ≡ map sym ([]-cong⁻¹ x≡y)
  []-cong⁻¹-sym = elim¹
    (λ x≡y → []-cong⁻¹ (sym x≡y) ≡ map sym ([]-cong⁻¹ x≡y))
    ([]-cong⁻¹ (sym (refl _))      ≡⟨ cong []-cong⁻¹ sym-refl ⟩
     []-cong⁻¹ (refl _)            ≡⟨ []-cong⁻¹-refl ⟩
     [ refl _ ]                    ≡⟨ []-cong [ sym sym-refl ] ⟩
     [ sym (refl _) ]              ≡⟨⟩
     map sym [ refl _ ]            ≡⟨ cong (map sym) $ sym []-cong⁻¹-refl ⟩∎
     map sym ([]-cong⁻¹ (refl _))  ∎)
    _

  []-cong-[sym] :
    {@0 A : Type a} {@0 x y : A} {@0 x≡y : x ≡ y} →
    []-cong [ sym x≡y ] ≡ sym ([]-cong [ x≡y ])
  []-cong-[sym] {x≡y = x≡y} =
    sym $ _↔_.to (from≡↔≡to $ Eq.↔⇒≃ Erased-≡↔[]≡[]) (
      []-cong⁻¹ (sym ([]-cong [ x≡y ]))      ≡⟨ []-cong⁻¹-sym ⟩
      map sym ([]-cong⁻¹ ([]-cong [ x≡y ]))  ≡⟨ cong (map sym) $ _↔_.left-inverse-of Erased-≡↔[]≡[] _ ⟩∎
      map sym [ x≡y ]                        ∎)

  -- []-cong and []-cong⁻¹ commute (kind of) with trans.

  []-cong⁻¹-trans :
    {@0 A : Type a} {@0 x y z : A}
    {x≡y : [ x ] ≡ [ y ]} {y≡z : [ y ] ≡ [ z ]} →
    []-cong⁻¹ (trans x≡y y≡z) ≡
    [ trans (erased ([]-cong⁻¹ x≡y)) (erased ([]-cong⁻¹ y≡z)) ]
  []-cong⁻¹-trans {y≡z = y≡z} = elim₁
    (λ x≡y → []-cong⁻¹ (trans x≡y y≡z) ≡
             [ trans (erased ([]-cong⁻¹ x≡y)) (erased ([]-cong⁻¹ y≡z)) ])
    ([]-cong⁻¹ (trans (refl _) y≡z)                                    ≡⟨ cong []-cong⁻¹ $ trans-reflˡ _ ⟩
     []-cong⁻¹ y≡z                                                     ≡⟨⟩
     [ erased ([]-cong⁻¹ y≡z) ]                                        ≡⟨ []-cong [ sym $ trans-reflˡ _ ] ⟩
     [ trans (refl _) (erased ([]-cong⁻¹ y≡z)) ]                       ≡⟨⟩
     [ trans (erased [ refl _ ]) (erased ([]-cong⁻¹ y≡z)) ]            ≡⟨ []-cong [ cong (flip trans _) $ cong erased $ sym
                                                                          []-cong⁻¹-refl ] ⟩∎
     [ trans (erased ([]-cong⁻¹ (refl _))) (erased ([]-cong⁻¹ y≡z)) ]  ∎)
    _

  []-cong-[trans] :
    {@0 A : Type a} {@0 x y z : A} {@0 x≡y : x ≡ y} {@0 y≡z : y ≡ z} →
    []-cong [ trans x≡y y≡z ] ≡
    trans ([]-cong [ x≡y ]) ([]-cong [ y≡z ])
  []-cong-[trans] {x≡y = x≡y} {y≡z = y≡z} =
    sym $ _↔_.to (from≡↔≡to $ Eq.↔⇒≃ Erased-≡↔[]≡[]) (
      []-cong⁻¹ (trans ([]-cong [ x≡y ]) ([]-cong [ y≡z ]))  ≡⟨ []-cong⁻¹-trans ⟩

      [ trans (erased ([]-cong⁻¹ ([]-cong [ x≡y ])))
              (erased ([]-cong⁻¹ ([]-cong [ y≡z ]))) ]       ≡⟨ []-cong [ cong₂ (λ p q → trans (erased p) (erased q))
                                                                            (_↔_.left-inverse-of Erased-≡↔[]≡[] _)
                                                                            (_↔_.left-inverse-of Erased-≡↔[]≡[] _) ] ⟩∎
      [ trans x≡y y≡z ]                                      ∎)

  -- In an erased context there is an equivalence between equality of
  -- values and equality of "boxed" values.

  @0 ≡≃[]≡[] : (x ≡ y) ≃ ([ x ] ≡ [ y ])
  ≡≃[]≡[] = Eq.↔⇒≃ (record
    { surjection = record
      { logical-equivalence = record
        { to   = []-cong ∘ [_]→
        ; from = cong erased
        }
      ; right-inverse-of = λ eq →
          []-cong [ cong erased eq ]  ≡⟨ []-cong-[]≡cong-[] ⟩
          cong [_]→ (cong erased eq)  ≡⟨ cong-∘ _ _ _ ⟩
          cong id eq                  ≡⟨ sym $ cong-id _ ⟩∎
          eq                          ∎
      }
    ; left-inverse-of = λ eq →
        cong erased ([]-cong [ eq ])  ≡⟨ cong (cong erased) []-cong-[]≡cong-[] ⟩
        cong erased (cong [_]→ eq)    ≡⟨ cong-∘ _ _ _ ⟩
        cong id eq                    ≡⟨ sym $ cong-id _ ⟩∎
        eq                            ∎
    })

  -- The left-to-right and right-to-left directions of the equivalence
  -- are definitionally equal to certain functions.

  _ : _≃_.to (≡≃[]≡[] {x = x} {y = y}) ≡ []-cong ∘ [_]→
  _ = refl _

  @0 _ : _≃_.from (≡≃[]≡[] {x = x} {y = y}) ≡ cong erased
  _ = refl _

  -- Another rearrangement lemma.

  subst-[]-cong-[] :
    {P : @0 A → Type p} {p : P x} →
    subst (λ ([ x ]) → P x) ([]-cong [ eq ]) p ≡
    subst (λ x → P x) eq p
  subst-[]-cong-[] {eq = eq} {P = P} {p = p} = elim¹
    (λ eq → subst (λ ([ x ]) → P x) ([]-cong [ eq ]) p ≡
            subst (λ x → P x) eq p)
    (subst (λ ([ x ]) → P x) ([]-cong [ refl _ ]) p  ≡⟨ cong (flip (subst _) _) []-cong-[refl] ⟩
     subst (λ ([ x ]) → P x) (refl [ _ ]) p          ≡⟨ subst-refl _ _ ⟩
     p                                               ≡⟨ sym $ subst-refl _ _ ⟩∎
     subst (λ x → P x) (refl _) p                    ∎)
    eq

  -- The function map (cong f) can be expressed in terms of
  -- cong (map f) (up to pointwise equality).

  map-cong≡cong-map :
    {@0 A : Type a} {@0 B : Type b} {@0 x y : A}
    {@0 f : A → B} {x≡y : Erased (x ≡ y)} →
    map (cong f) x≡y ≡ []-cong⁻¹ (cong (map f) ([]-cong x≡y))
  map-cong≡cong-map {f = f} {x≡y = [ x≡y ]} =
    [ cong f x≡y ]                                    ≡⟨⟩
    [ cong (erased ∘ map f ∘ [_]→) x≡y ]              ≡⟨ []-cong [ sym $ cong-∘ _ _ _ ] ⟩
    [ cong (erased ∘ map f) (cong [_]→ x≡y) ]         ≡⟨ []-cong [ cong (cong _) $ sym []-cong-[]≡cong-[] ] ⟩
    [ cong (erased ∘ map f) ([]-cong [ x≡y ]) ]       ≡⟨ []-cong [ sym $ cong-∘ _ _ _ ] ⟩
    [ cong erased (cong (map f) ([]-cong [ x≡y ])) ]  ≡⟨ sym []-cong⁻¹≡[cong-erased] ⟩∎
    []-cong⁻¹ (cong (map f) ([]-cong [ x≡y ]))        ∎
