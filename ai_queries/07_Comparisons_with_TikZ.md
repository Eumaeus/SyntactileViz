You have been helping me with this project: <https://github.com/Eumaeus/SyntactileViz>: SyntactileViz.

It is closely associated with this one that we have worked on a lot: <https://github.com/Eumaeus/Syntactile>: Syntactile.

The goal is to analyze the syntax of Ancient Greek sentences and serialize those analyses in a way that can be usefully compared, visualized, aligned with their source texts and thus used in various ways.

The tool Syntactile exports alignment serialized as `.cex` files. The data—analyzed tokens—is linked to the words in their literary context by means of CTS-URNs.

The code for the project we're looking at now, at <https://github.com/Eumaeus/SyntactileViz>, includes a directory, `ai_queries` that contains the history of my requests for help that got the project to its present state.

All code and data is up-to-date in the repository.

The last conversation we had on this topic is here:  <https://x.com/i/grok/share/d39c4bf7664642ad86c0bccf4cdc7471>.

We had just implemented Tizk Dependency and Tree graphs coming off of `src/CEXGraph.jl`, with overridable parameters for changing the appearance of individual nodes and edges.

## Comparison with Tikz

You outlined what we want to see happen… 

- Nodes and edges identical between two graphs.
- Color-coded differences.
- Data from `Comparisons.jl` (as you did for me with the Makie visualization).

For the Dependency view, the most perfect solution would be to have the arcs representing one graph's edges arcing above the sentence, and those for the other graph arcing below. Still with color-coding, above and below, to highlight differences.

I imagine that the "tree" view would follow what we did with Makie, but I am completely open to other approaches.

---

This looks great… thanks!

Before I start editing, we do have a file `src/TikzExport.jl` for all other TikZ-related functions. I want to make sure it would not be better to add this new TikZ stuff there?

But I am _not_ well-informed at the complexities of Julia modules!

---

Great! Okay… let me get all this into place!

Conversation at: <https://x.com/i/grok/share/c1d4698239ec47868bfa8a60104387b1>

---

Okay. All new changes are checked into the repo: <https://github.com/Eumaeus/SyntactileViz>.

As seems always to be the case when I add functions in Julia, I'm getting integration errors.

I've edited `scripts/12_TikZ_Comparison.jl` as a test script.

The error I get is:

~~~

 SyntactileViz git:(main) ✗ julia --project=. scripts/12_TikZ_Comparison.jl
Precompiling SyntactileViz finished.
  1 dependency successfully precompiled in 5 seconds. 294 already precompiled.
ERROR: LoadError: UndefVarError: `tikz_dual_dependency_comparison` not defined in `SyntactileViz.Comparison`
Suggestion: check for spelling errors or missing imports.
Hint: a global variable of this name also exists in SyntactileViz.TikzExport.
    - Also exported by SyntactileViz.
Stacktrace:
 [1] tikz_dependency_comparison(comp::ComparisonResult; kwargs::@Kwargs{})
   @ SyntactileViz.Comparison ~/Dropbox/CITE/grok/SyntactileViz/src/Comparison.jl:330
 [2] tikz_dependency_comparison(comp::ComparisonResult)
   @ SyntactileViz.Comparison ~/Dropbox/CITE/grok/SyntactileViz/src/Comparison.jl:329
 [3] top-level scope
   @ ~/Dropbox/CITE/grok/SyntactileViz/scripts/12_TikZ_Comparison.jl:16
 [4] include(mod::Module, _path::String)
   @ Base ./Base.jl:306
 [5] exec_options(opts::Base.JLOptions)
   @ Base ./client.jl:317
 [6] _start()
   @ Base ./client.jl:550
in expression starting at /Users/cblackwell/Dropbox/CITE/grok/SyntactileViz/scripts/12_TikZ_Comparison.jl:16
➜  SyntactileViz git:(main) ✗ 

~~~


---

Progress!!!

The change you suggested, and changing the order of `import`s in SyntactileViz.jl to put TikzExport.jl _before_ Comparison.jl, got it to compile.

I'm now getting the following error:

~~~

SyntactileViz git:(main) ✗ julia --project=. scripts/12_TikZ_Comparison.jl
Precompiling SyntactileViz finished.
  1 dependency successfully precompiled in 5 seconds. 294 already precompiled.
