# FeatureSelectors.jl

Simple tool to select feature based on the statistical relationship between features to target variable. The currently implemented feature is based on:

* Correlation
* P-value, which can be obtained by either Chi-square or F test

## Quick start

```jldoctest
julia> using RDatasets, FeatureSelectors, DataFrames

julia> boston = dataset("MASS", "Boston");

julia> selector = UnivariateFeatureSelector(method=pearson_correlation, k=5)
UnivariateFeatureSelector(FeatureSelectors.pearson_correlation, 5, nothing)

julia> select_features(
           selector,
           boston[:, Not(:MedV)],
           boston.MedV
       )
5-element Vector{String}:
 "LStat"
 "Rm"
 "PTRatio"
 "Indus"
 "Tax"
```