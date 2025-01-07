using CairoMakie
using MakieCore
using Measurements
const marker_cycle =
    [:circle, :diamond, :rect, :utriangle, :ltriangle, :dtriangle, :rtriangle]

function qed_theme()
    return merge(
        theme_latexfonts(),
        Theme(
            figure_padding = 1,
            Axis = (; xgridvisible = false, ygridvisible = false),
            Legend = (;
                framevisible = false,
                labelsize = 12,
                titlesize = 14,
                patchsize = (14, 14),
            ),
            palette = (color = Makie.wong_colors(), marker = marker_cycle),
            MeasPlot = (cycle = Cycle([:color, :marker], covary = true),),
            Scatter = (cycle = Cycle([:color, :marker], covary = true),),
        ),
    )
end

@recipe MeasPlot (x, y) begin
    errorcolor = @inherit markercolor
    MakieCore.documented_attributes(Scatter)...
end

function Makie.plot!(mp::MeasPlot{<:Tuple{AbstractVector,AbstractVector}})
    vals = @lift(Measurements.value.($(mp.y)))
    errs = @lift(Measurements.uncertainty.($(mp.y)))
    errorbars!(mp, mp.x, vals, errs, color = mp.errorcolor)
    scatter!(
        mp,
        mp.x,
        vals;
        marker = mp.marker,
        color = mp.color,
        strokecolor = mp.strokecolor,
    )
    return mp
end

function Makie.legendelements(plot::MeasPlot, legend)
    LegendElement[
        LineElement(
            linepoints = [Point2f(0.5, 0), Point2f(0.5, 1)],
            color = plot.errorcolor,
        ),
        # MarkerElement(points = [Point2f(0.5, 0), Point2f(0.5, 1)], marker = :hline, markersize = 10),
        MarkerElement(
            points = [Point2f(0.5, 0.5)],
            marker = plot.marker,
            color = plot.color,
            strokecolor = plot.strokecolor,
            strokewidth = plot.strokewidth,
        ),
    ]
end

@recipe MeasLinesPlot (x, y) begin
    errorcolor = @inherit markercolor
    MakieCore.documented_attributes(ScatterLines)...
end

function Makie.plot!(mp::MeasLinesPlot{<:Tuple{AbstractVector,AbstractVector}})
    vals = @lift(Measurements.value.($(mp.y)))
    errs = @lift(Measurements.uncertainty.($(mp.y)))
    errorbars!(mp, mp.x, vals, errs, color = mp.errorcolor)
    scatterlines!(
        mp,
        mp.x,
        vals;
        marker = mp.marker,
        color = mp.color,
        strokecolor = mp.strokecolor,
        linewidth = mp.linewidth,
        linestyle = mp.linestyle,
        linecap = mp.linecap,
    )
    return mp
end

function Makie.legendelements(plot::MeasLinesPlot, legend)
    LegendElement[
        LineElement(
            linepoints = [Point2f(0.5, 0), Point2f(0.5, 1)],
            color = plot.errorcolor,
        ),
        LineElement(linepoints = [Point2f(0, 0.5), Point2f(1, 0.5)], color = plot.color),
        MarkerElement(
            points = [Point2f(0.5, 0.5)],
            marker = plot.marker,
            color = plot.color,
            strokecolor = plot.strokecolor,
            strokewidth = plot.strokewidth,
        ),
    ]
end
