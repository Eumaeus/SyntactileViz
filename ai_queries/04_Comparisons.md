You have been helping me with this project: <https://github.com/Eumaeus/SyntactileViz>: SyntactileViz.

It is closely associated with this one that we have worked on a lot:<https://github.com/Eumaeus/Syntactile>: Syntactile.

The goal is to analyze the syntax of Ancient Greek sentences and serialize those analyses in a way that can be usefully compared, visualized, aligned with their source texts and thus used in various ways.

The tool Syntactile exports alignment serialized as `.cex` files. The data—analyzed tokens—is linked to the words in their literary context by means of CTS-URNs.

The code for the project we're looking at now, at <https://github.com/Eumaeus/SyntactileViz>, includes a directory, `ai_queries` that contains the history of my requests for help that got the project to its present state.

All code and data is up-to-date in the repository.

The last conversation we had on this topic is here: <https://x.com/i/grok/share/ec6d4f2e6dcd429985b52b3dcc43fbeb>.

We had just fixed some bugs in the visualizations code.

I have done some refactoring of the UI for the Syntactile project, to make the workflow for graphing sentence more intuititive.

Now I am ready to come back to SyntactileViz to think about comparing graphs and reporting on the comparison.


## Comparing Graphs for Evaluation (of Student Work) and Scholarly Argument.

The last thing we talked about at <https://x.com/i/grok/share/ec6d4f2e6dcd429985b52b3dcc43fbeb> was this:

> …the ability to script out reports comparing two syntactic analyses of the same sentence. This will be useful for evaulating student work, and to focus conversation about controversial readings of difficult passages. Thucydides 1.22 comes to mind… what is he saying? And what does it mean?

For the moment, I would like to work purely in Julia, with reporting via something comparable to the `pretty_print()` function in `src/SyntaxGraph.jl`.

We can talk at a subsequent stage about visualizing comparison via Makie. And I am really looking forward to doing TikZ visualizations of graphs and comparisons, which I think will be very elegant and offer lots of scope for fine-tuning layout and typesetting.

---

Conversation at: <https://x.com/i/grok/share/4c6850b1af2341bca79369439a01ab0a>

This is great. Perfect. We don't need NP-Hard problems on our hands, and the UAS & LAS scores are exactly what I asked for, without knowing the terms-of-art. Super!

You sketches of what is needed look ideal. For reporting, I love that you proposed what I was thinking: identifying graph by editor + sentence-id. Perfect.

Currently `src/Comparison.jl` is an empty stub, so code can go there.

As always, I will need a lot of help wiring it into the SyntactileViz project.

Thanks for this! Let's go ahead and implement it!

So, for comparing two graphs, I'm not sure what graph-theorists do. I assume we can catalog edges differently labeled, and pull out sub-graphs that differ. 

Is there a standard way to assign a number to "degree of difference" between two graphs? A way to weight that according to more trivial difference (differently labeled edge) vs. more significant differences (different nodes linked with different graphs)?

I would love to see your suggestions.

I have added a directory, `/data/comparison`, that contains six CEX files. They are paired as `Comp1-` (two files), `Comp2-` (two files), and `Comp3-` (two files). Those can serve to start as example data.

Everything at this point is checked into the repository: <https://github.com/Eumaeus/SyntactileViz>

---
Conversation at: <https://x.com/i/grok/share/4c6850b1af2341bca79369439a01ab0a>

This is great. 

Perfect. We don't need NP-Hard problems on our hands, and the UAS & LAS scores are exactly what I asked for, without knowing the terms-of-art. Super!

You sketches of what is needed look ideal. For reporting, I love that you proposed what I was thinking: identifying graph by editor + sentence-id. Perfect.

Currently `src/Comparison.jl` is an empty stub, so code can go there.

As always, I will need a lot of help wiring it into the SyntactileViz project.

Thanks for this! Let's go ahead and implement it!


---

This is looking great! One error on running the script, almost certainly a matter of integration of `Comparison.jl` into `SyntactileViz.jl`:

~~~
ERROR: LoadError: UndefVarError: `parse_cex` not defined in `SyntactileViz.Comparison`
Suggestion: check for spelling errors or missing imports.
Hint: a global variable of this name also exists in SyntactileViz.CEXParser.
    - Also exported by SyntactileViz.
Stacktrace:
 [1] compare_cex_files(path1::String, path2::String)
   @ SyntactileViz.Comparison ~/Dropbox/CITE/grok/SyntactileViz/src/Comparison.jl:167
 [2] top-level scope
   @ ~/Dropbox/CITE/grok/SyntactileViz/scripts/05_Comparison.jl:11
 [3] include(mod::Module, _path::String)
   @ Base ./Base.jl:306
 [4] exec_options(opts::Base.JLOptions)
   @ Base ./client.jl:317
 [5] _start()
   @ Base ./client.jl:550
