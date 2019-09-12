------------------------------------------------------------------------
-- Queue instances for the queues in Queue.Bankers
------------------------------------------------------------------------

{-# OPTIONS --without-K --safe #-}

open import Equality

module Queue.Bankers.Instances
  {c⁺} (eq : ∀ {a p} → Equality-with-J a p c⁺)
  where

open Derived-definitions-and-properties eq

open import Prelude

open import Queue eq
open import Queue.Bankers eq as Q using (Queue)

private
  variable
    ℓ ℓ₁ ℓ₂ : Level

instance

  -- Instances.

  Queue-is-queue : Is-queue Queue (λ _ → ↑ _ ⊤) ℓ
  Queue-is-queue .Is-queue.to-List                 = λ _ → Q.to-List
  Queue-is-queue .Is-queue.from-List               = Q.from-List
  Queue-is-queue .Is-queue.to-List-from-List       = Q.to-List-from-List
  Queue-is-queue .Is-queue.empty                   = Q.empty
  Queue-is-queue .Is-queue.to-List-empty           = Q.to-List-empty
  Queue-is-queue .Is-queue.cons                    = Q.cons
  Queue-is-queue .Is-queue.to-List-cons    {q = q} = Q.to-List-cons q
  Queue-is-queue .Is-queue.enqueue                 = Q.enqueue
  Queue-is-queue .Is-queue.to-List-enqueue {q = q} = Q.to-List-enqueue q
  Queue-is-queue .Is-queue.dequeue                 = λ _ → Q.dequeue
  Queue-is-queue .Is-queue.to-List-dequeue {q = q} = Q.to-List-dequeue q

  Queue-is-queue-with-map : Is-queue-with-map Queue ℓ₁ ℓ₂
  Queue-is-queue-with-map .Is-queue-with-map.map                 = Q.map
  Queue-is-queue-with-map .Is-queue-with-map.to-List-map {q = q} =
    Q.to-List-map q
