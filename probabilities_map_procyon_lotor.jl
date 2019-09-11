using Distributed
using JLD2

include("../BioClim/src/required.jl")

## Get & prepare data
@time @everywhere begin
    # Load data from CSV files
    #df = CSV.read("/Users/kiristern/Documents/GitHub/SDM/data/pred_prey/Puma_concolor.csv", header=true)
    # Prepare data (select columns, arrange values)
    # df = prepare_gbif_data(pred_prey)
    df = pred_prey
    # Separate species
    taxa_occ = [df[df.species .== u,:] for u in unique(df.species)]
end

## Load predictions
@load "../SDM/data/predictions_procyon_lotor.jld2" predictions
pred = predictions[1]
p1 = predictions[2]
p2 = predictions[3]
p3 = predictions[4]
p4 = predictions[5]
p5 = predictions[6]
p6 = predictions[7]
p7 = predictions[8]

# Combine layers
layers = [pred, p1, p2, p3,p4,p5,p6,p7]

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
#create array, probs, using pred data
probs = copy(newlayers[1].grid)
#for all prey data
@time for j in 2:length(newlayers)
    for k in 1:length(newlayers[1].grid)
        #if prey occurence is not NaN value AND if the probability of overlap is not NaN (ie. no overlap)
        if !isnan(probs[k]) && !isnan(newlayers[j][k])
            #then multiply the probability of sp 1,2,3... by the next sp
            probs[k] = probs[k] .* newlayers[j][k]
        end
    end
end
probs

#check if probability of occurence changed (thus overlap in species occurence) -- if layer[1] value changes or not
presence = probs .== newlayers[1].grid
#if no change, change to NaN
probs[presence] .= NaN
#filter only occurence data (ie. not NaN values)
filter(!isnan, probs)

# Convert to SDMLayer
map_layer = SDMLayer(probs, newlayers[1].left, newlayers[1].right, newlayers[1].bottom, newlayers[1].top)

plot_layer = plotSDM(map_layer)
plot_layer = plot!(title="Probability of Occurence: Procyon lotor")

savefig("../SDM/figures/sdm_map-Procyon_lotor_predictions_title.pdf")




#save sp individual maps
worldmap = clip(worldshape(50), pred)

sdm_plot = plot([0.0], lab = " ", msw = 0.0, ms = 0.0, size = (900, 450), frame=:box,
                title = "Procyon lotor")
xaxis!(sdm_plot, (pred.left, pred.right), "Longitude")
yaxis!(sdm_plot, (pred.bottom, pred.top), "Latitude")

for p in worldmap
    sh = Shape([pp.x for pp in p.points], [pp.y for pp in p.points])
    plot!(sdm_plot, sh, c = :lightgrey, lab = " ")
end

heatmap!(
    sdm_plot,
    longitudes(pred), latitudes(pred), pred.grid,
    aspectratio = 92.60/60.75, c = :BuPu,
    clim = (0.0, maximum(filter(!isnan, pred.grid)))
    )

for p in worldmap
    xy = map(x -> (x.x, x.y), p.points)
    plot!(sdm_plot, xy, c=:grey, lab = " ", leg=false)
end
sdm_plot

savefig("../SDM/figures/sdm_map-Procyon_lotor.pdf")



#save for preys
worldmap = clip(worldshape(50), p7)

sdm_plot = plot([0.0], lab = " ", msw = 0.0, ms = 0.0, size = (900, 450), frame=:box,
                title = "Anas platyrhynchos")
xaxis!(sdm_plot, (p7.left, p7.right), "Longitude")
yaxis!(sdm_plot, (p7.bottom, p7.top), "Latitude")

for p in worldmap
    sh = Shape([pp.x for pp in p.points], [pp.y for pp in p.points])
    plot!(sdm_plot, sh, c = :lightgrey, lab = " ")
end

heatmap!(
    sdm_plot,
    longitudes(p7), latitudes(p7), p7.grid,
    aspectratio = 92.60/60.75, c = :BuPu,
    clim = (0.0, maximum(filter(!isnan, p7.grid)))
    )

for p in worldmap
    xy = map(x -> (x.x, x.y), p.points)
    plot!(sdm_plot, xy, c=:grey, lab = " ", leg=false)
end
sdm_plot

savefig("../SDM/figures/sdm_map-Anas_platyrhynchos.pdf")
