(** Based on "Elements of Set Theory" Chapter 7 Part 1 **)
(** Coq coding by choukh, Nov 2020 **)

Require Export ZFC.EST3_3.

(*** EST第七章1：偏序，线序，极值，最值，确界 ***)

Definition relLt := λ x y R, <x, y> ∈ R.
Notation "x <ᵣ y" := (relLt x y) (at level 60).
Definition relLe := λ x y R, <x, y> ∈ R ∨ x = y.
Notation "x ≤ᵣ y" := (relLe x y) (at level 60).

Lemma relLe_tranr : ∀ x y z R, tranr R →
  (x ≤ᵣ y) R → (y ≤ᵣ z) R → (x ≤ᵣ z) R.
Proof with eauto.
  intros * Htr [Hxy|Hxy] [Hyz|Hyz].
  - left. eapply Htr...
  - subst. left...
  - subst. left...
  - subst. right...
Qed.

Lemma relLt_le_tranr : ∀ x y z R, tranr R →
  (x <ᵣ y) R → (y ≤ᵣ z) R → (x ≤ᵣ z) R.
Proof with eauto.
  intros * Htr Hxy [Hyz|Hyz].
  - left. eapply Htr...
  - subst. left...
Qed.

Lemma relLe_lt_tranr : ∀ x y z R, tranr R →
  (x ≤ᵣ y) R → (y <ᵣ z) R → (x ≤ᵣ z) R.
Proof with eauto.
  intros * Htr [Hxy|Hyx] Hyz.
  - left. eapply Htr...
  - subst. left...
Qed.

(* 严格偏序，反自反偏序 *)
Definition partialOrder : set → Prop := λ R,
  is_rel R ∧ tranr R ∧ irrefl R.

(* 非对称性 *)
Definition asym : set → Prop := λ R,
  ∀ x y, (x <ᵣ y) R → ¬(y <ᵣ x) R.

(* 反对称性 *)
Definition antisym : set → Prop := λ R,
  ∀ x y, (x <ᵣ y) R → (y <ᵣ x) R → x = y.

(* 偏序具有非对称性 *)
Fact partialOrder_asym : ∀ R, partialOrder R → asym R.
Proof.
  intros R [Hrl [Htr Hir]] x y Hxy Hyx.
  eapply Hir. eapply Htr; eauto.
Qed.

(* 偏序至多满足"<" "=" ">"之一 *)
Fact partialOrder_quasi_trich : ∀ R x y, partialOrder R →
  ¬((x <ᵣ y) R ∧ x = y) ∧
  ¬((y <ᵣ x) R ∧ x = y) ∧
  ¬((x <ᵣ y) R ∧ (y <ᵣ x) R).
Proof with eauto.
  intros * [Hrl [Htr Hir]].
  repeat split; intros [H1 H2].
  - subst. eapply Hir...
  - subst. eapply Hir...
  - eapply Hir. eapply Htr...
Qed.

(* 偏序若满足"≤"且"≥"则满足"=" *)
Fact partialOrder_semi_antisym : ∀ R x y, partialOrder R →
  (x ≤ᵣ y) R ∧ (y ≤ᵣ x) R → x = y.
Proof with auto.
  intros * Hpo [H1 H2].
  destruct (classic (x = y))... exfalso.
  cut (¬((x <ᵣ y) R ∧ (y <ᵣ x) R)). firstorder.
  apply partialOrder_quasi_trich...
Qed.

(* 偏序结构 *)
Definition poset : set → set → Prop := λ A R,
  is_binRel R A ∧ partialOrder R.

(* 线序结构 *)
Definition loset : set → set → Prop := λ A R,
  linearOrder R A.

(* 线序等价于连通的偏序 *)
Fact loset_iff_connected_poset : ∀ A R,
  loset A R ↔ connected R A ∧ poset A R.
Proof with eauto.
  intros. split.
  - intros [Hrl [Htr Hir]]. repeat split...
    + apply trich_iff...
    + intros x Hx. apply Hrl in Hx. apply cprod_is_pairs in Hx...
    + eapply trich_iff...
  - intros [Hcon [Hbr [_ [Htr Hir]]]]. repeat split...
    apply trich_iff...
Qed.

(* 极小元 *)
Definition minimal : set → set → set → Prop := λ m A R,
  m ∈ A ∧ ¬∃x ∈ A, (x <ᵣ m) R.

(* 最小元 *)
Definition minimum : set → set → set → Prop := λ m A R,
  m ∈ A ∧ ∀x ∈ A, (m ≤ᵣ x) R.

