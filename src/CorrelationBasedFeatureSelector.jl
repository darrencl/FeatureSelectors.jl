"""
`CorrelationBasedFeatureSelector` has the following fields:

* `k::Int64` - Select top `k` features with the highest correlation to target
  variable. You could ignore this by specifying k <= 0.
* `threshold::Float64` - Select features with correlation more than or equal to
  threshold. To ignore, simply set threshold to 0.
"""
struct CorrelationBasedFeatureSelector
    k::Int64
    threshold::Float64
end

function select_features(selector::CorrelationBasedFeatureSelector,
                         X_data::Matrix,
                         X_features::Vector{Any}
                         y::Vector{Any})
    cor_arr = cor(X_data, y)
    sorted_tup = sort([x for x in zip(X_features, cor_arr)], by=v-> abs(v[2]))
    if selector.k > 0
        @info "Filtering top k features" selector.k
        sorted_tup = sorted_tup[1:selector.k]
    end
    @info "Filtering by threshold" selector.threshold
    sorted_tup = filter(v-> v[2]=>selector.threshold, sorted_tup)
    first.(sorted_tup)
end

function select_features(selector::CorrelationBasedFeatureSelector,
                         X::DataFrame,
                         y::Vector{Any})
    select_features(selector, convert(Matrix, X), names(X), y)
end
