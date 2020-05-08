(** Based on "Elements of Set Theory"  **)
(** Coq coding by choukh, May 2020 **)

Require Export ZFC.EX4.

(*** TG集合论扩展5：补集，集合代数定律 ***)

(** 补集 **)
Definition Comp : set → set → set := λ A B, {x ∊ A | λ x, x ∉ B}.
Notation "A - B" := (Comp A B).

Lemma CompI : ∀ A B, ∀x ∈ A, x ∉ B → x ∈ A - B.
Proof. introq. apply SepI. apply H. apply H0. Qed.

Lemma CompE : ∀ A B, ∀x ∈ A - B, x ∈ A ∧ x ∉ B.
Proof. introq. apply SepE in H. apply H. Qed.

Lemma CompNE : ∀ A B x, x ∉ A - B → x ∉ A ∨ x ∈ B.
Proof.
  intros. destruct (classic (x ∈ B)).
  - right. apply H0.
  - left. intros H1. apply H. apply CompI; assumption.
Qed.

Example union_comp : ∀ A B C, (A ∪ B) - C = (A - C) ∪ (B - C).
Proof.
  intros. apply ExtAx. split; intros.
  - apply CompE in H. destruct H as [H HC].
    apply BUnionE in H. destruct H.
    + apply BUnionI1. apply CompI. apply H. apply HC.
    + apply BUnionI2. apply CompI. apply H. apply HC.
  - apply BUnionE in H. destruct H.
    + apply CompE in H as [HA HC].
      apply CompI. apply BUnionI1. apply HA. apply HC.
    + apply CompE in H as [HB HC].
      apply CompI. apply BUnionI2. apply HB. apply HC.
Qed.

(* 并，交，补运算与子集关系构成集合代数，
  类似与自然数的加，乘，减运算与小于等于关系 *)

(** 集合代数定律 **)

(* 二元并交换律 *)
Lemma bunion_comm : ∀ A B, A ∪ B = B ∪ A.
Proof.
  intros. apply ExtAx. split; intros.
  - apply BUnionE in H. destruct H.
    + apply BUnionI2. apply H.
    + apply BUnionI1. apply H.
  - apply BUnionE in H. destruct H.
    + apply BUnionI2. apply H.
    + apply BUnionI1. apply H.
Qed.

(* 二元交交换律 *)
Lemma binter_comm : ∀ A B, A ∩ B = B ∩ A.
Proof.
  intros. apply ExtAx. split; intros.
  - apply BInterE in H as [H1 H2].
    apply BInterI. apply H2. apply H1.
  - apply BInterE in H as [H1 H2].
    apply BInterI. apply H2. apply H1.
Qed.

(* 二元并结合律 *)
Lemma bunion_assoc : ∀ A B C, A ∪ (B ∪ C) = (A ∪ B) ∪ C.
Proof.
  intros. apply ExtAx. split; intros.
  - apply BUnionE in H. destruct H.
    + apply BUnionI1. apply BUnionI1. apply H.
    + apply BUnionE in H. destruct H.
      * apply BUnionI1. apply BUnionI2. apply H.
      * apply BUnionI2. apply H.
  - apply BUnionE in H. destruct H.
    + apply BUnionE in H. destruct H.
      * apply BUnionI1. apply H.
      * apply BUnionI2. apply BUnionI1. apply H.
    + apply BUnionI2. apply BUnionI2. apply H.
Qed.

(* 二元交结合律 *)
Lemma binter_assoc : ∀ A B C, A ∩ (B ∩ C) = (A ∩ B) ∩ C.
Proof.
  intros. apply ExtAx. split; intros.
  - apply BInterE in H as [H1 H2].
    apply BInterE in H2 as [H2 H3].
    repeat apply BInterI; auto.
  - apply BInterE in H as [H1 H2].
    apply BInterE in H1 as [H0 H1].
    repeat apply BInterI; auto.
Qed.

(* 交并分配律 *)
Lemma binter_bunion_distr : ∀ A B C,
  A ∩ (B ∪ C) = (A ∩ B) ∪ (A ∩ C).
