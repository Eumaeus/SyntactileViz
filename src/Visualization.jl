module Visualization

using ..SyntaxGraph
using CairoMakie
using GraphMakie
using Graphs
using NetworkLayout

export draw_syntax_tree, save_syntax_tree

"""
    syntaxgraph_to_digraph(g::SyntaxGraph)

Converts a SyntaxGraph into a Graphs.jl DiGraph + node labels.
The direction follows the stored edges (dependent → head).
"""
function syntaxgraph_to_digraph(g::SyntaxGraph)
    node_ids = collect(keys(g.nodes))
    sort!(node_ids)  # for reproducibility
    id_to_idx = Dict(id => i for (i, id) in enumerate(node_ids))

    digraph = SimpleDiGraph(length(node_ids))

    for e in g.edges
        if haskey(id_to_idx, e.source) && haskey(id_to_idx, e.target)
            add_edge!(digraph, id_to_idx[e.source], id_to_idx[e.target])
        end
    end

    labels = [get(g.nodes, id, SyntaxNode(id, id, String[])).text for id in node_ids]
    return digraph, labels, node_ids
end

"""
    draw_syntax_tree(g::SyntaxGraph; title = nothing, kwargs...)

Draws a syntax tree using a hierarchical (Buchheim) layout.
Returns a Makie `Figure` (displays nicely in Pluto).
"""
function draw_syntax_tree(g::SyntaxGraph; title = nothing, kwargs...)
    digraph, labels, _ = syntaxgraph_to_digraph(g)

    fig = Figure(size = (900, 700))
    ax = Axis(fig[1, 1]; title = something(title, g.sentence_text))

    graphplot!(ax, digraph;
        layout = Buchheim(),
        nlabels = labels,
        nlabels_align = (:center, :center),
        node_size = 25,
        node_color = :lightblue,
        edge_color = :gray,
        arrow_size = 12,
        kwargs...
    )

    hidedecorations!(ax)
    hidespines!(ax)
    return fig
end

"""
    save_syntax_tree(g::SyntaxGraph, path::String; format = :pdf, title = nothing)

Saves a syntax tree visualization to disk.
Supported formats: `:pdf`, `:png`, `:svg`.
"""
function save_syntax_tree(g::SyntaxGraph, path::String; format = :pdf, title = nothing)
    fig = draw_syntax_tree(g; title = title)

    if format == :pdf
        save(path, fig; backend = CairoMakie)
    elseif format == :png
        save(path, fig; backend = CairoMakie)
    elseif format == :svg
        save(path, fig; backend = CairoMakie)
    else
        error("Unsupported format: $format. Use :pdf, :png, or :svg")
    end

    return path
end

end # module Visualization