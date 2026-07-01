module SyntactileViz

include("CEXParser.jl")
include("SyntaxGraph.jl")
include("Comparison.jl")          # ← NEW
include("Visualization.jl")

using .CEXParser
using .SyntaxGraph
using .Comparison               # ← NEW
using .Visualization

export parse_cex, Analysis, Token, VerbalUnit, SyntacticRelation
export SyntaxNode, SyntaxEdge, SyntaxGraph
export build_syntax_graph
export get_node, get_root, outgoing, incoming, children_of
export get_tokens_in_vu, get_verbal_units_of_node
export print_graph_summary
export pretty_print, get_subgraph_for_vu, get_verbal_units_sorted
export get_primary_verbal_unit

# Comparison exports
export ComparisonResult, compare_syntax_graphs, report_comparison, compare_cex_files

# Visualization exports
export draw_syntax_tree, save_syntax_tree

end # module SyntactileViz