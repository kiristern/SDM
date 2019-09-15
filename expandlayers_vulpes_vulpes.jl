using Distributed
using JLD2

include("../BioClim/src/required.jl")

## Get & prepare data
@time @everywhere begin
    # Load data from CSV files
    df = CSV.read("/Users/kiristern/Documents/GitHub/SDM/data/pred_prey/Vulpes_vulpes_sp.csv", header=true)
    # Prepare data (select columns, arrange values)
    #df = prepare_gbif_data(pred_prey)
    ## no need to import dataframe since already in workspace under pred_prey
    ##df = pred_prey
    # Separate species
    taxa_occ = [df[df.species .== u,:] for u in unique(df.species)]
end

taxa_occ[2]

## Load predictions
@load "../SDM/data/predictions_vulpes_vulpes.jld2" predictions
pred = predictions[1]
p1 = predictions[2]
p2 = predictions[3]
p3 = predictions[4]
p4 = predictions[5]
p5 = predictions[6]
p6 = predictions[7]
p7 = predictions[8]
p8 = predictions[9]
p9 = predictions[10]
p10 = predictions[11]
p11 = predictions[12]
p12 = predictions[13]
p13 = predictions[14]
p14 = predictions[15]
p15 = predictions[16]

# Combine layers
layers = [pred, p1, p2, p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15]

# Create function to set layers all on the same scale (global)
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
