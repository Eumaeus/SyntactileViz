module TikzExport

import ..SyntaxGraph

export tikz_dependency_code, save_tikz_dependency

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
                              preamble::String = default_preamble())
    code = tikz_dependency_code(g)
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

const default_preamble = """
\\documentclass{article}
\\usepackage{fontspec}
\\usepackage{tikz}
\\usepackage{tikz-dependency}

% === Your polytonic Greek setup (customize with your purchased fonts) ===
\\defaultfontfeatures{Ligatures=TeX}
\\setmainfont{YourGreekFontHere}          % e.g. Brill, IFAO, or your professional font
% \\newfontfamily\\greekfont[Script=Greek]{YourGreekFontHere}
% \\usepackage{polyglossia}
% \\setotherlanguage[variant=ancient]{greek}
"""

end # module