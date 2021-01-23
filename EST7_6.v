(** Based on "Elements of Set Theory" Chapter 7 Part 6 **)
(** Coq coding by choukh, Jan 2021 **)

Require Export ZFC.lib.Cardinal.
Require Import ZFC.lib.FuncFacts.

(*** EST第七章6：冯·诺伊曼宇宙，集合的秩，正则公理 ***)

Section V_Def.
Import TransfiniteRecursion.

Let γ := λ x y, y = ⋃{Power | z ∊ ran x}.
Let F := λ δ, constr δ (MemberRel δ) γ.
Let F_spec := λ δ, is_function (F δ) ∧ dom (F δ) = δ ∧
  ∀α ∈ δ, (F δ)[α] = ⋃{λ β, 𝒫 (F δ)[β] | β ∊ α}.

Local Lemma F_spec_intros : ∀ δ, is_ord δ → F_spec δ.
Proof with eauto; try congruence.
  intros δ Hoδ.
  pose proof (spec_intro δ (MemberRel δ) γ) as [HfF [HdF HrF]]. {
    apply ord_woset...
  } {
    intros x. split... exists (⋃{Power | z ∊ ran x})...
  }
  fold (F δ) in HfF, HdF, HrF.
  split... split...
  intros α Hα. rewrite HrF...
  apply ExtAx. split; intros Hx.
  - apply UnionAx in Hx as [y [Hy Hx]].
    apply ReplAx in Hy as [z [Hz Hy]].
    apply ranE in Hz as [β Hp].
    apply restrE2 in Hp as [Hp Hβ]. apply func_ap in Hp...
    apply SepE2 in Hβ. apply binRelE3 in Hβ.
    apply UnionAx. exists y. split...
    apply ReplAx. exists β. split...
  - apply UnionAx in Hx as [y [Hy Hx]].
    apply ReplAx in Hy as [β [Hβ Hy]].
    assert (Hβδ: β ∈ δ). eapply ord_trans...
    apply UnionAx. exists y. split...
    apply ReplAx. exists ((F δ)[β]). split...
    apply (ranI _ β). apply restrI. apply segI.
    apply binRelI... apply func_correct...
Qed.

Local Lemma F_agree_on_smaller_partial : ∀ δ ε, δ ∈ ε →
  is_ord δ → is_ord ε → ∀α ∈ δ ∩ ε, (F δ)[α] = (F ε)[α].
