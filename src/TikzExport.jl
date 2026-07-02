module TikzExport

import ..SyntaxGraph

export tikz_dependency_code, save_tikz_dependency, save_tikz_tree, tikz_hierarchical_tree_code



const default_preamble = """
\\documentclass{article}
\\usepackage{fontspec}
\\usepackage{tikz}
\\usepackage{tikz-dependency}
\\usepackage{adjustbox}


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
                              # NEW: edge overrides for comparison highlighting
                              edge_overrides::Dict{Tuple{String,String}, String} = Dict{Tuple{String,String}, String}())
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
                # deproot can also take options if needed later
                push!(lines, "   \\deproot{$pos}{$(e.label)}")
            end
        else
            if haskey(pos_map, e.source) && haskey(pos_map, e.target)
                dep_pos = pos_map[e.source]      # dependent
                gov_pos = pos_map[e.target]      # governor / head

                # Check for override on this edge (gov_id, dep_id)
                override = get(edge_overrides, (e.target, e.source), "")
                
                if isempty(override)
                    push!(lines, "   \\depedge{$gov_pos}{$dep_pos}{$(e.label)}")
                else
                    push!(lines, "   \\depedge[$override]{$gov_pos}{$dep_pos}{$(e.label)}")
                end
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
                              use_adjustbox::Bool = true,
                              adjustbox_options::String = "max width=\\textwidth",
                              # NEW
                              edge_overrides::Dict{Tuple{String,String}, String} = Dict{Tuple{String,String}, String}())
    code = tikz_dependency_code(g; edge_overrides = edge_overrides)
    
    content = if use_adjustbox
        """
        \\begin{adjustbox}{$adjustbox_options}
        $code
        \\end{adjustbox}
        """
    else
        code
    end

    full = """
    $preamble

    \\begin{document}
    \\begin{figure}[ht]
    \\centering
    $content
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
        edge_label_style::String = "fill=none, draw=none, font=\\tiny, text=black",
        show_labels::Bool = true,
        # NEW: overrides for comparison highlighting
        node_overrides::Dict{String, String} = Dict{String, String}(),           # id => TikZ style string
        edge_overrides::Dict{Tuple{String,String}, String} = Dict{Tuple{String,String}, String}()  # (parent, child) => TikZ style string
    )

    # --- Build children (head → dependents) ---
    children = Dict{String, Vector{String}}()
    for id in keys(g.nodes)
        children[id] = String[]
    end
    for e in g.edges
        if e.target == "root"
            push!(children["root"], e.source)
        elseif haskey(children, e.target)
            push!(children[e.target], e.source)
        end
    end

    # --- Safe node names + layout ---
    all_ids = collect(keys(g.nodes))
    id_to_node = Dict(id => "n$i" for (i, id) in enumerate(all_ids))

    node_level = Dict{String, Int}()
    node_x     = Dict{String, Float64}()

    function assign_positions(node_id::String, level::Int, x_start::Float64)
        node_level[node_id] = level
        node_x[node_id] = x_start

        kids = get(children, node_id, String[])
        if isempty(kids)
            return 1.0
        end

        width = 0.0
        x = x_start
        step = parse(Float64, replace(sibling_distance, "cm" => ""))
        for kid in kids
            w = assign_positions(kid, level + 1, x)
            width += w
            x += w * step
        end
        return max(1.0, width)
    end

    assign_positions("root", 0, 0.0)

    # --- Generate TikZ ---
    lines = String[]
    push!(lines, "\\begin{tikzpicture}[")

    push!(lines, "  every node/.style={$node_style},")
    push!(lines, "  level distance=$level_distance,")
    push!(lines, "  sibling distance=$sibling_distance,")
    push!(lines, "  >=stealth,")
    push!(lines, "]")

 # Nodes with optional overrides
    for (id, lvl) in sort(collect(node_level), by = x -> (x[2], get(node_x, x[1], 0.0)))
        text = (id == "root") ? "ROOT" : escape_latex(g.nodes[id].text)
        x = get(node_x, id, 0.0)
        y = -lvl * parse(Float64, replace(level_distance, "cm" => ""))
        nodename = id_to_node[id]
        
        extra_style = get(node_overrides, id, "")
        style = isempty(extra_style) ? node_style : "$node_style, $extra_style"
        push!(lines, "  \\node[$style] ($nodename) at ($(x)cm, $(y)cm) {$text};")
    end

    # Edges with optional overrides
    for e in g.edges
        if e.target == "root"
            parent_id, child_id = "root", e.source
        else
            parent_id, child_id = e.target, e.source
        end

        if haskey(id_to_node, parent_id) && haskey(id_to_node, child_id)
            pnode = id_to_node[parent_id]
            cnode = id_to_node[child_id]
            
            base_edge = edge_style
            extra = get(edge_overrides, (parent_id, child_id), "")
            final_edge = isempty(extra) ? base_edge : "$base_edge, $extra"
            
            if show_labels
                label = "node[midway, above, $edge_label_style] {$(e.label)}"
                push!(lines, "  \\draw[$final_edge] ($pnode) -- $label ($cnode);")
            else
                push!(lines, "  \\draw[$final_edge] ($pnode) -- ($cnode);")
            end
        end
    end

    push!(lines, "\\end{tikzpicture}")
    return join(lines, "\n")
end

function save_tikz_tree(g::SyntaxGraph.SyntaxGraph, path::String;
                        preamble::String = default_preamble,
                        use_adjustbox::Bool = true,
                        adjustbox_options::String = "max width=\\textwidth")
    code = tikz_hierarchical_tree_code(g)
    
    content = if use_adjustbox
        """
        \\begin{adjustbox}{$adjustbox_options}
        $code
        \\end{adjustbox}
        """
    else
        code
    end

    full = """
    $preamble

    \\begin{document}
    \\begin{figure}[ht]
    \\centering
    $content
    \\caption{Hierarchical tree — $(g.editor) — $(g.sentence_text)}
    \\end{figure}
    \\end{document}
    """
    write(path, full)
    return path
end






end # module