using Plots
using GDAL
using Shapefile
using GBIF
using StatsBase
using CSV
using DataFrames
using Statistics

cd("/Users/kiristern/Documents/GitHub/SDM/")
include("../BioClim/src/lib/SDMLayer.jl")
include("../BioClim/src/lib/gdal.jl")
include("../BioClim/src/lib/worldclim.jl")
include("../BioClim/src/lib/bioclim.jl")
include("../BioClim/src/lib/shapefiles.jl")
include("explo_fnc.jl")

# Import CSV file
sp_table = CSV.read("data/preds_csv/originals/polar_bear.csv")
## View sp_table in consol: values(sp_table)
# select only scientificName, decimalLatitude, decimalLongitude, and year
sp_table = sp_table[:, [:species, :infraspecificEpithet, :taxonRank,
                        :decimalLatitude, :decimalLongitude, :year]]
## if subspecies, specify in new_sp name
sp_table.new_sp = copy(sp_table.species)
for i in 1:length(sp_table)
    if sp_table.taxonRank[i] == "SUBSPECIES"
        sp_table.new_sp[i] = string(sp_table.species[i], "_", sp_table.infraspecificEpithet[i])
    end
end

# merge two columns
# sp_table.new_sp = sp_table[:species] .* "_" .* sp_table[:infraspecificEpithet]

# Get number of observatons per species/subspecies
newdf = by(df, :new_sp, n = :new_sp => length)
show(sort(newdf, order(:new_sp)), allrows=true)

# Show result for subspecies observations
show(sp_table[sp_table.taxonRank .== "SUBSPECIES", [:species, :infraspecificEpithet, :new_sp]], allrows=true)

# # select only occurences with included year date
# sp_table = sp_table[sp_table.year .!= "NA", :]
# # convert year "string" to "integer"
# sp_table.year = parse.(Int64, sp_table.year)

# Prepare csv data using fnc
df = prepare_csvdata(sp_table)

## From Tim's BioClim/main.jl
# Get the worldclim data by their layer number
cd("/Users/kiristern/Documents/GitHub/BioClim/")

@info "Extract and crop bioclim variables"
@time wc_vars = [clip(worldclim(i), df) for i in 1:19];
# Make the prediction for each layer
@info "Predictions for each layer"
@time predictions = [bioclim(wc_vars[i], df) for i in 1:length(wc_vars)];
# Make the final prediction by taking the minimum
@info "Minimum-consensus aggregation"
@time prediction = reduce(minimum, predictions);
# Get the threshold for NaN given a percentile
@info "Threshold estimation"
pred_noNaN = replace(prediction[df], NaN => missing)
@time threshold = first(quantile(skipmissing(pred_noNaN), [0.05]))
@info "5% threshold:\t$(round(threshold; digits=3))"
# Filter the predictions based on the threshold
@info "Final prediction filtering"
@time for i in eachindex(prediction.grid)
    prediction.grid[i] < threshold && (prediction.grid[i] = NaN)
end

worldmap = clip(worldshape(50), prediction)

sdm_plot = plot([0.0], lab = " ", msw = 0.0, ms = 0.0, size = (900, 450), frame=:box,
                title = first(unique(df.species)))
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

savefig("../SDM/figures/sdm.png")
savefig("../SDM/figures/sdm_map-$(first(unique(sp_table.species))).pdf")
