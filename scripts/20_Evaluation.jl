using Revise
using SyntactileViz
using Makie

Revise.revise()


unit = "unit_01"

output_files = "reports/grading/student_reports/$(unit)/"
key_file = "reports/grading/keys/$(unit)/hq_01_01.cex"
submissions_dir = "reports/grading/submissions/$(unit)/"
student_file = "reports/grading/submissions/$(unit)/hq_10_01_diffs.cex"


function generate_reports(output_files::String, key_file::String, student_file::String)

	println("=========================")
	println("Initialization ")
	println("=========================")

	# Ensure that the directories exist
	run(`mkdir -p output_files`)

	# Get Editor name from student_file CEX
	editor_name = get_editor(student_file)
	println("-------\nEditor: $(editor_name)\n-------")
	output_prefix = "$(editor_name)_"

	# ... load or build g1 and g2 ...-


	# Set a font with good Greek support (Noto Sans usually works well)
	Makie.set_theme!(fonts = (regular = "DejaVu Sans", bold = "DejaVu Sans Bold"))


	println("==============================")
	println("Loading and Comparing Graphs ")
	println("==============================")

	keyAnalysis = parse_cex(key_file)
	keyGraph = build_syntax_graph(keyAnalysis)

	submissionAnalysis = parse_cex(student_file)
	submissionGraph = build_syntax_graph(submissionAnalysis)

	comp = compare_syntax_graphs(keyGraph, submissionGraph)

	println("Generating Report…")

	# report_comparison(comp, show_details = true, show_tree = false)
	export_comparison_markdown(comp, show_details = true, show_tree = true, "$(output_files)$(output_prefix)report.md")

	println("Generating Stress Visualization…")

	# Graph with Stress
	save_syntax_tree(submissionGraph, "$(output_files)$(output_prefix)makie.pdf")

	println("Generating Stress Comparison… ")

	# NEW: beautiful side-by-side PDF with differences highlighted
	save_syntax_comparison(comp, "$(output_files)$(output_prefix)comparison_makie.pdf")


	println("Generating Dependency Graph…")

	save_tikz_dependency(submissionGraph, "$(output_files)$(output_prefix)tikz_dependency.tex")

	println("Generating Tree Graph…")

	save_tikz_tree(submissionGraph, "$(output_files)$(output_prefix)tree.tex")

	println("Generating Dependency Comparison…")

	# TikZ Dependency Comparison
	save_tikz_dual_dependency_comparison(comp, "$(output_files)$(output_prefix)tikz_comparison.tex")

	# CLI Stuff: Make PDFs

	println("Processing PDFs…")

	run(`xelatex -interaction=batchmode -output-directory $(output_files) $(output_prefix)tree.tex`)
	run(`xelatex -interaction=batchmode -output-directory $(output_files) $(output_prefix)tikz_comparison.tex`)
	run(`xelatex -interaction=batchmode -output-directory $(output_files) $(output_prefix)tikz_dependency.tex`)
	run(`pandoc --metadata-file=/Users/cblackwell/cite/grok/Markdown_LaTeX/dv-defaults.yaml --pdf-engine=xelatex -o $(output_files)$(output_prefix)report.pdf $(output_files)$(output_prefix)report.md`)

	run(`pdfunite $(output_files)$(output_prefix)tikz_dependency.pdf $(output_files)$(output_prefix)tree.pdf $(output_files)$(output_prefix)makie.pdf $(output_files)$(output_prefix)report.pdf $(output_files)$(output_prefix)comparison_makie.pdf $(output_files)$(output_prefix)tikz_comparison.pdf $(output_files)$(output_prefix)combined_report.pdf`)


	println("Cleaning Up…")

	# Clean Up
	run(`sh -c "rm $(output_files)*.aux"`)
	run(`sh -c "rm $(output_files)*.log"`)
	run(`sh -c "rm $(output_files)*.tex"`)
	#run(`sh -c "rm $(output_files)*.md"`)
	run(`rm $(output_files)$(output_prefix)tikz_dependency.pdf $(output_files)$(output_prefix)tree.pdf $(output_files)$(output_prefix)makie.pdf $(output_files)$(output_prefix)report.pdf $(output_files)$(output_prefix)comparison_makie.pdf $(output_files)$(output_prefix)tikz_comparison.pdf`)

	println("================================")
	println("** Done **")
	println("Output in `$(output_files)`")
	println("================================")
end

# Get Student Submissions

all_files = readdir(submissions_dir)

all_subs = filter(all_files) do f 
	contains(f, ".cex")
end

for f in all_subs 
	generate_reports(output_files, key_file, "$(submissions_dir)$(f)")
end





