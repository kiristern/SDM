using DataFrames
using CSV

cd("/Users/kiristern/Documents/GitHub/SDM/")

predators = CSV.read("data/preds/originals/Nasua_nasua2.csv")
predators = select(predators, [:species, :decimalLatitude, :decimalLongitude, :year])

# select only ursus arctos from imported all predators csv file
#df = predators[predators.species .== "Ursus arctos", :]

p1 = CSV.read("data/prey_class/Diplopoda2.csv")
p1 = select(p1,[:class, :decimalLatitude, :decimalLongitude, :year])
rename!(p1, :class => :species)

#create one dataframe with predators/prey dataframes
pred_prey = vcat(predators, p1)

pred_prey = dropmissing!(pred_prey, [:decimalLatitude, :decimalLongitude, :year])

CSV.write("data/pred_prey/Nasua_nasua.csv", pred_prey)

show(by(pred_prey, :species, :species => length), allcols=true)
