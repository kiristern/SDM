using Distributed
using JLD2

include("../BioClim/src/required.jl")
include("expandlayers_vulpes_vulpes.jl")


#find probability of species occuring together
#create array, probs, using pred data
probs = copy(newlayers[1].grid)
#for all prey data
@time for j in 2:length(newlayers)     # iterate through all preys
    for k in 1:length(newlayers[1].grid)   # iterate through all coordinates
        #if the probability of overlap is not NaN (ie. overlap) AND if prey occurence is not NaN value
        if !isnan(probs[k]) && !isnan(newlayers[j][k])
            #then multiply the probability of sp 1,2,3... occurence by the next sp
            probs[k] = probs[k] .* newlayers[j][k]
        end
    end
end
probs

#check if probability of occurence changed (thus overlap in species occurence) -- if newlayers[1] value changes or not
presence = probs .== newlayers[1].grid
#if no change, change to NaN
probs[presence] .= NaN
#filter only occurence data (ie. not NaN values)
filter(!isnan, probs)

# Convert to SDMLayer
map_layer = SDMLayer(probs, newlayers[1].left, newlayers[1].right, newlayers[1].bottom, newlayers[1].top)

plot_layer = plotSDM(map_layer)
plot_layer = plot!(title="Probability of Occurence: Vulpes vulpes")
plot_layer

savefig("../SDM/figures/sdm_map-Procyon_lotor_probability_title.pdf")
