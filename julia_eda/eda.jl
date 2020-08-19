### A Pluto.jl notebook ###
# v0.11.7

using Markdown
using InteractiveUtils

# ╔═╡ bef1d414-e1f2-11ea-3005-7d734ef29af8
begin
	using Hamburg
	using Dates
	using DataFrames
end

# ╔═╡ d43534e2-e1f2-11ea-2b7d-654863a51ee3
begin
	using Gadfly
	Gadfly.set_default_plot_size(900px, 300px)
end

# ╔═╡ 80ca3a72-e1ec-11ea-14e0-9b6321f69aaf
md"""
# Exploring data in julia

## TL;DR

**Exploring** the data we crawled before.

Using **visualizations** and correlate to other data to gain some initial **insights**.
"""

# ╔═╡ b715770a-e1f2-11ea-296b-833ff13790b4
md"""
## Previously

Last time, we build a [webcrawler](https://medium.com/oembot/alien-facehugger-wasps-a-pandemic-webcrawlers-and-julia-c1f136925f8) that would crawl the [hamburg.de](https://www.hamburg.de/corona-zahlen/) website for the current covid-19 numbers in Hamburg.

This time we are going to dig a bit deeper into the data. We are not going to be bothered with getting the data, it will be provided already - kinda like having only dessert for dinner. Or a kaggle challenge.

For that purpose, I went ahead and wrote a [small package, Hamburg.jl](https://github.com/oem/Hamburg.jl) that provides those numbers for all recorded days, not just a current snapshot. You can easily get it: `]add https://github.com/oem/Hamburg.jl`.

Let's quickly recreate the borough plot we did last time, this time with the help of the package (there won't be much webscraping this time).
"""

# ╔═╡ cafd3f0a-e1f2-11ea-2861-fbd429841e67
md"""
We are going to use [Gadfly.jl](http://gadflyjl.org/stable/) again, the plots look great.
"""

# ╔═╡ e70f6018-e1f7-11ea-0b8f-8d48c9eaa94d
boroughs = dataset("covid-19", "boroughs")

# ╔═╡ e2e0a582-e1f2-11ea-37e2-236507742cdc
select!(boroughs, Not(:recordedat))

# ╔═╡ e664290c-e1f2-11ea-27f2-7fbc16af7f19
mat_boroughs = convert(Matrix, boroughs)

# ╔═╡ eaa31474-e1f2-11ea-1e01-a1d50df4fcec
plot(x=names(boroughs), y=mat_boroughs[end, :], Geom.bar, Theme(bar_spacing=10mm), Guide.xlabel("Boroughs"), Guide.ylabel("New infections"))

# ╔═╡ Cell order:
# ╟─80ca3a72-e1ec-11ea-14e0-9b6321f69aaf
# ╟─b715770a-e1f2-11ea-296b-833ff13790b4
# ╠═bef1d414-e1f2-11ea-3005-7d734ef29af8
# ╟─cafd3f0a-e1f2-11ea-2861-fbd429841e67
# ╠═d43534e2-e1f2-11ea-2b7d-654863a51ee3
# ╠═e70f6018-e1f7-11ea-0b8f-8d48c9eaa94d
# ╠═e2e0a582-e1f2-11ea-37e2-236507742cdc
# ╠═e664290c-e1f2-11ea-27f2-7fbc16af7f19
# ╠═eaa31474-e1f2-11ea-1e01-a1d50df4fcec
