using Revise
using SyntactileViz

Revise.revise()


a1 = parse_cex("data/comparison/Comp3-analysis_HQ8.2_Christopher_Blackwell.cex")
g1 = build_syntax_graph(a1)

a2 = parse_cex("data/comparison/Comp3-analysis_HQ8.2_Able_Student_urn_cite2_analyzer_analysis_2025-06-13-71b14619-0261-4ee0-90ae-00a9ecd76cef.cex")
g2 = build_syntax_graph(a2)

comp = compare_syntax_graphs(g1, g2)


tikz_dependency_comparison(comp)