using Revise
using SyntactileViz
using Makie

Revise.revise()

student_file = "reports/grading/unit_01/Brown_hq_01_01_1attach.cex"

# Get Editor name from student_file CEX
editor_name = get_editor(student_file)
println("-------\nEditor: $(editor_name)\n-------")
