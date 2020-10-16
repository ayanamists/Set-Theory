(*** Formal Construction of a Set Theory in Coq ***)
(** based on the thesis by Jonas Kaiser, November 23, 2012 **)
(** Coq coding by choukh, April 2020 **)

Require Export ZFC.ZFC0.

(*** ZFC集合论1：配对，单集，二元并，集族的并 ***)

Definition Doubleton : set := 𝒫 𝒫 ∅.

Lemma DoubletonI1 : ∅ ∈ Doubleton.
Proof. apply PowerAx. intros x Hx. exfalso0. Qed.

Lemma DoubletonI2 : 𝒫 ∅ ∈ Doubleton.
Proof.
  apply PowerAx. intros x Hx.
  apply only_empty_in_power_empty in Hx.
  subst. apply empty_in_all_power.
Qed.

Definition PairRepl : set → set → set → set := λ a b x,
  match (ixm (∅ ∈ x)) with
  | inl _ => b
  | inr _ => a
  end.

(** 配对 **)
Definition Pair : set → set → set := λ x y,
  {PairRepl x y | w ∊ Doubleton}.
Notation "{ x , y }" := (Pair x y).

Lemma PairI1 : ∀ x y, x ∈ {x, y}.
Proof.
  intros. apply ReplAx. exists ∅. split.
  - apply DoubletonI1.
  - unfold PairRepl. destruct (ixm (∅ ∈ ∅)).
    + exfalso0.
    + reflexivity.
Qed.

Lemma PairI2 : ∀ x y, y ∈ {x, y}.
Proof.
  intros. apply ReplAx. exists (𝒫 ∅). split.
  - apply DoubletonI2.
  - unfold PairRepl. destruct (ixm (∅ ∈ 𝒫 ∅)).
    + reflexivity.
    + exfalso. apply n. apply empty_in_all_power. 
Qed.

Lemma PairE : ∀ x y, ∀w ∈ {x, y}, w = x ∨ w = y.
Proof.
  intros x y w Hw. apply ReplAx in Hw as [z [_ Heq]].
  unfold PairRepl in Heq. destruct (ixm (∅ ∈ z)).
  - subst. right. reflexivity.
  - subst. left. reflexivity.
Qed.

(* 配对是顺序无关的 *)
Theorem pair_ordering_agnostic : ∀ a b, {a, b} = {b, a}.
Proof.
  intros. apply ExtAx.
  split; intros.
  - apply PairE in H.
    destruct H as [H1|H2].
    + subst x. apply PairI2.
    + subst x. apply PairI1.
  - apply PairE in H.
    destruct H as [H1|H2].
    + subst x. apply PairI2.
    + subst x. apply PairI1.
Qed.

(** 单集 **)
Definition Singleton : set → set := λ x, {x, x}.
Notation "⎨ x ⎬" := (Singleton x).

Lemma SingI : ∀ x, x ∈ ⎨x⎬.
Proof. unfold Singleton. intros. apply PairI1. Qed.
Hint Immediate SingI : core.

Lemma SingE : ∀ x y, x ∈ ⎨y⎬ → x = y.
Proof.
  intros. apply PairE in H.
  destruct H; apply H.
Qed.

Lemma SingNI : ∀ A B, A ≠ B → A ∉ ⎨B⎬.
Proof.
  intros * Hnq H. apply Hnq. apply SingE in H. apply H.
Qed.

Lemma SingNE : ∀ A B, A ∉ ⎨B⎬ → A ≠ B.
Proof.
  intros * H Heq. apply H. subst A. apply SingI.
Qed.

Declare Scope ZFC1_scope.
Delimit Scope ZFC1_scope with zfc1.
Open Scope ZFC1_scope.

(* 壹 *)
Definition One := ⎨∅⎬.
Notation "1" := One : ZFC1_scope.

Lemma OneI1 : ∅ ∈ 1.
Proof. apply SingI. Qed.

Lemma OneI2 : ∀ A, A = ∅ → A ∈ 1.

Proof. intros. subst. apply OneI1. Qed.
Lemma OneE : ∀ A, A ∈ 1 → A = ∅.
Proof. intros. apply SingE. apply H. Qed.

Example empty_neq_one : ∅ ≠ 1.
Proof.
  intros H. eapply ExtAx in H.
  destruct H as [_ H].
  pose proof (H OneI1).
  eapply EmptyAx. apply H0.
