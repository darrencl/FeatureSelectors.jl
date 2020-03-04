@testset "correlation feature selection" begin
    # 1. Test without k and threshold
    boston = dataset("MASS", "Boston")
    selector = CorrelationBasedFeatureSelector()
    X = boston[:, Not(:MedV)]
    y = boston.MedV
    selected_features_all = select_features(selector, X, y, return_val = true)
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
    @test first.(selected_features_all) == first.(expected)
    # Using isapprox because the result with Matrix vs Array is not the
    # exact same due to floating point computation. More detail:
    # https://github.com/JuliaLang/Statistics.jl/issues/24
    @test all(last.(selected_features_all) .≈ last.(expected))

    # 2. Test with only k
    selector.k = 5
    selected_features = select_features(selector, X, y)
    @test selected_features == first.(selected_features_all[1:5])

    # 3. Test with only threshold
    selector.k = 0
    selector.threshold = 0.5
    selected_features_threshold = select_features(selector, X, y, return_val = true)
    @test all(i -> abs(i[2]) >= 0.5, (selected_features_threshold))

    # 4. Test with both
    selector.k = 2
    selector.threshold = 0.5
    selected_features = select_features(selector, X, y)
    @test selected_features == first.(selected_features_threshold[1:2])
end