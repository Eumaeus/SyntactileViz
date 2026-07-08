using Revise
using SyntactileViz

Revise.revise()

comp = compare_cex_files(
    "data/comparison/hq_10_02.cex",
    "data/comparison/hq_10_02_vu.cex"
)


export_comparison_markdown(comp, "reports/comparison_report.md")

export_comparison_markdown(comp, "reports/report_detailed.md"; show_token_vu_assignments = true)