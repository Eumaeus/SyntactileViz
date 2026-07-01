using Revise
using SyntactileViz

Revise.revise()


comp = compare_cex_files(
    "data/comparison/Comp1-analysis_HQ1.7-corect.cex",
    "data/comparison/Comp1-analysis_HQ1.7_incorrect.cex"
)

# Console report (with your new controls)
report_comparison(comp; show_details=true, show_tree=true)

# Export to Markdown
export_comparison_markdown(comp, "reports/Comp1_HQ1.7_comparison.md";
                           show_details=true, show_tree=true)