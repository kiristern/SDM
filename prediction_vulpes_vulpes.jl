using Distributed
using JLD2
using ProgressMeter

@time @everywhere include("../BioClim/src/required.jl")
cd("/Users/kiristern/Documents/GitHub/SDM")
## Get & prepare data
@time @everywhere begin
    # Load data from CSV files
    pred_prey = CSV.read("data/pred_prey/vulpes_vulpes_america.csv", header=true)
     # Prepare data (select columns, arrange values)
    df = prepare_gbif_data(pred_prey)
    # Separate species
    taxa_occ = [df[df.species .== u,:] for u in unique(df.species)]
    #define predator coordinate range
    long_predator = extrema(taxa_occ[1].longitude)
    lat_predator = extrema(taxa_occ[1].latitude)
    #define coordinate range for all species
    long_all = extrema(df.longitude)
    lat_all = extrema(df.latitude)
end

#take worldclim values for all coordinate range
@time wc_vars = pmap(x -> worldclim(x)[long_all, lat_all], 1:19)
#make predictions for all species
@time predictions = @showprogress pmap(x -> species_bclim(x, wc_vars), taxa_occ)

#new predictions of species only within predator coordinate range
new_predictions = [p[long_predator, lat_predator] for p in predictions]
##another way to write loop
#new_predictions = [predictions[i][long_predator, lat_predator] for i in 1:4]


# convert year "string" to "integer"
#df.longitude = parse.(Float64, df.longitude)

# Get the worldclim data by their layer number
cd("/Users/kiristern/Documents/GitHub/BioClim/")

# #prediction pred
# @info "Extract and crop bioclim variables"
# @time wc_vars = [clip(worldclim(i),  taxa_occ[1]) for i in 1:19];
# # Make the prediction for each layer
# @info "Predictions for each layer"
# @time predictions = [bioclim(wc_vars[i], taxa_occ[1]) for i in 1:length(wc_vars)];
# # Make the final prediction by taking the minimum
# @info "Minimum-consensus aggregation"
# @time prediction1 = reduce(minimum, predictions);
# # Get the threshold for NaN given a percentile
# @info "Threshold estimation"
# @time threshold = first(quantile(prediction1[taxa_occ[1]], [0.05]))
# @info "5% threshold:\t$(round(threshold; digits=3))"
# # Filter the predictions based on the threshold
# @info "Final prediction filtering"
# @time for i in eachindex(prediction1.grid)
#     prediction1.grid[i] < threshold && (prediction1.grid[i] = NaN)
# end
#
# #prediction prey1
# @info "Extract and crop bioclim variables"
# @time wc_vars = [clip(worldclim(i), taxa_occ[2]) for i in 1:19];
# # Make the prediction for each layer
# @info "Predictions for each layer"
# @time predictions = [bioclim(wc_vars[i], taxa_occ[2]) for i in 1:length(wc_vars)];
# # Make the final prediction by taking the minimum
# @info "Minimum-consensus aggregation"
# @time prediction2 = reduce(minimum, predictions);
# # Get the threshold for NaN given a percentile
# @info "Threshold estimation"
# @time threshold = first(quantile(prediction2[taxa_occ[2]], [0.05]))
# @info "5% threshold:\t$(round(threshold; digits=3))"
# # Filter the predictions based on the threshold
# @info "Final prediction filtering"
# @time for i in eachindex(prediction2.grid)
#     prediction2.grid[i] < threshold && (prediction2.grid[i] = NaN)
# end
#
# @info "Extract and crop bioclim variables"
# @time wc_vars = [clip(worldclim(i), taxa_occ[3]) for i in 1:19];
# # Make the prediction for each layer
# @info "Predictions for each layer"
# @time predictions = [bioclim(wc_vars[i], taxa_occ[3]) for i in 1:length(wc_vars)];
# # Make the final prediction by taking the minimum
# @info "Minimum-consensus aggregation"
# @time prediction3 = reduce(minimum, predictions);
# # Get the threshold for NaN given a percentile
# @info "Threshold estimation"
# @time threshold = first(quantile(prediction3[taxa_occ[3]], [0.05]))
# @info "5% threshold:\t$(round(threshold; digits=3))"
# # Filter the predictions based on the threshold
# @info "Final prediction filtering"
# @time for i in eachindex(prediction3.grid)
#     prediction3.grid[i] < threshold && (prediction3.grid[i] = NaN)
# end
#
# @info "Extract and crop bioclim variables"
# @time wc_vars = [clip(worldclim(i), taxa_occ[4]) for i in 1:19];
# # Make the prediction for each layer
# @info "Predictions for each layer"
# @time predictions = [bioclim(wc_vars[i], taxa_occ[4]) for i in 1:length(wc_vars)];
# # Make the final prediction by taking the minimum
# @info "Minimum-consensus aggregation"
# @time prediction4 = reduce(minimum, predictions);
# # Get the threshold for NaN given a percentile
# @info "Threshold estimation"
# @time threshold = first(quantile(prediction4[taxa_occ[4]], [0.05]))
# @info "5% threshold:\t$(round(threshold; digits=3))"
# # Filter the predictions based on the threshold
# @info "Final prediction filtering"
# @time for i in eachindex(prediction4.grid)
#     prediction4.grid[i] < threshold && (prediction4.grid[i] = NaN)
# end

