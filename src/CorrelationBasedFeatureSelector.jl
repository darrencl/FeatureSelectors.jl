"""
`CorrelationBasedFeatureSelector` has the following fields:

* `k::Int64` - Select top `k` features with the highest correlation to target
  variable. You could ignore this by specifying k <= 0. This defaults to 0.
* `threshold::Float64` - Select features with correlation more than or equal to
  threshold. To ignore, simply set threshold to 0 (default behavior).
"""
struct CorrelationBasedFeatureSelector
    k::Int64
    threshold::Float64
end

function CorrelationBasedFeatureSelector(;k::Int64=0, threshold::Float64=0.0)
    CorrelationBasedFeatureSelector(k, threshold)
end

"""
    function select_features(selector,
                             X::DataFrame,
                             y::Vector)

Select features based on the importance, which is defined by `selector` to
target `y`. The available options for `selector` are:

* `CorrelationBasedFeatureSelector` - Based on Pearson's correlation
* `ModelBasedFeatureSelector` (TODO)
"""
function select_features(selector::CorrelationBasedFeatureSelector,
                         X_data::Matrix,
                         X_features::Vector,
                         y::Vector;
                         verbose::Bool=false,
                         return_val::Bool=true)
    cor_arr = cor(X_data, y)
    sorted_tup = sort([x for x in zip(X_features, cor_arr)], by=v-> abs(v[2]))
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

select_features(selector::CorrelationBasedFeatureSelector,
                X::DataFrame,
                y::Vector;
                verbose::Bool=false,
                return_val::Bool=true) =
    select_features(selector,
                    convert(Matrix, X),
                    names(X),
                    y;
                    verbose=verbose,
                    return_val=return_val)