Qed.

(* 贰 *)
Definition Two := {∅, 1}.
Notation "2" := Two : ZFC1_scope.

Lemma TwoI1 : ∅ ∈ 2.
Proof. apply PairI1. Qed.

Lemma TwoI2 : 1 ∈ 2.
Proof. apply PairI2. Qed.

Lemma TwoI3 : ∀ A, A = ∅ ∨ A = 1 → A ∈ 2.
Proof.
  intros A [H1|H2].
  - subst. apply TwoI1.
  - subst. apply TwoI2.
  
  Qed.
Lemma TwoE : ∀ A, A ∈ 2 → A = ∅ ∨ A = 1.
Proof. intros. apply PairE. apply H. Qed.

(* 更多引理 *)

(* 集合的成员的单集是原集合的子集 *)
Lemma single_of_member_is_subset : ∀ A, ∀x ∈ A, ⎨x⎬ ⊆ A.
Proof.
  intros A x Hx y Hy.
  apply SingE in Hy. subst. apply Hx.
Qed.

(* 任意成员都与给定的任意成员相等的集合是单集 *)
Lemma character_of_single : ∀ A, ∀x ∈ A, (∀y ∈ A, x = y) → A = ⎨x⎬.
Proof.
  intros A x Hx H.
  apply ExtAx. split; intros.
  - apply H in H0. subst. apply SingI.
  - apply SingE in H0. subst. apply Hx.
Qed.

(* 单集的子集是空集或该单集 *)
Lemma subset_of_single : ∀ x A, A ⊆ ⎨x⎬ → A = ∅ ∨ A = ⎨x⎬.
Proof.
  intros. destruct (empty_or_inh A).
  - left. apply H0.
  - right. destruct H0 as [a Ha].
    apply character_of_single.
    + apply H in Ha as Hs. apply SingE in Hs.
      subst. apply Ha.
    + intros b Hb.
      apply H in Hb. apply SingE in Hb. auto.
Qed.

(* 壹的子集是零或壹 *)
Lemma subset_of_one : ∀ A, A ⊆ 1 -> A = ∅ ∨ A = 1.
Proof. apply subset_of_single. Qed.

(* 贰的成员的成员必是零 *)
Lemma member_of_member_of_two_is_zero :
  ∀ a A, a ∈ A → A ∈ 2 → a = ∅.
Proof.
  intros. apply EmptyI. intros x Hx.
  apply TwoE in H0 as []; subst.
  - exfalso0.
  - apply OneE in H. subst. exfalso0.
Qed.

(* 属于贰的非空集合必是壹 *)
Lemma nonempty_member_of_two_is_one :
  ∀S ∈ 2, ⦿ S → S = 1.
Proof.
  intros S HS Hi.
  apply TwoE in HS. destruct HS.
  - subst. destruct Hi. exfalso0.
  - apply H.
Qed.

(* 任意集合的单集的并就是原集合 *)
Example union_single : ∀ X, ⋃ ⎨X⎬ = X.
Proof.
  intros. apply ExtAx. split; intros.
  - apply UnionAx in H as [a [H1 H2]].
    apply SingE in H1. subst. apply H2.
  - eapply UnionI. apply SingI. apply H.
Qed.

(* 壹的并是零 *)
Example union_one : ⋃ 1 = ∅.
Proof. exact (union_single ∅). Qed.

(* 贰的成员的并必是零 *)
Example union_of_any_member_of_two_is_zero :
  ∀ X, X ∈ 2 → ⋃ X = ∅.
Proof.
  intros. apply TwoE in H. destruct H.
  - subst. apply union_empty.
  - subst. apply union_one.
Qed.

(* 贰的并是壹 *)
Example union_two : ⋃ 2 = 1.
Proof.
  apply ExtAx. split; intro.
  - apply UnionAx in H as [a [H1 H2]].
    apply TwoE in H1 as [].
    + rewrite H in H2. exfalso0.
    + subst. apply H2.
  - eapply UnionI. apply TwoI2. apply H.
Qed.

(* 零的幂集是壹 *)
Example power_zero : 𝒫 ∅ = 1.
Proof.
  apply ExtAx. split; intros.
  - apply PowerAx in H. apply OneI2.
    apply sub_empty. apply H.
  - apply PowerAx. apply OneE in H.
    subst. apply sub_empty. reflexivity.
Qed.

