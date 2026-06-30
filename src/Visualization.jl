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
function syntaxgraph_to_digraph(g::SyntaxGraph)
    node_ids = collect(keys(g.nodes))
    sort!(node_ids)
    id_to_idx = Dict(id => i for (i, id) in enumerate(node_ids))

    digraph = SimpleDiGraph(length(node_ids))
    edge_labels = String[]

    for e in g.edges
        if haskey(id_to_idx, e.source) && haskey(id_to_idx, e.target)
            add_edge!(digraph, id_to_idx[e.source], id_to_idx[e.target])
            push!(edge_labels, e.label)
        end
    end

    node_labels = [g.nodes[id].text for id in node_ids]
    return digraph, node_ids, node_labels, edge_labels
end

"""
    draw_syntax_tree(g::SyntaxGraph; title=nothing, kwargs...)

Draws a syntax graph. Ellipsis nodes are highlighted in yellow.
"""
function draw_syntax_tree(g::SyntaxGraph; title = nothing, kwargs...)
    digraph, node_ids, node_labels, edge_labels = syntaxgraph_to_digraph(g)

    # === Special styling for ellipsis nodes ===
    node_colors = fill(:lightblue, length(node_ids))
    node_sizes  = fill(35, length(node_ids))

    for (i, id) in enumerate(node_ids)
        if startswith(id, "urn:cite2:fuTeaching:syntax.ellipsis")
            node_colors[i] = :gold          # Yellow/gold like in pretty_print
            node_sizes[i]  = 42             # Slightly larger
        end
    end

    fig = Figure(size = (1100, 800))
    ax = Axis(fig[1, 1]; title = something(title, g.sentence_text))

    graphplot!(ax, digraph;
        layout = NetworkLayout.Stress(),
        nlabels = node_labels,
        nlabels_align = (:center, :center),
        nlabels_fontsize = 12,
        node_size = node_sizes,
        node_color = node_colors,
        edge_color = :gray50,
        arrow_size = 18,
        elabels = edge_labels,
        elabels_color = :darkred,
        elabels_fontsize = 9,
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
function save_syntax_tree(g::SyntaxGraph, path::String; 
                          format::Symbol = :pdf, title = nothing)
    fig = draw_syntax_tree(g; title = title)
    save(path, fig)
    return path
end

end # module Visualization