using DataFrames
using CSV

cd("/Users/kiristern/Documents/GitHub/SDM/")

predators = CSV.read("data/preds/originals/Ursus_arctos_horribilis.csv")

# select only ursus arctos from imported all predators csv file
#df = predators[predators.species .== "Ursus arctos", :]

prey = CSV.read("data/prey_sp/Cervus_canadensis.csv")

#create one dataframe with predators/prey dataframes
pred_prey = vcat(predators, prey)

pred_prey = select(pred_prey, [:species, :decimalLatitude, :decimalLongitude, :year])

pred_prey = dropmissing!(pred_prey, [:decimalLatitude, :decimalLongitude, :year])

# rename!(pred_prey, :decimalLatitude => :latitude)
# rename!(pred_prey, :decimalLongitude => :longitude)

CSV.write("data/pred_prey/Ursus_arctos_horribilis.csv", pred_prey)





#select for one species from dataframe
species = [pred_prey[pred_prey.species .== u,:] for u in unique(pred_prey.species)]
occ = species[1]
