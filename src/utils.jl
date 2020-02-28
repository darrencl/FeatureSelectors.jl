"""
    function one_hot(df::DataFrame; cols::Vector{Symbol})

Utility function to perform one-hot-encoding in DataFrame. This will add new columns
with names <original_col_name>_<value>. `cols` can be passed to specify which columns
to be encoded.
"""
function one_hot(df::DataFrame; cols::Vector{Symbol})
    result_df = ""
    for (col_name, col) in eachcol(df, true)
        tmp_df = DataFrame(
            Array(transpose(indicatormat(df[:, col_name]))))
        names!(tmp_df, [Symbol("$(col_name)_$x") for x in sort(unique(df[:, col_name]))])
        result_df = hcat(df, tmp_df)
    end
    result_df
end
