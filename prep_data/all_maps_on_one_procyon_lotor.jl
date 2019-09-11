using Distributed
using JLD2

include("../BioClim/src/required.jl")

## Get & prepare data
## Get & prepare data
@time @everywhere begin
    # Load data from CSV files
    #df = CSV.read("/Users/kiristern/Documents/GitHub/SDM/data/pred_prey/Puma_concolor.csv", header=true)
    # Prepare data (select columns, arrange values)
    #df = prepare_gbif_data(df)
    df = pred_prey
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
@load "data/predictions.jld2" predictions
pred = predictions[1]
p1 = predictions[2]
p2 = predictions[3]
p3 = predictions[4]
p4 = predictions[5]
p5 = predictions[6]
p6 = predictions[7]
p7 = predictions[8]
# Combine layers
layers = [pred, p1, p2,p3,p4,p5,p6,p7]

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
        # Convert to SDMLayer
        newlayer = SDMLayer(newgrid, min_lon, max_lon, min_lat, max_lat)
        # Export result
        push!(newlayers, newlayer)
    end
    return newlayers
end

@time newlayers = expand_layers(layers)

# Plot result
plotn1 = plotSDM(newlayers[1])
plotn2 = plotSDM(newlayers[2])
plotn3 = plotSDM(newlayers[3])

# Combine heatmaps
sdm_plot = plotSDM(newlayers[1])
heatmap!(
    sdm_plot,
    longitudes(newlayers[5]), latitudes(newlayers[5]), # layer range
    newlayers[5].grid, # evenness values
    c=cgrad([:lightpurple, :purple, :darkpurple]), # ~color palette
    clim=(0.0, maximum(filter(!isnan, newlayers[5].grid)))) # colorbar limits
sdm_plot
# plot!(
#     sdm_plot,
#     xlims=(pred.left, pred.right),
#     ylims=(pred.bottom, pred.top),
#     aspectratio=92.60/60.75
# )
# Compare to p2
plotp1
