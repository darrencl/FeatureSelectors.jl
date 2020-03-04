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
    expected =  [(:PetalLength, 0.0),
                 (:SepalWidth, 8.948397578478762e-14),
                 (:PetalWidth, 0.37975655685608567),
                 (:SepalLength, 0.8960092318703157)]
    @test first.(selected_features_all) == first.(expected)
    @test all(last.(selected_features_all) .≈ last.(expected))

    # Test also the p-values are not affected when target encoding swapped
    y = Vector{Int64}(recode(iris.Species,
                             "setosa"=> 3,
                             "versicolor"=> 1,
                             "virginica"=>2))
    selected_features_all = select_features(selector, X, y, return_val=true)
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
    @test all(i->abs(i[2])<=0.5, (selected_features_threshold))

    # 4. Test with both
    selector.k = 2
    selector.threshold = 0.5
    selected_features = select_features(selector, X, y)
    @test selected_features == first.(selected_features_threshold[1:2])
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
    expected =  [
        (:V2_1, 1.2657890724845934e-23),
        (:V3_1, 6.420486028446245e-22),
        (:V1_10, 5.522053763061195e-7),
        (:V1_1, 2.501514629267585e-6),
        (:V3_5, 3.034100127497124e-6),
        (:V2_10, 1.6011325170677212e-5),
        (:V2_5, 3.6277160399500314e-5),
        (:V3_10, 0.00018174534852021112),
        (:V1_8, 0.000940161869807205),
        (:V2_3, 0.0021417003254380123),
        (:V1_4, 0.004106630359262986),
        (:V1_7, 0.004251672172049395),
        (:V1_9, 0.004251672172049395),
        (:V3_7, 0.004251672172049395),
        (:V2_4, 0.004446485982989494),
        (:V3_6, 0.004446485982989494),
        (:V1_2, 0.005279083487939165),
        (:V3_4, 0.007455684495551331),
        (:V2_6, 0.009569951674053072),
        (:V2_7, 0.020438140781459755),
        (:V1_3, 0.05154325403026049),
        (:V3_8, 0.0924058047659373),
        (:V1_5, 0.10639608980657496),
        (:V3_3, 0.1697251182676055),
        (:V3_9, 0.25122678139322957),
        (:V3_2, 0.26413900085737735),
        (:V2_8, 0.4100233417486837),
        (:V2_2, 0.6279678908602435),
        (:V1_6, 0.695728316971443),
    ]
    @test first.(selected_features_all) == first.(expected)
    @test all(last.(selected_features_all) .≈ last.(expected))

    # Test also the p-values are not affected when target encoding changed
    y = Vector{Int64}(recode(biopsy.Class,
                             "benign"=> 0,
                             "malignant"=> 1))
    selected_features_all = select_features(selector, X, y, return_val=true)
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
    @test all(i->abs(i[2])<=0.5, (selected_features_threshold))

    # 4. Test with both
    selector.k = 2
    selector.threshold = 0.5
    selected_features = select_features(selector, X, y)
    @test selected_features == first.(selected_features_threshold[1:2])
end
