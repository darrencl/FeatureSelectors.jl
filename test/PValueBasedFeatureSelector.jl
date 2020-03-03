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
    biopsy = dataset("MASS", "biopsy")[1:150, :] # Only use 150 data for test purpose
    selector = PValueBasedFeatureSelector(method=:ChiSq)
    # One-hot encode and only use 3 features
    X = one_hot_encode(biopsy[:, [:V1, :V2, :V3]]; drop_original=true)
    y = Vector{Int64}(recode(biopsy.Class,
                             "benign"=> 1,
                             "malignant"=> 2))
    selected_features_all = select_features(selector, X, y, return_val=true)
    expected =  [(:SepalLength, 0.8960092318703157),
                 (:PetalWidth, 0.37975655685608567),
                 (:SepalWidth, 8.948397578478762e-14),
                 (:PetalLength, 0.0)]
    @test first.(selected_features_all) == first.(expected)
    @test all(last.(selected_features_all) .≈ last.(expected))

    # Test also the p-values are not affected when target encoding changed
    y = Vector{Int64}(recode(biopsy.Survived,
                             "benign"=> 0,
                             "malignant"=> 1))
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
