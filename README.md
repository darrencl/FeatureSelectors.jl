# FeatureSelector.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://darrencl.github.io/FeatureSelector.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://darrencl.github.io/FeatureSelector.jl/dev)
[![CI](https://github.com/darrencl/FeatureSelector.jl/workflows/CI/badge.svg)](https://github.com/darrencl/FeatureSelector.jl/actions?query=workflow%3ACI)
[![Codecov](https://codecov.io/gh/darrencl/FeatureSelector.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/darrencl/FeatureSelector.jl)

Simple tool to select feature based on the statistical relationship between features to target variable. The currently implemented feature is based on:

* Correlation
* P-value, which can be obtained by either Chi-square or F test

## Quick start

```
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