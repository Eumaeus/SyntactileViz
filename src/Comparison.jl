module Comparison

using ..SyntaxGraph
using ..CEXParser
using Printf          # ← REQUIRED for @printf


export ComparisonResult, compare_syntax_graphs, report_comparison, diff_summary

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
# New: Quick one-line summary
# ============================================================

function diff_summary(comp::ComparisonResult)
    minor = length(comp.label_diff)
    major = length(comp.head_diff)
    @printf("UAS: %5.1f%% | LAS: %5.1f%% | Minor diffs: %2d | Major diffs: %2d\n",
            comp.uas * 100, comp.las * 100, minor, major)
end

# ============================================================
# Enhanced reporting with Verbal Unit comparison
# ============================================================

function report_comparison(comp::ComparisonResult; show_details::Bool = true)
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
        # --- Attachment differences ---
        if !isempty(comp.label_diff)
            println("── Minor differences (same head, different label) ──")
            for (nid, l1, l2) in comp.label_diff
                node = get_node(g1, nid)
                text = node === nothing ? nid : node.text
                println("  • $(text)  →  \"$l1\"  vs  \"$l2\"")
            end
            println()
        end

        if !isempty(comp.head_diff)
            println("── Major differences (different head) ──")
            for (nid, h1, h2) in comp.head_diff
                node = get_node(g1, nid)
                text = node === nothing ? nid : node.text
                h1_text = get_node(g1, h1) !== nothing ? get_node(g1, h1).text : string(h1)
                h2_text = get_node(g2, h2) !== nothing ? get_node(g2, h2).text : string(h2)
                println("  • $(text)  →  head: \"$h1_text\"  vs  \"$h2_text\"")
            end
            println()
        end

        if isempty(comp.label_diff) && isempty(comp.head_diff)
            println("✓ Perfect agreement on all attachments!")
        end

        # --- NEW: Verbal Unit differences ---
        println("── Verbal Unit Comparison ──")
        vus1 = Set(keys(g1.verbal_units))
        vus2 = Set(keys(g2.verbal_units))
        only_in_g1 = setdiff(vus1, vus2)
        only_in_g2 = setdiff(vus2, vus1)
        common_vus = intersect(vus1, vus2)

        println("  VUs in Analysis 1: $(length(vus1))   |   VUs in Analysis 2: $(length(vus2))")
        if !isempty(only_in_g1)
            println("  Only in Analysis 1: $(collect(only_in_g1))")
        end
        if !isempty(only_in_g2)
            println("  Only in Analysis 2: $(collect(only_in_g2))")
        end

        # Check for nodes with different primary verbal unit
        nodes1 = setdiff(collect(keys(g1.nodes)), ["root"])
        nodes2 = setdiff(collect(keys(g2.nodes)), ["root"])
        common_nodes = intersect(nodes1, nodes2)

        vu_assignment_diffs = Tuple{String, Union{String,Nothing}, Union{String,Nothing}}[]
        for nid in common_nodes
            pu1 = get_primary_verbal_unit(g1, nid)
            pu2 = get_primary_verbal_unit(g2, nid)
            if pu1 != pu2
                push!(vu_assignment_diffs, (nid, pu1, pu2))
            end
        end

        if !isempty(vu_assignment_diffs)
            println("\n  Nodes with different primary Verbal Unit assignment:")
            for (nid, pu1, pu2) in vu_assignment_diffs
                node = get_node(g1, nid)
                text = node === nothing ? nid : node.text
                println("    • $(text)  →  $(pu1)  vs  $(pu2)")
            end
        else
            println("  ✓ All nodes have consistent primary Verbal Unit assignments")
        end
        println()
    end

    println("────────────────────────────────────────────────────────────────────")
    println("Quick tree views:")
    println()
    println(">>> Analysis 1 ($(g1.editor)):")
    pretty_print(g1; show_vu = true)
    println()
    println(">>> Analysis 2 ($(g2.editor)):")
    pretty_print(g2; show_vu = true)
end

end # module Comparison