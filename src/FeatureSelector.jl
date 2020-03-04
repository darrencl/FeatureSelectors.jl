module FeatureSelector

using Statistics
using StatsBase
using DataFrames
using HypothesisTests
using RDatasets

include("utils.jl")
include("CorrelationBasedFeatureSelector.jl")
include("PValueBasedFeatureSelector.jl")

export CorrelationBasedFeatureSelector, PValueBasedFeatureSelector

export select_features, one_hot_encode

end # module
