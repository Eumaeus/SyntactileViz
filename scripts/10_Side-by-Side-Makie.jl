using Revise
using SyntactileViz

Revise.revise()

# ... load or build g1 and g2 ...

a1 = parse_cex("data/comparison/Comp2-analysis_HQ8.1-Able_Student.cex")
g1 = build_syntax_graph(a)

a2 = parse_cex("data/comparison/Comp2-analysis_HQ8.1-Christopher_Blackwell.cex")
g2 = build_syntax_graph(a)

comp = compare_syntax_graphs(g1, g2)

report_comparison(comp)
export_comparison_markdown(comp, "reports/my_comparison.md")

# NEW: beautiful side-by-side PDF with differences highlighted
save_comparison_visualization(comp, "reports/pdf/comparison_diffs.pdf")