Proof.
  intros. apply ExtAx. split; intros.
  - apply BInterE in H as [H1 H2].
    apply BUnionE in H2. destruct H2.
    + apply BUnionI1. apply BInterI; auto.
    + apply BUnionI2. apply BInterI; auto.
  - apply BUnionE in H. destruct H.
    + apply BInterE in H as [H1 H2].
      apply BInterI. apply H1. apply BUnionI1. apply H2.
    + apply BInterE in H as [H1 H2].
      apply BInterI. apply H1. apply BUnionI2. apply H2.
Qed.

(* 并交分配律 *)
Lemma bunion_binter_distr : ∀ A B C,
  A ∪ (B ∩ C) = (A ∪ B) ∩ (A ∪ C).
Proof.
  intros. apply ExtAx. split; intros.
  - apply BUnionE in H. destruct H.
    + apply BInterI; apply BUnionI1; apply H.
    + apply BInterE in H as [H1 H2].
      apply BInterI; apply BUnionI2; auto.
  - apply BInterE in H as [H1 H2].
    apply BUnionE in H1. apply BUnionE in H2.
    destruct H1; destruct H2.
    + apply BUnionI1. apply H.
    + apply BUnionI1. apply H.
    + apply BUnionI1. apply H0.
    + apply BUnionI2. apply BInterI; auto.
Qed.

(* 交补分配律 *)
Lemma binter_comp_distr : ∀ A B C, A ∩ (B - C) = (A ∩ B) - (A ∩ C).
Proof.
  intros. apply ExtAx. split; intros.
  - apply BInterE in H as [H1 H2].
    apply CompE in H2 as [H2 H3].
    apply CompI. apply BInterI; assumption.
    intros H4. apply BInterE in H4 as [_ H4]. auto.
  - apply CompE in H as [H1 H2].
    apply BInterE in H1 as [H0 H1].
    apply BInterI. apply H0. apply CompI. apply H1.
    intros H3. apply H2. apply BInterI; assumption.
Qed.

(* 二元并德摩根定律 *)
Lemma bunion_demorgen : ∀ A B x, x ∉ A ∪ B ↔ x ∉ A ∧ x ∉ B.
Proof.
  intros. split; intros.
  - split; intros.
    + intros HA. apply H. apply BUnionI1. apply HA.
    + intros HB. apply H. apply BUnionI2. apply HB.
  - destruct H as [H1 H2]. intros H.
    apply BUnionE in H. destruct H; auto.
Qed.

(* 二元并补德摩根定律 *)
Lemma comp_bunion_demorgen : ∀ A B C, C - (A ∪ B) = (C - A) ∩ (C - B).
Proof.
  intros. apply ExtAx. split; intros.
  - apply CompE in H as [H1 H2].
    apply bunion_demorgen in H2. destruct H2 as [H2 H3].
    apply BInterI; apply CompI; auto.
  - apply BInterE in H as [H1 H2].
    apply CompE in H1 as [HC HA].
    apply CompE in H2 as [_ HB].
    apply CompI. apply HC. apply bunion_demorgen. auto.
Qed.

(* 二元交德摩根定律 *)
Lemma binter_demorgen : ∀ A B x, x ∉ A ∩ B ↔ x ∉ A ∨ x ∉ B.
Proof.
  intros. split; intros.
  - destruct (classic (x ∈ A)).
    + right. intros HB. apply H.
      apply BInterI; auto.
    + left. apply H0.
  - intros H0. destruct H.
    + apply H. apply BInterE in H0 as [H0 _]. apply H0.
    + apply H. apply BInterE in H0 as [_ H0]. apply H0.
Qed.

(* 二元交补德摩根定律 *)
Lemma comp_binter_demorgen : ∀ A B C, C - (A ∩ B) = (C - A) ∪ (C - B).
Proof.
  intros. apply ExtAx. split; intros.
  - apply CompE in H as [HC H].
    apply binter_demorgen in H. destruct H.
    + apply BUnionI1. apply CompI. apply HC. apply H.
    + apply BUnionI2. apply CompI. apply HC. apply H.
  - apply BUnionE in H. destruct H.
    + apply CompE in H as [HC HA].
      apply CompI. apply HC. apply binter_demorgen. left. apply HA.
    + apply CompE in H as [HC HB].
      apply CompI. apply HC. apply binter_demorgen. right. apply HB.
Qed.

(* 涉及空集的同一性 *)

Lemma bunion_empty : ∀ A, A ∪ ∅ = A.
Proof.
  intros. apply ExtAx. split; intros.
  - apply BUnionE in H. destruct H. apply H. exfalso0.
  - apply BUnionI1. apply H.
