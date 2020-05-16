@testset "correlation feature selection" begin
    # 1. Test without k and threshold
    boston = dataset("MASS", "Boston")
    selector = UnivariateFeatureSelector(method = pearson_correlation)
    X = boston[:, Not(:MedV)]
    y = boston.MedV
    selected_features_all = select_features(selector, X, y)
    feature_scores_all = calculate_feature_importance(selector.method, X, y)
    expected = [
        (:LStat, -0.7376627261740151),
        (:Rm, 0.6953599470715394),
        (:PTRatio, -0.507786685537562),
        (:Indus, -0.4837251600283729),
        (:Tax, -0.46853593356776707),
        (:NOx, -0.4273207723732826),
        (:Crim, -0.38830460858681154),
        (:Rad, -0.38162623063977785),
        (:Age, -0.37695456500459634),
        (:Zn, 0.3604453424505432),
        (:Black, 0.3334608196570664),
        (:Dis, 0.24992873408590394),
        (:Chas, 0.1752601771902984),
    ]
    @test selected_features_all == first.(expected)
    # Using isapprox because the result with Matrix vs Array is not the
    # exact same due to floating point computation. More detail:
    # https://github.com/JuliaLang/Statistics.jl/issues/24
    @test all(sort(collect(values(feature_scores_all)), by=abs, rev=true) .≈ last.(expected))

    # 2. Test with only k
    selector.k = 5
    selected_features = select_features(selector, X, y)
    @test selected_features == selected_features_all[1:5]

    # 3. Test with only threshold
    selector.k = nothing
    selector.threshold = 0.5
    selected_features_threshold = select_features(selector, X, y)
    feature_scores = calculate_feature_importance(selector.method, X, y)
    selected_features_score = filter(e->e[1] in selected_features_threshold, feature_scores)
    @test all(i -> abs(i) >= 0.5, values(selected_features_score))

    # 4. Test with both
    selector.k = 2
    selector.threshold = 0.5
    selected_features = select_features(selector, X, y)
    @test selected_features == selected_features_threshold[1:2]

    # 5. Test warn when setting k = 0
    selector.k = 0
    @test_logs(
        (:warn, r"k cannot be less than 1. Resetting value to 1"),
        select_features(selector, X, y)
    )

end

@testset "f-test feature selection" begin
    # 1. Test without k and threshold
    iris = dataset("datasets", "iris")
    selector = UnivariateFeatureSelector(method = f_test)
    X = iris[:, Not(:Species)]
    y = Vector{Int64}(recode(
        iris.Species,
        "setosa" => 1,
        "versicolor" => 2,
        "virginica" => 3,
    ))
    selected_features_all = select_features(selector, X, y)
    feature_scores_all = calculate_feature_importance(selector.method, X, y)
    expected = [
        (:PetalLength, 0.0),
        (:SepalWidth, 8.948397578478762e-14),
        (:PetalWidth, 0.37975655685608567),
        (:SepalLength, 0.8960092318703157),
    ]
    @test selected_features_all == first.(expected)
    @test all(sort(collect(values(feature_scores_all)), by=abs) .≈ last.(expected))

    # Test also the p-values are not affected when target encoding swapped
    y = Vector{Int64}(recode(
        iris.Species,
        "setosa" => 3,
        "versicolor" => 1,
        "virginica" => 2,
    ))
    selected_features_all = select_features(selector, X, y)
    feature_scores_all = calculate_feature_importance(selector.method, X, y)
    @test selected_features_all == first.(expected)
    @test all(sort(collect(values(feature_scores_all)), by=abs) .≈ last.(expected))

    # 2. Test with only k
    selector.k = 2
    selected_features = select_features(selector, X, y)
    @test selected_features == selected_features_all[1:2]

    # 3. Test with only threshold
    selector.k = nothing
    selector.threshold = 0.5
    selected_features_threshold = select_features(selector, X, y)
    feature_scores = calculate_feature_importance(selector.method, X, y)
    selected_features_score = filter(e->e[1] in selected_features, feature_scores)
    @test all(i -> abs(i) <= 0.5, values(selected_features_score))

    # 4. Test with both
    selector.k = 2
    selector.threshold = 0.5
    selected_features = select_features(selector, X, y)
    @test selected_features == selected_features_threshold[1:2]
end

@testset "chi-square feature selection" begin
    # 1. Test without k and threshold
    biopsy = dataset("MASS", "biopsy")[1:150, :] # Only use 150 data for test purpose
    selector = UnivariateFeatureSelector(method = chisq_test)
    # One-hot encode and only use 3 features
    X = one_hot_encode(biopsy[:, [:V1, :V2, :V3]]; drop_original = true)
    y = Vector{Int64}(recode(biopsy.Class, "benign" => 1, "malignant" => 2))
    selected_features_all = select_features(selector, X, y)
    feature_scores_all = calculate_feature_importance(selector.method, X, y)
    expected = [
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
    @test selected_features_all == first.(expected)
    @test all(sort(collect(values(feature_scores_all)), by=abs) .≈ last.(expected))

    # Test also the p-values are not affected when target encoding changed
    y = Vector{Int64}(recode(biopsy.Class, "benign" => 0, "malignant" => 1))
    selected_features_all = select_features(selector, X, y)
    feature_scores_all = calculate_feature_importance(selector.method, X, y)
    @test selected_features_all == first.(expected)
    @test all(sort(collect(values(feature_scores_all)), by=abs) .≈ last.(expected))

    # 2. Test with only k
    selector.k = 2
    selected_features = select_features(selector, X, y)
    @test selected_features == selected_features_all[1:2]

    # 3. Test with only threshold
    selector.k = nothing
    selector.threshold = 0.5
    selected_features_threshold = select_features(selector, X, y)
    feature_scores = calculate_feature_importance(selector.method, X, y)
    selected_features_score = filter(e->e[1] in selected_features, feature_scores)
    @test all(i -> abs(i) <= 0.5, values(selected_features_score))

    # 4. Test with both
    selector.k = 2
    selector.threshold = 0.5
    selected_features = select_features(selector, X, y)
    @test selected_features == selected_features_threshold[1:2]
end