ERROR: LoadError: TypeError: in keyword argument head_diff, expected Set{String}, got a value of type Set{Tuple{String, String, String}}
Stacktrace:
 [1] tikz_dependency_comparison(comp::ComparisonResult; kwargs::@Kwargs{})
   @ SyntactileViz.Comparison ~/Dropbox/CITE/grok/SyntactileViz/src/Comparison.jl:333
 [2] tikz_dependency_comparison(comp::ComparisonResult)
   @ SyntactileViz.Comparison ~/Dropbox/CITE/grok/SyntactileViz/src/Comparison.jl:332
 [3] top-level scope
   @ ~/Dropbox/CITE/grok/SyntactileViz/scripts/12_TikZ_Comparison.jl:16
 [4] include(mod::Module, _path::String)
   @ Base ./Base.jl:306
 [5] exec_options(opts::Base.JLOptions)
   @ Base ./client.jl:317
 [6] _start()
   @ Base ./client.jl:550
in expression starting at /Users/cblackwell/Dropbox/CITE/grok/SyntactileViz/scripts/12_TikZ_Comparison.jl:16
➜  SyntactileViz git:(main) ✗ 

~~~

Conversation at: <https://x.com/i/grok/share/1f551398d8484ebb900da71644ee5115>

---

Success! I was able to generate a `.tex` file, which looks good. I used the current version of `scripts/12_TikZ_Comparison.jl`.

In `src/TikzExport.jl`, the function `save_tikz_dependency()` takes advantage of the constant `default_preamble` at the front of the `.tex` file.

~~~

function save_tikz_dependency(g::SyntaxGraph.SyntaxGraph, path::String; 
                              preamble::String = default_preamble,
                              use_adjustbox::Bool = true,
                              adjustbox_options::String = "max width=\\textwidth",
                              # NEW
                              edge_overrides::Dict{Tuple{String,String}, String} = Dict{Tuple{String,String}, String}())

~~~

It also concludes the generated `.tex` file with closing code:

~~~
   full = """
    $preamble

    \\begin{document}
    \\begin{figure}[ht]
    \\centering
    $content
    \\caption{$(g.editor) — $(g.sentence_text)}
    \\end{figure}
    \\end{document}
    """
    write(path, full)
    return path
~~~

And in the TikZ Dependency files from a single analysis, the edge-labels are nicely at the apex of each arc, thus staying out of each others' way. In the dual-comparison ones, they are all on the same vertical level and collide.

I wasn't able to locate where in the older code we set those for the single-analysis graphs. Maybe that is the default, that we are overriding for the dual-comparison?

Thanks for your ongoing help with this!

---

Conversation at: <https://x.com/i/grok/share/25fe6f4e78ea4a3488471dda1cc21560>

This is looking really good. The customization of edge-labels, proportionate to edge-length, works well!

I am not seeing color-coding on edges that differ from one analysis to the other.

I am testing with `scripts/12_TikZ_Comparison.jl`, which loads two syntax-graphs that I made to be significantly different. Our Makie visualization works well, and the reporting from `Comparisons.jl` gives an evaluation of:

~~~
UAS (Unlabeled Attachment Score) :   80.0%
LAS (Labeled Attachment Score)   :   66.7%
~~~

The TikZ Dependency graph looks great, but isn't showing the differences.

All code, and the example script, and its output, are checked into the repository: <https://github.com/Eumaeus/SyntactileViz>.

---

Thanks for this!

I would love a bug-fix that does what you offer!

> Would you like me to give you a cleaned-up version of tikz_dual_dependency_comparison that:
> - Fixes the label-side logic for diff arcs
> - Makes the function a bit more robust
> - Adds a proper save_tikz_dual_dependency_comparison(comp, path) that works nicely with ComparisonResult

I have updated—and checked into the repo—the file `scripts/12_TikZ_Comparison.jl`. The code runs without error.

But the helper-function `tikz_dependency_comparison()` doesn't have provision for saving the output, as `TikzExport.save_tikz_dual_dependency_comparison()` does. Or am I missing something?

---

Okay, those changes are checked into the repository.

I think the convenience wrappers are getting confused. In `Tikzeport.jl` we have `tikz_dual_dependency_comparison()`. In `Comparison.jl` we have `tikz_dependency_comparison()`. 

Perhaps we don't need the one in `Comparison.jl`, since we have everything we need in `TikzExport.jl`?