Qed.
  
Lemma binter_empty : ∀ A, A ∩ ∅ = ∅.
Proof.
  intros. apply EmptyI. intros x H.
  apply BInterE in H as [_ H]. exfalso0.
Qed.

Lemma binter_comp_empty : ∀ A C, A ∩ (C - A) = ∅.
Proof.
  intros. apply EmptyI. intros x H.
  apply BInterE in H as [H1 H2].
  apply CompE in H2. destruct H2 as [_ H2]. auto.
Qed.

(* 涉及全集的同一性 *)

Lemma bunion_parent : ∀ A S, A ⊆ S → A ∪ S = S.
Proof.
  intros. apply ExtAx. split; intros.
  - apply BUnionE in H0. destruct H0.
    + apply H in H0. apply H0. 
    + apply H0.
  - apply BUnionI2. apply H0.
Qed.

Lemma binter_parent : ∀ A S, A ⊆ S → A ∩ S = A.
Proof.
  intros. apply ExtAx. split; intros.
  - apply BInterE in H0 as [H0 _]. apply H0.
  - apply BInterI. apply H0. apply H in H0. apply H0.
Qed.

Lemma bunion_comp_parent : ∀ A S, A ⊆ S → A ∪ (S - A) = S.
Proof.
  intros. apply ExtAx. split; intros.
  - apply BUnionE in H0. destruct H0.
    + apply H in H0. apply H0.
    + apply CompE in H0 as [H0 _]. apply H0.
  - destruct (classic (x ∈ A)).
    + apply BUnionI1. apply H1.
    + apply BUnionI2. apply CompI. apply H0. apply H1.
Qed.

Lemma binter_comp_parent : ∀ A S, A ⊆ S → A ∩ (S - A) = ∅.
Proof.
  intros. apply EmptyI. intros x Hx.
  apply BInterE in Hx as [H1 H2].
  apply CompE in H2 as [_ H2]. auto.
Qed.

(* 子集关系的单调性 *)

Lemma sub_bunion_mono : ∀ A B C, A ⊆ B → A ∪ C ⊆ B ∪ C.
Proof.
  intros. intros x Hx. apply BUnionE in Hx. destruct Hx.
  - apply H in H0. apply BUnionI1. apply H0.
  - apply BUnionI2. apply H0.
Qed.

Lemma sub_binter_mono : ∀ A B C, A ⊆ B → A ∩ C ⊆ B ∩ C.
Proof.
  intros. intros x Hx. apply BInterE in Hx as [H1 H2].
  apply H in H1. apply BInterI. apply H1. apply H2.
Qed.

Lemma sub_union_mono : ∀ A B, A ⊆ B → ⋃A ⊆ ⋃B.
Proof.
  intros. intros x Hx. apply UnionAx in Hx as [y [H1 H2]].
  eapply UnionI. apply H in H1. apply H1. apply H2.
Qed.

(* 子集关系的反单调性 *)

Lemma sub_comp_amono : ∀ A B C, A ⊆ B → C - B ⊆ C - A.
Proof.
  intros. intros x Hx. apply CompE in Hx as [HC HB].
  apply CompI. apply HC. intros HA.
  apply HB. apply H. apply HA.
Qed.

Lemma sub_inter_amono : ∀ A B, ⦿ A → A ⊆ B → ⋂B ⊆ ⋃A.
Proof.
  intros. intros x Hx. apply InterE in Hx as [_ Hy].
  destruct H as [a Ha]. eapply UnionI. apply Ha.
  apply H0 in Ha. apply Hy in Ha. apply Ha.
Qed.

(* 二元并任意交分配律 *)
Lemma bunion_inter_distr : ∀ A ℬ,
  ⦿ ℬ → A ∪ ⋂ℬ = ⋂{λ X, A ∪ X | X ∊ ℬ}.
