using FeatureSelectors
using Test
using RDatasets

@testset "FeatureSelectors.jl" begin
    @testset "Univariate feature selector" begin
        include("UnivariateFeatureSelector.jl")
    end
end
