using Revise
using SyntactileViz

Revise.revise()

comp = compare_cex_files(
    "data/comparison/hq_10_02.cex",
    "data/comparison/hq_10_02_vu.cex"
)

a1 = parse_cex("data/comparison/hq_10_02.cex")
g1 = build_syntax_graph(a1)

a2 = parse_cex("data/comparison/hq_10_02_vu.cex")
g2 = build_syntax_graph(a2)

#comp = compare_syntax_graphs(g1, g2)

export_comparison_markdown(comp, "reports/comparison_report.md")

export_comparison_markdown(comp, "reports/report_detailed.md"; show_token_vu_assignments = true)

# Single analysis
#save_tikz_verbal_unit_linear(g1, "reports/verbal_units.tex")

# Comparison (side-by-side)
#comp = compare_syntax_graphs(g1, g2)
#save_tikz_verbal_unit_comparison(comp, "reports/verbal_units_comparison.tex")