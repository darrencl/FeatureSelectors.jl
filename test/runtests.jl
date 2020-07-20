using FeatureSelector
using Test
using RDatasets

@testset "FeatureSelector.jl" begin
    @testset "Univariate feature selector" begin
        include("UnivariateFeatureSelector.jl")
    end
end
