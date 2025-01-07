function qfunc(x)
    b1 = 3.27
    b2 = -0.242
    b3 = 0.213

    return x^2 / (b1 + b2 * x + b3 * x^1.5)
end

function fig_gradient_mapping()
    df_grad = h5open("../data/gradient_mapping.h5", "r") do f
        return DataFrame(:vs => read(f, "/vs"), :Qs => read(f, "Qs"), :ρ => read(f, "ρ"))
    end

    fig = Figure(size = (390, 250))
    ax = Axis(fig[1, 1], xlabel = L"v/ρ", ylabel = L"\mathcal{Q}^2/ρ")

    ρ = df_grad.ρ
    scatter!(ax, df_grad.vs ./ ρ, df_grad.Qs ./ ρ)
    lines!(ax, df_grad.vs ./ ρ, qfunc.(df_grad.vs ./ ρ), color = :black)
    # axislegend(ax, position = :rb)
    fig

    return fig

end
