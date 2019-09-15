using Distributed
using JLD2

include("../BioClim/src/required.jl")
include("expandlayers_vulpes_vulpes.jl")

taxa_occ[2]

#create empty array
presence_all = []
# fill pred/prey pp_presence matrix with binary values (1 if present, 0 if not)
@time for i in 1:length(newlayers)     # iterate through all species
    # create new empty matrix for predator presence, dimensions of predator newlayers[1]
        pp_presence = zeros(Int64, 2031, 4223)
        for j in 1:length(newlayers[1].grid)   # iterate through all coordinates
            if isnan(newlayers[i][j])
                pp_presence[j] = 0
            else
                pp_presence[j] = 1
            end
        end
        push!(presence_all, pp_presence)
    end
presence_all

##get sum
sum_all = copy(presence_all[1])
#add arrays to pred array
for k in 2:length(presence_all)
    #only add where predator species is present
    #if presence_all[1][k] == 1
        sum_all .+= presence_all[k]
    end
end


##get sum
sum_all_test = copy(presence_all[1])
#add arrays to pred array
for k in 2:length(presence_all)
    sum_all_test = copy(presence_all[1])
    #only add where predator species is present
    if presence_all[1][k] == 1
        sum_all_test = sum_all_test .+ presence_all[k]
    end
end

#replace zeros to NaN
sum_all = replace(sum_all, 0 => NaN)

#save as SDMLayer
sum_lay = SDMLayer(sum_all, newlayers[1].left, newlayers[1].right, newlayers[1].bottom, newlayers[1].top)

plot_sum = plotSDM(sum_lay)

#crop to americas range only
long_range = (-180.0, -46.0)
lat_range = (-90.0, 90.0)
#specify the range of sum_lay
sum_lay_Am = sum_lay[long_range, lat_range]

plot_am = plotSDM(sum_lay_Am)
