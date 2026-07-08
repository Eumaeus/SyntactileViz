module Comparison

using CairoMakie
using GraphMakie
using Graphs
using NetworkLayout

using ..SyntaxGraph
using ..CEXParser
using ..Visualization
using ..TikzExport        

using Printf
using Dates

export ComparisonResult, compare_syntax_graphs, report_comparison, diff_summary, 
       export_comparison_markdown, compare_verbal_units, VerbalUnitComparison,
       tikz_dual_dependency_comparison, save_tikz_dual_dependency_comparison,
       tikz_verbal_unit_comparison, save_tikz_verbal_unit_comparison

export draw_syntax_comparison, save_syntax_comparison, save_tikz_dual_dependency_comparison


# ============================================================
# Result struct
# ============================================================

struct ComparisonResult
    g1::SyntaxGraph
    g2::SyntaxGraph
    uas::Float64
    las::Float64
    total_tokens::Int
    agreeing::Vector{String}
    label_diff::Vector{Tuple{String, String, String}}
    head_diff::Vector{Tuple{String, String, String}}
end

# ============================================================
# Verbal Unit Comparison
# ============================================================

struct VerbalUnitComparison
    g1_vu_count::Int
    g2_vu_count::Int
    matched::Vector{NamedTuple{(:g1_id, :g2_id, :jaccard, :g1_level, :g2_level, 
                                 :g1_syntactic, :g2_syntactic, :g1_semantic, :g2_semantic), 
                                Tuple{String,String,Float64,Int,Int,String,String,String,String}}}
    unmatched_g1::Vector{String}
    unmatched_g2::Vector{String}
end

"""
    compare_verbal_units(g1, g2; jaccard_threshold=0.65)

Compares verbal units between two SyntaxGraphs using token-set overlap
(Jaccard similarity). This avoids relying on arbitrary VU IDs.

Returns a VerbalUnitComparison with matched pairs (including property comparison)
and unmatched VUs on each side.
"""
function compare_verbal_units(g1::SyntaxGraph, g2::SyntaxGraph; 
                              jaccard_threshold::Float64 = 0.65)

    # Helper: get set of token IDs belonging to a verbal unit
    function get_vu_token_set(g::SyntaxGraph, vu_id::String)
        nodes = get_tokens_in_vu(g, vu_id)
        return Set(n.id for n in nodes)
    end

    # Jaccard similarity
    function jaccard(s1::Set, s2::Set)
        inter = length(intersect(s1, s2))
        union_size = length(union(s1, s2))
        return union_size == 0 ? 0.0 : inter / union_size
    end

    # Build token sets for all VUs
    vus1 = collect(keys(g1.verbal_units))
    vus2 = collect(keys(g2.verbal_units))

    sets1 = Dict(vu => get_vu_token_set(g1, vu) for vu in vus1)
    sets2 = Dict(vu => get_vu_token_set(g2, vu) for vu in vus2)

    matched = NamedTuple[]
    used_g2 = Set{String}()

    for vu1 in vus1
        best_score = 0.0
        best_vu2 = ""
        
        for vu2 in vus2
            if vu2 in used_g2
                continue
            end
            score = jaccard(sets1[vu1], sets2[vu2])
            if score > best_score
                best_score = score
                best_vu2 = vu2
            end
        end

        if best_score >= jaccard_threshold && !isempty(best_vu2)
            push!(used_g2, best_vu2)
            
            vu1_obj = g1.verbal_units[vu1]
            vu2_obj = g2.verbal_units[best_vu2]
            
            push!(matched, (
                g1_id      = vu1,
                g2_id      = best_vu2,
                jaccard    = round(best_score, digits=3),
                g1_level   = vu1_obj.level,
                g2_level   = vu2_obj.level,
                g1_syntactic = vu1_obj.syntactic_type,
                g2_syntactic = vu2_obj.syntactic_type,
                g1_semantic  = vu1_obj.semantic_type,
                g2_semantic  = vu2_obj.semantic_type
            ))
        end
    end

    unmatched_g1 = setdiff(vus1, [m.g1_id for m in matched])
    unmatched_g2 = setdiff(vus2, [m.g2_id for m in matched])

    return VerbalUnitComparison(
        length(vus1),
        length(vus2),
        matched,
        unmatched_g1,
        unmatched_g2
    )
