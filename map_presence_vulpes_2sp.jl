using Distributed
using JLD2

include("../BioClim/src/required.jl")
include("expandlayers_vulpes_vulpes.jl")

taxa_occ[2]

##Presence maps
# create new empty matrix for predator presence, dimensions of predator newlayers[1]
pred_presence = zeros(Int64, 2031, 4223)

# fill pred_presence matrix with binary values (1 if present, 0 if not)
#length of columns
for i in 1:size(newlayers[1].grid,2)
    #length of rows
    for j in 1:size(newlayers[1].grid,1)
        if isnan((newlayers[1].grid)[j,i])
            pred_presence[j,i] = 0
        else
            pred_presence[j,i] = 1
        end
    end
end

# view binary presence-absence result
pred_presence

# create new empty matrix for prey1 presence, Armadillidium opacum
prey1_pres = zeros(Int64, 2031, 4223)

# fill prey1_pres matrix with binary values (1 if present, 0 if not)
for i in 1:size(newlayers[3].grid,2)
    for j in 1:size(newlayers[3].grid,1)
        if isnan((newlayers[3].grid)[j,i])
            prey1_pres[j,i] = 0
        else
            prey1_pres[j,i] = 1
        end
    end
end
prey1_pres

#add predator and prey1 matrices
sum1 = pred_presence .+ prey1_pres

# #add only where predator is present
# for k in 1:length(sum1)
#     if pred_presence[k] == 1
#         sum1 = pred_presence[k] .+ prey1_pres[k]
#     end
# end

#filter only occurence data (ie. values of 2)
for l in 1:length(sum1)
    if sum1[l] == 2
        sum1[l] = 2
    else
        sum1[l] = 0
    end
end

#replace zeros to NaN for clearer image when mapping
sum1 = replace(sum1, 0 => NaN)

# Convert to SDMLayer
sum1_lay = SDMLayer(sum1, newlayers[1].left, newlayers[1].right, newlayers[1].bottom, newlayers[1].top)

plot_sum1 = plotSDM(sum1_lay)
plot_sum1 = plot!(title="Vulpes vulpes and Armadillidium opacum")
savefig("../SDM/figures/vulpes_vulpes/sdm_map-Procyon_lotor_w_p1.pdf")
