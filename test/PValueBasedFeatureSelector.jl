@testset "f-test feature selection" begin
    # 1. Test without k and threshold
    iris = dataset("datasets", "iris")
    selector = PValueBasedFeatureSelector()
    X = iris[:, Not(:Species)]
    y = Vector{Int64}(recode(iris.Species,
                             "setosa"=> 1,
                             "versicolor"=> 2,
                             "virginica"=>3))
    selected_features_all = select_features(selector, X, y, return_val=true)
    expected =  [(:SepalLength, 0.8960092318703157),
                 (:PetalWidth, 0.37975655685608567),
                 (:SepalWidth, 8.948397578478762e-14),
                 (:PetalLength, 0.0)]
    @test first.(selected_features_all) == first.(expected)
    # Using isapprox because the result with Matrix vs Array is not the
    # exact same. More detail:
    # https://github.com/JuliaLang/Statistics.jl/issues/24
    @test all(last.(selected_features_all) .≈ last.(expected))

    # Test also the p-values are not affected when target encoding swapped
    y = Vector{Int64}(recode(iris.Species,
                             "setosa"=> 3,
                             "versicolor"=> 1,
                             "virginica"=>2))
    selected_features_all = select_features(selector, X, y, return_val=true)
    expected =  [(:SepalLength, 0.8960092318703157),
                 (:PetalWidth, 0.37975655685608567),
                 (:SepalWidth, 8.948397578478762e-14),
                 (:PetalLength, 0.0)]
    @test first.(selected_features_all) == first.(expected)
    @test all(last.(selected_features_all) .≈ last.(expected))

    # 2. Test with only k
    selector.k = 2
    selected_features = select_features(selector, X, y)
    @test selected_features == first.(selected_features_all[1:2])

    # 3. Test with only threshold
    selector.k = 0
    selector.threshold = 0.5
    selected_features_threshold = select_features(selector, X, y, return_val=true)
    @test all(i->abs(i[2])>=0.5, (selected_features_threshold))

    # 4. Test with both
    selector.k = 2
    selector.threshold = 0.5
    selected_features = select_features(selector, X, y)
    @test selected_features == first.(selected_features_threshold[1:1])
end

@testset "chi-square feature selection" begin
    # 1. Test without k and threshold
    titanic = dataset("datasets", "Titanic")
    selector = PValueBasedFeatureSelector(method=:ChiSq)
    X = one_hot_encode(titanic[:, [:Class, :Sex, :Age]]; drop_original=true)
    y = Vector{Int64}(recode(titanic.Survived,
                             "No"=> 1,
                             "Yes"=> 2))
    selected_features_all = select_features(selector, X, y, return_val=true)
    expected =  [(:SepalLength, 0.8960092318703157),
                 (:PetalWidth, 0.37975655685608567),
                 (:SepalWidth, 8.948397578478762e-14),
                 (:PetalLength, 0.0)]
    @test first.(selected_features_all) == first.(expected)
    # Using isapprox because the result with Matrix vs Array is not the
    # exact same. More detail:
    # https://github.com/JuliaLang/Statistics.jl/issues/24
    @test all(last.(selected_features_all) .≈ last.(expected))

    # Test also the p-values are not affected when target encoding changed
    y = Vector{Int64}(recode(titanic.Survived,
                             "No"=> 0,
                             "Yes"=> 1))
    selected_features_all = select_features(selector, X, y, return_val=true)
    expected =  [(:SepalLength, 0.8960092318703157),
                 (:PetalWidth, 0.37975655685608567),
                 (:SepalWidth, 8.948397578478762e-14),
                 (:PetalLength, 0.0)]
    @test first.(selected_features_all) == first.(expected)
    @test all(last.(selected_features_all) .≈ last.(expected))

    # 2. Test with only k
    selector.k = 2
    selected_features = select_features(selector, X, y)
    @test selected_features == first.(selected_features_all[1:2])

    # 3. Test with only threshold
    selector.k = 0
    selector.threshold = 0.5
    selected_features_threshold = select_features(selector, X, y, return_val=true)
    @test all(i->abs(i[2])>=0.5, (selected_features_threshold))

    # 4. Test with both
    selector.k = 2
    selector.threshold = 0.5
    selected_features = select_features(selector, X, y)
    @test selected_features == first.(selected_features_threshold[1:1])
end
