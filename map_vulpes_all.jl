using Distributed
using JLD2

include("../BioClim/src/required.jl")
# include("expandlayers_vulpes_vulpes.jl")

taxa_occ[2]

#using new_predictions from north america only
newlayers = new_predictions

#create empty array
presence_all = []
# fill pred/prey pp_presence matrix with binary values (1 if present, 0 if not)
@time for i in 1:length(newlayers)     # iterate through all species
    # create new empty matrix for predator presence, dimensions of predator newlayers[1]
        pp_presence = zeros(Int64, size(newlayers[1]))
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
    sum_all .+= presence_all[k]
end

#replace zeros to NaN
sum_all = replace(sum_all, 0 => NaN)

#save as SDMLayer
sum_lay = SDMLayer(sum_all, newlayers[1].left, newlayers[1].right, newlayers[1].bottom, newlayers[1].top)

plot_sum = plotSDM(sum_lay)
plot_sum = plot!(title="All species overlap")


#crop to americas range only
long_range = (-180.0, -46.0)
lat_range = (-90.0, 90.0)
#specify the range of sum_lay
sum_lay_Am = sum_lay[long_range, lat_range]

plot_am = plotSDM(sum_lay_Am)
plot_sum = plot!(title="All species overlap")



#####################
##get sum where only predator is present
sum_on_pred = copy(presence_all[1])
#add arrays to pred array
for k in 2:length(presence_all)
    for j in 1:length(presence_all[1])
    #only add where predator species is present
         if presence_all[1][j] == 1
            sum_on_pred[j] = sum_on_pred[j] .+ presence_all[k][j]
        end
    end
end

#replace zeros to NaN
sum_on_pred = replace(sum_on_pred, 0 => NaN)

#save as SDMLayer
sum_lay_pred = SDMLayer(sum_on_pred, newlayers[1].left, newlayers[1].right, newlayers[1].bottom, newlayers[1].top)

plot_sum_on_pred = plotSDM(sum_lay_pred)
plot_sum_on_pred = plot!(title="Presence map: vulpes vulpes")
savefig("../SDM/figures/vulpes_vulpes/sdm_map-vulpes_northamerica.pdf")

#crop to americas range only
long_range = (-180.0, -46.0)
lat_range = (-90.0, 90.0)
#specify the range of sum_lay_pred
sum_lay_Am = sum_lay_pred[long_range, lat_range]

plot_am = plotSDM(sum_lay_Am)
plot_am = plot!(title="All species overlap")
savefig("../SDM/figures/vulpes_vulpes/sdm_map-vulpes_vulpes_america.pdf")

###############################
###plot individual sp map
taxa_occ[4]

plot1 = plotSDM(new_predictions[1])
plot1 = plot!(title="Vulpes vulpes")
savefig("../SDM/figures/vulpes_vulpes/sdm_map-vulpes_vulpes_newpredictions.pdf")

plot2 = plotSDM(new_predictions[2])
plot2 = plot!(title="Cynomys ludovicianus")
savefig("../SDM/figures/vulpes_vulpes/sdm_map-cynomys_ludovicianus.pdf")

plot3 = plotSDM(new_predictions[3])
plot3 = plot!(title="Tetrix subulata")
savefig("../SDM/figures/vulpes_vulpes/sdm_map-tetrix_subulata.pdf")

plot4 = plotSDM(new_predictions[4])
plot4 = plot!(title="Lepus europaeus")
savefig("../SDM/figures/vulpes_vulpes/sdm_map-lepus_europaeus.pdf")
