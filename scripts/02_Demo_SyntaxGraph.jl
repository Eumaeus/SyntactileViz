using Revise
using SyntactileViz

Revise.revise()



println("=== DEMO: SyntaxGraph Features ===\n")

# Load both examples
a1 = parse_cex("data/samples/analysis_HQ1.7-corect.cex")
g1 = build_syntax_graph(a1)

a2 = parse_cex("data/samples/analysis_Ellipsis_Option3.cex")
g2 = build_syntax_graph(a2)

# === Pretty Print ===
println(">>> Pretty Print (simple sentence)")
pretty_print(g1; show_vu=false)
println()

println(">>> Pretty Print with Verbal Units + Colors (ellipsis example)")
pretty_print(g2; show_vu=true)
println()

# === Subgraph for a Verbal Unit ===
println(">>> Subgraph for VU8 (the clause with the ellipsis)")
sub_g = get_subgraph_for_vu(g2, "VU8")
print_graph_summary(sub_g)
println("Nodes in VU8 subgraph: ", length(sub_g.nodes))
println()

# === Multi-VU helpers ===
println(">>> Verbal Units sorted by level:")
for vu in get_verbal_units_sorted(g2)
    println("  $(vu.id): level $(vu.level) — $(vu.syntactic_type)")
end

println("\n>>> Primary verbal unit for a participle that belongs to two VUs:")
participle = "urn:cts:greekLit:tlg0031.tlg001.wh:14.19.2"
println("  Node: $(get_node(g2, participle).text)")
println("  Primary VU: ", get_primary_verbal_unit(g2, participle))

println("\n=== Demo complete ===")