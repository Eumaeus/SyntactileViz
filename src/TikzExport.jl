module TikzExport

import ..SyntaxGraph

export tikz_dependency_code, save_tikz_dependency, save_tikz_tree, tikz_hierarchical_tree_code


const default_preamble = """
\\documentclass{article}
\\usepackage{fontspec}
\\usepackage{tikz}
\\usepackage{tikz-dependency}

% === Your polytonic Greek setup (customize with your purchased fonts) ===
\\defaultfontfeatures{Ligatures=TeX}
\\setmainfont{ArnoPro-Regular}          % e.g. Brill, IFAO, or your professional font
% \\newfontfamily\\greekfont[Script=Greek]{YourGreekFontHere}
\\newfontfamily\\greekfont[Script=Greek]{Arno Pro}

% \\usepackage{polyglossia}
% \\setotherlanguage[variant=ancient]{greek}
"""

function tikz_dependency_code(g::SyntaxGraph.SyntaxGraph;
                              theme::String = "simple",
                              column_sep::String = "1.2em",
                              root_label::String = "ROOT")
    ordered_ids = g.ordered_token_ids
    if isempty(ordered_ids)
        return "% Empty graph"
    end

    texts = [escape_latex(g.nodes[id].text) for id in ordered_ids]
    deptext_line = join(texts, " \\& ")

    pos_map = Dict(id => i for (i, id) in enumerate(ordered_ids))

    lines = String[]
    push!(lines, "\\begin{dependency}[theme = $theme]")
    push!(lines, "   \\begin{deptext}[column sep=$column_sep]")
    push!(lines, "      $deptext_line \\\\")
    push!(lines, "   \\end{deptext}")

    for e in g.edges
        if e.target == "root"
            if haskey(pos_map, e.source)
                pos = pos_map[e.source]
                push!(lines, "   \\deproot{$pos}{$(e.label)}")
            end
        else
            if haskey(pos_map, e.source) && haskey(pos_map, e.target)
                dep_pos = pos_map[e.source]   # original source = dependent
                gov_pos = pos_map[e.target]   # original target = governor/head
                push!(lines, "   \\depedge{$gov_pos}{$dep_pos}{$(e.label)}")
            end
        end
    end

    push!(lines, "\\end{dependency}")
    return join(lines, "\n")
end

function escape_latex(s::String)
    # Minimal escaping — Greek text is almost always fine
    replace(s, "&" => "\\&", "%" => "\\%", "_" => "\\_")
end

function save_tikz_dependency(g::SyntaxGraph.SyntaxGraph, path::String; 
                              preamble::String = default_preamble,
                              code = tikz_dependency_code(g))
    full = """
    $preamble

    \\begin{document}
    \\begin{figure}[ht]
    \\centering
    $code
    \\caption{$(g.editor) — $(g.sentence_text)}
    \\end{figure}
    \\end{document}
    """
    write(path, full)
    return path
end


# =====================================================
# Hierarchical Tree (pure TikZ, no extra packages)
# =====================================================

"""
    tikz_hierarchical_tree_code(g; ...)

Generates a traditional hierarchical syntax tree using pure TikZ.
Root is at the top. Arrows point head → dependent.
Uses simple level-based positioning (good results for typical sentence length).
"""
function tikz_hierarchical_tree_code(g::SyntaxGraph.SyntaxGraph;
        level_distance::String = "2.8cm",
        sibling_distance::String = "2.2cm",
        node_style::String = "draw, rounded corners, fill=gray!8, align=center, font=\\small, minimum width=2.8cm, minimum height=0.9cm",
        edge_style::String = "->, thick, >=stealth",
        show_labels::Bool = true)

    # Build children lists (head → dependents)
    children = Dict{String, Vector{String}}()
    for node_id in keys(g.nodes)
        children[node_id] = String[]
    end
    for e in g.edges
        if e.target != "root"
            push!(children[e.target], e.source)
        end
    end
    # Also attach direct children of root
    for e in g.edges
        if e.target == "root"
            push!(children["root"], e.source)
        end
    end

    # Simple layout: assign (level, x_index) to every node
    node_level = Dict{String, Int}()
    node_x     = Dict{String, Float64}()
    node_parent = Dict{String, String}()

    function assign_positions(node_id::String, level::Int, x_start::Float64)
        node_level[node_id] = level
        node_x[node_id] = x_start

        kids = get(children, node_id, String[])
        if isempty(kids)
            return 1.0
        end

        width = 0.0
        x = x_start
        for (i, kid) in enumerate(kids)
            node_parent[kid] = node_id
            w = assign_positions(kid, level + 1, x)
            width += w
            x += w * parse(Float64, replace(sibling_distance, "cm" => ""))
        end
        return max(1.0, width)
    end

    # Start from root
    assign_positions("root", 0, 0.0)

    # Generate TikZ code
    lines = String[]
    push!(lines, "\\begin{tikzpicture}[")

    push!(lines, "  every node/.style={$node_style},")
    push!(lines, "  level distance=$level_distance,")
    push!(lines, "  sibling distance=$sibling_distance,")
    push!(lines, "  >=stealth,")
    push!(lines, "]")

    # Nodes
    for (id, level) in sort(collect(node_level), by = x -> (x[2], node_x[x[1]]))
        text = id == "root" ? "ROOT" : escape_latex(g.nodes[id].text)
        x = node_x[id]
        y = -level * parse(Float64, replace(level_distance, "cm" => ""))
        push!(lines, "  \\node (n_$id) at ($(x)cm, $(y)cm) {$text};")
    end

    # Edges + labels
    for e in g.edges
        if e.target == "root"
            parent_id = "root"
            child_id  = e.source
        else
            parent_id = e.target
            child_id  = e.source
        end

        if haskey(node_level, parent_id) && haskey(node_level, child_id)
            label = show_labels ? "node[midway, above, font=\\tiny, red!70!black] {$(e.label)}" : ""
            push!(lines, "  \\draw[$edge_style] (n_$parent_id) -- $label (n_$child_id);")
        end
    end

    push!(lines, "\\end{tikzpicture}")
    return join(lines, "\n")
end

function save_tikz_tree(g::SyntaxGraph.SyntaxGraph, path::String;
    preamble::String = default_preamble,
    code = tikz_hierarchical_tree_code(g))
    full = """
    $preamble

    \\begin{document}
    \\begin{figure}[ht]
    \\centering
    $code
    \\caption{Hierarchical tree — $(g.editor) — $(g.sentence_text)}
    \\end{figure}
    \\end{document}
    """
    write(path, full)
    return path
end


end # module