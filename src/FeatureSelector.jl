module FeatureSelector

using Statistics
using DataFrames
using HypothesisTests

include("utils.jl")
include("CorrelationBasedFeatureSelector.jl")
include("PValueBasedFeatureSelector.jl")

export
    CorrelationBasedFeatureSelector

export
    select_features

end # module
