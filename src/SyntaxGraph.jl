module SyntaxGraph

using ..CEXParser   # brings in Analysis, Token, VerbalUnit, etc.

export SyntaxNode, SyntaxEdge, SyntaxGraph, build_syntax_graph
export get_node, outgoing, incoming, children_of, get_tokens_in_vu

# ============================================
# Core Data Structures
# ============================================

"""
    SyntaxNode

A node in the syntax graph.
"""
struct SyntaxNode
    id::String                    # "root" or CTS/CITE2 URN
    text::String
    verbal_unit_ids::Vector{String}
end

"""
    SyntaxEdge

A directed syntactic relationship.
"""
struct SyntaxEdge
    source::String
    target::String
    label::String
end

"""
    SyntaxGraph

A complete syntactic analysis represented as a graph.
"""
struct SyntaxGraph
    nodes::Dict{String, SyntaxNode}
    edges::Vector{SyntaxEdge}
    verbal_units::Dict{String, VerbalUnit}
    analysis_urn::String
    sentence_text::String
end

# ============================================
# Builder
# ============================================

"""
    build_syntax_graph(analysis::Analysis) -> SyntaxGraph

Convert a parsed CEX Analysis into a SyntaxGraph.
"""
function build_syntax_graph(analysis::Analysis)::SyntaxGraph
    nodes = Dict{String, SyntaxNode}()
    
    for t in analysis.tokens
        nodes[t.id] = SyntaxNode(t.id, t.text, t.vu_ids)
    end

    edges = SyntaxEdge[]
    for r in analysis.relations
        push!(edges, SyntaxEdge(r.source, r.target, r.relation))
    end

    vu_dict = Dict(vu.id => vu for vu in analysis.verbal_units)

    SyntaxGraph(
        nodes,
        edges,
        vu_dict,
        analysis.analysis_urn,
        analysis.sentence_text
    )
end

# ============================================
# Basic Query Functions
# ============================================

function get_node(g::SyntaxGraph, id::String)
    get(g.nodes, id, nothing)
end

"""Return all edges going *out* from this node."""
function outgoing(g::SyntaxGraph, node_id::String)
    filter(e -> e.source == node_id, g.edges)
end

"""Return all edges coming *in* to this node."""
function incoming(g::SyntaxGraph, node_id::String)
    filter(e -> e.target == node_id, g.edges)
end

"""Return the direct children (things this node points to)."""
function children_of(g::SyntaxGraph, node_id::String)
    [e.target for e in outgoing(g, node_id)]
end

"""Return all tokens that belong to a given verbal unit."""
function get_tokens_in_vu(g::SyntaxGraph, vu_id::String)
    [node for node in values(g.nodes) if vu_id in node.verbal_unit_ids]
end

end # module SyntaxGraph