using Revise
using SyntactileViz

Revise.revise()

analysis = parse_cex("data/samples/analysis_HQ4.1.cex")
g = build_syntax_graph(analysis)

# Just the TikZ picture code
println(tikz_hierarchical_tree_code(g))

# Full compilable .tex file
save_tikz_tree(g, "reports/tex/hq4_1_tree.tex")


save_tikz_dependency(g, "reports/tex/hq4_1_dependency.tex")