Proof with unfoldq.
  intros * Hi. apply ExtAx. split; intros.
  - apply InterI...
    + destruct Hi as [b Hb]. exists (A ∪ b).
      apply ReplAx... exists b. auto.
    + intros y Hy. apply ReplE in Hy as [z [Hz Hu]]. subst y. 
      apply BUnionE in H as [].
      * apply BUnionI1. apply H.
      * apply BUnionI2. apply InterE in H as [_ H].
        apply H. apply Hz.
  - destruct (classic (x ∈ A)) as [HA|HA].
    + apply BUnionI1. apply HA.
    + apply BUnionI2. apply InterI... apply Hi. intros b Hb.
      assert (Hu: A ∪ b ∈ {BUnion A | X ∊ ℬ}). {
        apply ReplI. apply Hb.
      }
      apply InterE in H as [_ H]...
      apply H in Hu. apply BUnionE in Hu as [].
      * exfalso. apply HA. apply H0.
      * apply H0.
Qed.

(* 二元交任意并的分配律 *)
Lemma binter_union_distr : ∀ A ℬ,
  A ∩ ⋃ℬ = ⋃{λ X, A ∩ X | X ∊ ℬ}.
Proof.
  intros. apply ExtAx. split; intros.
  - apply BInterE in H as [HA Hu].
    apply UnionAx in Hu as [b [Hb1 Hb2]].
    eapply FUnionI.
    + apply Hb1.
    + apply BInterI; assumption.
  - apply FUnionE in H as [y [H1 H2]].
    apply BInterE in H2 as [H2 H3].
    apply BInterI. apply H2.
    eapply UnionI. apply H1. apply H3.
Qed.

(* 补并德摩根定律 *)
Lemma comp_union_demorgen : ∀ 𝒜 C,
  ⦿ 𝒜 → C - ⋃𝒜 = ⋂{λ X, C - X | X ∊ 𝒜}.
Proof.
  intros * [a Ha]. apply ExtAx. split; intros.
  - apply CompE in H as [HC HU]. apply InterI.
    + exists (C - a). apply ReplI. apply Ha.
    + intros y Hy. apply ReplE in Hy as [b [Hb Hc]].
      rewrite <- Hc. apply CompI. apply HC. intros H.
      apply HU. eapply UnionI. apply Hb. apply H.
  - apply InterE in H as [_ H]. apply CompI.
    + assert (C - a ∈ {Comp C | X ∊ 𝒜}). {
        apply ReplI. apply Ha.
      }
      apply H in H0. apply CompE in H0 as [HC _]. apply HC.
    + intros HU. apply UnionAx in HU as [b [Hb1 Hb2]].
      assert (C - b ∈ {Comp C | X ∊ 𝒜}). {
        apply ReplI. apply Hb1.
      }
      apply H in H0. apply CompE in H0 as [_ Hb3]. auto.
Qed.

(* 经典引理：并非所有都否定，则存在肯定 *)
Lemma classic_n_al_im_ex_n : ∀ (A : Type) (P Q : A → Prop),
  ¬ (∀ a, P a → Q a) → ∃ a, P a ∧ ¬ Q a.
Proof.
  intros. destruct (classic (∃ A, P A ∧ ¬ Q A)).
  - apply H0.
  - exfalso. apply H. intros a Hp.
    rewrite <- (double_negation (Q a)). intros Hq.
    apply H0. exists a. auto.
Qed.

(* x不在𝒜的交集里，则存在𝒜的成员A，x不是A的成员 *)
Lemma not_in_inter_intro : ∀ 𝒜 x, ⦿ 𝒜 → x ∉ ⋂ 𝒜 → ∃A ∈ 𝒜, x ∉ A.
Proof.
  intros * Hi Hx. apply classic_n_al_im_ex_n.
  intros H. apply Hx. apply InterI.
  apply Hi. unfoldq. apply H.
Qed.

(* 补交德摩根定律 *)
Lemma comp_inter_demorgen : ∀ 𝒜 C,
  ⦿ 𝒜 → C - ⋂𝒜 = ⋃{λ X, C - X | X ∊ 𝒜}.
Proof.
  intros * Hi. apply ExtAx. split; intros.
  - apply CompE in H as [HC HU].
    apply (not_in_inter_intro _ _ Hi) in HU as [a [Ha1 Ha2]].
    eapply FUnionI. apply Ha1.
    apply CompI. apply HC. apply Ha2.
  - apply FUnionE in H as [y [Hy1 Hy2]].
    apply CompE in Hy2 as [HC Hy2].
    apply CompI. apply HC. intros HU.
    apply InterE in HU as [_ H].
    apply Hy2. apply H. apply Hy1.
Qed.