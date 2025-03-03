using Distributed
using JLD2

include("../BioClim/src/required.jl")

## Get & prepare data
@time @everywhere begin
    # Load data from CSV files
    df = CSV.read("/Users/kiristern/Documents/GitHub/SDM/data/pred_prey/Puma_concolor.csv", header=true)
    # Prepare data (select columns, arrange values)
    df = prepare_gbif_data(df)
    # Separate species
    taxa_occ = [df[df.species .== u,:] for u in unique(df.species)]
end

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
        # Convert to SDMLayer
        newlayer = SDMLayer(newgrid, min_lon, max_lon, min_lat, max_lat)
        # Export result
        push!(newlayers, newlayer)
    end
    return newlayers
end

@time newlayers = expand_layers(layers)

#find probability of species occuring together
probs = copy(newlayers[1].grid)
for j in 2:length(newlayers)
    for k in 1:length(newlayers[1].grid)
        if !isnan(probs[k]) && !isnan(newlayers[j][k])
            probs[k] = probs[k] .* newlayers[j][k]
        end
    end
end
probs

#check if probability of occurence changed (thus overlap in species occurence)
presence = probs .== newlayers[1].grid
#if no change, change to NaN
probs[presence] .= NaN

filter(!isnan, probs)

# Convert to SDMLayer
test = SDMLayer(probs, newlayers[1].left, newlayers[1].right, newlayers[1].bottom, newlayers[1].top)

plot_test = plotSDM(test)
