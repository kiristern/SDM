using Distributed
using JLD2

@time @everywhere include("../BioClim/src/required.jl")
cd("/Users/kiristern/Documents/GitHub/SDM")
## Get & prepare data
@time @everywhere begin
    # Load data from CSV files
     df = CSV.read("/Users/kiristern/Documents/GitHub/SDM/data/pred_prey/Puma_concolor.csv", header=true)
    # Prepare data (select columns, arrange values)
    df = prepare_gbif_data(pred_prey)
    # Separate species
    taxa_occ = [df[df.species .== u,:] for u in unique(df.species)]
end

# convert year "string" to "integer"
#df.longitude = parse.(Float64, df.longitude)

# Get the worldclim data by their layer number
cd("/Users/kiristern/Documents/GitHub/BioClim/")

#prediction pred
@info "Extract and crop bioclim variables"
@time wc_vars = [clip(worldclim(i), taxa_occ[1]) for i in 1:19];
# Make the prediction for each layer
@info "Predictions for each layer"
@time predictions = [bioclim(wc_vars[i], taxa_occ[1]) for i in 1:length(wc_vars)];
# Make the final prediction by taking the minimum
@info "Minimum-consensus aggregation"
@time prediction1 = reduce(minimum, predictions);
# Get the threshold for NaN given a percentile
@info "Threshold estimation"
@time threshold = first(quantile(prediction1[taxa_occ[1]], [0.05]))
@info "5% threshold:\t$(round(threshold; digits=3))"
# Filter the predictions based on the threshold
@info "Final prediction filtering"
@time for i in eachindex(prediction1.grid)
    prediction1.grid[i] < threshold && (prediction1.grid[i] = NaN)
end

#prediction prey1
@info "Extract and crop bioclim variables"
@time wc_vars = [clip(worldclim(i), taxa_occ[2]) for i in 1:19];
# Make the prediction for each layer
@info "Predictions for each layer"
@time predictions = [bioclim(wc_vars[i], taxa_occ[2]) for i in 1:length(wc_vars)];
# Make the final prediction by taking the minimum
@info "Minimum-consensus aggregation"
@time prediction2 = reduce(minimum, predictions);
# Get the threshold for NaN given a percentile
@info "Threshold estimation"
@time threshold = first(quantile(prediction2[taxa_occ[2]], [0.05]))
@info "5% threshold:\t$(round(threshold; digits=3))"
# Filter the predictions based on the threshold
@info "Final prediction filtering"
@time for i in eachindex(prediction2.grid)
    prediction2.grid[i] < threshold && (prediction2.grid[i] = NaN)
end

@info "Extract and crop bioclim variables"
@time wc_vars = [clip(worldclim(i), taxa_occ[3]) for i in 1:19];
# Make the prediction for each layer
@info "Predictions for each layer"
@time predictions = [bioclim(wc_vars[i], taxa_occ[3]) for i in 1:length(wc_vars)];
# Make the final prediction by taking the minimum
@info "Minimum-consensus aggregation"
@time prediction3 = reduce(minimum, predictions);
# Get the threshold for NaN given a percentile
@info "Threshold estimation"
@time threshold = first(quantile(prediction3[taxa_occ[3]], [0.05]))
@info "5% threshold:\t$(round(threshold; digits=3))"
# Filter the predictions based on the threshold
@info "Final prediction filtering"
@time for i in eachindex(prediction3.grid)
    prediction3.grid[i] < threshold && (prediction3.grid[i] = NaN)
end

@info "Extract and crop bioclim variables"
@time wc_vars = [clip(worldclim(i), taxa_occ[4]) for i in 1:19];
# Make the prediction for each layer
@info "Predictions for each layer"
@time predictions = [bioclim(wc_vars[i], taxa_occ[4]) for i in 1:length(wc_vars)];
# Make the final prediction by taking the minimum
@info "Minimum-consensus aggregation"
@time prediction4 = reduce(minimum, predictions);
# Get the threshold for NaN given a percentile
@info "Threshold estimation"
@time threshold = first(quantile(prediction4[taxa_occ[4]], [0.05]))
@info "5% threshold:\t$(round(threshold; digits=3))"
# Filter the predictions based on the threshold
@info "Final prediction filtering"
@time for i in eachindex(prediction4.grid)
    prediction4.grid[i] < threshold && (prediction4.grid[i] = NaN)
