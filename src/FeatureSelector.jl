module FeatureSelector

using Statistics
using DataFrames

include("CorrelationBasedFeatureSelector.jl")
include("PValueBasedFeatureSelector.jl")

export
    CorrelationBasedFeatureSelector

export
    select_features

end # module
