"""
`UnivariateFeatureSelector` has the following fields:

* `method::Function` (required)- Method to calculate feature importance. The
  method chosen will determine the scoring. Below is the scring with available
  statistical method to obtain them.

    * Correlation - higher score means more important

        * `pearson_correlation`

    * P-value - lower score means more important

        * `f_test`
        * `chisq_test`

* `k::Union{Int64,Nothing}` - Select top `k` features with the highest correlation to target
  variable. You could ignore this by specifying k == nothing. This defaults to nothing.
* `threshold::Union{Float64,Nothing}` - Select features with correlation more than or equal
  to threshold. To ignore, simply set threshold to nothing (default behavior).
"""
mutable struct UnivariateFeatureSelector
    method::Function
    k::Union{Int64,Nothing}
    threshold::Union{Float64,Nothing}
end

function UnivariateFeatureSelector(;
    method::Function,
    k::Union{Int64,Nothing} = nothing,
    threshold::Union{Float64,Nothing} = nothing,
)
    UnivariateFeatureSelector(method, k, threshold)
end

"""
    select_features(selector,
                    X::DataFrame,
                    y::Vector;
                    verbose::Bool=false)

Select features based on the importance, which is defined by `selector.method`
to target `y`. if `verbose` is true, logs will be printed - this defaults to
false. This function will return only the feature names of selected features.

If you have feature `X_data` as matrix and feature names `X_features` as a
Vector, you can replace `X` with `X_data` and `X_features` (in this order).

# Example

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
5-element Array{Symbol,1}:
 :LStat
 :Rm
 :PTRatio
 :Indus
 :Tax

```
"""
function select_features(
    selector::UnivariateFeatureSelector,
    X_data::Matrix,
    X_features::Vector,
    y::Vector;
    verbose::Bool = false,
)
    score_arr = selector.method(X_data, y)
    # Correlation should be sorted descending
    if selector.method == pearson_correlation
        rev = true
        filter_operator = >=
        if verbose
            @info "method is correlation score, result will be " * "descendingly sorted" rev
        end
    else
        rev = false
        filter_operator = <=
        if verbose
            @info "method is p-value, result will be " * "ascendingly sorted" rev
        end
    end
    sorted_tup =
        sort([x for x in zip(X_features, score_arr)], by = v -> abs(v[2]), rev = rev)
    if !isnothing(selector.k)
        if selector.k < 1
            @warn "k cannot be less than 1. Resetting value to 1"
            selector.k = 1
        end
        verbose && @info "Filtering top k features" selector.k
        sorted_tup = sorted_tup[1:selector.k]
    end
    if !isnothing(selector.threshold)
        verbose && @info "Filtering by threshold" selector.threshold
        sorted_tup = filter(v -> filter_operator(abs(v[2]), selector.threshold), sorted_tup)
    end
    first.(sorted_tup)
end

select_features(
    selector::UnivariateFeatureSelector,
    X::DataFrame,
    y::Vector;
    verbose::Bool = false,
) = select_features(
    selector,
    convert(Matrix, X),
    names(X),
    y;
    verbose = verbose,
)

"""
    pearson_correlation(X_data::Matrix, y::Vector)

Calculate pearson's correlation on `X_data` to `y`.
"""
pearson_correlation(X_data::Matrix, y::Vector) = cor(X_data, y)

"""
    f_test(X_data::Matrix, y::Vector)

Calculate p-value using f-test method.
"""
function f_test(X_data::Matrix, y::Vector)
    pvals = [pvalue(VarianceFTest(X_col, y)) for X_col in eachcol(X_data)]
end

"""
    chisq_test(X_data::Matrix, y::Vector)

Calculate p-value using chi-square test.
"""
function chisq_test(X_data::Matrix, y::Vector)
    # DataFrame for easy aggregation
    data_df = DataFrame(hcat(X_data, y))
    # Rename cols to prevent name clash with count aggregation below
    rename!(data_df, [Symbol("input$i") for i = 1:size(data_df)[2]])
    y_name = names(data_df[!, [end]])[1]
    pvals = Vector{Float64}()
    for (col_name, X_col) in eachcol(data_df[:, 1:end-1], true)
        # Hacky method to generate frequency count and put 0 for missing
        # combination. `by` function is not able to achieve this. See:
        # https://github.com/JuliaData/DataFrames.jl/issues/2136

        # Feature + target to process and put count = 1 for each row
        Xy_df = hcat(data_df[:, [col_name, y_name]], Int.(ones(size(data_df)[1])))
        rename!(Xy_df, :x1 => :Count)
        # This nested join will append missing in Count to missing combination
        # of value in col_name and y_name
        Xy_df = join(
            join(
                DataFrame(; col_name => unique(Xy_df[:, col_name])),
                DataFrame(; y_name => unique(Xy_df[:, y_name])),
                kind = :cross,
            ),
            Xy_df,
            on = [col_name, y_name],
            kind = :outer,
        )
        # sum count and recode missing to 0
        _y = recode(sort(by(Xy_df, [col_name, y_name], r -> sum(r.Count))).x1, missing => 0)
        _y = reshape(
            _y,
            (length(unique(Xy_df[:, col_name])), length(unique(Xy_df[:, y_name]))),
        )
        push!(pvals, pvalue(ChisqTest(_y)))
    end
    pvals
end
