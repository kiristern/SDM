using CSV

cd("/Users/kiristern/Documents/GitHub/SDM/data/pred_prey")
df = CSV.read("Mustela_erminea.csv")

#View each sp
# show(unique(df, :species), allrows=true)

#Count number of unique sp observations
show(by(df, :species, :species => length), allrows=true)
