### A Pluto.jl notebook ###
# v1.0.1

using Markdown
using InteractiveUtils

# ╔═╡ 498716bc-c93e-4e1c-bec9-697adf274508
begin
	using Pkg
	Pkg.activate(".")

	include("CEXParser.jl")
	using .CEXParser
end

# ╔═╡ 6cf3a8fa-bf63-4336-85ad-3d7d09062ab5
analysis = parse_cex("../data/samples/analysis-iliad.cex")

# ╔═╡ Cell order:
# ╠═498716bc-c93e-4e1c-bec9-697adf274508
# ╠═6cf3a8fa-bf63-4336-85ad-3d7d09062ab5
