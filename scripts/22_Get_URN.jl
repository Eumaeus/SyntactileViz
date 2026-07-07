using Revise
using SyntactileViz
using Makie

Revise.revise()

student_file = "reports/grading/submissions/unit_01/Archer_h1_01_01_vu1.cex"
key_file = "reports/grading/keys/unit_01/hq_01_01.cex"

# Get Editor name from student_file CEX
urn1 = get_urn(student_file)
urn2 = get_urn(key_file)
println("-------\nStudent URN: $(urn1)")
println("-------\nKey URN: $(urn2)")
println("Are equal = $(urn1 == urn2)")
