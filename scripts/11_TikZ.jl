using Revise
using SyntactileViz

Revise.revise()

analysis = parse_cex("data/samples/analysis_HQ4.1.cex")
g = build_syntax_graph(analysis)


# Default behavior (recommended) — automatically scales if too wide
save_tikz_dependency(g, "reports/tex/hq4_1_dependency.tex")
save_tikz_tree(g, "reports/tex/hq4_1_tree.tex")