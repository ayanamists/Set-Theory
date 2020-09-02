#!/bin/sh

echo "building ZFC0"
coqc -R . ZFC ZFC0.v
echo "building ZFC1"
coqc -R . ZFC ZFC1.v
echo "building ZFC2"
coqc -R . ZFC ZFC2.v
echo "building ZFC3"
coqc -R . ZFC ZFC3.v
echo "building Essential"
coqc -R . ZFC lib/Essential.v

echo "building EST2"
coqc -R . ZFC EST2.v
echo "building CH2"
coqc -R . ZFC CH2.v
echo "building EST3_1"
coqc -R . ZFC EST3_1.v
echo "building EST3_2"
coqc -R . ZFC EST3_2.v
echo "building EST3_3"
coqc -R . ZFC EST3_3.v
echo "building CH3_1"
coqc -R . ZFC CH3_1.v
echo "building CH3_2"
coqc -R . ZFC CH3_2.v
echo "building Relation"
coqc -R . ZFC lib/Relation.v
echo "building FuncFacts"
coqc -R . ZFC lib/FuncFacts.v

echo "building EST4_1"
coqc -R . ZFC EST4_1.v
echo "building EST4_2"
coqc -R . ZFC EST4_2.v
echo "building EST4_3"
coqc -R . ZFC EST4_3.v
echo "building CH4"
coqc -R . ZFC CH4.v
echo "building Natural"
coqc -R . ZFC lib/Natural.v

echo "building EST5_1"
coqc -R . ZFC EST5_1.v
echo "building EST5_2"
coqc -R . ZFC EST5_2.v
echo "building EST5_3"
coqc -R . ZFC EST5_3.v
echo "building EST5_4"
coqc -R . ZFC EST5_4.v
echo "building CH5"
coqc -R . ZFC CH5.v
echo "building EST5_5"
coqc -R . ZFC EST5_5.v
echo "building EST5_6"
coqc -R . ZFC EST5_6.v
echo "building EST5_7"
coqc -R . ZFC EST5_7.v
echo "building Real"
coqc -R . ZFC lib/Real.v

echo "building EST6_1"
coqc -R . ZFC EST6_1.v
echo "building EST6_2"
coqc -R . ZFC EST6_2.v
