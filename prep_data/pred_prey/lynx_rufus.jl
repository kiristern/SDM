using DataFrames
using CSV

cd("/Users/kiristern/Documents/GitHub/SDM/")

predators = CSV.read("data/preds/originals/Canis_latrans.csv")
# # create new column "new_sp" for subspecies naming
# predators.new_sp = copy(predators.species)
# for i in 1:length(df)
#     if predators.taxonRank[i] == "SUBSPECIES"
#         predators.new_sp[i] = string(predators.species[i], "_", df.infraspecificEpithet[i])
#     end
# end

predators = select(predators, [:species, :decimalLatitude, :decimalLongitude, :year])


# select only ursus arctos from imported all predators csv file
#df = predators[predators.species .== "Ursus arctos", :]

p1 = CSV.read("data/prey_sp/Thamnophis_atratus.csv", delim="\t")
p1 = select(p1,[:species, :decimalLatitude, :decimalLongitude, :year])

p2 = CSV.read("data/prey_sp/Taricha_torosa.csv", delim="\t")
p2 = select(p2,[:species, :decimalLatitude, :decimalLongitude, :year])

p3 = CSV.read("data/prey_sp/Rana_draytonii.csv", delim="\t")
p3 = select(p3,[:species, :decimalLatitude, :decimalLongitude, :year])

p4 = CSV.read("data/prey_sp/Spermophilus_beecheyi.csv", delim="\t")
p4 = select(p4,[:species, :decimalLatitude, :decimalLongitude, :year])

p5 = CSV.read("data/prey_sp/Anaxyrus_boreas.csv", delim="\t")
p5 = select(p5,[:species, :decimalLatitude, :decimalLongitude, :year])

p6 = CSV.read("data/prey_sp/Fulica_americana.csv", delim="\t")
p6 = select(p6,[:species, :decimalLatitude, :decimalLongitude, :year])

p7 = CSV.read("data/prey_sp/Otospermophilus_beecheyi.csv", delim="\t")
p7 = select(p7,[:species, :decimalLatitude, :decimalLongitude, :year])

p8 = CSV.read("data/prey_sp/Odocoileus_virginianus.csv", delim="\t")
p8 = select(p8,[:species, :decimalLatitude, :decimalLongitude, :year])

p9 = CSV.read("data/prey_sp/Thomomys_bottae.csv", delim="\t")
p9 = select(p9,[:species, :decimalLatitude, :decimalLongitude, :year])

# p10 = CSV.read("data/prey_sp/Boiga_irregularis.csv", delim="\t")
# p10 = select(p10,[:species, :decimalLatitude, :decimalLongitude, :year])
#
# p11 = CSV.read("data/prey_sp/Trichosurus_vulpecula.csv", delim="\t")
# p11 = select(p11,[:species, :decimalLatitude, :decimalLongitude, :year])
#
# p12 = CSV.read("data/prey_sp/Tachyglossus_aculeatus.csv", delim="\t")
# p12 = select(p12,[:species, :decimalLatitude, :decimalLongitude, :year])


#create one dataframe with predators/prey dataframes
pred_prey = vcat(predators, p1, p2, p3, p4, p5,p6,p7,p8,p9)

pred_prey = dropmissing!(pred_prey, [:decimalLatitude, :decimalLongitude, :year])

# rename!(pred_prey, :decimalLatitude => :latitude)
# rename!(pred_prey, :decimalLongitude => :longitude)



CSV.write("data/pred_prey/Canis_latrans.csv", pred_prey)






#select for one species from dataframe
species = [pred_prey[pred_prey.species .== u,:] for u in unique(pred_prey.species)]
occ = species[1]
