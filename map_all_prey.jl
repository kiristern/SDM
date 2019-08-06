using Plots
using GDAL
using Shapefile
using StatsBase
using CSV
using DataFrames
using Statistics
using GBIF

cd("/Users/kiristern/Documents/GitHub/SDM")
include("../BioClim/src/lib/SDMLayer.jl")
include("../BioClim/src/lib/gdal.jl")
include("../BioClim/src/lib/worldclim.jl")
include("../BioClim/src/lib/bioclim.jl")
include("../BioClim/src/lib/shapefiles.jl")
include("explo_fnc.jl")

# Import csv file
df = CSV.read("data/prey_genus/prey_gen_onedf.csv", header=true)

#remove rows with missing values
df_drop = dropmissing(df, [:decimalLatitude, :decimalLongitude, :year])

#new df of just genus, occurence, year
df_new = select(df, [:genus, :decimalLatitude, :decimalLongitude, :year])

# Rename coordinate names
rename!(df_new, :decimalLatitude => :latitude)
rename!(df_new, :decimalLongitude => :longitude)
#for simplicity sake of running Tim's predictive model
rename!(df_new, :genus => :species)

# convert longitude "string" into "Float64"
df_new.longitude = parse.(Float64, df_new.longitude)

# prepare data according to explo_fnc function
# df = prepare_csvdata(df)

#select for one genus at a time
prey = [df_new[df_new.species .== u,:] for u in unique(df_new.species)]
occ = prey[1]

#select for one species at a time
# prey = [df[df.species .== u,:] for u in unique(df.species)]
# occ = prey[1]

# Get the worldclim data by their layer number
cd("/Users/kiristern/Documents/GitHub/BioClim/")

@info "Extract and crop bioclim variables"
@time wc_vars = [clip(worldclim(i), occ) for i in 1:19];
# Make the prediction for each layer
@info "Predictions for each layer"
@time predictions = [bioclim(wc_vars[i], occ) for i in 1:length(wc_vars)];
# Make the final prediction by taking the minimum
@info "Minimum-consensus aggregation"
@time prediction = reduce(minimum, predictions);
# Get the threshold for NaN given a percentile
@info "Threshold estimation"
@time threshold = first(quantile(prediction[occ], [0.05]))
@info "5% threshold:\t$(round(threshold; digits=3))"
# Filter the predictions based on the threshold
@info "Final prediction filtering"
@time for i in eachindex(prediction.grid)
    prediction.grid[i] < threshold && (prediction.grid[i] = NaN)
end

worldmap = clip(worldshape(50), prediction)

sdm_plot = plot([0.0], lab = " ", msw = 0.0, ms = 0.0, size = (900, 450), frame=:box,
                title = first(unique(occ.species)))
xaxis!(sdm_plot, (prediction.left, prediction.right), "Longitude")
yaxis!(sdm_plot, (prediction.bottom, prediction.top), "Latitude")

for p in worldmap
    sh = Shape([pp.x for pp in p.points], [pp.y for pp in p.points])
    plot!(sdm_plot, sh, c = :lightgrey, lab = " ")
end

heatmap!(
    sdm_plot,
    longitudes(prediction), latitudes(prediction), prediction.grid,
    aspectratio = 92.60/60.75, c = :BuPu,
    clim = (0.0, maximum(filter(!isnan, prediction.grid)))
    )

for p in worldmap
    xy = map(x -> (x.x, x.y), p.points)
    plot!(sdm_plot, xy, c=:grey, lab = " ", leg=false)
end
sdm_plot

savefig("../SDM/figures/sdm_map-$(first(unique(occ.species))).pdf")
