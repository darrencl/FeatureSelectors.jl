"""
    one_hot_encode(df::DataFrame;
                   cols::Vector{Symbol}=Vector{Symbol}(),
                   drop_original::Bool=false)

Utility function to perform one-hot-encoding in DataFrame. This will add new columns
with names `<original_col_name>_<value>`.

Following options can be passed to modify behavior.

* `cols` - Vector of Symbol to specify which columns to be encoded. Defaults to
  empty, which means all features will be encoded.
* `drop_original` - If true, this will drop the original feature set from resulting
  DataFrame. This defaults to false.

# Example

```jldoctest
julia> using RDatasets, FeatureSelectors

julia> titanic = dataset("datasets", "Titanic");

julia> first(one_hot_encode(titanic[:, [:Class, :Sex, :Age]]), 3)
3×11 DataFrame
 Row │ Class    Sex      Age      Class_1st  Class_2nd  Class_3rd  Class_Crew  ⋯
     │ String7  String7  String7  Bool       Bool       Bool       Bool        ⋯
─────┼──────────────────────────────────────────────────────────────────────────
   1 │ 1st      Male     Child         true      false      false       false  ⋯
   2 │ 2nd      Male     Child        false       true      false       false
   3 │ 3rd      Male     Child        false      false       true       false
                                                               4 columns omitted


julia> first(one_hot_encode(titanic[:, [:Class, :Sex, :Age]], cols=[:Class], drop_original=true), 3)
3×6 DataFrame
 Row │ Sex      Age      Class_1st  Class_2nd  Class_3rd  Class_Crew
     │ String7  String7  Bool       Bool       Bool       Bool
─────┼───────────────────────────────────────────────────────────────
   1 │ Male     Child         true      false      false       false
   2 │ Male     Child        false       true      false       false
   3 │ Male     Child        false      false       true       false

```
"""
function one_hot_encode(
    df::DataFrame;
    cols::Vector{Symbol} = Vector{Symbol}(),
    drop_original::Bool = false,
)
    result_df = df
    for col_name in names(df)
        # Ignore if column not in cols
        if !(Symbol(col_name) in cols) && !isempty(cols)
            continue
        end
        tmp_df = DataFrame(Array(transpose(indicatormat(df[:, col_name]))), :auto)
        rename!(tmp_df, [Symbol("$(col_name)_$x") for x in sort(unique(df[:, col_name]))])
        result_df = drop_original ? hcat(result_df, tmp_df)[:, Not(col_name)] :
            hcat(result_df, tmp_df)
    end
    result_df
end


"""
    calculate_feature_importance(method::Function, X::DataFrame, y::Vector)

Calculate feature importance defined by `method`. Similar with `select_features`, this can
take `X` in `DataFrame` or splitted into `X_data` in `Matrix` and `X_features` in `Vector`.

This function will return `Dict` with feature names as key and scores as value.
"""
function calculate_feature_importance(
    method::Function,
    X_data::Matrix,
    X_features::Vector,
    y::Vector
)
    scores = method(X_data, y)
    Dict(feature_name=>score for (feature_name,score) in zip(X_features, scores))
end

calculate_feature_importance(
    method::Function,
    X::DataFrame,
    y::Vector
) = calculate_feature_importance(
    method,
    Matrix(X),
    names(X),
    y,
)
