module TikzExport

import ..SyntaxGraph



export tikz_dependency_code, save_tikz_dependency, save_tikz_tree, tikz_hierarchical_tree_code, tikz_dependency_comparison, tikz_dual_dependency_comparison

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
        node_style::String = "draw, rounded corners, fill=gray!8, align=center, font=\\small, minimum width=2cm, minimum height=0.9cm",
        edge_style::String = "->, thick, draw=lightgray, >=stealth",
        edge_label_style::String = "pos=0.8, fill=none, draw=none, font=\\small, text=black",
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
        adjustbox_options::String = "max width=\\textwidth",
        # NEW override parameters
        node_overrides::Dict{String, String} = Dict{String, String}(),
        edge_overrides::Dict{Tuple{String,String}, String} = Dict{Tuple{String,String}, String}(),
        show_labels::Bool = true)

    code = tikz_hierarchical_tree_code(g;
        node_overrides = node_overrides,
        edge_overrides = edge_overrides,
        show_labels = show_labels)

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

# ============================================================
# Dual-arc dependency comparison (one graph above, one below)
# ============================================================

"""
    tikz_dual_dependency_comparison(g1, g2; 
        head_diff = Set{String}(), label_diff = Set{String}(),
        node_overrides = Dict{String,String}(),
        g1_name = "Analysis 1", g2_name = "Analysis 2",
        node_spacing = 2.5)

Generates a single TikZ picture with:
- Nodes on a baseline (color-coded if diffs provided)
- g1 arcs arcing **above** the sentence (blue base)
- g2 arcs arcing **below** the sentence (teal base)
- Arcs belonging to differing tokens drawn in red

Pass the `head_diff` and `label_diff` sets from a `ComparisonResult`
for automatic highlighting.
"""
function tikz_dual_dependency_comparison(g1::SyntaxGraph.SyntaxGraph, 
                                         g2::SyntaxGraph.SyntaxGraph;
                                         head_diff::AbstractVector = String[],
                                         label_diff::AbstractVector = String[],
                                         node_overrides::Dict{String,String} = Dict{String,String}(),
                                         g1_name::String = g1.editor,
                                         g2_name::String = g2.editor,
                                         node_spacing::Float64 = 2.5)

    # Normalize diff sets (handles both Vector{String} and Vector{Tuple})
    head_set   = Set{String}(first(d) for d in head_diff)
    label_set  = Set{String}(first(d) for d in label_diff)

    ordered_ids = filter(id -> haskey(g1.nodes, id) && !startswith(id, "root"), 
                         g1.ordered_token_ids)
    n = length(ordered_ids)
    isempty(ordered_ids) && return "% No tokens"
    id_to_idx = Dict(id => i for (i, id) in enumerate(ordered_ids))

    # Node coloring
    node_colors = copy(node_overrides)
    for id in head_set
        node_colors[id] = get(node_colors, id, "salmon!85!white")
    end
    for id in label_set
        node_colors[id] = get(node_colors, id, "orange!75!white")
    end

    tikz = """
\\begin{tikzpicture}[
    every node/.style={font=\\footnotesize, minimum width=1.8em, minimum height=0.9em, 
                       draw=none, align=center, inner sep=2pt},
    arc g1/.style={->, thick, blue!75, shorten >=1pt, shorten <=1pt},
    arc g2/.style={->, thick, teal!75, shorten >=1pt, shorten <=1pt},
    diff arc/.style={->, thick, red!85, shorten >=1pt, shorten <=1pt},
    label/.style={font=\\scriptsize}
]
\\node[font=\\bfseries, above] at ($(n*node_spacing/2), 7.2) {Dependency Comparison};
\\node[font=\\small] at ($(n*node_spacing/2), 6.4) {$(g1_name) (above, blue) vs $(g2_name) (below, teal)};
\\node[font=\\tiny] at ($(n*node_spacing/2), 5.85) {Green = agree • Orange = label diff • Salmon = head diff • Red arcs = differences};
"""

    # Nodes
    for (i, id) in enumerate(ordered_ids)
        text = escape_latex(g1.nodes[id].text)
        col = get(node_colors, id, "white")
        tikz *= "  \\node[fill=$col] (n$i) at ($(i * node_spacing), 0) {\\strut $text};\n"
    end

    # ===================== g1 arcs (ABOVE) =====================
    tikz *= "\n% === g1 arcs (ABOVE) ===\n"
    for e in g1.edges
        head_id, dep_id = e.source, e.target
        haskey(id_to_idx, dep_id) && haskey(id_to_idx, head_id) || continue
        i_dep, i_head = id_to_idx[dep_id], id_to_idx[head_id]
        label = escape_latex(e.label)

        is_diff = dep_id ∈ head_set || dep_id ∈ label_set
        style = is_diff ? "diff arc" : "arc g1"
        is_g1 = true

        out_a = i_head > i_dep ? 55 : 125
        in_a  = i_head > i_dep ? 125 : 55
        tikz *= "  \\draw[$style] (n$i_dep) to [out=$out_a, in=$in_a, looseness=1.35] (n$i_head);\n"

        if !isempty(label)
            mid_x = (i_dep + i_head) * node_spacing / 2
            distance = abs(i_head - i_dep)
            y_offset = 0.65 + (distance * 0.75)
            tikz *= "  \\node[label, above] at ($mid_x, $y_offset) {$label};\n"
        end
    end

    # ===================== g2 arcs (BELOW) =====================
    tikz *= "\n% === g2 arcs (BELOW) ===\n"
    for e in g2.edges
        head_id, dep_id = e.source, e.target
        haskey(id_to_idx, dep_id) && haskey(id_to_idx, head_id) || continue
        i_dep, i_head = id_to_idx[dep_id], id_to_idx[head_id]
        label = escape_latex(e.label)

        is_diff = dep_id ∈ head_set || dep_id ∈ label_set
        style = is_diff ? "diff arc" : "arc g2"
        is_g1 = false

        out_a = i_head > i_dep ? -55 : -125
        in_a  = i_head > i_dep ? -125 : -55
        tikz *= "  \\draw[$style] (n$i_dep) to [out=$out_a, in=$in_a, looseness=1.35] (n$i_head);\n"

        if !isempty(label)
            mid_x = (i_dep + i_head) * node_spacing / 2
            distance = abs(i_head - i_dep)
            y_offset = 0.65 + (distance * 0.75)
            tikz *= "  \\node[label, below] at ($mid_x, -$y_offset) {$label};\n"
        end
    end

    tikz *= "\\end{tikzpicture}\n"
    return tikz
