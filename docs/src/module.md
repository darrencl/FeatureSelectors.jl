# Module

Feature selection has been one of the important steps in machine learning.
Some of the advantages of feature selection are the performance increase
and may prevent model to overfits.

This technique selects features based on their importance, which is defined
by how much impact does the feature have to the target variable. This package
helps selecting the important features based on the correlation and p-value.

## Selectors

### Univariate feature selector
```@autodocs
Modules = [FeatureSelector]
Pages   = ["UnivariateFeatureSelector.jl"]
Filter = t -> typeof(t) === DataType
```

#### Supported method
```@docs
pearson_correlation
f_test
chisq_test
```

## Select feature function
```@docs
select_features
```

## Other util functions
```@autodocs
Modules = [FeatureSelector]
Pages   = ["utils.jl"]
```