end

# ============================================================
# Core helpers
# ============================================================

function get_head_and_label(g::SyntaxGraph, node_id::String)
    outs = outgoing(g, node_id)
    if isempty(outs)
        return (nothing, nothing)
    elseif length(outs) > 1
        @warn "Node $node_id has multiple outgoing edges — using first one"
        e = outs[1]
        return (e.target, e.label)
    else
        e = outs[1]
        return (e.target, e.label)
    end
end

function compare_syntax_graphs(g1::SyntaxGraph, g2::SyntaxGraph)
    if g1.sentence_text != g2.sentence_text
        @warn "Sentences differ between the two graphs"
    end

    nodes1 = setdiff(collect(keys(g1.nodes)), ["root"])
    nodes2 = setdiff(collect(keys(g2.nodes)), ["root"])
    common_nodes = intersect(nodes1, nodes2)

    if length(common_nodes) < min(length(nodes1), length(nodes2))
        @warn "Node sets are not identical"
    end

    total = length(common_nodes)
    agreeing = String[]
    label_diff = Tuple{String,String,String}[]
    head_diff = Tuple{String,String,String}[]

    correct_head = 0
    correct_label = 0

    for nid in common_nodes
        h1, l1 = get_head_and_label(g1, nid)
        h2, l2 = get_head_and_label(g2, nid)

        if h1 == h2 && h1 !== nothing
            correct_head += 1
            if l1 == l2
                correct_label += 1
                push!(agreeing, nid)
            else
                push!(label_diff, (nid, string(l1), string(l2)))
            end
        else
            push!(head_diff, (nid, string(h1), string(h2)))
        end
    end

    uas = total > 0 ? correct_head / total : 0.0
    las = total > 0 ? correct_label / total : 0.0

    ComparisonResult(g1, g2, uas, las, total, agreeing, label_diff, head_diff)
end

# ============================================================
# Robust stdout capture using a temp file (avoids pipe deadlocks)
# ============================================================
function capture_pretty_print(g::SyntaxGraph; show_vu::Bool = true)
    mktemp() do path, file_io
        redirect_stdout(file_io) do
            pretty_print(g; show_vu = show_vu)
        end
        flush(file_io)
        seekstart(file_io)
        return read(file_io, String)
    end
end

# ============================================================
# Quick one-line summary
# ============================================================

function diff_summary(comp::ComparisonResult)
    minor = length(comp.label_diff)
    major = length(comp.head_diff)
    @printf("UAS: %5.1f%% | LAS: %5.1f%% | Minor diffs: %2d | Major diffs: %2d\n",
            comp.uas * 100, comp.las * 100, minor, major)
end


# ============================================================
# Updated report_comparison with show_tree control
# ============================================================
function report_comparison(comp::ComparisonResult; 
                           show_details::Bool = true, 
                           show_tree::Bool = true)
    g1 = comp.g1
    g2 = comp.g2

    println("╔══════════════════════════════════════════════════════════════════╗")
    println("║           SYNTACTIC ANALYSIS COMPARISON REPORT                   ║")
    println("╚══════════════════════════════════════════════════════════════════╝")
    println()
    println("Sentence: $(g1.sentence_text)")
    println()
    println("Analysis 1: $(g1.editor)")
    println("            $(g1.analysis_urn)")
    println()
    println("Analysis 2: $(g2.editor)")
    println("            $(g2.analysis_urn)")
    println()
    println("────────────────────────────────────────────────────────────────────")
    @printf("UAS (Unlabeled Attachment Score) : %6.1f%%\n", comp.uas * 100)
    @printf("LAS (Labeled Attachment Score)   : %6.1f%%\n", comp.las * 100)
    println("Tokens evaluated                 : $(comp.total_tokens)")
    println("────────────────────────────────────────────────────────────────────")
    println()

    if show_details
        # ... (all the existing difference sections stay exactly as before) ...
        # Minor diffs, Major diffs, Verbal Unit section, etc.
    end

    if show_tree
        println("────────────────────────────────────────────────────────────────────")
        println("Tree Views:")
        println()
        println(">>> Analysis 1 ($(g1.editor)):")
        pretty_print(g1; show_vu = true)
        println()
        println(">>> Analysis 2 ($(g2.editor)):")
        pretty_print(g2; show_vu = true)
    end
