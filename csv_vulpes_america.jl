using CSV
using DataFrames

df = CSV.read("../SDM/data/pred_prey/Vulpes_vulpes_sp.csv")

newdf = df[df.decimalLongitude .<=-45,:]

taxa_occ = [newdf[newdf.species .== u,:] for u in unique(newdf.species)]

sp_import = ["Vulpes vulpes", "Cynomys ludovicianus", "Tetrix subulata", "Lepus europaeus"]
imported = [newdf[newdf.species .== u,:] for u in sp_import]
newdf = vcat(imported...)

# vulpes = newdf[newdf.species .== "Vulpes vulpes", :]
# cynomys = newdf[newdf.species .== "Cynomys ludovicianus",:
# tetrix = newdf[newdf.species .== "Tetrix subulata", :]
# lepus = newdf[newdf.species .== "Lepus europaeus", :]
#
# newdf = vcat(vulpes, cynomys, tetrix, lepus)

CSV.write("../SDM/data/pred_prey/vulpes_vulpes_america.csv", newdf)
