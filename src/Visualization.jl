module Visualization

# We use `import` (instead of `using`) for the sibling submodule
# because `SyntaxGraph` is both the module name *and* the name of
# an exported type inside it. `using ..SyntaxGraph` can cause the
# bare name `SyntaxGraph` to resolve to the *type* in some contexts,
# which then breaks qualified access like `SyntaxGraph.SyntaxGraph`.
# `import` brings only the module, avoiding the name clash.
import ..SyntaxGraph

using CairoMakie
using GraphMakie
using Graphs
using NetworkLayout

export draw_syntax_tree, save_syntax_tree, plot_syntax_tree!

"""
    syntaxgraph_to_digraph(g::SyntaxGraph.SyntaxGraph; reverse_direction::Bool = true)

Converts a SyntaxGraph into data usable by GraphMakie.
When `reverse_direction=true` (default), edges are reversed for display
so arrows point from head → dependent (more intuitive reading:
"ROOT has a sentence adverbial, καὶ").
The underlying SyntaxGraph data and CEX serialization are never changed.
"""
function syntaxgraph_to_digraph(g::SyntaxGraph.SyntaxGraph; reverse_direction::Bool = true)
    node_ids = collect(keys(g.nodes))
    sort!(node_ids)
    id_to_idx = Dict(id => i for (i, id) in enumerate(node_ids))

    digraph = SimpleDiGraph(length(node_ids))
    label_map = Dict{Tuple{String,String}, String}()

    for e in g.edges
        if haskey(id_to_idx, e.source) && haskey(id_to_idx, e.target)
            if reverse_direction
                add_edge!(digraph, id_to_idx[e.target], id_to_idx[e.source])
                label_map[(e.target, e.source)] = e.label
            else
                add_edge!(digraph, id_to_idx[e.source], id_to_idx[e.target])
                label_map[(e.source, e.target)] = e.label
            end
        end
    end

    node_labels = [g.nodes[id].text for id in node_ids]

    digraph_edges = collect(edges(digraph))
    edge_labels = [
        get(label_map, (node_ids[e.src], node_ids[e.dst]), "")
        for e in digraph_edges
    ]

    return digraph, node_ids, node_labels, edge_labels
end


"""
    plot_syntax_tree!(ax::Axis, g::SyntaxGraph.SyntaxGraph;
                      reverse_direction::Bool = true,
                      node_color_overrides::Dict{String, Symbol} = Dict{String, Symbol}(),
                      edge_color_overrides::Dict{Tuple{String,String}, Symbol} = Dict{Tuple{String,String}, Symbol}(),
                      kwargs...)

Core plotting function that draws into an existing Axis.  
Supports per-node and per-edge color overrides for difference highlighting.
"""
function plot_syntax_tree!(ax::Axis, g::SyntaxGraph.SyntaxGraph;
                           reverse_direction::Bool = true,
                           node_color_overrides::Dict{String, Symbol} = Dict{String, Symbol}(),
                           edge_color_overrides::Dict{Tuple{String,String}, Symbol} = Dict{Tuple{String,String}, Symbol}(),
                           kwargs...)
    digraph, node_ids, node_labels, edge_labels = syntaxgraph_to_digraph(g; reverse_direction=reverse_direction)

    node_colors = fill(:wheat1, length(node_ids))
    node_sizes  = fill(35, length(node_ids))

    for (i, id) in enumerate(node_ids)
        if startswith(id, "urn:cite2:fuTeaching:syntax.ellipsis")
            node_colors[i] = :plum
            node_sizes[i]  = 35
        elseif startswith(id, "root")
            node_colors[i] = :gold2
            node_sizes[i]  = 60
        end

        if haskey(node_color_overrides, id)
            node_colors[i] = node_color_overrides[id]
        end
    end

    digraph_edges = collect(edges(digraph))
    edge_colors = fill(:gray50, length(digraph_edges))

    # (Optional) apply edge overrides here if you pass them in the future

    graphplot!(ax, digraph;
        layout = NetworkLayout.Stress(dim=2),
        nlabels = node_labels,
        nlabels_align = (:center, :center),
        nlabels_fontsize = 10,
        node_size = node_sizes,
        node_color = node_colors,
        edge_color = edge_colors,
        arrow_size = 8,
        elabels = edge_labels,
        elabels_color = :darkred,
        elabels_fontsize = 6,
        kwargs...
    )

    hidedecorations!(ax)
    hidespines!(ax)
end

"""
    draw_syntax_tree(g::SyntaxGraph.SyntaxGraph; title=nothing, kwargs...)

Draws a syntax graph. Ellipsis nodes are highlighted in plum, root in gold.
Arrows point head → dependent when `reverse_direction=true` (the default).
"""
# Update the existing draw_syntax_tree to use the new function
function draw_syntax_tree(g::SyntaxGraph.SyntaxGraph; title = nothing, kwargs...)
    fig = Figure(size = (1100, 800))
    titleText = isnothing(title) ? 
        (g.editor * "\n\n" * replace(g.sentence_text, "," => ",\n")) : title
    ax = Axis(fig[1, 1]; title = titleText)

    plot_syntax_tree!(ax, g; kwargs...)
    return fig
end

"""
    save_syntax_tree(g::SyntaxGraph.SyntaxGraph, path::String; format=:pdf, title=nothing)
"""
function save_syntax_tree(g::SyntaxGraph.SyntaxGraph, path::String; format::Symbol = :pdf, title = nothing)
    fig = draw_syntax_tree(g; title = title)
    save(path, fig)
    return path
end



end # module Visualization