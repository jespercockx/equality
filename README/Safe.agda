------------------------------------------------------------------------
-- Safe modules
------------------------------------------------------------------------

{-# OPTIONS --cubical --safe --sized-types #-}

module README.Safe where

-- Definitions of some basic types and some related functions.

import Prelude

-- Support for sized types.

import Prelude.Size

-- Logical equivalences.

import Logical-equivalence

-- Two logically equivalent axiomatisations of equality. Many of the
-- modules below are parametrised by a definition of equality that
-- satisfies these axioms.
--
-- The reason for this parametrisation was that I thought that I might
-- later want to use a definition of equality where the application
-- elim P r (refl x) did not compute to r x, unlike the equality in
-- Equality.Propositional. Now, with the advent of cubical type theory
-- and paths, there is such an equality (see Equality.Path).
--
-- (Note that Equality.Tactic contains a definition of equality which,
-- roughly speaking, computes like the one in Equality.Propositional.)

import Equality

-- One model of the axioms: propositional equality.

import Equality.Propositional

-- A simple tactic for proving equality of equality proofs.

import Equality.Tactic

-- Injections.

import Injection

-- Split surjections.

import Surjection

-- Some definitions related to and properties of natural numbers.

import Nat

-- H-levels, along with some general properties.

import H-level

-- Types with decidable equality have unique identity proofs, and
-- related results.

import Equality.Decidable-UIP

-- Some decision procedures for equality.

import Equality.Decision-procedures

-- Bijections.

import Bijection

-- Groupoids.

import Groupoid

-- Closure properties for h-levels.

import H-level.Closure

-- Preimages.

import Preimage

-- Equivalences.

import Equivalence

-- Embeddings.

import Embedding

-- A universe which includes several kinds of functions (ordinary
-- functions, logical equivalences, injections, embeddings,
-- surjections, bijections and equivalences).

import Function-universe

-- Pointed types and loop spaces.

import Pointed-type

-- Equalities can be turned into groupoids which are sometimes
-- commutative.

import Equality.Groupoid

-- Results relating different instances of certain axioms related to
-- equality.

import Equality.Instances-related

-- A parametrised specification of "natrec", along with a proof that
-- the specification is propositional (assuming extensionality).

import Nat.Eliminator

-- Some definitions related to and properties of booleans.

import Bool

-- Monads.

import Monad

-- The reader monad transformer.

import Monad.Reader

-- The state monad transformer.

import Monad.State

-- The double-negation monad.

import Double-negation

-- The univalence axiom.

import Univalence-axiom

-- Paths, extensionality and univalence.

import Equality.Path

-- Isomorphisms and equalities relating an arbitrary "equality with J"
-- to path equality, along with proofs of extensionality and
-- univalence for the "equality with J".

import Equality.Path.Isomorphisms

-- The cubical identity type.

import Equality.Id

-- The "interval".

import Interval

-- Truncation.

import H-level.Truncation

-- Propositional truncation.

import H-level.Truncation.Propositional

-- The "circle".

import Circle

-- Suspensions.

import Suspension

-- Some omniscience principles.

import Omniscience

-- Lists.

import List

-- Conatural numbers.

import Conat

-- Colists.

import Colist

-- Some definitions related to and properties of finite sets.

import Fin

-- M-types.

import M

-- Some definitions related to and properties of the Maybe type.

import Maybe

-- Vectors, defined using a recursive function.

import Vec

-- Vectors, defined using an inductive family.

import Vec.Data

-- Vectors, defined as functions from finite sets.

import Vec.Function

-- Some properties related to the const function.

import Const

-- Support for reflection.

import TC-monad

-- Some tactics aimed at making equational reasoning proofs more
-- readable.

import Tactic.By

-- Quotients, defined as families of equivalence classes.

import Quotient.Families-of-equivalence-classes

-- Quotients (set-quotients), defined using a higher inductive type.

import Quotient

-- Isomorphism of monoids on sets coincides with equality (assuming
-- univalence).

import Univalence-axiom.Isomorphism-is-equality.Monoid

-- In fact, several large classes of algebraic structures satisfy the
-- property that isomorphism coincides with equality (assuming
-- univalence).

import Univalence-axiom.Isomorphism-is-equality.Simple
import Univalence-axiom.Isomorphism-is-equality.Simple.Variant
import Univalence-axiom.Isomorphism-is-equality.More
import Univalence-axiom.Isomorphism-is-equality.More.Examples

-- A class of structures that satisfies the property that isomorphic
-- instances of a structure are equal (assuming univalence). This code
-- is superseded by the code above, but preserved because it is
-- mentioned in a blog post.

import Univalence-axiom.Isomorphism-implies-equality

-- 1-categories.

import Category
import Functor
import Adjunction

-- Aczel's structure identity principle (for 1-categories).

import Structure-identity-principle

-- The structure identity principle can be used to establish that
-- isomorphism coincides with equality (assuming univalence).

import
  Univalence-axiom.Isomorphism-is-equality.Structure-identity-principle

-- Bag equivalence for lists.

import Bag-equivalence

-- Binary trees.

import Tree

-- Implementations of tree sort. One only establishes that the
-- algorithm permutes its input, the other one also establishes
-- sortedness.

import Tree-sort.Partial
import Tree-sort.Full
import Tree-sort.Examples

-- Containers, including a definition of bag equivalence.

import Container

-- An implementation of tree sort which uses containers to represent
-- trees and lists.
--
-- In the module Tree-sort.Full indexed types are used to enforce
-- sortedness, but Containers contains a definition of non-indexed
-- containers, so sortedness is not enforced in this development.
--
-- The implementation using containers has the advantage of uniform
-- definitions of Any/membership/bag equivalence, but the other
-- implementations use more direct definitions and are perhaps a bit
-- "leaner".

import Container.List
import Container.Tree
import Container.Tree-sort
import Container.Tree-sort.Example

-- The stream container.

import Container.Stream

-- Record types with manifest fields and "with".

import Records-with-with

-- Overview of code related to some papers.

import README.Bag-equivalence
import README.Isomorphism-is-equality
import README.Weak-J
