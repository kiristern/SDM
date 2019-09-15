using Distributed
using JLD2

@time @everywhere include("../BioClim/src/required.jl")
cd("/Users/kiristern/Documents/GitHub/SDM")

@time begin
    # Load data from CSV files
    df = CSV.read("../data/pred_prey/Vulpes_vulpes_sp.csv", header=true, delim="\t")
    # Prepare data (select columns, arrange values)
    df = prepare_gbif_data(df)
    # Separate species
    taxa_occ = [df[df.species .== u,:] for u in unique(df.species)]

    # Define coordinates range
    lon_range = (-180.0, -46.0)
    lat_range = (-90.0, 90.0)
end

## Get the worldclim data
@time wc_vars = pmap(x -> worldclim(x)[lon_range, lat_range], 1:19);

## Make predictions for all species
@time all_predictions = pmap(x -> species_bclim(x, wc_vars), warblers_occ);

## Export predictions
@save "../data/all_predictions_vulpes_vulpes.jld2" all_predictions
