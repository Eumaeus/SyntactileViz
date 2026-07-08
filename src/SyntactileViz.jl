module SyntactileViz

include("CEXParser.jl")
include("SyntaxGraph.jl")
include("Visualization.jl")   # ← move this up
include("TikzExport.jl")
include("Comparison.jl")

using .CEXParser
using .SyntaxGraph
using .Comparison
using .Visualization
using .TikzExport
using Dates

export parse_cex, Analysis, Token, VerbalUnit, SyntacticRelation
export SyntaxNode, SyntaxEdge, SyntaxGraph
export build_syntax_graph
export get_node, get_root, outgoing, incoming, children_of
export get_tokens_in_vu, get_verbal_units_of_node
export print_graph_summary
export pretty_print, get_subgraph_for_vu, get_verbal_units_sorted
export get_primary_verbal_unit
export get_editor, get_urn

# Comparison
export ComparisonResult, compare_syntax_graphs, report_comparison, diff_summary, export_comparison_markdown, draw_syntax_comparison, save_syntax_comparison,compare_verbal_units, VerbalUnitComparison, tikz_verbal_unit_comparison, save_tikz_verbal_unit_comparison

# Visualization
export draw_syntax_tree, save_syntax_tree

# TikZ
export tikz_dependency_code, save_tikz_dependency, save_tikz_tree, tikz_hierarchical_tree_code, tikz_dependency_comparison, tikz_dual_dependency_comparison, save_tikz_dual_dependency_comparison, tikz_verbal_unit_linear, save_tikz_verbal_unit_linear

# Convenience function (moved here from Comparison module)
function compare_cex_files(path1::String, path2::String)
    a1 = parse_cex(path1)
    a2 = parse_cex(path2)
    g1 = build_syntax_graph(a1)
    g2 = build_syntax_graph(a2)
    compare_syntax_graphs(g1, g2)
end

export compare_cex_files

end # module SyntactileViz