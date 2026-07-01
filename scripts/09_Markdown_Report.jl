using Revise
using SyntactileViz

Revise.revise()

comp = compare_cex_files("data/comparison/Comp2-analysis_HQ8.1-Able_Student.cex", "data/comparison/Comp2-analysis_HQ8.1-Christopher_Blackwell.cex")

# Full report with trees
export_comparison_markdown(comp, "reports/Comp2_full.md")

# Short version for quick sharing / printing
export_comparison_markdown(comp, "reports/Comp2_summary.md"; executive_summary=true)