When I run the script `scripts/12_TikZ_Comparison.jl` (checked into the repo), I get the following error:

~~~

SyntactileViz git:(main) ✗ julia --project=. scripts/12_TikZ_Comparison.jl
Info Given SyntactileViz was explicitly requested, output will be shown live 
ERROR: LoadError: UndefVarError: `ComparisonResult` not defined in `SyntactileViz.TikzExport`
Suggestion: check for spelling errors or missing imports.
Stacktrace:
  [1] top-level scope
    @ ~/Dropbox/CITE/grok/SyntactileViz/src/TikzExport.jl:391
  [2] include(mapexpr::Function, mod::Module, _path::String)
    @ Base ./Base.jl:307
  [3] top-level scope
    @ ~/Dropbox/CITE/grok/SyntactileViz/src/SyntactileViz.jl:6
  [4] include(mod::Module, _path::String)
    @ Base ./Base.jl:306
  [5] include_package_for_output(pkg::Base.PkgId, input::String, depot_path::Vector{String}, dl_load_path::Vector{String}, load_path::Vector{String}, concrete_deps::Vector{Pair{Base.PkgId, UInt128}}, source::Nothing)
    @ Base ./loading.jl:3028
  [6] top-level scope
    @ stdin:5
  [7] eval(m::Module, e::Any)
    @ Core ./boot.jl:489
  [8] include_string(mapexpr::typeof(identity), mod::Module, code::String, filename::String)
    @ Base ./loading.jl:2874
  [9] include_string
    @ ./loading.jl:2884 [inlined]
 [10] exec_options(opts::Base.JLOptions)
    @ Base ./client.jl:315
 [11] _start()
    @ Base ./client.jl:550
in expression starting at /Users/cblackwell/Dropbox/CITE/grok/SyntactileViz/src/TikzExport.jl:1
in expression starting at /Users/cblackwell/Dropbox/CITE/grok/SyntactileViz/src/SyntactileViz.jl:1
in expression starting at stdin:5
  ✗ SyntactileViz
Precompiling SyntactileViz finished.
  0 dependencies successfully precompiled in 4 seconds. 294 already precompiled.

ERROR: LoadError: The following 1 direct dependency failed to precompile:

SyntactileViz 

Failed to precompile SyntactileViz [7a31ebc7-e5f0-4d97-940e-aa3fdd0bc38d] to "/Users/cblackwell/.julia/compiled/v1.12/SyntactileViz/jl_fcnblg".
ERROR: LoadError: UndefVarError: `ComparisonResult` not defined in `SyntactileViz.TikzExport`
Suggestion: check for spelling errors or missing imports.
Stacktrace:
  [1] top-level scope
    @ ~/Dropbox/CITE/grok/SyntactileViz/src/TikzExport.jl:391
  [2] include(mapexpr::Function, mod::Module, _path::String)
    @ Base ./Base.jl:307
  [3] top-level scope
    @ ~/Dropbox/CITE/grok/SyntactileViz/src/SyntactileViz.jl:6
  [4] include(mod::Module, _path::String)
    @ Base ./Base.jl:306
  [5] include_package_for_output(pkg::Base.PkgId, input::String, depot_path::Vector{String}, dl_load_path::Vector{String}, load_path::Vector{String}, concrete_deps::Vector{Pair{Base.PkgId, UInt128}}, source::Nothing)
    @ Base ./loading.jl:3028
  [6] top-level scope
    @ stdin:5
  [7] eval(m::Module, e::Any)
    @ Core ./boot.jl:489
  [8] include_string(mapexpr::typeof(identity), mod::Module, code::String, filename::String)
    @ Base ./loading.jl:2874
  [9] include_string
    @ ./loading.jl:2884 [inlined]
 [10] exec_options(opts::Base.JLOptions)
    @ Base ./client.jl:315
 [11] _start()
    @ Base ./client.jl:550
in expression starting at /Users/cblackwell/Dropbox/CITE/grok/SyntactileViz/src/TikzExport.jl:1
in expression starting at /Users/cblackwell/Dropbox/CITE/grok/SyntactileViz/src/SyntactileViz.jl:1
in expression starting at stdin:
in expression starting at /Users/cblackwell/Dropbox/CITE/grok/SyntactileViz/scripts/12_TikZ_Comparison.jl:2
➜  SyntactileViz git:(main) 

~~~




