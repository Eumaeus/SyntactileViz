using Revise
using SyntactileViz
using Makie


Revise.revise()



# Set a font with good Greek support (Noto Sans usually works well)
Makie.set_theme!(fonts = (regular = "DejaVu Sans", bold = "DejaVu Sans Bold"))

a = parse_cex("data/samples/analysis_Ellipsis_Option3.cex")
g = build_syntax_graph(a)

# draw_syntax_tree(g)
# Or save it
save_syntax_tree(g, "reports/pdf/syntax_with_labels-stress.pdf")