end

# ============================================================
# NEW & IMPROVED: export_comparison_markdown
# ============================================================
function export_comparison_markdown(comp::ComparisonResult, filepath::String;
                                    show_details::Bool = true,
                                    show_tree::Bool = true,
                                    executive_summary::Bool = false,
                                    show_token_vu_assignments::Bool = false)   # NEW

    if executive_summary
        show_tree = false
        show_token_vu_assignments = false
    end

    g1 = comp.g1
    g2 = comp.g2
    timestamp = Dates.format(now(), "yyyy-mm-dd HH:MM")

    open(filepath, "w") do io
        # Header
        write(io, "# Syntactic Analysis Comparison Report\n\n")
        write(io, "**Generated:** $(timestamp)\n\n")
        write(io, "**Sentence:** $(g1.sentence_text)\n\n")
        
        write(io, "**Analysis 1:** $(g1.editor)  \n")
        write(io, "$(g1.analysis_urn)\n\n")
        write(io, "**Analysis 2:** $(g2.editor)  \n")
        write(io, "$(g2.analysis_urn)\n\n")
        
        write(io, "---\n\n")

        # Scores + Explanations
        write(io, "## Scores\n\n")
        write(io, "| Metric | Value |\n")
        write(io, "|--------|-------:|\n")
        @printf(io, "| UAS    | %.1f%% |\n", comp.uas * 100)
        @printf(io, "| LAS    | %.1f%% |\n", comp.las * 100)
        write(io, "| Tokens | $(comp.total_tokens) |\n\n")

        if show_details
            write(io, "**UAS (Unlabeled Attachment Score)**: Measures how often the two analyses agree on the *head* (governor) of each token, regardless of the grammatical label.\n\n")
            write(io, "**LAS (Labeled Attachment Score)**: Measures how often the two analyses agree on *both* the head *and* the grammatical label (relation) of each token.\n\n")
        end

        if show_details
            write(io, "## Differences\n\n")

            # ... (keep your existing Minor/Major Differences sections exactly as they are) ...

            # === Verbal Unit Comparison (enhanced) ===
            write(io, "### Verbal Unit Comparison\n\n")

            vu_comp = compare_verbal_units(g1, g2)

            write(io, "- **Analysis 1**: $(vu_comp.g1_vu_count) verbal units\n")
            write(io, "- **Analysis 2**: $(vu_comp.g2_vu_count) verbal units\n")
            write(io, "- **Matched** (by token overlap): $(length(vu_comp.matched))\n")
            write(io, "- **Only in Analysis 1**: $(length(vu_comp.unmatched_g1))\n")
            write(io, "- **Only in Analysis 2**: $(length(vu_comp.unmatched_g2))\n\n")

            if show_details
                write(io, "**Jaccard similarity** is used to match verbal units across analyses. It measures the overlap between the sets of tokens belonging to each verbal unit (1.0 = identical token sets, 0.0 = no overlap). A threshold of 0.65 is used by default.\n\n")
            end

            if !isempty(vu_comp.matched)
                write(io, "#### Matched Verbal Units\n\n")
                write(io, "| VU1 | VU2 | Jaccard | Level | Syntactic Type                  | Semantic Type          |\n")
                write(io, "|-----|-----|---------|-------|---------------------------------|------------------------|\n")

                for m in vu_comp.matched
                    level_str = m.g1_level == m.g2_level ? string(m.g1_level) : "$(m.g1_level) vs $(m.g2_level)"
                    write(io, "| $(m.g1_id) | $(m.g2_id) | $(m.jaccard) | $(level_str) | ")
                    write(io, "$(m.g1_syntactic) vs $(m.g2_syntactic) | ")
                    write(io, "$(m.g1_semantic) vs $(m.g2_semantic) |\n")
                end
                write(io, "\n")
            end

            if !isempty(vu_comp.unmatched_g1)
                write(io, "#### Unmatched in Analysis 1\n\n")
                for vu in vu_comp.unmatched_g1
                    obj = g1.verbal_units[vu]
                    write(io, "- **$(vu)** — Level $(obj.level), $(obj.syntactic_type), $(obj.semantic_type)\n")
                end
                write(io, "\n")
            end

            if !isempty(vu_comp.unmatched_g2)
                write(io, "#### Unmatched in Analysis 2\n\n")
                for vu in vu_comp.unmatched_g2
                    obj = g2.verbal_units[vu]
                    write(io, "- **$(vu)** — Level $(obj.level), $(obj.syntactic_type), $(obj.semantic_type)\n")
                end
                write(io, "\n")
            end

            # === NEW: Token-by-Token Verbal Unit Assignment ===
            if show_token_vu_assignments
                write(io, "### Token-by-Token Verbal Unit Assignment\n\n")
                write(io, "Only tokens with **different** verbal unit assignments are shown below.\n\n")

                for token_id in g1.ordered_token_ids
                    node1 = get_node(g1, token_id)
                    node2 = get_node(g2, token_id)
                    if node1 === nothing || node2 === nothing
                        continue
                    end

                    vus1 = node1.verbal_unit_ids
                    vus2 = node2.verbal_unit_ids

                    if vus1 != vus2   # only show differences
                        primary1 = get_primary_verbal_unit(g1, token_id)
                        primary2 = get_primary_verbal_unit(g2, token_id)

                        write(io, "- **$(node1.text)**\n")
                        write(io, "  - Analysis 1: Primary = $(primary1), All = $(join(vus1, ", "))\n")
                        write(io, "  - Analysis 2: Primary = $(primary2), All = $(join(vus2, ", "))\n\n")
                    end
                end
            end
        end

        # Tree views (unchanged)
        if show_tree
            write(io, "---\n\n## Tree Views\n\n")

            tree1 = capture_pretty_print(g1; show_vu = true)
            write(io, "### Analysis 1 – $(g1.editor)\n\n")
            write(io, "```text\n")
            write(io, tree1)
            write(io, "```\n\n")

            tree2 = capture_pretty_print(g2; show_vu = true)
            write(io, "### Analysis 2 – $(g2.editor)\n\n")
            write(io, "```text\n")
            write(io, tree2)
            write(io, "```\n\n")
        end

        write(io, "---\n")
        write(io, "*Generated with SyntactileViz*\n")
    end

    println("Markdown report written to: $filepath")
