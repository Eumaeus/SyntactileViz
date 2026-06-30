using Pkg
Pkg.activate(".")

include("../src/CEXParser.jl")

using .CEXParser

a = parse_cex("data/samples/analysis_HQ1.7-corect.cex")
println(length(a.tokens))      # should be 14 (root + 13 tokens)
println(length(a.verbal_units)) # 1
println(length(a.relations))    # 13 or so

a2 = parse_cex("data/samples/analysis_Ellipsis_Option3.cex")
println("Ellipsis tokens present:", any(t -> startswith(t.id, "urn:cite2:fuTeaching:syntax.ellipsis"), a2.tokens))