You have been helping me with this project: <https://github.com/Eumaeus/SyntactileViz>: SyntactileViz.

It is closely associated with this one that we have worked on a lot: <https://github.com/Eumaeus/Syntactile>: Syntactile.

The goal is to analyze the syntax of Ancient Greek sentences and serialize those analyses in a way that can be usefully compared, visualized, aligned with their source texts and thus used in various ways.

The tool Syntactile exports alignment serialized as `.cex` files. The data—analyzed tokens—is linked to the words in their literary context by means of CTS-URNs.

The code for the project we're looking at now, at <https://github.com/Eumaeus/SyntactileViz>, includes a directory, `ai_queries` that contains the history of my requests for help that got the project to its present state.

All code and data is up-to-date in the repository.

The last conversation we had on this topic is here:  <https://x.com/i/grok/share/d5cdc3aac37748a99438c5d0f36763ca>.

You had just helped me implement side-by-side visualizations of graphs, with color-coding showing differences. The results look great!

## TikZ

We should start, as we did with Makie, on visualizations of individual graphs, and then move on to comparison. XeLaTeX / LuaLaTeX work well for polytonic Greek, and I would like the ability to use the fonts I have locally (some of them very nice professional ones that I've purchased over the years).

Of the options you gave me, I think generating TikZ code straight from our Julia scripts sounds most straightforward.

Years ago, I experimented with LaTeX visualizations of graphs. I did not get very far, but I did find this style, using the TikZ-Dependency package (<https://ctan.org/pkg/tikz-dependency?lang=en>) to be compelling. Some examples:

~~~tex

\begin{figure}[ht]
  \centering
\begin{dependency}[theme = simple]
   \begin{deptext}[column sep=1em]
      Panda \& eats \& shoots \& and \& leaves  \\
   \end{deptext}
   \deproot{2}{PRED}
   \depedge{2}{1}{SUBJ}
   \depedge[edge start x offset=2pt]{2}{4}{COORD}
   \depedge{4}{3}{OBJ-CO}
   \depedge[edge start x offset=-3pt]{4}{5}{OBJ-CO}
\end{dependency}
\label{fig:PandaDiet}
\caption{The Panda's Diet: the same tokens, different analysis}
\end{figure}

\begin{figure}[ht]
  \centering
\begin{dependency}[theme = simple]
   \begin{deptext}[column sep=1em]
      Panda \& eats \& shoots \& and \& leaves  \\
   \end{deptext}
   \deproot{4}{COORD}
   \depedge[edge start x offset=-3pt]{4}{2}{PRED-CO}
   \depedge[edge start x offset=-1pt]{4}{1}{SUBJ}
   \depedge[edge start x offset=-4pt]{4}{3}{PRED-CO}
   \depedge[edge start x offset=1pt]{4}{5}{PRED-CO}
\end{dependency}
\label{fig:PandaCrime}
\caption{A Panda Crime Spree}
\end{figure}


\begin{figure}
  \centering
\begin{dependency}[theme = simple]
   \begin{deptext}[column sep=1em]
      A \& hearing \& is \& scheduled \& on \& the \& issue \& today \& . \\
   \end{deptext}
   \deproot{3}{ROOT}
   \depedge{2}{1}{ATT}
   \depedge[edge start x offset=-6pt]{2}{5}{ATT}
   \depedge{3}{2}{SBJ}
   \depedge{3}{9}{PU}
   \depedge{3}{4}{VC}
   \depedge{4}{8}{TMP}
   \depedge{5}{7}{PC}
   \depedge[arc angle=50]{7}{6}{ATT}
\end{dependency}
\label{fig:DependencyTree}
\end{figure}

~~~

But I am open to anything that can get the job done, and I will certainly heed your advice!

---

Conversation at: <https://x.com/i/grok/share/cf376630121a404eba8439162ec8f981>

Thank you! This is exciting.

All updates are in the repository, <https://github.com/Eumaeus/SyntactileViz>.

I made the changes, and added an `include` and `export` line to `SyntactileViz.jl`. I ran the following to test it initially:

`julia --project=. -e 'using SyntactileViz; println("Loaded successfully")'`

This is the error:

~~~

 SyntactileViz git:(main) ✗ julia --project=. -e 'using SyntactileViz; println("Loaded successfully")'
Info Given SyntactileViz was explicitly requested, output will be shown live 
ERROR: LoadError: FieldError: type DataType has no field `SyntaxGraph`, available fields: `name`, `super`, `parameters`, `types`, `instance`, `layout`, `hash`, `flags`
Stacktrace:
  [1] getproperty(x::Type, f::Symbol)
    @ Base ./Base_compiler.jl:48
  [2] top-level scope
    @ ~/Dropbox/CITE/grok/SyntactileViz/src/TikzExport.jl:7
  [3] include(mapexpr::Function, mod::Module, _path::String)
    @ Base ./Base.jl:307
  [4] top-level scope
    @ ~/Dropbox/CITE/grok/SyntactileViz/src/SyntactileViz.jl:7
  [5] include(mod::Module, _path::String)
    @ Base ./Base.jl:306
  [6] include_package_for_output(pkg::Base.PkgId, input::String, depot_path::Vector{String}, dl_load_path::Vector{String}, load_path::Vector{String}, concrete_deps::Vector{Pair{Base.PkgId, UInt128}}, source::Nothing)
    @ Base ./loading.jl:3028
  [7] top-level scope
    @ stdin:5
  [8] eval(m::Module, e::Any)
    @ Core ./boot.jl:489
  [9] include_string(mapexpr::typeof(identity), mod::Module, code::String, filename::String)
    @ Base ./loading.jl:2874
 [10] include_string
    @ ./loading.jl:2884 [inlined]
 [11] exec_options(opts::Base.JLOptions)
    @ Base ./client.jl:315
 [12] _start()
    @ Base ./client.jl:550
in expression starting at /Users/cblackwell/Dropbox/CITE/grok/SyntactileViz/src/TikzExport.jl:1
in expression starting at /Users/cblackwell/Dropbox/CITE/grok/SyntactileViz/src/SyntactileViz.jl:1
in expression starting at stdin:5
  ✗ SyntactileViz
Precompiling SyntactileViz finished.
  0 dependencies successfully precompiled in 7 seconds. 294 already precompiled.

ERROR: The following 1 direct dependency failed to precompile:

SyntactileViz 

Failed to precompile SyntactileViz [7a31ebc7-e5f0-4d97-940e-aa3fdd0bc38d] to "/Users/cblackwell/.julia/compiled/v1.12/SyntactileViz/jl_qJ0w4W".
ERROR: LoadError: FieldError: type DataType has no field `SyntaxGraph`, available fields: `name`, `super`, `parameters`, `types`, `instance`, `layout`, `hash`, `flags`
Stacktrace:
  [1] getproperty(x::Type, f::Symbol)
    @ Base ./Base_compiler.jl:48
  [2] top-level scope
    @ ~/Dropbox/CITE/grok/SyntactileViz/src/TikzExport.jl:7
  [3] include(mapexpr::Function, mod::Module, _path::String)
    @ Base ./Base.jl:307
  [4] top-level scope
    @ ~/Dropbox/CITE/grok/SyntactileViz/src/SyntactileViz.jl:7
  [5] include(mod::Module, _path::String)
    @ Base ./Base.jl:306
  [6] include_package_for_output(pkg::Base.PkgId, input::String, depot_path::Vector{String}, dl_load_path::Vector{String}, load_path::Vector{String}, concrete_deps::Vector{Pair{Base.PkgId, UInt128}}, source::Nothing)
    @ Base ./loading.jl:3028
  [7] top-level scope
    @ stdin:5
  [8] eval(m::Module, e::Any)
    @ Core ./boot.jl:489
  [9] include_string(mapexpr::typeof(identity), mod::Module, code::String, filename::String)
    @ Base ./loading.jl:2874
 [10] include_string
    @ ./loading.jl:2884 [inlined]
 [11] exec_options(opts::Base.JLOptions)
    @ Base ./client.jl:315
 [12] _start()
    @ Base ./client.jl:550
in expression starting at /Users/cblackwell/Dropbox/CITE/grok/SyntactileViz/src/TikzExport.jl:1
in expression starting at /Users/cblackwell/Dropbox/CITE/grok/SyntactileViz/src/SyntactileViz.jl:1
in expression starting at stdin:
➜  SyntactileViz git:(main) ✗ 

~~~


And I should have mentoned earlier that an option for a more traditional tree-graph would also be nice to have. It looks like your code allows this with the `theme` parameter on `tikz_dependency_code()`. Something similar to what we're creating with Makie.

---

Conversation at: <https://x.com/i/grok/share/e6e78b8a1a49455cbc8a248b3295de12>

That compiled! Thanks! I'll make a test-script to see what we get!

And I would love a second function, perhaps the pure TikZ hierarchical version you mentioned? 


---

Nice!!!

The code compiles, and my little test-script at `scripts/11_TikZ.jl` produced two `.tex` files, one a "dependency" and one a "tree":

- `reports/tex/hq4_1_dependency.tex`
- `reports/tex/hq4_1_tree.tex`

All these changes are in the repository.

The "dependency" file compiled perfectly with `xelatex` to a PDF, but we'll need to make some adjustment for the fact that the graph is (inevitably) going to exceed the width of the page. I would welcome advice on how to set up the TeX parameters to make sure that the whole graph fits. Whatever you think will work!

The "tree" file did not compile with `xelatex`. It threw a bunch of errors like:

~~~


! Package PGF Math Error: Unknown function `cts' (in 'cts:fuTeaching:blackwell.
hq.2026:4.1.token.10').

See the PGF Math package documentation for explanation.
Type  H <return>  for immediate help.
 ...                                              
                                                  
l.42 ...fuTeaching:blackwell.hq.2026:4.1.token.10)

~~~

It doesn't like 

    \draw[->, thick, >=stealth] (n_root) -- node[midway, above, font=\tiny, red!70!black] {Unit Verb} (n_urn:cts:fuTeaching:blackwell.hq.2026:4.1.token.10);

or any of the other lines like that.

And if I am reading this correct, is this script usign the node-id (the CTS-URN) instead of the node-text in the graph? Or am I mistaken (quite likely).

Everything, including the `.tex` output, is checked into the repo.