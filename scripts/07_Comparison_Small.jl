using Revise
using SyntactileViz

Revise.revise()


comp = compare_cex_files(
    "data/comparison/Comp1-analysis_HQ1.7-corect.cex",
    "data/comparison/Comp1-analysis_HQ1.7_incorrect.cex"
)

diff_summary(comp)            # Quick one-liner
report_comparison(comp, show_details = true, show_tree = false)       # Full detailed report (now includes VU section)