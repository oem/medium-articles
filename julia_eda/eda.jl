### A Pluto.jl notebook ###
# v0.11.7

using Markdown
using InteractiveUtils

# ╔═╡ bef1d414-e1f2-11ea-3005-7d734ef29af8
begin
	using Pkg
	Pkg.activate(".")
	Pkg.add("Gadfly")
	using Hamburg
	using Dates
	using DataFrames
end

# ╔═╡ d43534e2-e1f2-11ea-2b7d-654863a51ee3
begin
	using Gadfly
	Gadfly.set_default_plot_size(800px, 300px)
end

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
plot(x=names(boroughs), y=mat_boroughs[1, :], Geom.bar, Theme(bar_spacing=10mm), Guide.xlabel("Boroughs"), Guide.ylabel("New infections"))

# ╔═╡ 762f1336-e206-11ea-3766-fd9b1a991e99
md"""
Ok, let's see what else we can find out from our data.
"""

# ╔═╡ 7c0246ac-e206-11ea-3f18-c5e9ccf73a93
md"""
## I have questions

Just diving into the data and start exploring a new dataset can be a lot of fun! 

Maybe you already have questions that can guide you in your exploration, or you have set yourself a concrete goal like, **"proof this and that"**, **"show the relationship between..."**, or **"create a report for monthly traffic of the website"**. Great, then you have your work cut out for you (though it might not be as much fun as freestyle exploration of a new dataset).

Sometimes though, we don't know yet exactly what questions we want to even ask. Where to start then?

Well, one thing we can explore already, is the structure of the data. In this case, we have the development of the covid-19 pandemic as a time series, which opens up plenty of possible questions.
"""

# ╔═╡ 85b11818-e206-11ea-1731-61cdec0e3470
md"""
### How are we doing?
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
	l1 = borough_plot(names(boroughs), mat_boroughs[1, :], Theme(default_color="#ffcf33", bar_spacing=10mm))
	l2 = borough_plot(names(boroughs), mat_boroughs[2, :], Theme(default_color="orange", bar_spacing=10mm))
	l3 = borough_plot(names(boroughs), mat_boroughs[3, :], Theme(default_color="red", bar_spacing=10mm))
	l4 = borough_plot(names(boroughs), mat_boroughs[end, :], Theme(default_color="purple", bar_spacing=10mm))

	plot(l4, l3, l2, l1,        
		Guide.xlabel("Boroughs"),
		Guide.ylabel("New Infections"),
		Guide.title("New infections in the last 14 days"),
		Guide.manual_color_key("Time",["Now - 14 days ago", "7 - 21 days ago", "14 - 28 days ago"],["orange","red", "purple"]))
end

# ╔═╡ e7041002-e206-11ea-3899-6b3a3cfe771f
df = dataset("covid-19", "infected")

# ╔═╡ e9b1f99c-e206-11ea-38da-ed8fccafdc2f
head(df, 10)

# ╔═╡ f8ce9a98-e206-11ea-31d6-0770158808a8
function plotnewcases(df)
    layer(df, y=:new,x=:recordedat, Geom.bar)
end

# ╔═╡ f9ac39c8-e206-11ea-0fbc-1b9ca1de4635
plot(plotnewcases(df),
    Coord.cartesian(xmin=Date(2020, 3,1)),
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
# ╟─762f1336-e206-11ea-3766-fd9b1a991e99
# ╟─7c0246ac-e206-11ea-3f18-c5e9ccf73a93
# ╟─85b11818-e206-11ea-1731-61cdec0e3470
# ╠═8edd85c0-e206-11ea-36d7-9fb3ce92eb67
# ╠═9879e5ba-e206-11ea-198c-c93264c4720b
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
