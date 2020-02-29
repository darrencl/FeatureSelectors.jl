"""
`PValueBasedFeatureSelector` has the following fields:

* `k::Int64` - Select top `k` features with the highest correlation to target
  variable. You could ignore this by specifying k <= 0. This defaults to 0.
* `threshold::Float64` - Select features with correlation less than or equal to
  threshold. Note that, in P-value, a feature is considered important when the value
  is close to 0. To ignore, simply set threshold to 0 (default behavior).
* `options::Symbol` - Type of test to get the p-value. The available option are
  `:FTest` and `:ChiSq`. `:ChiSq` expects the input and target are in non-negative
  integers.
"""
mutable struct PValueBasedFeatureSelector
    k::Int64
    threshold::Float64
    options::Symbol
end

function PValueBasedFeatureSelector(;
                                    k::Int64=0,
                                    threshold::Float64=0.0,
                                    options::Symbol=:FTest)
    PValueBasedFeatureSelector(k, threshold, options)
end

# Docstring in CorrelationBasedFeatureSelector.jl
function select_features(selector::PValueBasedFeatureSelector,
                         X_data::Matrix,
                         X_features::Vector,
                         y::Vector;
                         verbose::Bool=false,
                         return_val::Bool=false)
    # TODO: Calculate p value for each test - F-test and ChiSq
    pvals = begin
        if pval == :FTest
            [pvalue(VarianceFTest(X_col, y))
             for X_col in eachcol(X_data)]
        elseif pval == :ChiSq
            [pvalue(ChisqTest(X_col, y))
             for X_col in eachcol(X_data)]
        end
    end
    sorted_tup = sort([x for x in zip(X_features, pvals)], 
                      by=v-> abs(v[2]), 
                      rev=true)
    if selector.k > 0
        verbose && @info "Filtering top k features" selector.k
        sorted_tup = sorted_tup[1:selector.k]
    end
    if selector.threshold > 0.0
        verbose && @info "Filtering by threshold" selector.threshold
        sorted_tup = filter(v-> v[2]>=selector.threshold, sorted_tup)
    end
    if return_val
        sorted_tup
    else
        first.(sorted_tup)
    end
end

select_features(selector::PValueBasedFeatureSelector,
                X::DataFrame,
                y::Vector;
                verbose::Bool=false,
                return_val::Bool=false) =
    select_features(selector,
                    convert(Matrix, X),
                    names(X),
                    y;
                    verbose=verbose,
                    return_val=return_val)
