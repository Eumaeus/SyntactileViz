using Revise
using SyntactileViz

Revise.revise()


a1 = parse_cex("data/comparison/analysis_HQ1.10_CWB.cex")
g1 = build_syntax_graph(a1)

a2 = parse_cex("data/comparison/analysis_HQ1.10__Bad_Student_.cex")
g2 = build_syntax_graph(a2)


comp = compare_syntax_graphs(g1, g2)

tikz_code = tikz_dependency_comparison(comp)           # ← use this

#save_tikz_dual_dependency_comparison(g1, g2, "reports/tex/dual_comparison.tex")