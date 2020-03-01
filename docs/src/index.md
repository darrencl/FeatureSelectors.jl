# FeatureSelector.jl

Simple tool to select feature based on the statistical relationship between features to target variable. The currently implemented feature is based on:

* Correlation
* P-value, which can be obtained by either Chi-square or F test

## Quick start

```jldoctest
julia> using RDatasets, FeatureSelector

julia> boston = dataset("MASS", "Boston");

julia> selector = CorrelationBasedFeatureSelector(k=5)
CorrelationBasedFeatureSelector(5, 0.0)

julia> select_features(selector, boston[:, Not(:MedV)], boston.MedV)
5-element Array{Symbol,1}:
 :LStat
 :Rm
 :PTRatio
 :Indus
 :Tax
```