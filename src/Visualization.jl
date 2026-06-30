module Visualization

using ..SyntaxGraph

using CairoMakie
using GraphMakie
using Graphs
using NetworkLayout

export draw_syntax_tree, save_syntax_tree

"""
    syntaxgraph_to_digraph(g::SyntaxGraph)

Converts a SyntaxGraph into a Graphs.jl DiGraph + node and edge labels.
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
    return digraph, node_labels, edge_labels
end

"""
    draw_syntax_tree(g::SyntaxGraph; title=nothing, kwargs...)

Draws a syntax graph with node text and edge relation labels.
"""
function draw_syntax_tree(g::SyntaxGraph; title = nothing, kwargs...)
    digraph, node_labels, edge_labels = syntaxgraph_to_digraph(g)

    fig = Figure(size = (1100, 800))
    ax = Axis(fig[1, 1]; title = something(title, g.sentence_text))

    graphplot!(ax, digraph;
        layout = NetworkLayout.Stress(),
        nlabels = node_labels,
        nlabels_align = (:center, :center),
        nlabels_fontsize = 12,
        node_size = 35,
        node_color = :lightblue,
        edge_color = :gray50,
        arrow_size = 18,
        elabels = edge_labels,
        elabels_color = :darkred,
        elabels_fontsize = 9,
        elabel_align = (:center, :center),
        kwargs...
    )

    hidedecorations!(ax)
    hidespines!(ax)
    return fig
end

"""
    save_syntax_tree(g::SyntaxGraph, path::String; format=:pdf, title=nothing)

Saves the syntax visualization to disk (`:pdf`, `:png`, or `:svg`).
"""
function save_syntax_tree(g::SyntaxGraph, path::String; 
                          format::Symbol = :pdf, title = nothing)
    fig = draw_syntax_tree(g; title = title)
    save(path, fig)
    return path
end

end # module Visualization