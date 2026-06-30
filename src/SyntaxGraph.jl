module SyntaxGraph

using ..CEXParser

export SyntaxNode, SyntaxEdge, SyntaxGraph
export build_syntax_graph
export get_node, get_root, outgoing, incoming, children_of
export get_tokens_in_vu, get_verbal_units_of_node
export summary

# ============================================
# Core Types
# ============================================

struct SyntaxNode
    id::String
    text::String
    verbal_unit_ids::Vector{String}
end

struct SyntaxEdge
    source::String
    target::String
    label::String
end

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

function build_syntax_graph(analysis::Analysis)::SyntaxGraph
    nodes = Dict{String, SyntaxNode}()

    for t in analysis.tokens
        nodes[t.id] = SyntaxNode(t.id, t.text, t.vu_ids)
    end

    edges = [SyntaxEdge(r.source, r.target, r.relation) for r in analysis.relations]

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
# Query / Helper Functions
# ============================================

function get_node(g::SyntaxGraph, id::String)
    get(g.nodes, id, nothing)
end

function get_root(g::SyntaxGraph)
    get_node(g, "root")
end

"""Edges going *out* from this node."""
function outgoing(g::SyntaxGraph, node_id::String)
    filter(e -> e.source == node_id, g.edges)
end

"""Edges coming *in* to this node."""
function incoming(g::SyntaxGraph, node_id::String)
    filter(e -> e.target == node_id, g.edges)
end

"""Direct children (nodes this one points to)."""
function children_of(g::SyntaxGraph, node_id::String)
    [e.target for e in outgoing(g, node_id)]
end

"""All nodes that belong to a given verbal unit."""
function get_tokens_in_vu(g::SyntaxGraph, vu_id::String)
    [node for node in values(g.nodes) if vu_id in node.verbal_unit_ids]
end

"""Which verbal units does this node belong to?"""
function get_verbal_units_of_node(g::SyntaxGraph, node_id::String)
    node = get_node(g, node_id)
    node === nothing ? String[] : node.verbal_unit_ids
end

"""Quick summary of the graph."""
function summary(g::SyntaxGraph)
    println("SyntaxGraph")
    println("  Analysis: $(g.analysis_urn)")
    println("  Sentence: $(g.sentence_text)")
    println("  Nodes:    $(length(g.nodes))")
    println("  Edges:    $(length(g.edges))")
    println("  Verbal Units: $(length(g.verbal_units))")
end

end # module SyntaxGraph