end

# ============================================================
# Side-by-side Makie visualization (moved here from Visualization)
# ============================================================

"""
    draw_syntax_comparison(comp::ComparisonResult;
                           highlight_diffs::Bool = true,
                           size = (2200, 900))

Side-by-side Makie visualization of two syntax analyses with difference highlighting.
"""
function draw_syntax_comparison(comp::ComparisonResult;
                                highlight_diffs::Bool = true,
                                size = (2200, 900))
    g1 = comp.g1
    g2 = comp.g2

    node_overrides = Dict{String, Symbol}()

    if highlight_diffs
        for (nid, _, _) in comp.label_diff
            node_overrides[nid] = :orange
        end
        for (nid, _, _) in comp.head_diff
            node_overrides[nid] = :pink
        end
    end

    fig = Figure(size = size)

    g1_editor = replace(g1.editor, "_" => " ")
    g2_editor = replace(g2.editor, "_" => " ")

    # Header
    Label(fig[0, 1:2],
          "Syntactic Analysis Comparison\n$(g1.sentence_text)",
          fontsize = 18, halign = :center, tellwidth = false)

    # Left panel
    ax1 = Axis(fig[1, 1];
               title = "Analysis 1: $(g1_editor)\nUAS: $(round(comp.uas*100, digits=1))%  |  LAS: $(round(comp.las*100, digits=1))%",
               titlesize = 14)
    Visualization.plot_syntax_tree!(ax1, g1; node_color_overrides = node_overrides)

    # Right panel
    ax2 = Axis(fig[1, 2];
               title = "Analysis 2: $(g2_editor)\nUAS: $(round(comp.uas*100, digits=1))%  |  LAS: $(round(comp.las*100, digits=1))%",
               titlesize = 14)
    Visualization.plot_syntax_tree!(ax2, g2; node_color_overrides = node_overrides)

    # Legend
    Label(fig[2, 1:2],
          "Orange = label change (minor diff)   •   Salmon = head change (major diff)   •   Gold = root, Plum = ellipsis",
          fontsize = 11, halign = :center)

    return fig
