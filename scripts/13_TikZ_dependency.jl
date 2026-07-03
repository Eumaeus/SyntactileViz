using Revise
using SyntactileViz

Revise.revise()

analysis = parse_cex("data/samples/analysis_HQ2.13_Christopher_Blackwell_specific_objects.cex")
g = build_syntax_graph(analysis)


# Default behavior (recommended) — automatically scales if too wide
save_tikz_dependency(g, "reports/tex/hq2_13_dependency.tex")
save_tikz_tree(g, "reports/tex/hq2_13_tree.tex")

