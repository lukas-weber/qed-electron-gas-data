# The light-matter correlation energy functional of the cavity-coupled two-dimensional electron gas via quantum Monte Carlo simulations

This is the data repository for our paper [The light-matter correlation energy functional of the cavity-coupled two-dimensional electron gas via quantum Monte Carlo simulations](https://doi.org/10.48550/arXiv.2412.19222).

The data is in JSON and HDF5 format in the `data` directory.

To regenerate the plots, you need Julia. Running

```bash
cd scripts
julia --project -e "using Pkg; Pkg.instantiate()"
julia --project make_plots.jl
```

should install all further dependencies and write plots to the `plots` directory.
