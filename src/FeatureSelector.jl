module FeatureSelector

using Statistics
using DataFrames

include("CorrelationBasedFeatureSelector.jl")

export
    CorrelationBasedFeatureSelector

end # module
