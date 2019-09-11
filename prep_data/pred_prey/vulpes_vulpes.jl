using DataFrames
using CSV

cd("/Users/kiristern/Documents/GitHub/SDM/")

predators = CSV.read("data/preds/originals/Vulpes_vulpes.csv", delim="\t")

p1 = CSV.read("data/prey_sp/Armadillidium_opacum.csv", delim="\t")

p2 = CSV.read("data/prey_sp/Lithobius_piceus.csv", delim="\t")

p3 = CSV.read("data/prey_sp/Tetrix_subulata.csv", delim="\t")

p4 = CSV.read("data/prey_sp/Conocephalus_fuscus.csv", delim="\t")

p5 = CSV.read("data/prey_sp/Chorthippus_montanus.csv", delim="\t")

p6 = CSV.read("data/prey_sp/Staphylinus_erythropterus.csv", delim="\t")

p7 = CSV.read("data/prey_sp/Conocephalus_dorsalis.csv", delim="\t")

p8 = CSV.read("data/prey_sp/Rana_temporaria.csv", delim="\t")
#cannot convert "missing" values to Float64, so must dropmissing first
p8 = dropmissing(p8, [:decimalLongitude])
# convert longitude character "string" into "Float64"
p8.decimalLongitude = parse.(Float64, p8.decimalLongitude)

p9 = CSV.read("data/prey_sp/Hyla_arborea.csv", delim="\t")

p10 = CSV.read("data/prey_sp/Sylvia_atricapilla.csv", delim="\t")

p11 = CSV.read("data/prey_sp/Microtus_agrestis.csv", delim="\t")

p12 = CSV.read("data/prey_sp/Threskiornis_molucca.csv", delim="\t")

p13 = CSV.read("data/prey_sp/Lepus_europaeus.csv", delim="\t")

p14 = CSV.read("data/prey_sp/Timarcha_tenebricosa.csv", delim="\t")

p15 = CSV.read("data/prey_sp/Sciurus_vulgaris.csv", delim="\t")

p16 = CSV.read("data/prey_sp/Cynomys_ludovicianus.csv", delim="\t")

#create one dataframe with predators/prey dataframes
pred_prey = vcat(predators, p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16)

pred_prey = select(pred_prey, [:species, :decimalLatitude, :decimalLongitude, :year])

pred_prey = dropmissing!(pred_prey, [:decimalLatitude, :decimalLongitude, :year])
pred_prey.decimalLongitude = parse.(Float64, pred_prey.decimalLongitude)


CSV.write("data/pred_prey/Procyon_lotor.csv", pred_prey)

show(by(pred_prey, :species, :species => length), allcols=true)
