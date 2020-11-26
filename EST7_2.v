(** Based on "Elements of Set Theory" Chapter 7 Part 2 **)
(** Coq coding by choukh, Nov 2020 **)

Require Export ZFC.lib.Natural.

(*** EST第七章2：良序，超限归纳原理，超限递归定理 ***)

(* 良序 *)
Print EST4_3.wellOrder.
(* Definition wellOrder : set → set → Prop := λ R A,
  linearOrder R A ∧
  ∀ B, B ≠ ∅ → B ⊆ A →
  ∃ m, minimum m B R. *)

(* 无穷降链 *)
Definition descending_chain : set → set → set → Prop := λ f A R,
  f: ω ⇒ A ∧ ∀n ∈ ω, <f[n⁺], f[n]> ∈ R.

(* ==需要选择公理== *)
(* 非良序的关系存在无穷降链 *)
Lemma ex_descending_chain : AC_I → ∀ A R, ⦿ A →
  (∀y ∈ A, ∃x ∈ A, <x, y> ∈ R) →
  ∃ f, descending_chain f A R.
Proof with eauto.
  intros AC1 * [a Ha] Hpr.
  set {p ∊ R | λ p, π1 p ∈ A ∧ π2 p ∈ A} as R'.
  pose proof (inv_rel R') as Hrel'.
  apply AC1 in Hrel' as [F [HfF [HsF HdF]]].
  assert (HF: F: A ⇒ A). {
    split; [|split]...
    - rewrite HdF. rewrite inv_dom.
      apply ExtAx. intros y. split; intros Hy.
      + apply ranE in Hy as [x Hp].
        apply SepE in Hp as [_ [_ Hy]]. zfcrewrite.
      + pose proof (Hpr _ Hy) as [x [Hx Hp]].
        eapply ranI. apply SepI. apply Hp. zfcrewrite...
    - intros y Hy. apply ranE in Hy as [x Hp].
      apply HsF in Hp. apply inv_op in Hp.
      apply SepE in Hp as [_ [Hx _]]. zfcrewrite.
  }
  pose proof (ω_recursion _ _ _ HF Ha) as [f [Hf [Hf0 Heq]]].
  exists f. split... intros n Hn. rewrite Heq...
  assert (HsR: R' ⊆ R). { intros p Hp. apply SepE1 in Hp... }
  apply HsR. rewrite inv_op. apply HsF. apply func_correct...
  destruct HF as [_ [Hd _]]. rewrite Hd. eapply ap_ran...
Qed.

(* ==需要选择公理== *)
(* 全序是良序当且仅当其上不存在无穷降链 *)
Theorem wellOrder_iff_no_descending_chain :
  AC_I → ∀ A R, linearOrder R A →
  wellOrder R A ↔ ¬ ∃ f, descending_chain f A R.
Proof with neauto.
  intros AC1 * Hlo. split.
  - intros [_ Hwo] [f [[Hf [Hd Hr]] Hlt]].
    apply linearOrder_irrefl in Hlo as Hir.
    destruct Hlo as [_ [Htr _]].
    assert (Hne: ⦿ ran f). {
      exists (f[0]). eapply ranI.
      apply func_correct... rewrite Hd...
    }
    apply Hwo in Hne as [m [Hm Hmin]]...
    apply ranE in Hm as [x Hp].
    apply domI in Hp as Hx. rewrite Hd in Hx.
    apply func_ap in Hp as Hap... subst m.
    assert (Hfx: f[x⁺] ∈ ran f). {
      eapply ap_ran. split... apply ω_inductive...
    }
    apply Hlt in Hx. apply Hmin in Hfx as [].
    + eapply Hir. eapply Htr...
    + eapply Hir. rewrite H in Hx...
  - intros Hndc. split... intros B Hne Hsub.
    destruct (classic (∃ m, minimum m B R))...
    pose proof (ex_descending_chain AC1 B R Hne) as [f Hdc]. {
      intros y Hy. eapply not_ex_all_not in H.
      apply not_and_or in H as []. exfalso...
      apply set_not_all_ex_not in H as [x [Hx H]].
      apply not_or_and in H as []. exists x. split...
      apply Hsub in Hy. apply Hsub in Hx.
      eapply linearOrder_connected in H0 as []... exfalso...
    }
    exfalso. apply Hndc. exists f.
    destruct Hdc as [[Hf [Hd Hr]] Hdc].
    split... split... split... eapply sub_tran...
Qed.

(* 前节 *)
(* initial segment *)
Definition seg : set → set → set := λ t R,
  {x ∊ dom R | λ x, <x, t> ∈ R}.

Lemma segI : ∀ x t R, <x, t> ∈ R → x ∈ seg t R.
Proof with eauto.
  intros. apply SepI... eapply domI...
Qed.

(* 自然数的前节等于自身 *)
Example seg_of_nat : ∀n ∈ ω, seg n ωLt = n.
Proof with eauto.
  intros n Hn. apply ExtAx. split; intros Hx.
  - apply SepE in Hx as [_ Hp].
    apply SepE in Hp as [_ H]. zfcrewrite.
  - assert (Hxw: x ∈ ω). { eapply ω_trans... }
    apply SepI. eapply domI. apply (binRelI _ _ x Hxw (x⁺)).
    apply ω_inductive... apply suc_has_n. apply binRelI...
Qed.

(* 归纳子集 *)
Definition inductive_subset : set → set → set → Prop := λ B A R,
  B ⊆ A ∧ ∀t ∈ A, seg t R ⊆ B → t ∈ B.

(* 超限归纳原理：良序集的归纳子集与自身相等 *)
Theorem transfinite_induction : ∀ A R, wellOrder R A →
  ∀ B, inductive_subset B A R → B = A.
Proof with auto.
  intros A R [[Hbr [Htr Htri]] Hwo] B [Hsub Hind].
  destruct (classic (B = A)) as [|Hnq]... exfalso.
  assert (Hne: ⦿ (A - B)) by (apply comp_nonempty; split; auto).
  apply Hwo in Hne as [m [Hm Hmin]]...
  apply SepE in Hm as [Hm Hm']. apply Hm'. apply Hind...
  intros x Hx. apply SepE in Hx as [_ Hp].
  apply Hbr in Hp as Hx. apply CProdE1 in Hx as [Hx _]. zfcrewrite.
  destruct (classic (x ∈ B)) as [|Hx']... exfalso.
  assert (x ∈ A - B) by (apply SepI; auto).
  apply Hmin in H as []; firstorder.
Qed.

(* 线序集良序当且仅当其归纳子集与自身相等 *)
Theorem wellOrder_iff_inductive : ∀ A R, linearOrder R A →
  wellOrder R A ↔ ∀ B, inductive_subset B A R → B = A.
Proof with eauto; try congruence.
  intros A R Hlo.
  split. { apply transfinite_induction. }
  intros Hind. split... intros C [c Hc] Hsub.
  (* strict lower bounds of C *)
  set {t ∊ A | λ t, ∀x ∈ C, <t, x> ∈ R} as B.
  destruct (classic (inductive_subset B A R)).
  - exfalso. apply Hsub in Hc as Hc'.
    apply Hind in H. rewrite <- H in Hc'.
    apply SepE in Hc' as [_ Hp]. apply Hp in Hc.
    eapply linearOrder_irrefl...
  - apply not_and_or in H as []. {
      exfalso. apply H. intros x Hx. apply SepE1 in Hx...
    }
    apply set_not_all_ex_not in H as [t [Hta H]].
    apply imply_to_and in H as [Hseg Htb].
    cut (∀x ∈ C, < t, x > ∈ R ∨ t = x). {
      intros H. exists t. split...
      destruct (classic (t ∈ C)) as [|Htc]...
      exfalso. apply Htb. apply SepI...
      intros x Hx. pose proof (H x Hx) as []...
    }
    intros x Hxc. apply Hsub in Hxc as Hxa.
    destruct (classic (t = x))...
    eapply linearOrder_connected in H as [|Hxt]...
    exfalso. assert (Hxb: x ∈ B). {
      apply Hseg. apply segI...
    }
    apply SepE in Hxb as [_ H]. apply H in Hxc.
    eapply linearOrder_irrefl...
Qed.

(* 以前节为定义域的所有函数 *)
Definition SegFuncs : set → set → set → set := λ A R B,
  {f ∊ 𝒫 (A × B) | λ f, ∃ t ∈ A, f: seg t R ⇒ B}.

(* 超限递归定理初级表述 *)
Definition transfinite_recursion_preliminary_form :=
  ∀ A R B G, wellOrder R A → G: SegFuncs A R B ⇒ B →
  ∃! F, F: A ⇒ B ∧ ∀t ∈ A, F[t] = G[F ↾ seg t R].

(* 超限递归定理模式 *)
Definition transfinite_recursion_schema :=
  ∀ A R γ, wellOrder R A →
  ∃! F, is_function F ∧ dom F = A ∧ ∀t ∈ A, F[t] = γ (F ↾ seg t R).

(* 超限递归定理模式蕴含其初级表述 *)
Fact transfinite_recursion_schema_to_preliminary_form :
  transfinite_recursion_schema →
  transfinite_recursion_preliminary_form.
Proof with eauto; try congruence.
  intros Schema A R B G Hwo HG.
  pose proof (Schema A R (λ f, G[f]) Hwo) as [[F [HF [Hd Hrec]]] Hu].
  set {x ∊ A | λ x, F[x] ∈ B} as A'.
  replace A with A' in *. {
    assert (Hr: ran F ⊆ B). {
      intros y Hy. apply ranE in Hy as [x Hp].
      apply domI in Hp as Hx. rewrite Hd in Hx.
      apply func_ap in Hp... apply SepE2 in Hx...
    }
    split.
    - exists F. split. split... intros t Ht. rewrite Hrec...
    - intros f1 f2 [[Hf1 [Hd1 Hr1]] H1] [[Hf2 [Hd2 Hr2]] H2].
      apply Hu; split...
  }
  eapply transfinite_induction... split.
  - intros x Hx. apply SepE1 in Hx...
  - intros t Ht Hsub. apply SepI...
    rewrite Hrec... eapply ap_ran... apply SepI.
    + apply PowerAx. intros p Hp.
      apply restrE1 in Hp as [a [b [Ha [Hp Heq]]]]. subst p.
      apply Hsub in Ha. apply SepE in Ha as [Ha HFa].
      apply func_ap in Hp... apply CProdI...
    + exists t. split... split; [|split].
      * apply restr_func...
      * apply restr_dom... eapply sub_tran. apply Hsub.
        rewrite Hd. intros x Hx. apply SepE1 in Hx...
      * intros y Hy. apply ranE in Hy as [x Hp].
        apply restrE2 in Hp as [Hp Hx]. apply func_ap in Hp...
        apply Hsub in Hx. apply SepE2 in Hx...
Qed.



