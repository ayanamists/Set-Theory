(** Coq coding by choukh, Oct 2020 **)

Require Import ZFC.EST7_2.

Module SimpleVer.

(* 良序集上的最小元函数 *)
Definition Min : set → set := λ R,
  let P := λ p, minimum (π2 p) (π1 p) R in
  {p ∊ (𝒫 (fld R) - ⎨∅⎬) × fld R | P}.

Lemma minE : ∀ R B m, <B, m> ∈ Min R →
  B ∈ 𝒫 (fld R) - ⎨∅⎬ ∧ minimum m B R.
Proof.
  intros. apply SepE in H as [Hp [Hn Hle]].
  apply CProdE2 in Hp as [HN _].
  zfcrewrite. repeat split; auto.
Qed.

Lemma min_maps_into : ∀ A R, woset A R → (fld R) = A →
  (Min R): 𝒫 A - ⎨∅⎬ ⇒ A.
Proof with eauto.
  intros * [Hlo Hmin] Heq. subst A. split; split.
  - intros p Hp. apply SepE in Hp as [Hp _].
    apply cprod_is_pairs in Hp...
  - intros B HB. split. apply domE in HB...
    intros a b H1 H2.
    apply minE in H1 as [_ [Ha H1]].
    apply minE in H2 as [_ [Hb H2]].
    apply H1 in Hb as []; apply H2 in Ha as []...
    exfalso. eapply lo_irrefl...
    destruct Hlo as [_ [Htr _]]. eapply Htr...
  - apply ExtAx. intros B. split; intros HB.
    + apply domE in HB as [a Hp].
      apply minE in Hp as []...
    + apply SepE in HB as [HB HB']. apply PowerAx in HB as Hsub.
      apply SingNE in HB' as Hne. apply EmptyNE in Hne.
      pose proof (Hmin B Hne Hsub) as [a [Ha Hle]].
      apply (domI _ _ a). apply SepI.
      * apply CProdI. apply SepI... apply Hsub...
      * split. zfcrewrite. intros m Hm. zfcrewrite. apply Hle...
  - intros a Ha. apply ranE in Ha as [B Hp].
    apply minE in Hp as [HB [Ha _]]. apply SepE in HB as [HB _].
    apply PowerAx in HB. apply HB...
Qed.

Lemma min_correct : ∀ A R B, woset A R → (fld R) = A →
  ⦿ B → B ⊆ A → minimum (Min R)[B] B R.
Proof with eauto.
  intros * Hwo Heq Hne Hsub.
  pose proof (min_maps_into A R Hwo) as [Hfm [Hdm _]]...
  assert (HB: B ∈ dom (Min R)). {
    rewrite Hdm. apply SepI. apply PowerAx...
    apply SingNI. apply EmptyNI...
  }
  apply domE in HB as [m Hp]. apply func_ap in Hp as Hap...
  rewrite Hap. eapply minE...
Qed.

(* 良序集上的后继函数 *)
Definition Next : set → set → set → set := λ B R a,
  (Min R)[tail a B R].

Lemma fld_woset : ∀ A R, woset A R →
  (∃ a b ∈ A, (a <ᵣ b) R) → fld R = A.
Proof with eauto.
  intros A R Hwo [a [Ha [b [Hb Hab]]]].
  apply ExtAx. split; intros Hx.
  - destruct Hwo as [[Hbr _] _]. apply BUnionE in Hx as [].
    + apply domE in H as [y Hp]. apply Hbr in Hp.
      apply CProdE2 in Hp as []...
    + apply ranE in H as [w Hp]. apply Hbr in Hp.
      apply CProdE2 in Hp as []...
  - destruct Hwo as [Hlo _].
    destruct (classic (x = a)).
      + destruct (classic (x = b)).
        * exfalso. subst. eapply lo_irrefl...
        * eapply lo_connected in H0 as []...
          apply BUnionI1. eapply domI...
          apply BUnionI2. eapply ranI...
      + eapply lo_connected in H as []...
        * apply BUnionI1. eapply domI...
        * apply BUnionI2. eapply ranI...
Qed.

Lemma next_correct : ∀ A R B, woset A R → B ⊆ A →
  ∀a ∈ B, (∃b ∈ B, (a <ᵣ b) R) →
  minimum (Next B R a) (tail a B R) R.
Proof with eauto.
  intros * Hwo Hsub a Ha [b [Hb Hab]].
  assert (Heq: fld R = A). {
    apply fld_woset...
    exists a. split. apply Hsub...
    exists b. split. apply Hsub... auto.
  }
  specialize (min_correct A R (tail a B R)) as [Hm Hmin]...
  - exists b. apply SepI...
  - destruct Hwo as [[Hbr _] _].
    intros x Hx. apply SepE in Hx as [_ Hp].
    apply Hbr in Hp. apply CProdE2 in Hp as []...
  - split...
Qed.

Lemma next_injective : ∀ A R B, woset A R → B ⊆ A →
  ∀ a b ∈ B, (∃c ∈ B, (a <ᵣ c) R) → (∃d ∈ B, (b <ᵣ d) R) →
  Next B R a = Next B R b → a = b.
Proof with eauto; try congruence.
  intros A R B Hwo Hsub a Ha b Hb Hea Heb Heq.
  pose proof (next_correct A R B Hwo Hsub a Ha Hea) as [Hna H1].
  pose proof (next_correct A R B Hwo Hsub b Hb Heb) as [Hnb H2].
  destruct Hwo as [Hlo _]. assert (H := Hlo).
  destruct H as [_ [Htr _]].
  destruct (classic (a = b))... exfalso.
  eapply lo_connected in H as [Hab|Hba]; eauto; [| |apply Hsub..]...
  - apply SepE in Hnb as [_ Hnb].
    pose proof (H1 b) as []. { apply SepI... }
    + eapply (lo_irrefl R A)...
      eapply Htr. apply Hnb. congruence.
    + eapply (lo_irrefl R A)...
      rewrite <- Heq, H in Hnb. apply Hnb.
  - apply SepE in Hna as [_ Hna].
    pose proof (H2 a) as []. { apply SepI... }
    + eapply (lo_irrefl R A)...
      eapply Htr. apply Hna. congruence.
    + eapply (lo_irrefl R A)...
      rewrite Heq, H in Hna. apply Hna.
Qed.

Lemma ω_min_maps_into : (Min Lt): 𝒫 ω - ⎨∅⎬ ⇒ ω.
Proof.
  apply min_maps_into.
  apply Lt_wellOrder. apply fld_Lt.
Qed.

Lemma ω_min : ∀ N, ⦿ N → N ⊆ ω → ε_minimum (Min Lt)[N] N.
Proof with eauto.
  intros N Hne Hsub.
  eapply ε_minimum_iff... apply (min_correct ω)...
  apply Lt_wellOrder. apply fld_Lt.
Qed.

Lemma ω_next : ∀ N, N ⊆ ω → ∀n ∈ N,
  (∃m ∈ N, n ∈ m) →
  let t := {x ∊ N | λ x, n ∈ x} in
  let p := Next N Lt n in
  p ∈ t ∧ ∀m ∈ t, p ⊆ m.
Proof with auto.
  intros N Hsub n Hn Hne t p.
  assert (Hnw: n ∈ ω) by (apply Hsub; auto).
  pose proof (next_correct ω Lt N) as [Hnxt Hle]...
  - apply Lt_wellOrder.
  - apply Hn.
  - destruct Hne as [m [Hm Hnm]].
    exists m. split... apply binRelI... apply Hsub...
  - split.
    + apply SepE in Hnxt as [Hnxt Hlt].
      apply SepI... apply binRelE3 in Hlt...
    + intros m Hm. assert (m ∈ tail n N Lt). {
        apply SepE in Hm as [Hm Hnm].
        apply SepI... apply binRelI... apply Hsub...
      }
      apply Hle in H as [].
      * apply binRelE2 in H as [Hpw [Hmw Hlt]].
        apply lt_iff_psub...
      * subst m...
Qed.

Lemma ω_next_injective : ∀ N, N ⊆ ω →
  ∀ n m ∈ N, (∃p ∈ N, n ∈ p) → (∃q ∈ N, m ∈ q) →
  Next N Lt n = Next N Lt m → n = m.
Proof with eauto.
  intros N Hsub n Hn m Hm [p [Hp Hnp]] [q [Hq Hmq]].
  eapply next_injective...
  - apply Lt_wellOrder.
  - exists p. split... apply binRelI; auto; apply Hsub...
  - exists q. split... apply binRelI; auto; apply Hsub...
Qed.

Fact ω_next_eq_suc : ∀n ∈ ω, Next ω Lt n = Suc n.
Proof with neauto.
  intros n Hn.
  specialize (ω_next ω) as [Hm Hmin]... {
    exists n⁺. split... apply ω_inductive...
  }
  remember (Next n ω Lt) as p.
  apply SepE in Hm as [Hpw Hnp].
  apply ExtAx. split; intros Hx.
  - assert (n⁺ ∈ {x ∊ ω | In n}). {
      apply SepI... eapply ω_inductive...
    }
    apply Hmin in H. apply H...
  - apply BUnionE in Hx as [].
    + eapply nat_trans...
    + apply SingE in H. subst...
Qed.

End SimpleVer.

Module FullVer.

Definition Min : set → set → set := λ A R,
  let P := λ p, minimum (π2 p) (π1 p) R in
  {p ∊ (𝒫 A - ⎨∅⎬) × A | P}.

Lemma minE : ∀ A R B m, <B, m> ∈ Min A R →
  B ∈ 𝒫 A - ⎨∅⎬ ∧ minimum m B R.
Proof.
  intros. apply SepE in H as [Hp [Hn Hle]].
  apply CProdE2 in Hp as [HN _].
  zfcrewrite. repeat split; auto.
Qed.

Lemma min_maps_into : ∀ A R, woset A R → (Min A R): 𝒫 A - ⎨∅⎬ ⇒ A.
Proof with eauto.
  intros * [Hlo Hmin]. split; split.
  - intros p Hp. apply SepE in Hp as [Hp _].
    apply cprod_is_pairs in Hp...
  - intros B HB. split. apply domE in HB...
    intros a b H1 H2.
    apply minE in H1 as [_ [Ha H1]].
    apply minE in H2 as [_ [Hb H2]].
    apply H1 in Hb as []; apply H2 in Ha as []...
    exfalso. eapply lo_irrefl...
    destruct Hlo as [_ [Htr _]]. eapply Htr...
  - apply ExtAx. intros B. split; intros HB.
    + apply domE in HB as [a Hp].
      apply minE in Hp as []...
    + apply SepE in HB as [HB HB']. apply PowerAx in HB as Hsub.
      apply SingNE in HB' as Hne. apply EmptyNE in Hne.
      pose proof (Hmin B Hne Hsub) as [a [Ha Hle]].
      apply (domI _ _ a). apply SepI.
      * apply CProdI. apply SepI... apply Hsub...
      * split. zfcrewrite. intros m Hm. zfcrewrite. apply Hle...
  - intros a Ha. apply ranE in Ha as [B Hp].
    apply minE in Hp as [HB [Ha _]]. apply SepE in HB as [HB _].
    apply PowerAx in HB. apply HB...
Qed.

Lemma min_correct : ∀ A R B, woset A R →
  ⦿ B → B ⊆ A → minimum (Min A R)[B] B R.
Proof with eauto.
  intros * Hwo Hne Hsub.
  pose proof (min_maps_into A R Hwo) as [Hfm [Hdm _]]...
  assert (HB: B ∈ dom (Min A R)). {
    rewrite Hdm. apply SepI. apply PowerAx...
    apply SingNI. apply EmptyNI...
  }
  apply domE in HB as [m Hp]. apply func_ap in Hp as Hap...
  rewrite Hap. eapply minE...
Qed.

End FullVer.