(* 壹的幂集是贰 *)
Example power_one : 𝒫 1 = 2.
Proof.
  apply ExtAx. split; intros.
  - apply PowerAx in H.
    apply TwoI3. apply subset_of_one. apply H.
  - apply PowerAx. apply TwoE in H. destruct H; subst.
    + intros x H. exfalso0.
    + apply sub_refl.
Qed.

(** 二元并 **)
Definition BUnion : set → set → set := λ X Y, ⋃{X, Y}.
Notation "X ∪ Y" := (BUnion X Y) (at level 50).

Lemma BUnionI1 : ∀ w X Y, w∈X → w ∈ X∪Y.
Proof.
  intros. apply UnionI with X.
  - apply PairI1.
  - apply H.
Qed.

Lemma BUnionI2 : ∀ w X Y, w∈Y → w ∈ X∪Y.
Proof.
  intros. apply UnionI with Y.
  - apply PairI2.
  - apply H.
Qed.

Lemma BUnionE : ∀ w X Y, w ∈ X∪Y → w∈X ∨ w∈Y.
Proof.
  intros. apply UnionAx in H.
  destruct H as [z [H1 H2]].
  apply PairE in H1.
  destruct H1 ; subst; auto.
Qed.

Lemma bunion_self : ∀ A, A ∪ A = A.
Proof.
  intros. apply ExtAx. split; intros Hx.
  - apply BUnionE in Hx as []; auto.
  - apply BUnionI1; auto.
Qed.

(** 集族的并 **)

Lemma FUnionI : ∀ X F, ∀x ∈ X, ∀y ∈ F x, y ∈ ⋃{F|x ∊ X}.
Proof.
  intros X F x Hx y Hy. eapply UnionI.
  - apply ReplI. apply Hx.
  - apply Hy.
Qed.

Lemma FUnionE : ∀ X F, ∀y ∈ ⋃{F|x ∊ X}, ∃x ∈ X, y ∈ F x.
Proof.
  intros X F y Hy.
  apply UnionAx in Hy as [x [H1 H2]].
  apply ReplAx in H1 as [z [H3 H4]].
  exists z. split. apply H3. subst. apply H2.
Qed. 

Example funion_0 : ∀ F, ⋃{F|x ∊ ∅} = ∅.
Proof. intros. rewrite repl_empty. apply union_empty. Qed.

Example funion_1 : ∀ X F,
  (∀x ∈ X, F x ∈ 2) → (∃x ∈ X, F x = 1) → ⋃{F|x ∊ X} = 1.
Proof.
  intros. assert (∀ x ∈ ⋃{F | x ∊ X}, x = ∅). {
    intros x Hx. apply FUnionE in Hx as [y [H1 H2]].
    apply H in H1.
    eapply member_of_member_of_two_is_zero. apply H2. apply H1.
  }
  apply ExtAx. split; intros.
  - apply H1 in H2. subst. apply OneI1.
  - apply UnionAx. exists 1. split.
    + apply ReplAx in H0. apply H0. 
    + apply H2.
Qed.

Example funion_const : ∀ X F C,
  ⦿ X → (∀x ∈ X, F x = C) → ⋃{F|x ∊ X} = C.
Proof.
  intros. apply ExtAx. split; intros.
  - apply FUnionE in H1. destruct H1 as [y [H1 H2]].
    apply H0 in H1. subst. auto.
  - destruct H as [y H]. eapply FUnionI.
    apply H. apply H0 in H. subst. auto.
Qed.

Example funion_const_0 : ∀ X F, 
  (∀x ∈ X, F x = ∅) → ⋃{F|x ∊ X} = ∅.
Proof.
  intros. destruct (empty_or_inh X).
  - subst. apply funion_0.
  - exact (funion_const X F ∅ H0 H).
Qed.

Example funion_2 : ∀ X F, 
  (∀x ∈ X, F x ∈ 2) → ⋃{F|x ∊ X} ∈ 2.
Proof.
  intros. destruct (classic (∃x ∈ X, F x = 1)).
  - pose proof (funion_1 X F H H0) as H1.
    rewrite H1. apply TwoI2.
  - assert (∀x ∈ X, F x = ∅). {
      intros x Hx. apply H in Hx as H2.
      apply TwoE in H2. destruct H2; firstorder. 
    }
    pose proof (funion_const_0 X F H1).
    rewrite H2. apply TwoI1.
Qed.

Close Scope ZFC1_scope.