in expression starting at /Users/cblackwell/Dropbox/CITE/grok/SyntactileViz/scripts/05_Comparison.jl:11
➜  SyntactileViz git:(main) ✗ 
~~~

Updates are checked into the repository.

---

Everything runs cleanly, and the output and information look perfect.

Let's do all three of your suggestions as a next step!

---

Got it.

In the previous version of `Comparison.jl` and in this new one, there are some `@printf` calls that throw errors prefenting compilation. Earlier, I just changed those to `println` and it worked. Is `@printf` something I need to know about?

---

That worked, once I added Printf. Thanks!

I am happy using Printf.

I love this. I did a little editing in `src/Comparison.jl` to give three levels of reporting:

  `function report_comparison(comp::ComparisonResult; show_details::Bool = true, show_tree::Bool = true)`

I think these reports are ideal.

Now, what would be the best way to get these in a format I can print out and share? My instinct is always to use Markdown. That might be easiest for now.

When we turn to more elegant printable visualizations, that might be the natural point to pay more attention to typsetting reports. 

So perhaps just a provision to export a report as a Markdown file, using code-blocks to force a monospaced font, thus allowing the tree-view to line up correctly?

---

Conversation at: <https://x.com/i/grok/share/c41c9e9d6d4d446bb23d6cb853ed37ec>

Okay! I've made these changes and updated the repo. 

`export_comparison_markdown()` throws this error:

~~~
ERROR: LoadError: MethodError: no method matching (::Base.RedirectStdStream)(::IOBuffer)
The function `Base.RedirectStdStream(1, true)` exists, but no method is defined for this combination of argument types.

Closest candidates are:
  (::Base.RedirectStdStream)()
   @ Base stream.jl:1293
  (::Base.RedirectStdStream)(::Pipe)
   @ Base stream.jl:1285
  (::Base.RedirectStdStream)(::Base.DevNull)
   @ Base stream.jl:1271
  ...

Stacktrace:
  [1] (::Base.RedirectStdStream)(thunk::SyntactileViz.Comparison.var"#12#13"{SyntactileViz.SyntaxGraph.SyntaxGraph}, stream::IOBuffer)
    @ Base ./stream.jl:1462
  [2] (::SyntactileViz.Comparison.var"#10#11"{SyntactileViz.SyntaxGraph.SyntaxGraph})(s::IOBuffer)
    @ SyntactileViz.Comparison ~/Dropbox/CITE/grok/SyntactileViz/src/Comparison.jl:226
  [3] sprint(::SyntactileViz.Comparison.var"#10#11"{SyntactileViz.SyntaxGraph.SyntaxGraph}; context::Nothing, sizehint::Int64)
    @ Base ./strings/io.jl:117
  [4] sprint(::Function)
    @ Base ./strings/io.jl:110
  [5] (::SyntactileViz.Comparison.var"#8#9"{Bool, Bool, ComparisonResult, SyntactileViz.SyntaxGraph.SyntaxGraph, SyntactileViz.SyntaxGraph.SyntaxGraph})(io::IOStream)
    @ SyntactileViz.Comparison ~/Dropbox/CITE/grok/SyntactileViz/src/Comparison.jl:225
  [6] open(::SyntactileViz.Comparison.var"#8#9"{Bool, Bool, ComparisonResult, SyntactileViz.SyntaxGraph.SyntaxGraph, SyntactileViz.SyntaxGraph.SyntaxGraph}, ::String, ::Vararg{String}; kwargs::@Kwargs{})
    @ Base ./io.jl:412
  [7] open
    @ ./io.jl:409 [inlined]
  [8] #export_comparison_markdown#2
    @ ~/Dropbox/CITE/grok/SyntactileViz/src/Comparison.jl:160 [inlined]
  [9] top-level scope
    @ ~/Dropbox/CITE/grok/SyntactileViz/scripts/09_Markdown_Report.jl:16
 [10] include(mod::Module, _path::String)
    @ Base ./Base.jl:306
 [11] exec_options(opts::Base.JLOptions)
    @ Base ./client.jl:317
 [12] _start()
    @ Base ./client.jl:550
in expression starting at /Users/cblackwell/Dropbox/CITE/grok/SyntactileViz/scripts/09_Markdown_Report.jl:16
➜  SyntactileViz git:(main) ✗ 
~~~

And while we look at that, your three suggestions sound great:

- A timestamp in the Markdown header?
- A small table for the scores instead of a list?
- An option to include only the differences (no trees) for a shorter “executive summary” version?

Thank you for all this help!

---

Another error having to do with IO:

~~~
ERROR: LoadError: MethodError: no method matching (::Base.RedirectStdStream)(::IOBuffer)
The function `Base.RedirectStdStream(1, true)` exists, but no method is defined for this combination of argument types.

Closest candidates are:
  (::Base.RedirectStdStream)()
   @ Base stream.jl:1293
  (::Base.RedirectStdStream)(::Pipe)
   @ Base stream.jl:1285
  (::Base.RedirectStdStream)(::Base.DevNull)
   @ Base stream.jl:1271
  ...

