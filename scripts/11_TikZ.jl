using Revise
using SyntactileViz

Revise.revise()

analysis = parse_cex("data/samples/analysis_HQ4.1.cex")
g = build_syntax_graph(analysis)


# Default behavior (recommended) — automatically scales if too wide
save_tikz_dependency(g, "reports/tex/hq4_1_dependency.tex")
save_tikz_tree(g, "reports/tex/hq4_1_tree.tex")

# Testing overrides

# With edge highlighting (example)
overrides = Dict(
    ("urn:cts:fuTeaching:blackwell.hq.2026:4.1.token.8", "urn:cts:fuTeaching:blackwell.hq.2026:4.1.token.3") => "red, thick",
    ("urn:cts:fuTeaching:blackwell.hq.2026:4.1.token.10", "urn:cts:fuTeaching:blackwell.hq.2026:4.1.token.1")  => "orange, dashed"
)

save_tikz_dependency(g, "reports/tex/override_hq4_1_dependency.tex"; 
                     edge_overrides = overrides)