# @info "Extract and crop bioclim variables"
# @time wc_vars = [clip(worldclim(i), taxa_occ[5]) for i in 1:19];
# # Make the prediction for each layer
# @info "Predictions for each layer"
# @time predictions = [bioclim(wc_vars[i], taxa_occ[5]) for i in 1:length(wc_vars)];
# # Make the final prediction by taking the minimum
# @info "Minimum-consensus aggregation"
# @time prediction5 = reduce(minimum, predictions);
# # Get the threshold for NaN given a percentile
# @info "Threshold estimation"
# @time threshold = first(quantile(prediction5[taxa_occ[5]], [0.05]))
# @info "5% threshold:\t$(round(threshold; digits=3))"
# # Filter the predictions based on the threshold
# @info "Final prediction filtering"
# @time for i in eachindex(prediction5.grid)
#     prediction5.grid[i] < threshold && (prediction5.grid[i] = NaN)
# end
#
# @info "Extract and crop bioclim variables"
# @time wc_vars = [clip(worldclim(i), taxa_occ[6]) for i in 1:19];
# # Make the prediction for each layer
# @info "Predictions for each layer"
# @time predictions = [bioclim(wc_vars[i], taxa_occ[6]) for i in 1:length(wc_vars)];
# # Make the final prediction by taking the minimum
# @info "Minimum-consensus aggregation"
# @time prediction6 = reduce(minimum, predictions);
# # Get the threshold for NaN given a percentile
# @info "Threshold estimation"
# @time threshold = first(quantile(prediction6[taxa_occ[6]], [0.05]))
# @info "5% threshold:\t$(round(threshold; digits=3))"
# # Filter the predictions based on the threshold
# @info "Final prediction filtering"
# @time for i in eachindex(prediction6.grid)
#     prediction6.grid[i] < threshold && (prediction6.grid[i] = NaN)
# end
#
# @info "Extract and crop bioclim variables"
# @time wc_vars = [clip(worldclim(i), taxa_occ[7]) for i in 1:19];
# # Make the prediction for each layer
# @info "Predictions for each layer"
# @time predictions = [bioclim(wc_vars[i], taxa_occ[7]) for i in 1:length(wc_vars)];
# # Make the final prediction by taking the minimum
# @info "Minimum-consensus aggregation"
# @time prediction7 = reduce(minimum, predictions);
# # Get the threshold for NaN given a percentile
# @info "Threshold estimation"
# @time threshold = first(quantile(prediction7[taxa_occ[7]], [0.05]))
# @info "5% threshold:\t$(round(threshold; digits=3))"
# # Filter the predictions based on the threshold
# @info "Final prediction filtering"
# @time for i in eachindex(prediction7.grid)
#     prediction7.grid[i] < threshold && (prediction7.grid[i] = NaN)
# end
#
# @info "Extract and crop bioclim variables"
# @time wc_vars = [clip(worldclim(i), taxa_occ[8]) for i in 1:19];
# # Make the prediction for each layer
# @info "Predictions for each layer"
# @time predictions = [bioclim(wc_vars[i], taxa_occ[8]) for i in 1:length(wc_vars)];
# # Make the final prediction by taking the minimum
# @info "Minimum-consensus aggregation"
# @time prediction8 = reduce(minimum, predictions);
# # Get the threshold for NaN given a percentile
# @info "Threshold estimation"
# @time threshold = first(quantile(prediction8[taxa_occ[8]], [0.05]))
# @info "5% threshold:\t$(round(threshold; digits=3))"
# # Filter the predictions based on the threshold
# @info "Final prediction filtering"
# @time for i in eachindex(prediction8.grid)
#     prediction8.grid[i] < threshold && (prediction8.grid[i] = NaN)
# end

