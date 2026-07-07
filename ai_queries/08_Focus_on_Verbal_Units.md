You have been helping me with this project: <https://github.com/Eumaeus/SyntactileViz>: SyntactileViz.

It is closely associated with this one that we have worked on a lot: <https://github.com/Eumaeus/Syntactile>: Syntactile.

The goal is to analyze the syntax of Ancient Greek sentences and serialize those analyses in a way that can be usefully compared, visualized, aligned with their source texts and thus used in various ways.

The tool Syntactile exports alignment serialized as `.cex` files. The data—analyzed tokens—is linked to the words in their literary context by means of CTS-URNs.

The code for the project we're looking at now, at <https://github.com/Eumaeus/SyntactileViz>, includes a directory, `ai_queries` that contains the history of my requests for help that got the project to its present state.

All code and data is up-to-date in the repository.

The last conversation we had on this topic is here: <https://x.com/i/grok/share/50973a1b489149208ec46bcfae66547c>.

We had just implemented visualizations of graph-comparison with Tizk Dependency. The process was somewhat laborious, as we dealt with Julia's module- and include-management.

For the next step, I would like to begin with a comprehensive review of the code in `Cpmparison.jl`, `Visualization.jl`, and `TikzExport.jl`. Last time, there was a lot of moving functions back and forth among libraries. I think we probably should add new code, which I will describe below, to `Comparison.jl`, but I am certainly open to better ideas.

## Comparison Focused on Verbal Units

This should be easier than previous ones. I would like a nice TeX-based visualization of a comparison of verbal-units across two analyses serialized as CEX files.

First, I would like more information on "verbal-unit-diff" in `ComparisonResult`, which is in `Comparisons.jl`. Currently it reports how many verbal units are in each of the two CEX files compared. I would like to see more about:

- Which tokens are assigned to which verbal units.
- The assignment of `level`, `semantic type` and `syntactic type` to each verbal unit.

We can't rely on the verbal unit's ID, though, because students can create them in any order. I was hoping you would have good thoughts on this kind of comparison.

Second, I would like a visualization to go with the markdown-report. Ideally using TikZ, with colors to show how the two analyses define and assign tokens to verbal units, along with some key to `level`, `semantic type` and `syntactic type`.

The trick with colors will be to distinguish adjacent verbal-units, as well as containing and contained verbal units. Again, it seems that other projects must do this all the time, but I have not ever tried.