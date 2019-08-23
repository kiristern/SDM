using Distributed
using JLD2

include("../BioClim/src/required.jl")

## Get & prepare data
## Get & prepare data
@time @everywhere begin
    # Load data from CSV files
    df = CSV.read("/Users/kiristern/Documents/GitHub/SDM/data/pred_prey/Puma_concolor.csv", header=true)
    # Prepare data (select columns, arrange values)
    df = prepare_gbif_data(df)
    # Separate species
    taxa_occ = [df[df.species .== u,:] for u in unique(df.species)]
    #
    # # Define coordinates range
    # lon_range = (-145.0, -50.0)
    # lat_range = (20.0, 75.0)
end

# ## Get the worldclim data
# @time wc_vars = pmap(x -> worldclim(x), 1:19);
# temp = wc_vars[1]

## Load predictions
@load "../SDM/data/predictions.jld2" predictions
pred = predictions[1]
prey1 = predictions[2]
prey2 = predictions[3]

# Combine layers
layers = [pred, prey1, prey2]

# Create function
function expand_layers(layers::Array{SDMLayer{Float64},1})
    # Get minimum coordinates
    min_lon = min(map(x -> x.left, layers)...)
    max_lon = max(map(x -> x.right, layers)...)
    min_lat = min(map(x -> x.bottom, layers)...)
    max_lat = max(map(x -> x.top, layers)...)

    # Get grid size (rounding should prevent problems with last decimal)
    grid_size_lons = 1/round(1/stride(layers[1],1))
    grid_size_lats = 1/round(1/stride(layers[1],2))

    # Get coordinate range of newlayer -> original layers must have same stride
    lons_newlayers = min_lon+grid_size_lons:2*grid_size_lons:max_lon-grid_size_lons
    lats_newlayers = min_lat+grid_size_lats:2*grid_size_lats:max_lat-grid_size_lats

    # Create expanded layers
    newlayers = []
    for i in 1:length(layers)
        # Get position of original layers in new layer
        ## find where the point = 0 (= min value; all others are the absolute value)
        m_lon = findmin(abs.(layers[i].left+grid_size_lons .- lons_newlayers))[2]
        M_lon = findmin(abs.(layers[i].right-grid_size_lons .- lons_newlayers))[2]
        m_lat = findmin(abs.(layers[i].bottom+grid_size_lats .- lats_newlayers))[2]
        M_lat = findmin(abs.(layers[i].top-grid_size_lats .- lats_newlayers))[2]
        # Create new grid
        newgrid = fill(NaN, length(lats_newlayers), length(lons_newlayers))
        # Fill in original values
        newgrid[(m_lat:M_lat), (m_lon:M_lon)] .= layers[i].grid
        #
        newlayer = SDMLayer(newgrid, min_lon, max_lon, min_lat, max_lat)
        # Export result
        push!(newlayers, newlayer)
    end
    return newlayers
end

@time newlayers = expand_layers(layers)

#find probability of species occuring together
# probs = ones(size(newlayers[1]))
probs = copy(newlayers[1].grid)
for j in 2:length(newlayers)
    for k in 1:length(newlayers[1].grid)
        if !isnan(probs[k]) && !isnan(newlayers[j][k])
            probs[k] = probs[k] .* newlayers[j][k]
        end
    end
end
probs

presence = probs .== newlayers[1].grid
probs[presence] .= NaN
#check if there are values other than 1.0
# filter(!isone, probs)
# #change all 1.0 values to NaN
# replace!(probs, 1.0 .=> NaN)

filter(!isnan, probs)

# Convert to SDMLayer
test = SDMLayer(probs, newlayers[1].left, newlayers[1].right, newlayers[1].bottom, newlayers[1].top)


plot_test = plotSDM(test)

# Plot result
plotp1 = plotSDM(pred)
plotp2 = plotSDM(prey1)
plotn1 = plotSDM(newlayers[1])
plotn2 = plotSDM(newlayers[2])
plotn3 = plotSDM(newlayers[3])

# Combine heatmaps
sdm_plot = plotSDM(newlayers[1])
heatmap!(
    sdm_plot,
    longitudes(newlayers[3]), latitudes(newlayers[3]), # layer range
    newlayers[3].grid, # evenness values
    c=:viridis, # ~color palette
    clim=(0.0, maximum(filter(!isnan, newlayers[3].grid)))) # colorbar limits

# plot!(
#     sdm_plot,
#     xlims=(pred.left, pred.right),
#     ylims=(pred.bottom, pred.top),
#     aspectratio=92.60/60.75
# )
# Compare to p2
plotp1

#probability of species overlap
prob = pred .* prey1