(* 最小元也是极小元 *)
Fact minimum_is_minimal : ∀ m A R, partialOrder R →
  minimum m A R → minimal m A R.
Proof with auto.
  intros * Hpo [Hm H]. split... intros [x [Hx Hp]].
  apply partialOrder_asym in Hpo as Hasym.
  destruct Hpo as [_ [_ Hir]].
  apply H in Hx as []. firstorder. subst. firstorder.
Qed.

(* 线序上的极小元等价与最小元 *)
Fact linearOrder_minimal_iff_minimum : ∀ m A R, linearOrder R A →
  minimal m A R ↔ minimum m A R.
Proof with auto.
  intros * Hto. split; intros [Hm Hmin].
  - split... intros x Hx.
    destruct (classic ((m ≤ᵣ x) R))...
    exfalso. apply Hmin. apply not_or_and in H as [Hmx Hnq].
    exists x. split... apply linearOrder_connected in Hto. firstorder.
  - split... intros [x [Hx Hxm]].
    destruct Hto as [_ [_ Htri]]. firstorder.
Qed.

(* 最小元唯一 *)
Fact minimum_unique : ∀ m₁ m₂ A R, partialOrder R →
  minimum m₁ A R → minimum m₂ A R → m₁ = m₂.
Proof with auto.
  intros * Hpo [Hm1 H1] [Hm2 H2].
  apply H1 in Hm2 as []; apply H2 in Hm1 as []...
  apply partialOrder_asym in Hpo. firstorder.
Qed.

(* 极大元 *)
Definition maximal : set → set → set → Prop := λ m A R,
  m ∈ A ∧ ¬∃x ∈ A, (m <ᵣ x) R.

(* 最大元 *)
Definition maximum : set → set → set → Prop := λ m A R,
  m ∈ A ∧ ∀x ∈ A, (x ≤ᵣ m) R.

(* 最大元也是极大元 *)
Fact maximum_is_maximal : ∀ m A R, partialOrder R →
  maximum m A R → maximal m A R.
Proof with auto.
  intros * Hpo [Hm H]. split... intros [x [Hx Hp]].
  apply partialOrder_asym in Hpo as Hasym.
  destruct Hpo as [_ [_ Hir]].
  apply H in Hx as []. firstorder. subst. firstorder.
Qed.

(* 线序上的极大元等价与最大元 *)
Fact linearOrder_maximal_iff_maximum : ∀ m A R, linearOrder R A →
  maximal m A R ↔ maximum m A R.
Proof with auto.
  intros * Hto. split; intros [Hm Hmin].
  - split... intros x Hx.
    destruct (classic ((x ≤ᵣ m) R))...
    exfalso. apply Hmin. apply not_or_and in H as [Hmx Hnq].
    exists x. split... apply linearOrder_connected in Hto. firstorder.
  - split... intros [x [Hx Hxm]].
    destruct Hto as [_ [_ Htri]]. firstorder.
Qed.

(* 最大元唯一 *)
Fact maximum_unique : ∀ m₁ m₂ A R, partialOrder R →
  maximum m₁ A R → maximum m₂ A R → m₁ = m₂.
Proof with auto.
  intros * Hpo [Hm1 H1] [Hm2 H2].
  apply H1 in Hm2 as []; apply H2 in Hm1 as []...
  apply partialOrder_asym in Hpo. firstorder.
Qed.

(* 逆关系 *)
Lemma inv_is_binRel : ∀ A R, is_binRel R A → is_binRel R⁻¹ A.
Proof.
  intros * Hbr p Hp.
  apply SepE in Hp as [H [_ Hp]].
  apply CProdE1 in H as [a [_ [b [_ Heq]]]].
  subst p. zfcrewrite. apply Hbr in Hp.
  apply CProdE2 in Hp as [Ha Hb]. apply CProdI; auto.
Qed.

(* 偏序的逆仍是偏序 *)
Fact inv_partialOrder : ∀ R, partialOrder R → partialOrder R⁻¹.
Proof with auto.
  intros R [Hrl [Htr Hir]]. split; [|split].
  - apply inv_rel.
  - intros x y z Hxy Hyz. rewrite <- inv_op in *. firstorder.
  - intros x Hx. rewrite <- inv_op in Hx. firstorder.
Qed.

(* 极小元在逆关系下是极大元 *)
Fact minimal_iff_maximal_inv : ∀ m A R,
  minimal m A R ↔ maximal m A R⁻¹.
Proof with auto.
  intros; split; intros [Hm H]; split; auto;
  intros [x [Hx Hp]]; apply H; exists x; split; auto;
  unfold relLt. rewrite inv_op... rewrite <- inv_op...
