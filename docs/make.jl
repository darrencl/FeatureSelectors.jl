using Documenter, FeatureSelector

makedocs(;
    modules = [FeatureSelector],
    format = Documenter.HTML(prettyurls = false),
    pages = ["Home" => "index.md", "Module" => "module.md"],
    repo = "https://github.com/darrencl/FeatureSelector.jl/blob/{commit}{path}#L{line}",
    sitename = "FeatureSelector.jl",
    authors = "Darren Lukas <darrenc2995@gmail.com>",
    clean = true,
    doctest = true,
)

deploydocs(
    repo = "github.com/darrencl/FeatureSelector.jl.git",
    target = "build",
    push_preview = true,
)
