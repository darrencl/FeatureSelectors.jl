module FeatureSelector

@doc let path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    replace(read(path, String), "```julia" => "```jldoctest")
end FeatureSelector

using Statistics
using StatsBase
using DataFrames
using HypothesisTests
using RDatasets

include("utils.jl")
include("UnivariateFeatureSelector.jl")
# include("PValueBasedFeatureSelector.jl")

#! format: off
export
    UnivariateFeatureSelector

export
    select_features,
    # Measurements
    pearson_correlation,
    f_test,
    chisq_test,
    # Utils
    one_hot_encode

#! format: on
end # module