# @info "Extract and crop bioclim variables"
# @time wc_vars = [clip(worldclim(i), taxa_occ[9]) for i in 1:19];
# # Make the prediction for each layer
# @info "Predictions for each layer"
# @time predictions = [bioclim(wc_vars[i], taxa_occ[9]) for i in 1:length(wc_vars)];
# # Make the final prediction by taking the minimum
# @info "Minimum-consensus aggregation"
# @time prediction9 = reduce(minimum, predictions);
# # Get the threshold for NaN given a percentile
# @info "Threshold estimation"
# @time threshold = first(quantile(prediction9[taxa_occ[9]], [0.05]))
# @info "5% threshold:\t$(round(threshold; digits=3))"
# # Filter the predictions based on the threshold
# @info "Final prediction filtering"
# @time for i in eachindex(prediction9.grid)
#     prediction9.grid[i] < threshold && (prediction9.grid[i] = NaN)
# end
#
# @info "Extract and crop bioclim variables"
# @time wc_vars = [clip(worldclim(i), taxa_occ[10]) for i in 1:19];
# # Make the prediction for each layer
# @info "Predictions for each layer"
# @time predictions = [bioclim(wc_vars[i], taxa_occ[10]) for i in 1:length(wc_vars)];
# # Make the final prediction by taking the minimum
# @info "Minimum-consensus aggregation"
# @time prediction10 = reduce(minimum, predictions);
# # Get the threshold for NaN given a percentile
# @info "Threshold estimation"
# @time threshold = first(quantile(prediction10[taxa_occ[10]], [0.05]))
# @info "5% threshold:\t$(round(threshold; digits=3))"
# # Filter the predictions based on the threshold
# @info "Final prediction filtering"
# @time for i in eachindex(prediction10.grid)
#     prediction10.grid[i] < threshold && (prediction10.grid[i] = NaN)
# end
#
# @info "Extract and crop bioclim variables"
# @time wc_vars = [clip(worldclim(i), taxa_occ[11]) for i in 1:19];
# # Make the prediction for each layer
# @info "Predictions for each layer"
# @time predictions = [bioclim(wc_vars[i], taxa_occ[11]) for i in 1:length(wc_vars)];
# # Make the final prediction by taking the minimum
# @info "Minimum-consensus aggregation"
# @time prediction11 = reduce(minimum, predictions);
# # Get the threshold for NaN given a percentile
# @info "Threshold estimation"
# @time threshold = first(quantile(prediction11[taxa_occ[11]], [0.05]))
# @info "5% threshold:\t$(round(threshold; digits=3))"
# # Filter the predictions based on the threshold
# @info "Final prediction filtering"
# @time for i in eachindex(prediction11.grid)
#     prediction11.grid[i] < threshold && (prediction11.grid[i] = NaN)
# end
#
# @info "Extract and crop bioclim variables"
# @time wc_vars = [clip(worldclim(i), taxa_occ[12]) for i in 1:19];
# # Make the prediction for each layer
# @info "Predictions for each layer"
# @time predictions = [bioclim(wc_vars[i], taxa_occ[12]) for i in 1:length(wc_vars)];
# # Make the final prediction by taking the minimum
# @info "Minimum-consensus aggregation"
# @time prediction12 = reduce(minimum, predictions);
# # Get the threshold for NaN given a percentile
# @info "Threshold estimation"
# @time threshold = first(quantile(prediction12[taxa_occ[12]], [0.05]))
# @info "5% threshold:\t$(round(threshold; digits=3))"
# # Filter the predictions based on the threshold
# @info "Final prediction filtering"
# @time for i in eachindex(prediction12.grid)
#     prediction12.grid[i] < threshold && (prediction12.grid[i] = NaN)
# end
#
# @info "Extract and crop bioclim variables"
# @time wc_vars = [clip(worldclim(i), taxa_occ[13]) for i in 1:19];
# # Make the prediction for each layer
# @info "Predictions for each layer"
# @time predictions = [bioclim(wc_vars[i], taxa_occ[13]) for i in 1:length(wc_vars)];
# # Make the final prediction by taking the minimum
# @info "Minimum-consensus aggregation"
# @time prediction13 = reduce(minimum, predictions);
# # Get the threshold for NaN given a percentile
# @info "Threshold estimation"
# @time threshold = first(quantile(prediction13[taxa_occ[13]], [0.05]))
# @info "5% threshold:\t$(round(threshold; digits=3))"
# # Filter the predictions based on the threshold
# @info "Final prediction filtering"
# @time for i in eachindex(prediction13.grid)
#     prediction13.grid[i] < threshold && (prediction13.grid[i] = NaN)
# end
#
# @info "Extract and crop bioclim variables"
# @time wc_vars = [clip(worldclim(i), taxa_occ[14]) for i in 1:19];
# # Make the prediction for each layer
# @info "Predictions for each layer"
# @time predictions = [bioclim(wc_vars[i], taxa_occ[14]) for i in 1:length(wc_vars)];
# # Make the final prediction by taking the minimum
# @info "Minimum-consensus aggregation"
# @time prediction14 = reduce(minimum, predictions);
# # Get the threshold for NaN given a percentile
# @info "Threshold estimation"
# @time threshold = first(quantile(prediction14[taxa_occ[14]], [0.05]))
# @info "5% threshold:\t$(round(threshold; digits=3))"
# # Filter the predictions based on the threshold
# @info "Final prediction filtering"
# @time for i in eachindex(prediction14.grid)
#     prediction14.grid[i] < threshold && (prediction14.grid[i] = NaN)
# end
#
# @info "Extract and crop bioclim variables"
# @time wc_vars = [clip(worldclim(i), taxa_occ[15]) for i in 1:19];
# # Make the prediction for each layer
# @info "Predictions for each layer"
# @time predictions = [bioclim(wc_vars[i], taxa_occ[15]) for i in 1:length(wc_vars)];
# # Make the final prediction by taking the minimum
# @info "Minimum-consensus aggregation"
# @time prediction15 = reduce(minimum, predictions);
# # Get the threshold for NaN given a percentile
# @info "Threshold estimation"
# @time threshold = first(quantile(prediction8[taxa_occ[15]], [0.05]))
# @info "5% threshold:\t$(round(threshold; digits=3))"
# # Filter the predictions based on the threshold
# @info "Final prediction filtering"
# @time for i in eachindex(prediction15.grid)
#     prediction15.grid[i] < threshold && (prediction15.grid[i] = NaN)
# end
#
# @info "Extract and crop bioclim variables"
# @time wc_vars = [clip(worldclim(i), taxa_occ[16]) for i in 1:19];
# # Make the prediction for each layer
# @info "Predictions for each layer"
# @time predictions = [bioclim(wc_vars[i], taxa_occ[16]) for i in 1:length(wc_vars)];
# # Make the final prediction by taking the minimum
# @info "Minimum-consensus aggregation"
# @time prediction16 = reduce(minimum, predictions);
# # Get the threshold for NaN given a percentile
# @info "Threshold estimation"
# @time threshold = first(quantile(prediction16[taxa_occ[16]], [0.05]))
# @info "5% threshold:\t$(round(threshold; digits=3))"
# # Filter the predictions based on the threshold
# @info "Final prediction filtering"
# @time for i in eachindex(prediction16.grid)
#     prediction16.grid[i] < threshold && (prediction16.grid[i] = NaN)
# end

# # predictions = [prediction1, prediction2, prediction3, prediction4]
# # prediction5, prediction6, prediction7, prediction8]
#                # prediction9, prediction10, prediction11,
#                # prediction12, prediction13, prediction14, prediction15, prediction16]
#
# ## Export predictions
# @save "../SDM/data/predictions_vulpes_vulpes_am.jld2" predictions
#
# # Test import
# @load "data/predictions_vulpes_vulpes.jld2" predictions
