module Comparison

using ..SyntaxGraph
using ..CEXParser
using Printf
using Dates

export ComparisonResult, compare_syntax_graphs, report_comparison, diff_summary, export_comparison_markdown

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
# Robust helper to capture pretty_print output (pipe-based)
# ============================================================
function capture_pretty_print(g::SyntaxGraph; show_vu::Bool = true)
    old_stdout = stdout
    rd, wr = redirect_stdout()          # creates a pipe
    output = ""
    try
        pretty_print(g; show_vu = show_vu)
        close(wr)                       # important: close write end
        output = read(rd, String)
    finally
        redirect_stdout(old_stdout)
        close(rd)
    end
    return output
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
                                    executive_summary::Bool = false)
    
    if executive_summary
        show_tree = false
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

        # Scores as a Markdown table
        write(io, "## Scores\n\n")
        write(io, "| Metric | Value |\n")
        write(io, "|--------|-------:|\n")
        @printf(io, "| UAS    | %.1f%% |\n", comp.uas * 100)
        @printf(io, "| LAS    | %.1f%% |\n", comp.las * 100)
        write(io, "| Tokens | $(comp.total_tokens) |\n\n")

        if show_details
            write(io, "## Differences\n\n")

            if !isempty(comp.label_diff)
                write(io, "### Minor Differences (same head, different label)\n\n")
                for (nid, l1, l2) in comp.label_diff
                    node = get_node(g1, nid)
                    text = node === nothing ? nid : node.text
                    write(io, "- **$(text)**: `\"$l1\"` vs `\"$l2\"`\n")
                end
                write(io, "\n")
            end

            if !isempty(comp.head_diff)
                write(io, "### Major Differences (different head)\n\n")
                for (nid, h1, h2) in comp.head_diff
                    node = get_node(g1, nid)
                    text = node === nothing ? nid : node.text
                    h1_text = get_node(g1, h1) !== nothing ? get_node(g1, h1).text : string(h1)
                    h2_text = get_node(g2, h2) !== nothing ? get_node(g2, h2).text : string(h2)
                    write(io, "- **$(text)**: head `\"$h1_text\"` vs `\"$h2_text\"`\n")
                end
                write(io, "\n")
            end

            # Verbal Unit section
            write(io, "### Verbal Unit Comparison\n\n")
            vus1 = Set(keys(g1.verbal_units))
            vus2 = Set(keys(g2.verbal_units))
            only_g1 = setdiff(vus1, vus2)
            only_g2 = setdiff(vus2, vus1)

            write(io, "- **VUs in Analysis 1**: $(length(vus1))\n")
            write(io, "- **VUs in Analysis 2**: $(length(vus2))\n")
            if !isempty(only_g1) write(io, "- Only in Analysis 1: $(collect(only_g1))\n") end
            if !isempty(only_g2) write(io, "- Only in Analysis 2: $(collect(only_g2))\n") end
            write(io, "\n")
        end

        # Inside export_comparison_markdown, the tree capture becomes:
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

end # module Comparison