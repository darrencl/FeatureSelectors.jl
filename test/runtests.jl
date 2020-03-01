using FeatureSelector
using Test
using RDatasets

@testset "FeatureSelector.jl" begin
    include("CorrelationBasedFeatureSelector.jl")
    include("PValueBasedFeatureSelector.jl")
end
