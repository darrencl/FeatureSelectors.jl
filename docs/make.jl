using Documenter, FeatureSelectors

makedocs(;
    modules = [FeatureSelectors],
    format = Documenter.HTML(prettyurls = false),
    pages = ["Home" => "index.md", "Module" => "module.md"],
    repo = "https://github.com/darrencl/FeatureSelectors.jl/blob/{commit}{path}#L{line}",
    sitename = "FeatureSelectors.jl",
    authors = "Darren Lukas <darrenc2995@gmail.com>",
    clean = true,
    doctest = true,
)

deploydocs(
    repo = "github.com/darrencl/FeatureSelectors.jl.git",
    target = "build",
    push_preview = true,
)
