using DataFrames
using CSV

cd("/Users/kiristern/Documents/GitHub/SDM/")

predators = CSV.read("data/preds/originals/Puma_concolor2.csv")

# select only ursus arctos from imported all predators csv file
#df = predators[predators.species .== "Ursus arctos", :]

prey1 = CSV.read("data/prey_sp/Sus_scrofa2.csv")
prey2 = CSV.read("data/prey_sp/Odocoileus_hemionus2.csv")

#create one dataframe with predators/prey dataframes
pred_prey = vcat(predators, prey1, prey2)

pred_prey = select(pred_prey, [:species, :decimalLatitude, :decimalLongitude, :year])

pred_prey = dropmissing!(pred_prey, [:decimalLatitude, :decimalLongitude, :year])

# rename!(pred_prey, :decimalLatitude => :latitude)
# rename!(pred_prey, :decimalLongitude => :longitude)

CSV.write("data/pred_prey/Puma_concolor.csv", pred_prey)





#select for one species from dataframe
species = [pred_prey[pred_prey.species .== u,:] for u in unique(pred_prey.species)]
occ = species[1]