Qed.

(* 极大元在逆关系下是极小元 *)
Fact maximal_iff_minimal_inv : ∀ m A R,
  maximal m A R ↔ minimal m A R⁻¹.
Proof with auto.
  intros; split; intros [Hm H]; split; auto;
  intros [x [Hx Hp]]; apply H; exists x; split; auto;
  unfold relLt. rewrite inv_op... rewrite <- inv_op...
Qed.

(* 最小元在逆关系下是最大元 *)
Fact minimum_iff_maximum_inv : ∀ m A R,
  minimum m A R ↔ maximum m A R⁻¹.
Proof with auto.
  intros; split; intros [Hm H]; split; auto;
  intros x Hx; apply H in Hx as []; unfold relLe; auto; left...
  rewrite <- inv_op... rewrite inv_op...
Qed.

(* 最大元在逆关系下是最小元 *)
Fact maximum_iff_minimum_inv : ∀ m A R,
  maximum m A R ↔ minimum m A R⁻¹.
Proof with auto.
  intros; split; intros [Hm H]; split; auto;
  intros x Hx; apply H in Hx as []; unfold relLe; auto; left...
  rewrite <- inv_op... rewrite inv_op...
Qed.

(* 上界 *)
Definition upperBound : set → set → set → set → Prop :=
  λ x B A R, x ∈ A ∧ ∀y ∈ B, (y ≤ᵣ x) R.

(* 存在上界 *)
Definition boundedAbove : set → set → set → Prop :=
  λ B A R, ∃ x, upperBound x B A R.

(* 上确界 *)
Definition supremum : set → set → set → set → Prop :=
  λ x B A R, upperBound x B A R ∧
    ∀ y, upperBound y B A R → (x ≤ᵣ y) R.

(* 下界 *)
Definition lowerBound : set → set → set → set → Prop :=
  λ x B A R, x ∈ A ∧ ∀y ∈ B, (x ≤ᵣ y) R.

(* 存在下界 *)
Definition boundedBelow : set → set → set → Prop :=
  λ B A R, ∃ x, lowerBound x B A R.

(* 下确界 *)
Definition infimum : set → set → set → set → Prop :=
  λ x B A R, lowerBound x B A R ∧
    ∀ y, lowerBound y B A R → (y ≤ᵣ x) R.

(* 成员关系 *)
Definition MemberRel : set → set := λ A,
  BinRel A (λ x y, x ∈ y).

Lemma memberRel_is_binRel : ∀ A, is_binRel (MemberRel A) A.
Proof.
  intros S p Hp.
  apply binRelE1 in Hp as [a [Ha [b [Hb [Hp _]]]]].
  subst. apply CProdI; auto.
Qed.

(* 真子集关系 *)
Definition SubsetRel : set → set := λ S,
  BinRel S (λ A B, A ⊂ B).

Lemma subsetRel_is_binRel : ∀ S, is_binRel (SubsetRel S) S.
Proof.
  intros S p Hp.
  apply binRelE1 in Hp as [a [Ha [b [Hb [Hp _]]]]].
  subst. apply CProdI; auto.
Qed.

Lemma subsetRel_tranr : ∀ S, tranr (SubsetRel S).
Proof with eauto.
  intros S a b c Hab Hbc.
  apply binRelE2 in Hab as [Ha [Hb [Hab Hnq]]].
  apply binRelE2 in Hbc as [_ [Hc [Hbc _]]].
  apply binRelI... split. eapply sub_tran...
  intros Heq. subst. apply Hnq. apply sub_antisym...
Qed.

Lemma subsetRel_irrefl : ∀ S, irrefl (SubsetRel S).
Proof.
  intros S x Hp. apply binRelE2 in Hp as [_ [_ [_ Heq]]]. auto.
Qed.

Lemma subsetRel_is_poset : ∀ S, poset S (SubsetRel S).
Proof with auto.
  repeat split.
  - apply subsetRel_is_binRel.
  - eapply binRel_is_rel. apply subsetRel_is_binRel.
  - apply subsetRel_tranr.
  - apply subsetRel_irrefl.
Qed.

Example subsetRel_bunion_supremum : ∀ S, ∀ A B ∈ 𝒫 S,
  supremum (A ∪ B) {A, B} (𝒫 S) (SubsetRel (𝒫 S)).