end

# Convenience overload for ComparisonResult
#=
function tikz_dual_dependency_comparison(comp::Comparison.ComparisonResult; kwargs...)
    tikz_dual_dependency_comparison(
        comp.g1, comp.g2;
        head_diff  = comp.head_diff,
        label_diff = comp.label_diff,
        g1_name    = comp.g1.editor,
        g2_name    = comp.g2.editor,
        kwargs...
    )
end
=#

# Save functions
#=
function save_tikz_dual_dependency_comparison(comp::Comparison.ComparisonResult, path::String; kwargs...)
    content = tikz_dual_dependency_comparison(comp; kwargs...)
    full = """
$(default_preamble)

\\begin{document}
\\begin{figure}[ht]
\\centering
\\begin{adjustbox}{max width=\\textwidth}
$content
\\end{adjustbox}
\\caption{Comparison: $(comp.g1.sentence_text)}
\\end{figure}
\\end{document}
"""
    write(path, full)
    return path
end
=#

#=
function save_tikz_dual_dependency_comparison(comp::ComparisonResult, path::String; kwargs...)
    content = tikz_dual_dependency_comparison(comp; kwargs...)
    full = """
$(default_preamble)

\\begin{document}
\\begin{figure}[ht]
\\centering
\\begin{adjustbox}{max width=\\textwidth}
$content
\\end{adjustbox}
\\caption{Comparison: $(comp.g1.sentence_text)}
\\end{figure}
\\end{document}
"""
    write(path, full)
    return path
end
=#

#=
function save_tikz_dual_dependency_comparison(g1, g2, path::String; kwargs...)
    code = tikz_dual_dependency_comparison(g1, g2; kwargs...)
    open(path, "w") do io
        write(io, code)
    end
    path
end
=#

end # module