Proof with eauto; try congruence.
  intros δ ε Hlt Hoδ Hoε α Hα.
  assert (Hsm: δ ∩ ε = δ). {
    apply ExtAx. split; intros Hx.
    - apply BInterE in Hx as []...
    - apply BInterI... eapply ord_trans...
  }
  rewrite Hsm in Hα.
  set {α ∊ δ | λ α, (F δ)[α] = (F ε)[α]} as δ'.
  replace δ with δ' in Hα. apply SepE2 in Hα... clear Hα α.
  eapply transfinite_induction. apply ord_woset...
  split. intros α Hα. apply SepE1 in Hα...
  intros α Hα Hseg. apply SepI...
  pose proof (F_spec_intros δ Hoδ) as [_ [_ Heqδ]].
  pose proof (F_spec_intros ε Hoε) as [_ [_ Heqε]].
  assert (Hα': α ∈ ε). eapply ord_trans...
  rewrite Heqδ, Heqε...
  erewrite repl_rewrite. reflexivity.
  intros β Hβ. rewrite seg_of_ord in Hseg...
  apply Hseg in Hβ. apply SepE2 in Hβ...
Qed.

Local Lemma F_agree_on_smaller : ∀ δ ε, is_ord δ → is_ord ε →
  ∀α ∈ δ ∩ ε, (F δ)[α] = (F ε)[α].
Proof with auto; try congruence.
  intros δ ε Hoδ Hoε α Hα.
  destruct (classic (δ = ε)) as [|Hnq]...
  apply ord_connected in Hnq as []...
  apply (F_agree_on_smaller_partial δ ε)... symmetry.
  apply (F_agree_on_smaller_partial ε δ)... rewrite binter_comm...
Qed.

(* 冯·诺伊曼宇宙层级 *)
Definition V := λ α, (F α⁺)[α].

(* 宇宙层级的递推公式 *)
Theorem V_hierarchy : ∀ α, is_ord α →
  V α = ⋃{λ β, 𝒫 (V β) | β ∊ α}.
Proof with eauto.
  intros α Ho. unfold V.
  assert (Ho': is_ord α⁺). apply ord_suc_is_ord...
  pose proof (F_spec_intros α⁺) as [_ [_ Heqα]]...
  rewrite Heqα; [|apply suc_has_n].
  erewrite repl_rewrite. reflexivity.
  intros β Hβ. rewrite F_agree_on_smaller...
  eapply ord_is_ords... rewrite <- ord_suc_preserve_lt...
  eapply ord_is_ords... apply BUnionI1...
  apply BInterI. apply BUnionI1... apply BUnionI2...
Qed.

End V_Def.

Lemma V_intro : ∀ α, is_ord α → ∀β ∈ α, ∀x ∈ 𝒫 (V β), x ∈ V α.
Proof with auto.
  intros α Hoα β Hβ x Hx.
  rewrite V_hierarchy...
  apply UnionAx. exists (𝒫 (V β)). split...
  apply ReplAx. exists β. split...
Qed.

Lemma V_elim : ∀ α, is_ord α → ∀x ∈ V α, ∃β ∈ α, x ∈ 𝒫 (V β).
Proof with auto.
  intros α Hoα x Hx.
  rewrite V_hierarchy in Hx...
  apply UnionAx in Hx as [y [Hy Hx]].
  apply ReplAx in Hy as [β [Hβ Hy]]. subst y.
  exists β. split...
Qed.

Lemma V_trans : ∀ α, is_ord α → trans (V α).
Proof with eauto.
  intros α Hoα.
  cut (∀ δ, is_ord δ → ∀α ∈ δ, trans (V α)). {
    intros H. eapply (H α⁺)...
    apply ord_suc_is_ord... apply suc_has_n.
  }
  clear Hoα α. intros δ Hoδ α Hα.
  set {α ∊ δ | λ α, trans (V α)} as δ'.
  replace δ with δ' in Hα. apply SepE2 in Hα... clear Hα α.
  eapply transfinite_induction. apply ord_woset...
  split. intros α Hα. apply SepE1 in Hα...
  intros α Hα Hseg. rewrite seg_of_ord in Hseg...
  apply SepI... apply trans_sub. intros x Hx.
  assert (Hoα: is_ord α). eapply ord_is_ords...
  apply V_elim in Hx as [β [Hβ Hx]]...
  apply Hseg in Hβ as H. apply SepE2 in H. apply ex4_3 in H...
  apply trans_sub in H. apply H in Hx.
  intros w Hw. apply Hx in Hw. eapply V_intro...
Qed.

Theorem V_sub : ∀ α, is_ord α → ∀β ∈ α, V β ⊆ V α.
Proof with eauto.
  intros α Hoα β Hβ.
  apply trans_sub. apply V_trans...
  eapply V_intro... apply all_in_its_power.
Qed.

Theorem V_0 : V ∅ = ∅.
Proof with auto.
  apply ExtAx. split; intros Hx.
  - apply V_elim in Hx as [β [Hβ _]]... exfalso0.
  - exfalso0.
Qed.

Theorem V_suc : ∀ α, is_ord α → V α⁺ = 𝒫 (V α).
Proof with eauto.
  intros α Hoα.
  assert (Hoα': is_ord α⁺). apply ord_suc_is_ord...
  apply ExtAx. split; intros Hx.
  - apply V_elim in Hx as [β [Hβ Hx]]...
    apply BUnionE in Hβ as []; [|apply SingE in H; subst]...
    pose proof (V_sub α Hoα β) as Hsub.
    apply ex1_3 in Hsub... apply Hsub...
  - eapply V_intro... apply suc_has_n.
Qed.

Theorem V_limit : ∀ α, is_limit α → V α = ⋃{V | β ∊ α}.
Proof with eauto.
  intros α Hlim.
  assert (H := Hlim). destruct H as [Hoα _].
  apply sub_antisym; intros x Hx.
  - apply V_elim in Hx as [β [Hβ Hx]]...
    rewrite <- V_suc in Hx; [|eapply ord_is_ords]...
    apply UnionAx. exists (V β⁺). split...
    apply ReplAx. exists β⁺. split...
    apply suc_in_limit...
  - apply UnionAx in Hx as [y [Hy Hx]].
    apply ReplAx in Hy as [β [Hβ Hy]].
    subst y. eapply V_sub...
Qed.

(* 良基集：x ∈ 𝐖𝐅 *)
Definition grounded := λ x, ∃ α, is_ord α ∧ x ⊆ V α.

Definition rank_spec := λ A α, is_ord α ∧ A ⊆ V α ∧
  ∀ β, is_ord β → A ⊆ V β → α ⋸ β.

Lemma rank_exists : ∀ A, grounded A → ∃ α, rank_spec A α.
Proof with eauto; try congruence.
  intros A [α [Hoα Hsubα]].
  set {ξ ∊ α⁺ | λ ξ, A ⊆ V ξ} as B.
  destruct (ords_woset B) as [_ Hmin]. {
    intros x Hx. apply SepE1 in Hx.
    eapply ord_is_ords; revgoals...
    apply ord_suc_is_ord...
  }
  pose proof (Hmin B) as [μ [Hμ Hle]]... {
    exists α. apply SepI... apply suc_has_n.
  }
  apply SepE in Hμ as [Hμ Hsubμ].
  assert (Hoμ: is_ord μ). {
    eapply ord_is_ords; revgoals...
    apply ord_suc_is_ord...
  }
  exists μ. repeat split...
  intros β Hoβ Hsubβ.
  apply ord_leq_iff_not_gt... intros Hβ.
  assert (β ∈ B). {
    apply SepI... eapply ord_trans...
    apply ord_suc_is_ord...
  }
  apply Hle in H as [].
  - apply binRelE3 in H. eapply ord_not_lt_gt; revgoals...
  - eapply ord_not_lt_self...
Qed.

(* 秩 *)
(* == we use Hilbert's epsilon for convenience reasons == *)
Definition rank := λ A, ClassChoice (rank_spec A).

Lemma rank_spec_intro : ∀ A, grounded A → rank_spec A (rank A).
Proof.
  intros A Hgnd. apply (class_choice_spec (rank_spec A)).
  apply rank_exists. apply Hgnd.
Qed.

(* 秩是序数 *)
Lemma rank_is_ord : ∀ A, grounded A → is_ord (rank A).
Proof.
  intros A Hgnd. apply rank_spec_intro. apply Hgnd.
Qed.
Hint Immediate rank_is_ord : core.

Lemma grounded_in_rank : ∀ A, grounded A → A ⊆ V (rank A).
Proof.
  intros A Hgnd. apply rank_spec_intro. apply Hgnd.
Qed.

Lemma grounded_under_rank : ∀ A, grounded A → A ∈ V (rank A)⁺.
Proof with auto.
  intros A Hgnd. rewrite V_suc...
  apply PowerAx. apply grounded_in_rank...
Qed.

(* 良基集的成员也是良基集 *)
Theorem member_grounded : ∀ A, grounded A → ∀a ∈ A, grounded a.
Proof with eauto.
  intros A Hgnd a Ha.
  apply grounded_in_rank in Hgnd as HA. apply HA in Ha.
  apply V_elim in Ha as [β [Hβ Ha]]... apply PowerAx in Ha.
  exists β. split... eapply ord_is_ords; revgoals...
Qed.

(* 良基集的秩大于成员的秩 *)
Theorem rank_of_member : ∀ A, grounded A → ∀a ∈ A, rank a ∈ rank A.
Proof with eauto; try congruence.
  intros A Hgnd a Ha.
  apply grounded_in_rank in Hgnd as HA. apply HA in Ha.
  apply V_elim in Ha as [β [Hβ Ha]]... apply PowerAx in Ha.
  assert (Hoβ: is_ord β). eapply ord_is_ords; revgoals...
  assert (Hgnda: grounded a). exists β. split... 
  pose proof (rank_spec_intro a Hgnda) as [_ [_ H]].
  pose proof (H β Hoβ Ha) as []... eapply ord_trans...
Qed.

Section RankRecurrence.

Let Ω := λ A, {λ a, (rank a)⁺ | a ∊ A}.
Let α := λ A, ⋃ (Ω A).

Local Lemma Ω_is_ords : ∀ A, (∀a ∈ A, grounded a) → is_ords (Ω A).
Proof.
  intros A Hgnd x Hx.
  apply ReplAx in Hx as [a [Ha Hx]].
  subst x. apply ord_suc_is_ord.
  apply rank_is_ord. apply Hgnd. apply Ha.
Qed.

Local Lemma α_is_ord : ∀ A, (∀a ∈ A, grounded a) → is_ord (α A).
Proof.
  intros A Hgnd. apply union_of_ords_is_ord.
  apply Ω_is_ords. apply Hgnd.
Qed.

Local Lemma grounded_in_α : ∀ A, (∀a ∈ A, grounded a) → A ⊆ V (α A).
Proof with eauto; try congruence.
  intros A Hgnd a Ha. apply Hgnd in Ha as Hgnda.
  apply grounded_under_rank in Hgnda.
  assert ((rank a)⁺ ⋸ (α A)). {
    apply ord_sup_is_ub. apply Ω_is_ords...
    apply ReplAx. exists a. split...
  }
  destruct H as []... eapply V_sub... apply α_is_ord...
Qed.

(* 成员都是良基集的集合是良基集 *)
Theorem grounded_intro : ∀ A, (∀a ∈ A, grounded a) → grounded A.
Proof with auto.
  intros A Hgnd. exists (α A).
  split. apply α_is_ord... apply grounded_in_α...
Qed.

(* 秩的递推公式 *)
Theorem rank_recurrence : ∀ A, grounded A → rank A = α A.
Proof with eauto.
  intros A Hgnd.
  assert (Hoα: is_ord (α A)). {
    apply α_is_ord. apply member_grounded...
  }
  apply sub_antisym.
  - apply ord_leq_iff_sub... apply rank_spec_intro...
    apply grounded_in_α. apply member_grounded...
  - intros x Hx.
    apply UnionAx in Hx as [β [Hβ Hx]].
    apply ReplAx in Hβ as [a [Ha Hβ]]. subst β.
    apply rank_of_member in Ha...
    apply BUnionE in Hx as [].
    eapply ord_trans... apply SingE in H. subst...
Qed.

End RankRecurrence.

(* ex7_26 序数是良基集：𝐎𝐍 ⊆ 𝐖𝐅 *)
Fact ord_grounded : ∀ α, is_ord α → grounded α.
Proof.
  apply transfinite_induction_schema.
  intros α Hα. apply grounded_intro.
Qed.

(* ex7_26 序数的秩等于自身 *)
Fact rank_of_ord : ∀ α, is_ord α → rank α = α.
Proof with eauto; try congruence.
  apply transfinite_induction_schema.
  intros α Hα Hind.
  rewrite rank_recurrence; [|apply ord_grounded]...
  apply ExtAx. split; intros Hx.
  - apply UnionAx in Hx as [y [Hy Hx]].
    apply ReplAx in Hy as [β [Hβ Hy]]. subst y.
    rewrite Hind in Hx...
    apply BUnionE in Hx as [].
    eapply ord_trans... apply SingE in H...
  - apply Hind in Hx as Heq.
    apply UnionAx. exists x⁺. split; [|apply BUnionI2]...
    apply ReplAx. exists x. split...
Qed.

(* 任意集合都是良基集等价于正则公理 *)
Theorem all_grounded_iff_regularity :
  (∀ A, grounded A) ↔ Regularity.
Proof with eauto; try congruence.
  split.
  - intros Hgnd A Hne.
    set {rank | a ∊ A} as Ω.
    destruct (ords_woset Ω) as [_ Hmin]. {
      intros x Hx. apply ReplAx in Hx as [a [_ Hx]]. subst...
    }
    pose proof (Hmin Ω) as [μ [Hμ Hle]]... {
      apply EmptyNE in Hne as [a Ha].
      exists (rank a). apply ReplAx. exists a. split...
    }
    apply ReplAx in Hμ as [m [Hm Hμ]].
    exists m. split...
    apply ExtAx. split; intros Hx; [|exfalso0].
    apply BInterE in Hx as [Hxm HxA].
    apply rank_of_member in Hxm; [|eapply member_grounded]...
    assert (rank x ∈ Ω). apply ReplAx. exists x. split...
    exfalso. apply Hle in H as [].
    + apply binRelE3 in H. eapply ord_not_lt_gt; revgoals...
      eapply ord_is_ords; revgoals...
    + subst. eapply (ord_not_lt_self (rank x)); revgoals...
  - intros Reg.
    destruct (classic (∀ A, grounded A))... exfalso.
    apply not_all_ex_not in H as [c Hngc].
    set (𝗧𝗖 ⎨c⎬) as B.
    set {x ∊ B | λ x, ¬ grounded x} as A.
    pose proof (Reg A) as [m [Hm H0]]. {
      apply EmptyNI. exists c. apply SepI...
      apply tc_contains...
    }
    apply SepE in Hm as [Hmb Hngm].
    apply Hngm. apply grounded_intro.
    intros x Hx. destruct (classic (grounded x))... exfalso.
    assert (Hx': x ∈ A). apply SepI... eapply tc_trans...
    eapply EmptyNI in H0... exists x. apply BInterI...
Qed.

Module RegularityConsequences.

Axiom RegAx : Regularity.

(* 不存在集合的无穷降链 *)
Theorem no_descending_chain : ¬ ∃ f,
  is_function f ∧ dom f = ω ∧ ∀n ∈ ω, f[n⁺] ∈ f[n].
Proof with nauto; try congruence.
  intros [f [Hf [Hd Hr]]].
  pose proof (RegAx (ran f)) as [m [Hm H0]]. {
    apply EmptyNI. exists (f[∅]).
    eapply ranI. apply func_correct... rewrite Hd...
  }
  apply ranE in Hm as Hp. destruct Hp as [n Hp].
  apply domI in Hp as Hn. apply func_ap in Hp... subst m.
  eapply EmptyNI in H0... exists (f[n⁺]).
  apply BInterI. apply Hr... eapply ranI. apply func_correct...
  rewrite Hd. apply ω_inductive...
Qed.

Theorem no_descending_chain_1 : ∀ A, A ∉ A.
Proof with auto.
  intros A HA.
  set (Func ω A (λ n, A)) as f.
  assert (Hf: f: ω ⇒ A). {
    apply meta_maps_into. intros n Hn...
  }
  apply no_descending_chain.
  exists f. split. apply Hf. split. apply Hf.
  intros n Hn. unfold f.
  repeat rewrite meta_func_ap... apply ω_inductive...
Qed.

Theorem no_descending_chain_2 : ∀ A B, A ∈ B → B ∉ A.
Proof with nauto.
  intros A B HA HB.
  set (Func ω {A, B} (λ n, match (ixm (even n)) with
    | inl _=> A
    | inr _=> B
  end)) as f.
  assert (Hf: f: ω ⇒ {A, B}). {
    apply meta_maps_into. intros n Hn.
    destruct (ixm (even n)). apply PairI1. apply PairI2.
  }
  apply no_descending_chain.
  exists f. split. apply Hf. split. apply Hf.
  intros n Hn. unfold f.
  repeat rewrite meta_func_ap; [..|apply ω_inductive]...
  assert (Hnp: n⁺ ∈ ω). apply ω_inductive...
  destruct (ixm (even n⁺)); destruct (ixm (even n))...
  - exfalso. apply (no_even_and_odd n⁺)...
    split... apply even_iff_suc_odd...
  - exfalso. destruct (even_or_odd n⁺)...
    apply n1. apply even_iff_suc_odd...
Qed.

End RegularityConsequences.
