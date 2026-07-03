using Revise
using SyntactileViz

Revise.revise()

# ... load or build g1 and g2 ...

a1 = parse_cex("data/comparison/analysis_HQ1.10_CWB.cex")
g1 = build_syntax_graph(a1)

a2 = parse_cex("data/comparison/analysis_HQ1.10__Bad_Student_.cex")
g2 = build_syntax_graph(a2)

comp = compare_syntax_graphs(g1, g2)

report_comparison(comp)
export_comparison_markdown(comp, "reports/my_comparison.md")

# NEW: beautiful side-by-side PDF with differences highlighted
save_syntax_comparison(comp, "reports/pdf/comparison_diffs.pdf")