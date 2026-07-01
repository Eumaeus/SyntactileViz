module Comparison

using ..SyntaxGraph

export ComparisonResult, compare_syntax_graphs, report_comparison, compare_cex_files

# ============================================================
# Result struct
# ============================================================

struct ComparisonResult
    g1::SyntaxGraph
    g2::SyntaxGraph
    uas::Float64
    las::Float64
    total_tokens::Int
    agreeing::Vector{String}                           # node_ids with full match
    label_diff::Vector{Tuple{String, String, String}}  # (node_id, label_g1, label_g2)
    head_diff::Vector{Tuple{String, String, String}}   # (node_id, head_g1, head_g2)
end

# ============================================================
# Core comparison logic
# ============================================================

"""
    get_head_and_label(g::SyntaxGraph, node_id::String) -> (head_id, label) or (nothing, nothing)
"""
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

"""
    compare_syntax_graphs(g1::SyntaxGraph, g2::SyntaxGraph) -> ComparisonResult
"""
function compare_syntax_graphs(g1::SyntaxGraph, g2::SyntaxGraph)
    if g1.sentence_text != g2.sentence_text
        @warn "Sentences differ between the two graphs"
    end

    # Work with non-root nodes that exist in both graphs
    nodes1 = setdiff(collect(keys(g1.nodes)), ["root"])
    nodes2 = setdiff(collect(keys(g2.nodes)), ["root"])
    common_nodes = intersect(nodes1, nodes2)

    if length(common_nodes) < length(nodes1) || length(common_nodes) < length(nodes2)
        @warn "Node sets are not identical between the two analyses"
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
# Reporting
# ============================================================

"""
    report_comparison(comp::ComparisonResult; show_details::Bool=true)
"""
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
    println("UAS (Unlabeled Attachment Score) : %6.1f%%\n", comp.uas * 100)
    println("LAS (Labeled Attachment Score)   : %6.1f%%\n", comp.las * 100)
    println("Tokens evaluated                 : $(comp.total_tokens)")
    println("────────────────────────────────────────────────────────────────────")
    println()

    if show_details
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
                h1_text = get_node(g1, h1) !== nothing ? get_node(g1, h1).text : h1
                h2_text = get_node(g2, h2) !== nothing ? get_node(g2, h2).text : h2
                println("  • $(text)  →  head: \"$h1_text\"  vs  \"$h2_text\"")
            end
            println()
        end

        if isempty(comp.label_diff) && isempty(comp.head_diff)
            println("✓ Perfect agreement on all attachments!")
        end
    end

    println("────────────────────────────────────────────────────────────────────")
    println("Quick tree views (for reference):")
    println()
    println(">>> Analysis 1 ($(g1.editor)):")
    pretty_print(g1; show_vu=true)
    println()
    println(">>> Analysis 2 ($(g2.editor)):")
    pretty_print(g2; show_vu=true)
end

# ============================================================
# Convenience function
# ============================================================

"""
    compare_cex_files(path1::String, path2::String) -> ComparisonResult
"""
function compare_cex_files(path1::String, path2::String)
    a1 = parse_cex(path1)
    a2 = parse_cex(path2)
    g1 = build_syntax_graph(a1)
    g2 = build_syntax_graph(a2)
    compare_syntax_graphs(g1, g2)
end

end # module Comparison