Proof with auto.
  intros S A HAP B HBP.
  assert (Hu: A ∪ B ∈ 𝒫 S). {
    apply PowerAx in HAP. apply PowerAx in HBP.
    apply PowerAx. intros x Hx. apply BUnionE in Hx as [].
    apply HAP... apply HBP...
  }
  split.
  - split... intros C HC.
    apply PairE in HC as []; subst.
    + destruct (classic (A = A ∪ B)). right... left.
      apply binRelI... split...
      intros x Hx. apply BUnionI1...
    + destruct (classic (B = A ∪ B)). right... left.
      apply binRelI... split...
      intros x Hx. apply BUnionI2...
  - intros C [HC Hle].
    destruct (classic (A ∪ B = C)). right... left.
    assert (HA: A ∈ {A, B}) by apply PairI1.
    assert (HB: B ∈ {A, B}) by apply PairI2.
    apply Hle in HA as [HA|HA]; apply Hle in HB as [HB|HB].
    + apply binRelE2 in HA as [_ [_ [HsubA HnqA]]].
      apply binRelE2 in HB as [_ [_ [HsubB HnqB]]].
      apply binRelI... split...
      intros x Hx. apply BUnionE in Hx as [].
      apply HsubA... apply HsubB...
    + apply binRelE2 in HA as [_ [_ [HsubA HnqA]]].
      apply binRelI... split...
      intros x Hx. apply BUnionE in Hx as [].
      apply HsubA... subst...
    + apply binRelE2 in HB as [_ [_ [HsubB HnqB]]].
      apply binRelI... split...
      intros x Hx. apply BUnionE in Hx as [].
      subst... apply HsubB...
    + apply binRelI... subst. split...
      intros x Hx. apply BUnionE in Hx as []; subst...
Qed.

Example subsetRel_binter_infimum : ∀ S, ∀ A B ∈ 𝒫 S,
  infimum (A ∩ B) {A, B} (𝒫 S) (SubsetRel (𝒫 S)).
Proof with auto.
  intros S A HAP B HBP.
  assert (HiP: A ∩ B ∈ 𝒫 S). {
    apply PowerAx in HAP. apply PowerAx.
    intros x Hx. apply BInterE in Hx as [Hx _]. apply HAP...
  }
  split.
  - split... intros C HC.
    apply PairE in HC as []; subst.
    + destruct (classic (A ∩ B = A)). right... left.
      apply binRelI... split...
      intros x Hx. apply BInterE in Hx as []...
    + destruct (classic (A ∩ B = B)). right... left.
      apply binRelI... split...
      intros x Hx. apply BInterE in Hx as []...
  - intros C [HC Hle].
    destruct (classic (C = A ∩ B)). right... left.
    assert (HA: A ∈ {A, B}) by apply PairI1.
    assert (HB: B ∈ {A, B}) by apply PairI2.
    apply Hle in HA as [HA|HA]; apply Hle in HB as [HB|HB].
    + apply binRelE2 in HA as [_ [_ [HsubA HnqA]]].
      apply binRelE2 in HB as [_ [_ [HsubB HnqB]]].
      apply binRelI... split...
      intros x Hx. apply BInterI. apply HsubA... apply HsubB...
    + apply binRelE2 in HA as [_ [_ [HsubA HnqA]]].
      apply binRelI... split...
      intros x Hx. apply BInterI. apply HsubA... subst...
    + apply binRelE2 in HB as [_ [_ [HsubB HnqB]]].
      apply binRelI... split...
      intros x Hx. apply BInterI. subst... apply HsubB...
    + apply binRelI... subst... split...
      intros x Hx. apply BInterI; subst...
Qed.

Example subsetRel_union_supremum : ∀ S 𝒜, 𝒜 ⊆ 𝒫 S →
  supremum (⋃ 𝒜) 𝒜 (𝒫 S) (SubsetRel (𝒫 S)).
Proof with auto; try congruence.
  intros S 𝒜 Hsub.
  assert (Hu: ⋃ 𝒜 ∈ 𝒫 S). {
    apply PowerAx. intros x Hx.
    apply UnionAx in Hx as [A [HA Hx]].
    apply Hsub in HA. apply PowerAx in HA. apply HA...
  }
  split.
  - split... intros C HC.
    destruct (classic (C = ⋃ 𝒜)). right... left.
    apply binRelI... apply Hsub... split...
    intros x Hx. apply UnionAx. exists C. split...
  - intros C [HC Hle].
    assert (Hsubu: ⋃ 𝒜 ⊆ C). {
      intros x Hx.
      apply UnionAx in Hx as [A [HA Hx]].
      apply Hle in HA as [HA|]...
      apply binRelE2 in HA as [_ [_ [HsubA _]]].
      apply HsubA...
    }
    destruct (classic (C ⊆ ⋃ 𝒜)).
    + right. apply sub_antisym...
    + left. apply binRelI... split...
Qed.

