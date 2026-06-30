using CEXParser
using SyntaxGraph

println("=== Testing SyntaxGraph ===\n")

# Test 1: Simple single-VU sentence
println("--- analysis_HQ1.7-corect.cex ---")
analysis1 = parse_cex("data/samples/analysis_HQ1.7-corect.cex")
g1 = build_syntax_graph(analysis1)

summary(g1)
println()

root = get_root(g1)
println("Root node: ", root)

println("\nOutgoing from root:")
for e in outgoing(g1, "root")
    println("  ", e.source, " → ", e.target, "  [", e.label, "]")
end

println("\nChildren of the main verb (παιδεύει):")
verb_id = "urn:cts:fuTeaching:blackwell.hq.2026:1.7.token.12"
for child in children_of(g1, verb_id)
    node = get_node(g1, child)
    println("  ", node.text, "  (", child, ")")
end

# Test 2: Multi-VU + ellipsis sentence
println("\n\n--- analysis_Ellipsis_Option3.cex ---")
analysis2 = parse_cex("data/samples/analysis_Ellipsis_Option3.cex")
g2 = build_syntax_graph(analysis2)

summary(g2)
println()

println("Verbal Units present:")
for vu_id in keys(g2.verbal_units)
    println("  ", vu_id, " → ", g2.verbal_units[vu_id].syntactic_type)
end

println("\nTokens belonging to VU8:")
for node in get_tokens_in_vu(g2, "VU8")
    println("  ", node.text, "  (", node.id, ")")
end

println("\nDone.")