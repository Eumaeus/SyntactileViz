using Revise
using SyntactileViz
using Makie

Revise.revise()


unit = "iliad"

output_files = "reports/grading/reports/$(unit)/"
submissions_dir = "reports/grading/submissions/$(unit)/"


#student_file = "reports/grading/submissions/$(unit)/hq_10_01_diffs.cex"
#key_file = "reports/grading/keys/$(unit)/hq_01_01.cex"

#=

1. Get dictionary of key-file-path, urn.
2. Read files in Submissions-directory, making tuple of key-file + submission-file.
3. Generate reports.

=#

function generate_reports(output_files::String, student_file::String)

	println("=========================")
	println("Initialization ")
	println("=========================")

	# Ensure that the directories exist
	run(`mkdir -p output_files`)
	run(`mkdir -p submissions_dir`)

	output_filename =  replace(split(student_file,'/')[end], ".cex" => "")

	# Get Editor name from student_file CEX
	println("-------\nFilename: $output_filename\n--------")
	editor_name = get_editor(student_file)
	println("-------\nEditor: $(editor_name)\n-------")
	output_prefix = "$(editor_name)_$(output_filename)"

	# ... load or build g1 and g2 ...-


	# Set a font with good Greek support (Noto Sans usually works well)
	Makie.set_theme!(fonts = (regular = "DejaVu Sans", bold = "DejaVu Sans Bold"))


	println("==============================")
	println("Loading Graphs ")
	println("==============================")

	keyAnalysis = parse_cex(student_file)
	submissionGraph = build_syntax_graph(keyAnalysis)


	println("Generating Stress Visualization…")

	# Graph with Stress
	save_syntax_tree(submissionGraph, "$(output_files)$(output_prefix)makie.pdf")


	println("Generating Verbal Units Visualization")

	save_tikz_verbal_unit_linear(submissionGraph, "$(output_files)$(output_prefix)verbal_units_graph.tex")

	println("Generating Dependency Graph…")

	save_tikz_dependency(submissionGraph, "$(output_files)$(output_prefix)tikz_dependency.tex")

	println("Generating Tree Graph…")

	# save_tikz_tree(submissionGraph, "$(output_files)$(output_prefix)tree.tex")


	# CLI Stuff: Make PDFs

	println("Processing PDFs…")

	# run(`xelatex -interaction=batchmode -output-directory $(output_files) $(output_prefix)tree.tex`)

	run(`xelatex -interaction=batchmode -output-directory $(output_files) $(output_prefix)tikz_dependency.tex`)

	run(`xelatex -interaction=batchmode -output-directory $(output_files) $(output_prefix)verbal_units_graph.tex`)

	run(`pdfunite $(output_files)$(output_prefix)tikz_dependency.pdf $(output_files)$(output_prefix)verbal_units_graph.pdf $(output_files)$(output_prefix)makie.pdf $(output_files)$(output_prefix)combined_report.pdf`)


	println("Cleaning Up…")

	# Clean Up
	run(`sh -c "rm $(output_files)*.aux"`)
	run(`sh -c "rm $(output_files)*.log"`)
	run(`sh -c "rm $(output_files)*.tex"`)
	#run(`sh -c "rm $(output_files)*.md"`)
	run(`rm $(output_files)$(output_prefix)tikz_dependency.pdf $(output_files)$(output_prefix)verbal_units_graph.pdf $(output_files)$(output_prefix)makie.pdf`)

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

function get_submissions(submissions_dir::String)::Vector{String}

	file_vec = String[]

	for (dir, _, files) in walkdir(submissions_dir)	
		for f in files
			if endswith(lowercase(f), ".cex")
				sub_file = joinpath(dir, f)
				push!(file_vec, sub_file)
			end
		end
	end

	return file_vec

end


# Get submissions with keys: Tuple(key, submission)
subs = get_submissions(submissions_dir)

for sub in subs 
	student_file = sub
	generate_reports(output_files, student_file)
end




