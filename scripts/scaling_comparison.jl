
function plot_magnetic_ed(ax)
    df = load_data("1d_gas")

    x = df.ε .^ 2 .* df.N ./ (df.volume .* df.Ω .^ 2)
    lines!(ax, x, getindex.(df.EnergyED, 3), label = L"$E_\mathrm{ED}^{⟨\mathbf{A}⟩=0}$")
    plot!(
        ax,
        x,
        df.EnergyED[1][1] .+ 0.5df.Ω .* (sqrt.(1 .+ x) .- 1),
        label = L"$E_\mathrm{CS}^{⟨\mathbf{A}⟩=0}$",
        marker = :rect,
        color = Makie.wong_colors()[1],
    )

    lines!(ax, x, getindex.(df.EnergyED, 1), label = L"$E_\mathrm{ED}$")
    plot!(ax, x, df.EnergyCS, label = L"$E_\mathrm{CS}$", color = Makie.wong_colors()[2])

    axislegend(ax, position = (:right, 0.6))
end

function plot_scaling_compare(ax)
    df_noktwist = load_data("scaling_noktwist")
    df_ktwist = load_data("scaling_ktwist")

    df0 = filter(:ε => ==(0), df_noktwist)
    df1 = filter(:ε => ==(1), df_noktwist)

    df_ktwist_avg = twist_avg(filter(:ε => ==(1), df_ktwist))

    x = df1.N ./ (df1.volume .* df1.Ω .^ 2) .* df1.ε .^ 2

    df01 = innerjoin(
        df0,
        df1,
        on = setdiff(propertynames(df0), [:ε, :EnergyQMC, :EnergyCS]),
        renamecols = "0" => "1",
    )

    vacuum_shift(ε, Ω, N, volume) = @. 0.5Ω * (sqrt(1 + N * ε^2 / (volume * Ω^2)) - 1)
    transform!(df01, [:ε1, :Ω, :N, :volume] => ByRow(vacuum_shift) => :vacuum_shift)

    scatterlines!(
        ax,
        df01.N,
        Measurements.value.(df01.EnergyQMC1 .- df01.EnergyCS0 .- df01.vacuum_shift),
        label = L"E - E_\mathrm{CS}^{⟨\mathbf{A}⟩=0}",
        marker = :circle,
    )
    scatterlines!(
        ax,
        df01.N,
        Measurements.value.(df01.EnergyQMC1 - df01.EnergyCS1),
        label = L"E - E_\mathrm{CS}",
        marker = :rect,
    )
    scatterlines!(
        ax,
        df_ktwist_avg.N,
        Measurements.value.(df_ktwist_avg.CorrEnergy),
        label = L"\overline{E^\kappa - E^\kappa_\mathrm{CS}}",
        color = :black,
        marker = :diamond,
    )

    axislegend(ax, position = (:right, :bottom))

end

function fig_scaling_comparison()
    fig = Figure(size = (390, 300))
    ax1 = Axis(
        fig[1, 1],
        xlabel = L"\frac{N𝛜^2}{V_\text{c}Ω^2}",
        ylabel = L"$E$ (Ha)",
        yticks = [0.17, 0.2, 0.23],
    )
    ax2 = Axis(
        fig[1, 2],
        xlabel = L"N",
        ylabel = L"$E_\mathrm{c,el‐ph}$ (Ha)",
        yticks = [0, -0.1, -0.2],
    )
    ylims!(ax2, -0.225, 0.006)
    text!(
        ax1,
        0.02,
        1,
        align = (:left, :top),
        space = :relative,
        font = :bold,
        text = "(a)",
    )
    text!(
        ax2,
        0.02,
        1,
        align = (:left, :top),
        space = :relative,
        font = :bold,
        text = "(b)",
    )
    text!(
        ax2,
        0.25,
        0.7,
        align = (:left, :top),
        space = :relative,
        text = L"2D gas\n$v = 0.5\,\mathrm{Ha}$\n$|𝛜| = 1\,\mathrm{a.u.}$",
    )
    text!(
        ax1,
        0.02,
        0.02,
        align = (:left, :bottom),
        space = :relative,
        justification = :left,
        text = L"1D gas\n$v = 0.2\,\mathrm{Ha}$\n$N=4$",
    )


    plot_magnetic_ed(ax1)
    plot_scaling_compare(ax2)

    return fig
end
