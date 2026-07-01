module Visualization

using ..SyntaxGraph

using CairoMakie
using GraphMakie
using Graphs
using NetworkLayout

export draw_syntax_tree, save_syntax_tree

"""
    syntaxgraph_to_digraph(g::SyntaxGraph)

Converts a SyntaxGraph into data usable by GraphMakie.
"""
"""
    syntaxgraph_to_digraph(g::SyntaxGraph; reverse_direction::Bool = true)

Converts a SyntaxGraph into data usable by GraphMakie.
When `reverse_direction=true` (default), edges are reversed for display
so arrows point from head → dependent (more intuitive reading:
"ROOT has a sentence adverbial, καὶ").
The underlying SyntaxGraph data and CEX serialization are never changed.
"""
"""
    syntaxgraph_to_digraph(g::SyntaxGraph; reverse_direction::Bool = true)

Converts a SyntaxGraph into data usable by GraphMakie.
When `reverse_direction=true` (default), edges are reversed for display
so arrows point from head → dependent (more intuitive reading:
"ROOT has a sentence adverbial, καὶ").
The underlying SyntaxGraph data and CEX serialization are never changed.
"""
function syntaxgraph_to_digraph(g::SyntaxGraph; reverse_direction::Bool = true)
    node_ids = collect(keys(g.nodes))
    sort!(node_ids)
    id_to_idx = Dict(id => i for (i, id) in enumerate(node_ids))

    digraph = SimpleDiGraph(length(node_ids))
    label_map = Dict{Tuple{String,String}, String}()

    for e in g.edges
        if haskey(id_to_idx, e.source) && haskey(id_to_idx, e.target)
            if reverse_direction
                # Display direction: head (target) → dependent (source)
                add_edge!(digraph, id_to_idx[e.target], id_to_idx[e.source])
                label_map[(e.target, e.source)] = e.label
            else
                # Original data direction
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
    draw_syntax_tree(g::SyntaxGraph; title=nothing, kwargs...)

Draws a syntax graph. Ellipsis nodes are highlighted in yellow.
"""
function draw_syntax_tree(g::SyntaxGraph; title = nothing, kwargs...)
    digraph, node_ids, node_labels, edge_labels = syntaxgraph_to_digraph(g)

    # === Special styling for ellipsis nodes ===
    node_colors = fill(:wheat1, length(node_ids))
    node_sizes  = fill(35, length(node_ids))

    for (i, id) in enumerate(node_ids)
        if startswith(id, "urn:cite2:fuTeaching:syntax.ellipsis")
            node_colors[i] = :plum         # Yellow/gold like in pretty_print
            node_sizes[i]  = 35             # Slightly larger
        end
        if startswith(id, "root")
            node_colors[i] = :gold2          # Yellow/gold like in pretty_print
            node_sizes[i]  = 60             # Slightly larger
        end
    end

    fig = Figure(size = (1100, 800))
    titleText = g.editor * "\n\n" * replace(g.sentence_text, "," => ",\n")
    # ax = Axis(fig[1, 1]; title = something(title, g.sentence_text))
    ax = Axis(fig[1, 1]; title = titleText)
    # ax = Axis(fig[1, 1]; title = something(title, g.editor))
    # ax = Axis(fig[1, 1]; title = something(title, g.editor, g.sentence_text))

    graphplot!(ax, digraph;
        # layout = NetworkLayout.Spring(),
        # layout = NetworkLayout.Stress(),
        layout = NetworkLayout.Stress(dim=2),

        nlabels = node_labels,
        nlabels_align = (:center, :center),
        nlabels_fontsize = 10,
        node_size = node_sizes,
        node_color = node_colors,
        edge_color = :gray50,
        arrow_size = 8,
        elabels = edge_labels,
        elabels_color = :darkred,
        elabels_fontsize = 6,
        kwargs...
    )

    hidedecorations!(ax)
    hidespines!(ax)
    return fig
end

"""
    save_syntax_tree(g::SyntaxGraph, path::String; format=:pdf, title=nothing)

Save the visualization as PDF, PNG, or SVG.
"""
function save_syntax_tree(g::SyntaxGraph, path::String; format::Symbol = :pdf, title = nothing)
    fig = draw_syntax_tree(g; title = title)
    save(path, fig)
    return path
end

end # module Visualization