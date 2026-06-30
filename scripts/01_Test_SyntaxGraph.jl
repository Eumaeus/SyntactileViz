using SyntactileViz

println("=== Testing SyntactileViz Package ===\n")

# Test 1
println("--- analysis_HQ1.7-corect.cex ---")
analysis1 = parse_cex("data/samples/analysis_HQ1.7-corect.cex")
g1 = build_syntax_graph(analysis1)

print_graph_summary(g1)
println()

root = get_root(g1)
println("Root text: ", root.text)

println("\nOutgoing from root:")
for e in outgoing(g1, "root")
    println("  $(e.source) → $(e.target)  [$(e.label)]")
end

# Test 2
println("\n\n--- analysis_Ellipsis_Option3.cex ---")
analysis2 = parse_cex("data/samples/analysis_Ellipsis_Option3.cex")
g2 = build_syntax_graph(analysis2)

print_graph_summary(g2)
println()

println("Verbal Units:")
for (id, vu) in g2.verbal_units
    println("  $id → $(vu.syntactic_type) (level $(vu.level))")
end

println("\nTokens belonging to VU8:")
for node in get_tokens_in_vu(g2, "VU8")
    println("  $(node.text) ($(node.id))")
end

println("\n✓ Done.")