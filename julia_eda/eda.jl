### A Pluto.jl notebook ###
# v0.11.7

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ bef1d414-e1f2-11ea-3005-7d734ef29af8
begin
	using Pkg
	Pkg.activate(".")
end

# ╔═╡ 9fa3d164-e24b-11ea-27c4-f579ca84aac3
using Hamburg

# ╔═╡ 9a588752-e24b-11ea-02a3-ad978111b579
using Dates

# ╔═╡ 966af7ba-e24b-11ea-333a-eb8734613400
using DataFrames

# ╔═╡ b7149c2e-e3b7-11ea-387a-9966e5cd6e6a
using Gadfly

# ╔═╡ 0b899ce4-e2bb-11ea-1a85-7bee36ef0213
using PlutoUI

# ╔═╡ 295ffb50-e207-11ea-3095-550122a52bcf
using TimeSeries

# ╔═╡ 1514be60-e207-11ea-279a-9d0c777dc591
using Statistics

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

For that purpose, I went ahead and wrote a [small package, Hamburg.jl](https://github.com/oem/Hamburg.jl) that provides those numbers for all recorded days, not just a current snapshot. You can easily get it:

`]add https://github.com/oem/Hamburg.jl`.

Let's quickly recreate the borough plot we did last time, this time with the help of the package (there won't be much webscraping this time).
"""

# ╔═╡ cafd3f0a-e1f2-11ea-2861-fbd429841e67
md"""
We are going to use [Gadfly.jl](http://gadflyjl.org/stable/) again, the plots look great.
"""

# ╔═╡ f64848a0-e76d-11ea-1990-8f4b804f1e9b
Gadfly.set_default_plot_size(680px, 300px)

# ╔═╡ e70f6018-e1f7-11ea-0b8f-8d48c9eaa94d
boroughsovertime = dataset("covid-19", "boroughs")

# ╔═╡ e2e0a582-e1f2-11ea-37e2-236507742cdc
boroughs = select(boroughsovertime, Not(:recordedat))

# ╔═╡ e664290c-e1f2-11ea-27f2-7fbc16af7f19
mat_boroughs = convert(Matrix, boroughs)

# ╔═╡ c3adcd30-e249-11ea-0c86-03094a96cb2f
DataFrames.rename!(boroughs, "Hamburg Mitte" => "Mitte")

# ╔═╡ eaa31474-e1f2-11ea-1e01-a1d50df4fcec
plot(x=names(boroughs), y=mat_boroughs[1, :], Geom.bar, Theme(bar_spacing=10mm), Guide.xlabel("Boroughs"), Guide.ylabel("New infections"))

# ╔═╡ 762f1336-e206-11ea-3766-fd9b1a991e99
md"""
The first dataset shows the infections per borough, aggregated for 14 days. The aggregation happens to protect the privacy of the infected people.

Ok, let's see what else we can find out from our data.
"""

# ╔═╡ 7c0246ac-e206-11ea-3f18-c5e9ccf73a93
md"""
## I have questions

Just diving into the data and start exploring a new dataset can be a lot of fun! 

Maybe you already have questions that can guide you in your exploration, or you have set yourself a concrete goal like, **"prove this and that"**, **"show the relationship between..."**, or **"create a report for monthly traffic of the website"**. Great, then you have your work cut out for you (though it might not be as much fun as freestyle exploration of a new dataset).

Sometimes though, we don't know yet exactly what questions we want to even ask. Where to start then?

Well, one thing we can explore already, is the structure of the data. In this case, we have the development of the covid-19 pandemic as datapoints over time, which opens up some interesting questions.
"""

# ╔═╡ 85b11818-e206-11ea-1731-61cdec0e3470
md"""
### How are we doing?
"""

# ╔═╡ d536b636-e24c-11ea-2710-c3a5c7e2f267
md"""
#### Boroughs over time
"""

# ╔═╡ 8edd85c0-e206-11ea-36d7-9fb3ce92eb67
function borough_plot(labels, values, theme)
    layer(x=labels, 
        y=values,
        Geom.bar,
        theme)
end

# ╔═╡ 9879e5ba-e206-11ea-198c-c93264c4720b
begin
	l1 = borough_plot(names(boroughs), mat_boroughs[1, :], Theme(default_color="#ffcf33", bar_spacing=7mm))
	l2 = borough_plot(names(boroughs), mat_boroughs[2, :], Theme(default_color="orange", bar_spacing=7mm))
	l3 = borough_plot(names(boroughs), mat_boroughs[3, :], Theme(default_color="red", bar_spacing=7mm))
	l4 = borough_plot(names(boroughs), mat_boroughs[end, :], Theme(default_color="purple", bar_spacing=7mm))

	plot(l4, l3, l2, l1,
		Guide.xlabel("Boroughs"),
		Guide.ylabel("New Infections"),
		Guide.title("New infections in the last 14 days"),
		Guide.manual_color_key("Time",["Now - 14 days ago", "7 - 21 days ago", "14 - 28 days ago", "21 - 35 days ago"],["#ffcf33", "orange","red", "purple"]))
end

# ╔═╡ f5e067f6-e24c-11ea-3c3c-bf88fd1de331
md"""
#### Boroughs over time 2
"""

# ╔═╡ 5431e8f0-e76a-11ea-25f3-9590a086efd5
begin
	Gadfly.set_default_plot_size(680px, 1200px)
	plots = map(eachcol(boroughs)) do c
		plot(x=boroughsovertime.recordedat, 
			y=c,
			Geom.line,
			Coord.cartesian(xmin=Date(2020, 7, 22), ymax=180),
			Theme(bar_spacing=7mm))	
	end
	vstack(plots)
end

# ╔═╡ 0eb86234-e774-11ea-2cd0-0153ffd75aef
names(boroughs)

# ╔═╡ 4ed9b764-e76f-11ea-3da0-3d9bc46cec0f
Gadfly.set_default_plot_size(680px, 300px)

# ╔═╡ ba20f85c-e24c-11ea-3067-5fe2d57baf52
md"""
#### Boroughs over time 3
"""

# ╔═╡ 0a4c3ee8-e2bd-11ea-0ad0-1de3e6d82689
md"""
##### Choice! 

You can select the time window via the slider:

$(@bind i Slider(1:size(boroughs)[1]))
"""

# ╔═╡ eb66364a-e2bd-11ea-0157-9f55a8e415a6
begin
	layers = []
	push!(layers, borough_plot(names(boroughs), mat_boroughs[i, :], Theme(bar_spacing=7mm)))
	
	p = plot(layers...,
		Coord.cartesian(ymax=200),
		Guide.xlabel("Boroughs"),
		Guide.ylabel("New Infections"),
		Guide.title(string(boroughsovertime[i, :].recordedat)))
	# draw(SVG("plot.svg", 15cm, 10cm), p)
	p
end

# ╔═╡ e7041002-e206-11ea-3899-6b3a3cfe771f
df = dataset("covid-19", "infected")

# ╔═╡ e9b1f99c-e206-11ea-38da-ed8fccafdc2f
first(df, 10)

# ╔═╡ f8ce9a98-e206-11ea-31d6-0770158808a8
function plotnewcases(df)
    layer(df, y=:new,x=:recordedat, Geom.bar)
end

# ╔═╡ f9ac39c8-e206-11ea-0fbc-1b9ca1de4635
plot(plotnewcases(df),
    Coord.cartesian(xmin=Date(2020, 3,1), ymin=0),
    Guide.title("Confirmed new COVID-19 cases in Hamburg, Germany"), 
    Guide.xlabel("date"), 
    Guide.ylabel("new cases"))

# ╔═╡ 02d4ed92-e207-11ea-3e00-0765c2b58271
plot(plotnewcases(df[1:30, :]),
    Coord.cartesian(xmin=Date(2020, 7,1)),
    Guide.title("Confirmed new COVID-19 cases in Hamburg, Germany"), 
    Guide.xlabel("date"), 
    Guide.ylabel("new cases"))

# ╔═╡ 1f665d78-e208-11ea-269e-839f5f57f051
md"""
#### Weekly trends

We can calculate the weekly mean to avoid the distraction of daily fluctuations and to get a better feeling for the general trend.

Some of those fluctuations aren't even created by antything to do with the **corona virus** but rather with human bureaucracy. There is less cases processed on the weekend, for example, but that doesn't mean that the virus likes to chill over the weekend.
"""

# ╔═╡ d73763b0-e207-11ea-1892-cf261fa3e3fb
ta = TimeArray(df.recordedat, convert.(Float64, df.new), [:new])

# ╔═╡ ea2fb83e-e207-11ea-0129-67e41b8501cc
collapsed = collapse(ta, week, last, mean)

# ╔═╡ 15bf4900-e207-11ea-2a23-7314baaf6a5a
begin
	dfa = DataFrame(collapsed)[end-5:end, :]

	avg = layer(x=dfa.timestamp, y=dfa.new, Geom.line, Theme(default_color="red"))
	plot(avg, plotnewcases(df[1:30, :]),
		Coord.cartesian(xmin=Date(2020, 7,1)),
		Guide.title("Confirmed new COVID-19 cases in Hamburg, Germany"), 
		Guide.xlabel("date"), 
		Guide.ylabel("new cases"))
end

# ╔═╡ 726da05c-e222-11ea-0572-9113873f3c74
md"""
### Early signs?
"""

# ╔═╡ 76c9d308-e222-11ea-0762-43b8e2c65783
md"""
### What's important?

#### New stuff!

correlate
"""

# ╔═╡ 86e4658c-e238-11ea-26ab-1f4ea68bd363
holidays = dataset("holidays", "school")

# ╔═╡ Cell order:
# ╟─80ca3a72-e1ec-11ea-14e0-9b6321f69aaf
# ╟─b715770a-e1f2-11ea-296b-833ff13790b4
# ╠═bef1d414-e1f2-11ea-3005-7d734ef29af8
# ╠═9fa3d164-e24b-11ea-27c4-f579ca84aac3
# ╠═9a588752-e24b-11ea-02a3-ad978111b579
# ╠═966af7ba-e24b-11ea-333a-eb8734613400
# ╟─cafd3f0a-e1f2-11ea-2861-fbd429841e67
# ╠═b7149c2e-e3b7-11ea-387a-9966e5cd6e6a
# ╠═f64848a0-e76d-11ea-1990-8f4b804f1e9b
# ╠═e70f6018-e1f7-11ea-0b8f-8d48c9eaa94d
# ╠═e2e0a582-e1f2-11ea-37e2-236507742cdc
# ╠═e664290c-e1f2-11ea-27f2-7fbc16af7f19
# ╠═c3adcd30-e249-11ea-0c86-03094a96cb2f
# ╠═eaa31474-e1f2-11ea-1e01-a1d50df4fcec
# ╟─762f1336-e206-11ea-3766-fd9b1a991e99
# ╟─7c0246ac-e206-11ea-3f18-c5e9ccf73a93
# ╟─85b11818-e206-11ea-1731-61cdec0e3470
# ╟─d536b636-e24c-11ea-2710-c3a5c7e2f267
# ╠═8edd85c0-e206-11ea-36d7-9fb3ce92eb67
# ╠═9879e5ba-e206-11ea-198c-c93264c4720b
# ╟─f5e067f6-e24c-11ea-3c3c-bf88fd1de331
# ╠═5431e8f0-e76a-11ea-25f3-9590a086efd5
# ╠═0eb86234-e774-11ea-2cd0-0153ffd75aef
# ╠═4ed9b764-e76f-11ea-3da0-3d9bc46cec0f
# ╟─ba20f85c-e24c-11ea-3067-5fe2d57baf52
# ╠═0b899ce4-e2bb-11ea-1a85-7bee36ef0213
# ╟─0a4c3ee8-e2bd-11ea-0ad0-1de3e6d82689
# ╠═eb66364a-e2bd-11ea-0157-9f55a8e415a6
# ╠═e7041002-e206-11ea-3899-6b3a3cfe771f
# ╠═e9b1f99c-e206-11ea-38da-ed8fccafdc2f
# ╠═f8ce9a98-e206-11ea-31d6-0770158808a8
# ╠═f9ac39c8-e206-11ea-0fbc-1b9ca1de4635
# ╠═02d4ed92-e207-11ea-3e00-0765c2b58271
# ╟─1f665d78-e208-11ea-269e-839f5f57f051
# ╠═295ffb50-e207-11ea-3095-550122a52bcf
# ╠═1514be60-e207-11ea-279a-9d0c777dc591
# ╠═d73763b0-e207-11ea-1892-cf261fa3e3fb
# ╠═ea2fb83e-e207-11ea-0129-67e41b8501cc
# ╠═15bf4900-e207-11ea-2a23-7314baaf6a5a
# ╟─726da05c-e222-11ea-0572-9113873f3c74
# ╠═76c9d308-e222-11ea-0762-43b8e2c65783
# ╠═86e4658c-e238-11ea-26ab-1f4ea68bd363
