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
julia> using RDatasets, FeatureSelector

julia> titanic = dataset("datasets", "Titanic");

julia> first(one_hot_encode(titanic[:, [:Class, :Sex, :Age]]), 3)
3×11 DataFrames.DataFrame. Omitted printing of 5 columns
│ Row │ Class  │ Sex    │ Age    │ Class_1st │ Class_2nd │ Class_3rd │
│     │ String │ String │ String │ Bool      │ Bool      │ Bool      │
├─────┼────────┼────────┼────────┼───────────┼───────────┼───────────┤
│ 1   │ 1st    │ Male   │ Child  │ 1         │ 0         │ 0         │
│ 2   │ 2nd    │ Male   │ Child  │ 0         │ 1         │ 0         │
│ 3   │ 3rd    │ Male   │ Child  │ 0         │ 0         │ 1         │


julia> first(one_hot_encode(titanic[:, [:Class, :Sex, :Age]], cols=[:Class], drop_original=true), 3)
3×6 DataFrames.DataFrame
│ Row │ Sex    │ Age    │ Class_1st │ Class_2nd │ Class_3rd │ Class_Crew │
│     │ String │ String │ Bool      │ Bool      │ Bool      │ Bool       │
├─────┼────────┼────────┼───────────┼───────────┼───────────┼────────────┤
│ 1   │ Male   │ Child  │ 1         │ 0         │ 0         │ 0          │
│ 2   │ Male   │ Child  │ 0         │ 1         │ 0         │ 0          │
│ 3   │ Male   │ Child  │ 0         │ 0         │ 1         │ 0          │
```
"""
function one_hot_encode(
    df::DataFrame;
    cols::Vector{Symbol} = Vector{Symbol}(),
    drop_original::Bool = false,
)
    result_df = df
    for (col_name, col) in eachcol(df, true)
        # Ignore if column not in cols
        if !(col_name in cols) && !isempty(cols)
            continue
        end
        tmp_df = DataFrame(Array(transpose(indicatormat(df[:, col_name]))))
        rename!(tmp_df, [Symbol("$(col_name)_$x") for x in sort(unique(df[:, col_name]))])
        result_df = drop_original ? hcat(result_df, tmp_df)[:, Not(col_name)] :
            hcat(result_df, tmp_df)
    end
    result_df
end