Example subsetRel_inter_infimum : ∀ S 𝒜, ⦿ 𝒜 → 𝒜 ⊆ 𝒫 S →
  infimum (⋂ 𝒜) 𝒜 (𝒫 S) (SubsetRel (𝒫 S)).
Proof with auto; try congruence.
  intros S 𝒜 Hne Hsub.
  assert (Hi: ⋂ 𝒜 ∈ 𝒫 S). {
    apply PowerAx. intros x Hx.
    apply InterE in Hx as [[A HA] H].
    apply H in HA as Hx. apply Hsub in HA.
    apply PowerAx in HA. apply HA...
  }
  split.
  - split... intros C HC.
    destruct (classic (⋂ 𝒜 = C)). right... left.
    apply binRelI... apply Hsub... split...
    intros x Hx. apply InterE in Hx as [_ Hx]. apply Hx...
  - intros C [HC Hle].
    assert (HsubC: C ⊆ ⋂ 𝒜). {
      intros x Hx. apply InterI...
      intros y Hy. apply Hle in Hy as []; subst...
      apply binRelE2 in H as [_ [_ [HsubC _]]]... apply HsubC...
    }
    destruct (classic (⋂ 𝒜 ⊆ C)).
    + right. apply sub_antisym...
    + left. apply binRelI... split...
Qed.

(* 子关系 *)
Definition SubRel : set → set → set := λ R B,
  {p ∊ R | λ p, p ∈ B × B}.
Notation "R ⥏ B" := (SubRel R B) (at level 60).

Lemma subRel_is_binRel : ∀ R B, is_binRel (R ⥏ B) B.
Proof with auto.
  intros * p Hp. apply SepE2 in Hp...
Qed.

Lemma subRel_absorption : ∀ R A B, B ⊆ A → (R ⥏ A) ⥏ B = R ⥏ B.
Proof with auto.
  intros * Hsub. apply ExtAx. split; intros Hx.
  - apply SepE in Hx as [Hx Hp]. apply SepE1 in Hx.
    apply CProdE1 in Hp as [a [Ha [b [Hb Heq]]]]. subst x.
    apply SepI... apply CProdI...
  - apply SepE in Hx as [Hx Hp].
    apply CProdE1 in Hp as [a [Ha [b [Hb Heq]]]]. subst x.
    apply SepI; [|apply CProdI]...
    apply SepI... apply CProdI; apply Hsub...
Qed.

(* Theorem 7J *)
Theorem subRel_poset : ∀ A R B, poset A R → B ⊆ A → poset B (R ⥏ B).
Proof with eauto.
  intros * [Hbr [_ [Htr Hir]]] Hsub.
  repeat split.
  - intros p Hp. apply SepE2 in Hp...
  - eapply binRel_is_rel.
    intros p Hp. apply SepE2 in Hp...
  - intros x y z Hxy Hyz.
    apply SepE in Hxy as [Hxy Hx]. apply CProdE2 in Hx as [Hx _].
    apply SepE in Hyz as [Hyz Hz]. apply CProdE2 in Hz as [_ Hz].
    apply SepI. eapply Htr... apply CProdI...
  - intros x Hp. eapply Hir. apply SepE1 in Hp...
Qed.

(* Theorem 7J *)
Theorem subRel_loset : ∀ A R B, loset A R → B ⊆ A → loset B (R ⥏ B).
Proof with eauto.
  intros * Hlo Hsub.
  apply loset_iff_connected_poset in Hlo as [Hcon Hpo].
  apply loset_iff_connected_poset.
  split; [|eapply subRel_poset]...
  intros x Hx y Hy Hnq.
  apply Hcon in Hnq as []; [left|right|apply Hsub..]...
  - apply SepI... apply CProdI...
  - apply SepI... apply CProdI...
Qed.

Lemma subRel_empty : ∀ R, R ⥏ ∅ = ∅.
Proof with auto.
  intros. apply ExtAx. split; intros Hx.
  - apply SepE in Hx as [_ Hx].
    rewrite cprod_0_x in Hx. exfalso0.
  - exfalso0.
Qed.

Lemma empty_is_binRel : is_binRel ∅ ∅.
Proof. intros p Hp. exfalso0. Qed.

Lemma empty_tranr : tranr ∅.
Proof. intros x y z Hxy. exfalso0. Qed.

Lemma empty_trich : trich ∅ ∅.
Proof. intros x Hx. exfalso0. Qed.

Lemma empty_loset : loset ∅ ∅.
Proof with auto.
  split; [|split]. apply empty_is_binRel.
  apply empty_tranr. apply empty_trich.
Qed.