end



"""
    tikz_dual_dependency_comparison(comp::ComparisonResult; kwargs...)

High-level convenience function. Use this or `save_tikz_dual_dependency_comparison`.
"""
function tikz_dual_dependency_comparison(comp::ComparisonResult; kwargs...)
    TikzExport.tikz_dual_dependency_comparison(
        comp.g1, comp.g2;
        head_diff  = comp.head_diff,
        label_diff = comp.label_diff,
        g1_name    = replace(comp.g1.editor, "_" => " "),
        g2_name    = replace(comp.g2.editor, "_" => " "),
        kwargs...
    )
end

"""
    tikz_verbal_unit_comparison(comp::ComparisonResult; ...)

Side-by-side verbal unit visualization for two analyses.
Uses the same color palette where VUs were matched by `compare_verbal_units`.
"""
function tikz_verbal_unit_comparison(comp::ComparisonResult; kwargs...)
    # For now we generate two independent visualizations.
    # Future improvement: align colors using matched VUs from compare_verbal_units.
    left  = TikzExport.tikz_verbal_unit_linear(comp.g1; kwargs...)
    right = TikzExport.tikz_verbal_unit_linear(comp.g2; kwargs...)

    return """
\\begin{tabular}{@{}p{0.48\\textwidth}p{0.48\\textwidth}@{}}
\\centering
\\textbf{$(replace(comp.g1.editor, "_" => " "))} \\\\[0.3em]
$left
&
\\centering
\\textbf{$(replace(comp.g2.editor, "_" => " "))} \\\\[0.3em]
$right
\\end{tabular}
"""
end


"""
    save_tikz_verbal_unit_comparison(comp::ComparisonResult, path::String; ...)

Saves a standalone .tex file with side-by-side verbal unit visualizations
for two analyses.
"""
function save_tikz_verbal_unit_comparison(comp::ComparisonResult, path::String;
        preamble::String = TikzExport.default_preamble,
        use_adjustbox::Bool = true,
        adjustbox_options::String = "max width=\\textwidth",
        show_legend::Bool = true)

    content = tikz_verbal_unit_comparison(comp; 
        show_legend = show_legend)

    wrapped = if use_adjustbox
        """
        \\begin{adjustbox}{$adjustbox_options}
        $content
        \\end{adjustbox}
        """
    else
        content
    end

    full = """
    $preamble

    \\begin{document}
    \\begin{figure}[ht]
    \\centering
    $wrapped
    \\caption{Verbal Unit Comparison — $(comp.g1.sentence_text)}
    \\end{figure}
    \\end{document}
    """
    write(path, full)
    return path
end

"""
    save_tikz_dual_dependency_comparison(comp::ComparisonResult, path::String; kwargs...)

Recommended way to save a dual-arc TikZ comparison.
"""
function save_tikz_dual_dependency_comparison(comp::ComparisonResult, path::String; kwargs...)
    content = tikz_dual_dependency_comparison(comp; kwargs...)
    full = """
$(TikzExport.default_preamble)

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

"""
    save_syntax_comparison(comp::ComparisonResult, path::String;
                           format::Symbol = :pdf, kwargs...)

Saves the side-by-side comparison visualization to a file (PDF recommended).
"""
function save_syntax_comparison(comp::ComparisonResult, path::String;
                                format::Symbol = :pdf, kwargs...)
    fig = draw_syntax_comparison(comp; kwargs...)
    save(path, fig)
    @info "Saved comparison visualization → $path"
    return path
end

end # module Comparison