using FeatureSelector
using Test
using RDatasets

@testset "FeatureSelector.jl" begin
    include("CorrelationBasedFeatureSelector.jl")
end
