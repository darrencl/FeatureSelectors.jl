"""
`PValueBasedFeatureSelector` has the following fields:

* `k::Int64` - Select top `k` features with the highest correlation to target
  variable. You could ignore this by specifying k <= 0. This defaults to 0.
* `threshold::Float64` - Select features with correlation less than or equal to
  threshold. Note that, in P-value, a feature is considered important when the value
  is close to 0. To ignore, simply set threshold to 0 (default behavior).
* `method::Symbol` - Type of test to get the p-value. The available option are
  `:FTest` and `:ChiSq`. `:ChiSq` expects the input and target are in non-negative
  integers.
"""
mutable struct PValueBasedFeatureSelector
    k::Int64
    threshold::Float64
    method::Symbol
end

function PValueBasedFeatureSelector(;
    k::Int64 = 0,
    threshold::Float64 = 0.0,
    method::Symbol = :FTest,
)
    PValueBasedFeatureSelector(k, threshold, method)
end

# Docstring in CorrelationBasedFeatureSelector.jl
function select_features(
    selector::PValueBasedFeatureSelector,
    X_data::Matrix,
    X_features::Vector,
    y::Vector;
    verbose::Bool = false,
    return_val::Bool = false,
)
    # TODO: Calculate p value for each test - F-test and ChiSq
    pvals = begin
        if selector.method == :FTest
            [pvalue(VarianceFTest(X_col, y)) for X_col in eachcol(X_data)]
        elseif selector.method == :ChiSq
            # DataFrame for easy aggregation
            data_df = DataFrame(hcat(X_data, y))
            # Rename cols to prevent name clash with count aggregation below
            rename!(data_df, [Symbol("input$i") for i = 1:size(data_df)[2]])
            y_name = names(data_df[!, [end]])[1]
            tmp_pvals = Vector{Float64}()
            for (col_name, X_col) in eachcol(data_df[:, 1:end-1], true)
                # Hacky method to generate frequency count and put 0 for missing
                # combination. `by` function is not able to achieve this. See:
                # https://github.com/JuliaData/DataFrames.jl/issues/2136

                # Feature + target to process and put count = 1 for each row
                Xy_df =     hcat(data_df[:, [col_name, y_name]], Int.(ones(size(data_df)[1])))
                rename!(Xy_df, :x1 => :Count)
                # This nested join will append missing in Count to missing combination
                # of value in col_name and y_name
                Xy_df = join(
                    join(
                        DataFrame(Dict(col_name => unique(Xy_df[:, col_name]))),
                        DataFrame(Dict(y_name => unique(Xy_df[:, y_name]))),
                        kind = :cross,
                    ),
                    Xy_df,
                    on = [col_name, y_name],
                    kind = :outer,
                )
                # sum count and recode missing to 0
                _y = recode(
                    sort(by(Xy_df, [col_name, y_name], r -> sum(r.Count))).x1,
                    missing => 0,
                )
                _y = reshape(
                    _y,
                    (length(unique(Xy_df[:, col_name])), length(unique(Xy_df[:, y_name]))),
                )
                push!(tmp_pvals, pvalue(ChisqTest(_y)))
            end
            tmp_pvals
        end
    end
    sorted_tup = sort([x for x in zip(X_features, pvals)], by = v -> abs(v[2]))
    if selector.k > 0
        verbose && @info "Filtering top k features" selector.k
        sorted_tup = sorted_tup[1:selector.k]
    end
    if selector.threshold > 0.0
        verbose && @info "Filtering by threshold" selector.threshold
        sorted_tup = filter(v -> v[2] <= selector.threshold, sorted_tup)
    end
    if return_val
        sorted_tup
    else
        first.(sorted_tup)
    end
end

select_features(
    selector::PValueBasedFeatureSelector,
    X::DataFrame,
    y::Vector;
    verbose::Bool = false,
    return_val::Bool = false,
) = select_features(
    selector,
    convert(Matrix, X),
    names(X),
    y;
    verbose = verbose,
    return_val = return_val,
)