Stacktrace:
  [1] capture_pretty_print(g::SyntactileViz.SyntaxGraph.SyntaxGraph; show_vu::Bool)
    @ SyntactileViz.Comparison ~/Dropbox/CITE/grok/SyntactileViz/src/Comparison.jl:95
  [2] (::SyntactileViz.Comparison.var"#5#6"{Bool, ComparisonResult, String, SyntactileViz.SyntaxGraph.SyntaxGraph, SyntactileViz.SyntaxGraph.SyntaxGraph})(io::IOStream)
    @ SyntactileViz.Comparison ~/Dropbox/CITE/grok/SyntactileViz/src/Comparison.jl:239
  [3] open(::SyntactileViz.Comparison.var"#5#6"{Bool, ComparisonResult, String, SyntactileViz.SyntaxGraph.SyntaxGraph, SyntactileViz.SyntaxGraph.SyntaxGraph}, ::String, ::Vararg{String}; kwargs::@Kwargs{})
    @ Base ./io.jl:412
  [4] open
    @ ./io.jl:409 [inlined]
  [5] export_comparison_markdown(comp::ComparisonResult, filepath::String; show_details::Bool, show_tree::Bool, executive_summary::Bool)
    @ SyntactileViz.Comparison ~/Dropbox/CITE/grok/SyntactileViz/src/Comparison.jl:176
  [6] export_comparison_markdown(comp::ComparisonResult, filepath::String)
    @ SyntactileViz.Comparison ~/Dropbox/CITE/grok/SyntactileViz/src/Comparison.jl:163
  [7] top-level scope
    @ ~/Dropbox/CITE/grok/SyntactileViz/scripts/09_Markdown_Report.jl:9
  [8] include(mod::Module, _path::String)
    @ Base ./Base.jl:306
  [9] exec_options(opts::Base.JLOptions)
    @ Base ./client.jl:317
 [10] _start()
    @ Base ./client.jl:550
in expression starting at /Users/cblackwell/Dropbox/CITE/grok/SyntactileViz/scripts/09_Markdown_Report.jl:9
➜  SyntactileViz git:(main) ✗      
~~~

---

Okay, the current code (up-to-date in the repo), compiles and runs, but never seems to exit.

It _does_ generate markdown files, but without drawing the tree.

If this helps, when I quit the Julia process, I get this error:

~~~
Stacktrace:
  [1] poptask(W::Base.IntrusiveLinkedListSynchronized{Task})
    @ Base ./task.jl:1216
  [2] wait()
    @ Base ./task.jl:1228
  [3] wait(c::Base.GenericCondition{Base.Threads.SpinLock}; first::Bool)
    @ Base ./condition.jl:141
  [4] wait
    @ ./condition.jl:136 [inlined]
  [5] wait_readnb(x::Base.PipeEndpoint, nb::Int64)
    @ Base ./stream.jl:416
  [6] read
    @ ./stream.jl:963 [inlined]
  [7] read(s::Base.PipeEndpoint, ::Type{String})
    @ Base ./io.jl:1181
  [8] capture_pretty_print(g::SyntactileViz.SyntaxGraph.SyntaxGraph; show_vu::Bool)
    @ SyntactileViz.Comparison ~/Dropbox/CITE/grok/SyntactileViz/src/Comparison.jl:97
  [9] capture_pretty_print
    @ ~/Dropbox/CITE/grok/SyntactileViz/src/Comparison.jl:90 [inlined]
 [10] (::SyntactileViz.Comparison.var"#5#6"{…})(io::IOStream)
    @ SyntactileViz.Comparison ~/Dropbox/CITE/grok/SyntactileViz/src/Comparison.jl:242
 [11] open(::SyntactileViz.Comparison.var"#5#6"{…}, ::String, ::Vararg{…}; kwargs::@Kwargs{})
    @ Base ./io.jl:412
 [12] open
    @ ./io.jl:409 [inlined]
 [13] 
    @ SyntactileViz.Comparison ~/Dropbox/CITE/grok/SyntactileViz/src/Comparison.jl:178
 [14] export_comparison_markdown(comp::ComparisonResult, filepath::String)
    @ SyntactileViz.Comparison ~/Dropbox/CITE/grok/SyntactileViz/src/Comparison.jl:165
 [15] include(mapexpr::Function, mod::Module, _path::String)
    @ Base ./Base.jl:307
in expression starting at /Users/cblackwell/Dropbox/CITE/grok/SyntactileViz/scripts/09_Markdown_Report.jl:9
~~~

---

Yes, that worked beautifully! The `.md` documents look great. I want to play with all this new code you have given me. Then I'll be back and we can talk about the next level of visualization. But for now this is a lot! Thank you!

Conversation at: <https://x.com/i/grok/share/0298d6537c704587a0eb1a4a1222c0ec>