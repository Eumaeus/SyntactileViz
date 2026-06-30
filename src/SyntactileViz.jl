module SyntactileViz

# Include the submodules
include("CEXParser.jl")
include("SyntaxGraph.jl")

# Bring everything into this namespace
using .CEXParser
using .SyntaxGraph

# Re-export the most useful names so users can do `using SyntactileViz`
export parse_cex, Analysis, Token, VerbalUnit, SyntacticRelation
export SyntaxNode, SyntaxEdge, SyntaxGraph
export build_syntax_graph
export get_node, get_root, outgoing, incoming, children_of
export get_tokens_in_vu, get_verbal_units_of_node
export print_graph_summary

end # module SyntactileViz