end

@info "Extract and crop bioclim variables"
@time wc_vars = [clip(worldclim(i), taxa_occ[5]) for i in 1:19];
# Make the prediction for each layer
@info "Predictions for each layer"
@time predictions = [bioclim(wc_vars[i], taxa_occ[5]) for i in 1:length(wc_vars)];
# Make the final prediction by taking the minimum
@info "Minimum-consensus aggregation"
@time prediction5 = reduce(minimum, predictions);
# Get the threshold for NaN given a percentile
@info "Threshold estimation"
@time threshold = first(quantile(prediction5[taxa_occ[5]], [0.05]))
@info "5% threshold:\t$(round(threshold; digits=3))"
# Filter the predictions based on the threshold
@info "Final prediction filtering"
@time for i in eachindex(prediction5.grid)
    prediction5.grid[i] < threshold && (prediction5.grid[i] = NaN)
end

@info "Extract and crop bioclim variables"
@time wc_vars = [clip(worldclim(i), taxa_occ[6]) for i in 1:19];
# Make the prediction for each layer
@info "Predictions for each layer"
@time predictions = [bioclim(wc_vars[i], taxa_occ[6]) for i in 1:length(wc_vars)];
# Make the final prediction by taking the minimum
@info "Minimum-consensus aggregation"
@time prediction6 = reduce(minimum, predictions);
# Get the threshold for NaN given a percentile
@info "Threshold estimation"
@time threshold = first(quantile(prediction6[taxa_occ[6]], [0.05]))
@info "5% threshold:\t$(round(threshold; digits=3))"
# Filter the predictions based on the threshold
@info "Final prediction filtering"
@time for i in eachindex(prediction6.grid)
    prediction6.grid[i] < threshold && (prediction6.grid[i] = NaN)
end

@info "Extract and crop bioclim variables"
@time wc_vars = [clip(worldclim(i), taxa_occ[7]) for i in 1:19];
# Make the prediction for each layer
@info "Predictions for each layer"
@time predictions = [bioclim(wc_vars[i], taxa_occ[7]) for i in 1:length(wc_vars)];
# Make the final prediction by taking the minimum
@info "Minimum-consensus aggregation"
@time prediction7 = reduce(minimum, predictions);
# Get the threshold for NaN given a percentile
@info "Threshold estimation"
@time threshold = first(quantile(prediction7[taxa_occ[7]], [0.05]))
@info "5% threshold:\t$(round(threshold; digits=3))"
# Filter the predictions based on the threshold
@info "Final prediction filtering"
@time for i in eachindex(prediction7.grid)
    prediction7.grid[i] < threshold && (prediction7.grid[i] = NaN)
end

@info "Extract and crop bioclim variables"
@time wc_vars = [clip(worldclim(i), taxa_occ[8]) for i in 1:19];
# Make the prediction for each layer
@info "Predictions for each layer"
@time predictions = [bioclim(wc_vars[i], taxa_occ[8]) for i in 1:length(wc_vars)];
# Make the final prediction by taking the minimum
@info "Minimum-consensus aggregation"
@time prediction8 = reduce(minimum, predictions);
# Get the threshold for NaN given a percentile
@info "Threshold estimation"
@time threshold = first(quantile(prediction8[taxa_occ[8]], [0.05]))
@info "5% threshold:\t$(round(threshold; digits=3))"
# Filter the predictions based on the threshold
@info "Final prediction filtering"
@time for i in eachindex(prediction8.grid)
    prediction8.grid[i] < threshold && (prediction8.grid[i] = NaN)
end

predictions = [prediction1, prediction2, prediction3, prediction4, prediction5, prediction6, prediction7, prediction8]


# ## Get the worldclim data
# @time wc_vars = map(x -> worldclim(x)[lon_range, lat_range], 1:19);
#
# ## Make predictions for all species
# @time predictions = map(x -> species_bclim(x, wc_vars), taxa_occ);

## Export predictions
@save "data/predictions_procyon_lotor.jld2" predictions

# Test import
@load "data/predictions.jld2" predictions
