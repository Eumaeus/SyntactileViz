module Visualization

using ..SyntaxGraph

using CairoMakie
using GraphMakie
using Graphs
using NetworkLayout

export draw_syntax_tree, save_syntax_tree

"""
    syntaxgraph_to_digraph(g::SyntaxGraph)

Converts our SyntaxGraph into a Graphs.jl DiGraph for plotting.
"""
function syntaxgraph_to_digraph(g::SyntaxGraph)
    node_ids = collect(keys(g.nodes))
    sort!(node_ids)
    id_to_idx = Dict(id => i for (i, id) in enumerate(node_ids))

    digraph = SimpleDiGraph(length(node_ids))

    for e in g.edges
        if haskey(id_to_idx, e.source) && haskey(id_to_idx, e.target)
            add_edge!(digraph, id_to_idx[e.source], id_to_idx[e.target])
        end
    end

    labels = [g.nodes[id].text for id in node_ids]
    return digraph, labels
end

"""
    draw_syntax_tree(g::SyntaxGraph; title=nothing, kwargs...)

Creates a visual syntax tree using a hierarchical (Buchheim) layout.
Returns a Makie `Figure`.
"""
function draw_syntax_tree(g::SyntaxGraph; title = nothing, kwargs...)
    digraph, labels = syntaxgraph_to_digraph(g)

    fig = Figure(size = (1000, 750))
    ax = Axis(fig[1, 1]; title = something(title, g.sentence_text))

    graphplot!(ax, digraph;
        layout = NetworkLayout.Stress(),          # ← Changed from Buchheim
        nlabels = labels,
        nlabels_align = (:center, :center),
        node_size = 30,
        node_color = :lightblue,
        edge_color = :gray60,
        arrow_size = 15,
        kwargs...
    )

    hidedecorations!(ax)
    hidespines!(ax)
    return fig
end

"""
    save_syntax_tree(g::SyntaxGraph, path::String; format=:pdf, title=nothing)

Saves the syntax tree visualization to a file.
Supported formats: `:pdf`, `:png`, `:svg`.
"""
function save_syntax_tree(g::SyntaxGraph, path::String; 
                          format::Symbol = :pdf, title = nothing)
    fig = draw_syntax_tree(g; title = title)
    save(path, fig)
    return path
end

end # module Visualization