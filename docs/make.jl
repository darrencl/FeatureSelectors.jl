using Documenter, FeatureSelector

makedocs(;
    modules=[FeatureSelector],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/darrencl/FeatureSelector.jl/blob/{commit}{path}#L{line}",
    sitename="FeatureSelector.jl",
    authors="Darren Lukas <darren.lukas@tri.edu.au>",
    assets=String[],
)
