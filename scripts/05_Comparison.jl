using Revise
using SyntactileViz

Revise.revise()


# Option A: Compare two graphs you already have
g1 = build_syntax_graph(parse_cex("data/comparison/Comp1-analysis_HQ1.7-corect.cex"))
g2 = build_syntax_graph(parse_cex("data/comparison/Comp1-analysis_HQ1.7_incorrect.cex"))
comp = compare_syntax_graphs(g1, g2)
report_comparison(comp)

# Option B: One-liner (even nicer)
comp = compare_cex_files(
    "data/comparison/Comp1-analysis_HQ1.7-corect.cex",
    "data/comparison/Comp1-analysis_HQ1.7_incorrect.cex"
)
report_comparison(comp)