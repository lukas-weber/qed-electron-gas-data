xε(ε, N, volume, Ω) = ε^2 / (Ω * sqrt(1 + N * ε^2 / (volume * Ω^2)))
xv(v, N, volume) = v / (N / volume)
xΩ(N, volume, Ω) = Ω / (N / volume)

function fig_perturbative()
    df = load_data("εslices")
    df_pert = load_data("εslices_pert")

    fig = Figure(size = (160, 200))
    ax = Axis(
        fig[1, 1],
        xlabel = L"\frac{N𝛜^2}{ρV_\text{c}\tilde{\Omega}}",
        ylabel = L"E_{\text{c, el‐ph}}/v",
    )
    for d in (df, df_pert)
        filter!(
            r ->
                isapprox(r.v / (r.N / r.volume), 2.7, atol = 0.05) &&
                    isapprox(r.Ω / (r.N / r.volume), 0.9, atol = 0.05),
            d,
        )
        transform!(d, [:ε, :N, :volume, :Ω] => ByRow(xε) => :xε)
    end

    df_avg = twist_avg(df)
    df_avg_pert = twist_avg(df_pert, [:EnergyPT, :EnergyPTΩ0])

    p_qmc = scatter!(
        ax,
        df_avg.xε,
        Measurements.value.(df_avg.CorrEnergy) ./ df_avg.v,
        label = "QMC",
    )
    p_pert1 = lines!(
        ax,
        df_avg_pert.xε,
        df_avg_pert.EnergyPT ./ df_avg_pert.v,
        color = :black,
        linestyle = :dash,
        label = L"PT$_{\tilde{Ω}}$",
    )
    p_pert2 = lines!(
        ax,
        df_avg_pert.xε,
        df_avg_pert.EnergyPTΩ0 ./ df_avg_pert.v,
        color = "#777",
        linestyle = :dashdot,
        label = L"PT$_Ω$",
    )

    ylims!(ax, -0.051, 0.002)
    axislegend(
        ax,
        position = :rt,
        titlehalign = :left,
        titlefont = :regular,
        gridshalign = :left,
        padding = 4,
        margin = (0, 0, 0, 0),
    )

    return return fig
end


function param_label(param::Symbol)
    return get(
        Dict(
            :xv => L"\frac{v}{ρ}",
            :xΩ => L"\frac{Ω}{ρ}",
            :xε => L"\frac{N𝛜^2}{ρV_\text{c}\tilde{\Omega}}",
        ),
        param,
        string(param),
    )
end

function plot_functional(fig, df; xparam, group_params, df_pert = nothing, df_inf = nothing)
    ax = Axis(fig; xlabel = param_label(xparam), ylabel = L"E_{\text{c, el‐ph}}/v")

    for gdf in groupby(df, group_params)
        vnorm = copy(gdf.v)
        vnorm[vnorm.==0] .= 1
        s = scatter!(
            ax,
            gdf[!, xparam],
            Measurements.value.(gdf.CorrEnergy) ./ vnorm,
            label = join([@sprintf("%2.3g", gdf[1, p]) for p in group_params], ", "),
        )

        plot_fit(ax, gdf, xparam; color = s.color[])
    end

    if !isnothing(df_inf)
        vnorm = df_inf.v
        vnorm[vnorm.==0] .= 1
        scatter!(
            ax,
            df_inf.xv,
            Measurements.value.(df_inf.CorrEnergy ./ vnorm),
            color = :black,
            label = "∞, any",
        )

        df_inf.xε .= 1e7
        plot_fit(ax, df_inf, xparam; color = :black)
    end

    axislegend(
        LaTeXString(join([param_label(p) for p in group_params], L"\text{,~}"));
        position = :lb,
        unique = true,
        fontsize = 10,
        patchsize = (12, 12),
        titlehalign = :left,
        titlegap = 4,
        titlesize = 12,
        padding = (0.0, 0.0, 0.0, 0.0),
    )

    return ax
end

function plot_perturbative(ax, df_pert; group_params)
    for gdf in groupby(df_pert, group_params)
        lines!(
            ax,
            gdf.xε,
            gdf.EnergyPT ./ gdf.v,
            color = :black,
            linestyle = :dash,
            label = L"PT$_{\tilde{Ω}}$",
        )
    end
end

function plot_fit(ax, df, xparam; color)
    dfparam = crossjoin(
        DataFrame(xparam => range(extrema(df[!, xparam])..., 300)),
        select(df[1:1, :], Not(xparam)),
    )

    xq = xqfunc.(dfparam.xv)

    lines!(ax, dfparam[!, xparam], Efunc.(xq, dfparam.xε) ./ dfparam.xv; color)
end

function xqfunc(xv)
    b1 = 3.27
    b2 = -0.242
    b3 = 0.213

    return xv^2 / (b1 + b2 * xv + b3 * xv^(3 / 2))
end

function Efunc(xq, xε)
    c2 = 63.73
    c1 = 4.672

    return -xq * xε / (c1 * xε + c2)
end

function fig_functional()
    df_εslices = twist_avg(load_data("εslices"))
    df_vslices = twist_avg(load_data("vslices"))

    df_εslices_pert = twist_avg(load_data("εslices_pert"), [:EnergyPT])

    df_inf_coupling = filter(:pw_fac => ==(20), twist_avg(load_data("inf_coupling")))
    df_inf_coupling.ε .= Inf
    df_inf_coupling.Ω .= 0

    for d in (df_εslices, df_εslices_pert, df_vslices, df_inf_coupling)
        transform!(d, [:ε, :N, :volume, :Ω] => ByRow(xε) => :xε)
        transform!(d, [:N, :volume, :Ω] => ByRow(xΩ) => :xΩ)
        transform!(d, [:v, :N, :volume] => ByRow(xv) => :xv)
        sort!(d, [:xε, :xv, :xΩ])
    end


    fig = Figure(size = (390, 280), figure_padding = 2)
    ax1 = plot_functional(
        fig[1, 1],
        df_εslices;
        df_pert = df_εslices_pert,
        xparam = :xε,
        group_params = [:xv, :xΩ],
    )
    ax2 = plot_functional(
        fig[1, 2],
        df_vslices;
        xparam = :xv,
        df_inf = df_inf_coupling,
        group_params = [:xε, :xΩ],
    )

    plot_perturbative(ax1, df_εslices_pert; group_params = [:xv, :xΩ])

    ylims!(ax1, -0.09, 0.002)
    ylims!(ax2, -0.33, 0.006)

    colgap!(fig.layout, 8)

    hideydecorations!(
        ax2,
        ticklabels = false,
        ticks = false,
        grid = false,
        minorgrid = false,
        minorticks = false,
    )
    return fig
end
