"""
`CorrelationBasedFeatureSelector` has the following fields:

* `k::Int64` - Select top `k` features with the highest correlation to target
  variable. You could ignore this by specifying k <= 0. This defaults to 0.
* `threshold::Float64` - Select features with correlation more than or equal to
  threshold. To ignore, simply set threshold to 0 (default behavior).
"""
mutable struct CorrelationBasedFeatureSelector
    k::Int64
    threshold::Float64
end

function CorrelationBasedFeatureSelector(;k::Int64=0, threshold::Float64=0.0)
    CorrelationBasedFeatureSelector(k, threshold)
end

"""
    function select_features(selector,
                             X::DataFrame,
                             y::Vector;
                             verbose::Bool=false,
                             return_val::Bool=false)

Select features based on the importance, which is defined by `selector` to
target `y`. if `verbose` is true, logs will be printed - this defaults to
false. If `return_val` is true, this function will return only the feature
feature names, otherwise, tuple of selected feature names and the
correlation value are returned.

If you have feature `X_data` as matrix and feature names `X_features` as a
Vector, you can replace `X` with `X_data` and `X_features` (in this order).

# Example

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
"""
function select_features(selector::CorrelationBasedFeatureSelector,
                         X_data::Matrix,
                         X_features::Vector,
                         y::Vector;
                         verbose::Bool=false,
                         return_val::Bool=false)
    cor_arr = cor(X_data, y)
    sorted_tup = sort([x for x in zip(X_features, cor_arr)],
                      by=v-> abs(v[2]),
                      rev=true)
    if selector.k > 0
        verbose && @info "Filtering top k features" selector.k
        sorted_tup = sorted_tup[1:selector.k]
    end
    if selector.threshold > 0.0
        verbose && @info "Filtering by threshold" selector.threshold
        sorted_tup = filter(v-> abs(v[2])>=selector.threshold, sorted_tup)
    end
    if return_val
        sorted_tup
    else
        first.(sorted_tup)
    end
end

select_features(selector::CorrelationBasedFeatureSelector,
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
