# Load the local modules
include("../src/CEXParser.jl")
include("../src/SyntaxGraph.jl")

using .CEXParser
using .SyntaxGraph

println("=== Testing SyntaxGraph ===\n")

# =====================
# Test 1: Simple sentence
# =====================
println("--- analysis_HQ1.7-corect.cex ---")
analysis1 = parse_cex("data/samples/analysis_HQ1.7-corect.cex")
g1 = build_syntax_graph(analysis1)

summary(g1)
println()

root = get_root(g1)
println("Root node text: ", root.text)

println("\nFirst few relations from root:")
for e in outgoing(g1, "root")[1:min(3, end)]
    println("  ", e.source, " → ", e.target, "  [", e.label, "]")
end

# =====================
# Test 2: Multi-VU + ellipsis
# =====================
println("\n\n--- analysis_Ellipsis_Option3.cex ---")
analysis2 = parse_cex("data/samples/analysis_Ellipsis_Option3.cex")
g2 = build_syntax_graph(analysis2)

summary(g2)
println()

println("Verbal Units:")
for (id, vu) in g2.verbal_units
    println("  $id → $(vu.syntactic_type) (level $(vu.level))")
end

println("\nTokens in VU8 (the one with the ellipsis):")
for node in get_tokens_in_vu(g2, "VU8")
    println("  $(node.text)  ($(node.id))")
end

println("\n✓ All tests passed.")