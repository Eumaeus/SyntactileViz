module SyntaxGraph

using ..CEXParser

export SyntaxNode, SyntaxEdge, SyntaxGraph
export build_syntax_graph
export get_node, get_root, outgoing, incoming, children_of
export get_tokens_in_vu, get_verbal_units_of_node
export get_verbal_units_sorted, get_tokens_by_verbal_unit
export get_primary_verbal_unit, get_subgraph_for_vu
export pretty_print, print_graph_summary

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

    SyntaxGraph(nodes, edges, vu_dict, analysis.analysis_urn, analysis.sentence_text)
end

# ============================================
# Query Functions
# ============================================

function get_node(g::SyntaxGraph, id::String)
    get(g.nodes, id, nothing)
end

function get_root(g::SyntaxGraph)
    get_node(g, "root")
end

function outgoing(g::SyntaxGraph, node_id::String)
    filter(e -> e.source == node_id, g.edges)
end

function incoming(g::SyntaxGraph, node_id::String)
    filter(e -> e.target == node_id, g.edges)
end

function children_of(g::SyntaxGraph, node_id::String)
    [e.target for e in outgoing(g, node_id)]
end

function get_tokens_in_vu(g::SyntaxGraph, vu_id::String)
    [node for node in values(g.nodes) if vu_id in node.verbal_unit_ids]
end

function get_verbal_units_of_node(g::SyntaxGraph, node_id::String)
    node = get_node(g, node_id)
    node === nothing ? String[] : node.verbal_unit_ids
end

function get_verbal_units_sorted(g::SyntaxGraph)
    sort(collect(values(g.verbal_units)), by = vu -> vu.level)
end

function get_tokens_by_verbal_unit(g::SyntaxGraph)
    Dict(vu_id => get_tokens_in_vu(g, vu_id) for vu_id in keys(g.verbal_units))
end

function get_primary_verbal_unit(g::SyntaxGraph, node_id::String)
    node = get_node(g, node_id)
    isempty(node.verbal_unit_ids) && return nothing
    vus = [g.verbal_units[vid] for vid in node.verbal_unit_ids if haskey(g.verbal_units, vid)]
    isempty(vus) && return nothing
    return sort(vus, by = v -> v.level)[1].id
end

# ============================================
# Subgraph for a Verbal Unit
# ============================================

"""
    get_subgraph_for_vu(g::SyntaxGraph, vu_id::String) -> SyntaxGraph

Returns a new SyntaxGraph containing only the nodes and relations
that belong to the specified verbal unit.
"""
function get_subgraph_for_vu(g::SyntaxGraph, vu_id::String)
    nodes_in_vu = get_tokens_in_vu(g, vu_id)
    node_ids = Set(n.id for n in nodes_in_vu)

    # Include root if it has relations into this VU
    if haskey(g.nodes, "root")
        push!(node_ids, "root")
    end

    filtered_nodes = Dict(id => g.nodes[id] for id in node_ids if haskey(g.nodes, id))

    filtered_edges = filter(e -> e.source in node_ids && e.target in node_ids, g.edges)

    filtered_vus = Dict(vu_id => g.verbal_units[vu_id])

    SyntaxGraph(
        filtered_nodes,
        filtered_edges,
        filtered_vus,
        g.analysis_urn,
        g.sentence_text
    )
end

# ============================================
# Pretty Printer (traverses in the correct direction)
# ============================================

function pretty_print(g::SyntaxGraph; show_vu::Bool = true, max_depth::Int = 20)
    println("Syntax Tree — ", g.sentence_text)
    println("="^70)
    visited = Set{String}()
    _print_node(g, "root", 0, visited; show_vu=show_vu, max_depth=max_depth)
end

function _print_node(g::SyntaxGraph, node_id::String, depth::Int, visited::Set{String}; show_vu::Bool, max_depth::Int)

    if depth > max_depth
        println("  "^depth, "... (max depth reached)")
        return
    end

    node = get_node(g, node_id)
    if node === nothing
        printstyled("  "^depth, "[MISSING: $node_id]\n", color=:red)
        return
    end

    # Colors
    if node_id == "root"
        color = :blue
    elseif startswith(node_id, "urn:cite2:fuTeaching:syntax.ellipsis")
        color = :yellow
    else
        color = :default
    end

    vu_str = ""
    if show_vu && !isempty(node.verbal_unit_ids)
        if length(node.verbal_unit_ids) == 1
            vu_str = " [" * node.verbal_unit_ids[1] * "]"
        else
            primary = get_primary_verbal_unit(g, node_id)
            vu_str = " [primary=$primary]"
        end
    end

    indent = "  "^depth
    printstyled(indent, node.text, color=color)
    printstyled(" (", node_id, ")", color=:light_black)
    println(vu_str)

    push!(visited, node_id)

    # Use *incoming* edges so we traverse from root downward
    for edge in incoming(g, node_id)
        source_id = edge.source

        printstyled(indent * "  └── ", edge.label, " ← ", color=:cyan)

        if source_id in visited
            printstyled(indent * "[already shown]\n", color=:light_black)
        else
            # println()
            _print_node(g, source_id, depth + 1, visited; show_vu=show_vu, max_depth=max_depth)
        end
    end
end

# ============================================
# Summary
# ============================================

function print_graph_summary(g::SyntaxGraph)
    println("SyntaxGraph")
    println("  Analysis:      $(g.analysis_urn)")
    println("  Sentence:      $(g.sentence_text)")
    println("  Nodes:         $(length(g.nodes))")
    println("  Edges:         $(length(g.edges))")
    println("  Verbal Units:  $(length(g.verbal_units))")
end

end # module SyntaxGraph