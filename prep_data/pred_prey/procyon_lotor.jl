using DataFrames
using CSV

cd("/Users/kiristern/Documents/GitHub/SDM/")

predators = CSV.read("data/preds/originals/Procyon_lotor.csv", delim="\t")
predators = select(predators, [:species, :decimalLatitude, :decimalLongitude, :year])

# select only ursus arctos from imported all predators csv file
#df = predators[predators.species .== "Ursus arctos", :]

p1 = CSV.read("data/prey_sp/Bufo_bufo.csv")
p1 = select(p1,[:genus, :decimalLatitude, :decimalLongitude, :year])
rename!(p1, :genus => :species)

p2 = CSV.read("data/prey_sp/Caiman_yacare.csv", delim="\t")
p2 = select(p2,[:species, :decimalLatitude, :decimalLongitude, :year])

p3 = CSV.read("data/prey_sp/Emberiza_citrinella.csv", delim="\t")
p3 = select(p3,[:species, :decimalLatitude, :decimalLongitude, :year])

p4 = CSV.read("data/prey_sp/Larus_canus.csv", delim="\t")
p4 = select(p4,[:species, :decimalLatitude, :decimalLongitude, :year])

#create one dataframe with predators/prey dataframes
pred_prey = vcat(predators, p2)

pred_prey = select(pred_prey, [:species, :decimalLatitude, :decimalLongitude, :year])

pred_prey = dropmissing!(pred_prey, [:decimalLatitude, :decimalLongitude, :year])

CSV.write("data/pred_prey/Panthera_onca.csv", pred_prey)

show(by(pred_prey, :species, :species => length), allcols=true)
