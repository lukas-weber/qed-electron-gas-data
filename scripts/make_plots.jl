using HDF5
using CairoMakie
using Printf
using JSON
using Statistics
using DataFrames
using LaTeXStrings

function load_data(filename)
    data = JSON.parsefile("../data/$filename.json")

    df = DataFrame(Tables.dictrowtable(data))

    if :EnergyQMC in propertynames(df)
        select!(
            df,
            Not(:EnergyQMCError),
            [:EnergyQMC, :EnergyQMCError] => ByRow(measurement) => :EnergyQMC,
        )
    end

    return df
end

function twist_avg(df)
    return combine(
        groupby(df, Not(:EnergyQMC, :EnergyCS, :ktwist)),
        [:EnergyQMC, :EnergyCS] => ((eqmc, ehf) -> mean(eqmc - ehf)) => :CorrEnergy,
    )
end

function twist_avg(df, cols)
    return combine(
        groupby(df, Not(:EnergyPT, :EnergyPTΩ0, :ktwist)),
        (col => mean => col for col in cols)...,
    )
end


include("makie.jl")
include("scaling_comparison.jl")
include("functional.jl")
include("gradient_mapping.jl")

function plots()
    pt_per_unit = 0.625
    with_theme(qed_theme()) do
        for (name, fig) in [
            ("scaling_comparison", fig_scaling_comparison()),
            ("functional", fig_functional()),
            ("perturbative", fig_perturbative()),
            ("gradient_mapping", fig_gradient_mapping()),
        ]
            save("../plots/$name.pdf", fig; pt_per_unit)
        end
    end
end

function (@main)(args)
    plots()
end
