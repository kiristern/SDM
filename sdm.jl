using Distributed


@time @everywhere include("../BioClim/src/required.jl")

## Get & prepare data
@time @everywhere begin
    # Load data from CSV files
    df = CSV.read("/Users/kiristern/Documents/GitHub/SDM/data/pred_prey/Puma_concolor.csv", header=true)
    # Prepare data (select columns, arrange values)
    df = prepare_csvdata(df)
    # Separate species
    taxa_occ = [df[df.species .== u,:] for u in unique(df.species)]

    # Define coordinates range
    lon_range = (-165.0, -30.0)
    lat_range = (75.0, -60.0)
end

cd("/Users/kiristern/Documents/GitHub/SDM/")
## Get the worldclim data
@time wc_vars = pmap(x -> worldclim(x)[lon_range, lat_range], 1:19);

# Make predictions for all species
@time predictions = pmap(x -> species_bclim(x, wc_vars), taxa_occ);

begin
    # Create Y -> site-by-species community data table
    Y = zeros(Int64, (prod(size(predictions[1])),length(taxa_occ)))
    # Fill Y with community predictions
    @progress for gc in eachindex(predictions[1].grid) # loop for all sites
        # Group predictions for all species in site
        R = map(x -> x.grid[gc], predictions)
        # Fill Y with binary values -> 1 if species prediction for site != NaN, 0 if == NaN
        global Y[gc,:] = .!isnan.(R)
    end

    ## Arrange prediction values as grid
    # Create empty grid
    predict_grid = zeros(Float64, size(predictions[1]))

    # Create SDMLayer with prediction values
    predict_SDM = SDMLayer(predict_grid, predictions[1].left, predictions[1].right, predictions[1].bottom, predictions[1].top)
end

## Plot results
sdm_plot = plotSDM(predict_SDM)

## custom heatmap colour gradient
heatmap!(
    sdm_plot,
    longitudes(prediction), latitudes(prediction), prediction.grid,
    aspectratio = 92.60/60.75, c = cgrad([:lightblue, :blue, :darkblue]),
    clim = (0.0, maximum(filter(!isnan, prediction.grid)))
    )
