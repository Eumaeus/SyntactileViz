using Revise
using SyntactileViz

Revise.revise()


a1 = parse_cex("data/comparison/Comp3-analysis_HQ8.2_Able_Student_urn_cite2_analyzer_analysis_2025-06-13-71b14619-0261-4ee0-90ae-00a9ecd76cef.cex")
g1 = build_syntax_graph(a1)

a2 = parse_cex("data/comparison/Comp3-analysis_HQ8.2_Christopher_Blackwell.cex")
g2 = build_syntax_graph(a2)


save_tikz_dual_dependency_comparison(g1, g2, "reports/tex/dual_comparison.tex")