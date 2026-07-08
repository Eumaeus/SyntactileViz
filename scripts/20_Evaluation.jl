using Revise
using SyntactileViz
using Makie

Revise.revise()


unit = "unit_10"
key_dir = "reports/grading/keys/"

output_files = "reports/grading/student_reports/$(unit)/"
submissions_dir = "reports/grading/submissions/$(unit)/"


#student_file = "reports/grading/submissions/$(unit)/hq_10_01_diffs.cex"
#key_file = "reports/grading/keys/$(unit)/hq_01_01.cex"

#=

1. Get dictionary of key-file-path, urn.
2. Read files in Submissions-directory, making tuple of key-file + submission-file.
3. Generate reports.

=#

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
	# export_comparison_markdown(comp, show_details = true, show_tree = true, "$(output_files)$(output_prefix)report.md")
	export_comparison_markdown(comp, "$(output_files)$(output_prefix)report.md"; show_token_vu_assignments = true)

	println("Generating Stress Visualization…")

	# Graph with Stress
	save_syntax_tree(submissionGraph, "$(output_files)$(output_prefix)makie.pdf")

	println("Generating Stress Comparison… ")

	# NEW: beautiful side-by-side PDF with differences highlighted
	save_syntax_comparison(comp, "$(output_files)$(output_prefix)comparison_makie.pdf")


	println("Generating Verbal Units Visualization")

	save_tikz_verbal_unit_linear(submissionGraph, "$(output_files)$(output_prefix)verbal_units_graph.tex")

	println("Generating Verbal Units Comparison")

	save_tikz_verbal_unit_comparison(comp, "$(output_files)$(output_prefix)verbal_units_comparison.tex")

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

	run(`xelatex -interaction=batchmode -output-directory $(output_files) $(output_prefix)verbal_units_comparison.tex`)
	run(`xelatex -interaction=batchmode -output-directory $(output_files) $(output_prefix)verbal_units_graph.tex`)

	run(`pandoc --metadata-file=/Users/cblackwell/cite/grok/Markdown_LaTeX/dv-defaults.yaml --pdf-engine=xelatex -o $(output_files)$(output_prefix)report.pdf $(output_files)$(output_prefix)report.md`)

	run(`pdfunite $(output_files)$(output_prefix)tikz_dependency.pdf $(output_files)$(output_prefix)verbal_units_graph.pdf $(output_files)$(output_prefix)tree.pdf $(output_files)$(output_prefix)makie.pdf $(output_files)$(output_prefix)report.pdf $(output_files)$(output_prefix)verbal_units_comparison.pdf $(output_files)$(output_prefix)comparison_makie.pdf $(output_files)$(output_prefix)tikz_comparison.pdf $(output_files)$(output_prefix)combined_report.pdf`)


	println("Cleaning Up…")

	# Clean Up
	run(`sh -c "rm $(output_files)*.aux"`)
	run(`sh -c "rm $(output_files)*.log"`)
	run(`sh -c "rm $(output_files)*.tex"`)
	#run(`sh -c "rm $(output_files)*.md"`)
	run(`rm $(output_files)$(output_prefix)tikz_dependency.pdf $(output_files)$(output_prefix)tree.pdf $(output_files)$(output_prefix)makie.pdf $(output_files)$(output_prefix)report.pdf $(output_files)$(output_prefix)comparison_makie.pdf $(output_files)$(output_prefix)tikz_comparison.pdf $(output_files)$(output_prefix)verbal_units_comparison.pdf $(output_files)$(output_prefix)verbal_units_graph.pdf`)

	println("================================")
	println("** Done **")
	println("Output in `$(output_files)`")
	println("================================")
end

#= 
	Get Keys: get_keys(key_dir::String)::Dict{String,String}

	Recursively look at all .cex files in key_dir, making a 
	dictionary of sentence-token-urn => filepath
=#

function get_keys(key_dir::String)::Dict{String, String}
	index = Dict{String,String}()
	for (dir, _, files) in walkdir(key_dir)	
		for f in files
			if endswith(lowercase(f), ".cex")
				urn = get_urn(joinpath(dir, f))
				if !haskey(index, urn)
					index[urn] = joinpath(dir, f)
				end
			end
		end
	end
	return index
end

#=
	get_submissions(submissions_dir::String, key_dict::Dict{String, String})::(String, String)

	Recursively searches all .cex file starting at submissions_dir,
	matches them with keys (reported by get_keys)

=#

function get_submissions(submissions_dir::String, key_dict::Dict{String, String})::Vector{Tuple{String, String}}

	file_tuples = Tuple{String, String}[]

	for (dir, _, files) in walkdir(submissions_dir)	
		for f in files
			if endswith(lowercase(f), ".cex")
				sub_urn = get_urn(joinpath(dir, f))
				if haskey(key_dict, sub_urn)
					key_file = key_dict[sub_urn] 
					sub_file = joinpath(dir, f)
					push!(file_tuples, (key_file, sub_file))
				else
					println("No key found for: $(joinpath(dir, f))")
				end
			end
		end
	end

	return file_tuples

end

# Get Keys
keyDict = get_keys(key_dir)

# Get submissions with keys: Tuple(key, submission)
subs = get_submissions(submissions_dir, keyDict)

for sub in subs 
	key_file = sub[1]
	student_file = sub[2]
	generate_reports(output_files, key_file, student_file)
end




