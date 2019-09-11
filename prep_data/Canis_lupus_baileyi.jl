@time @everywhere include("../BioClim/src/required.jl")

# Import CSV file
sp_table = CSV.read("Canis_lupus_baileyi.csv")

# select only scientificName, decimalLatitude, decimalLongitude, and year
sp_table = sp_table[:, [:species, :infraspecificEpithet, :taxonRank,
                        :decimalLatitude, :decimalLongitude, :year]]
# create new column copying all info from species col
sp_table.new_name = copy(sp_table.species)
# replace spaces by "_"
sp_table.new_name .= replace.(sp_table.new_name, " " .=> "_")
# if subspecies, specify in new_name column
for i in 1:length(sp_table)
    if sp_table.taxonRank[i] == "SUBSPECIES"
        sp_table.new_name[i] = string(sp_table.species[i], "_", sp_table.infraspecificEpithet[i])
    end
end

# Subset with specific columns
df = sp_table[:, [:new_name, :year, :decimalLatitude, :decimalLongitude]]
# Rename coordinate names
rename!(df, :decimalLatitude => :latitude)
rename!(df, :decimalLongitude => :longitude)
rename!(df, :new_name => :species)
# Replace spaces by underscores in species names
df.species .= replace.(df.species, " " .=> "_")
# Remove entries with missing year, latitude and lontitude
dropmissing!(df, [:year, :latitude, :longitude])

# Get number of observatons per species/subspecies
newdf = by(df, :species, n = :species => length)
show(sort(newdf, order(:species)), allrows=true)

# Show result for subspecies observations
show(sp_table[sp_table.taxonRank .== "SUBSPECIES", [:species, :infraspecificEpithet, :new_name]], allrows=true)

# # select only occurences with included year date
# sp_table = sp_table[sp_table.year .!= "NA", :]
# # convert year "string" to "integer"
# sp_table.year = parse.(Int64, sp_table.year)

# Prepare csv data using fnc
# df = prepare_csvdata(sp_table)

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
@time threshold = first(quantile(prediction[df], [0.05]))
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
