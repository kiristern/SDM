using CSV
using DataFrames

cd("/Users/kiristern/Documents/GitHub/SDM/data/preds_csv/originals/")

# Import and read all saved GBIF csv files in directory
file_list = readdir()
files = Any[]
for i in 1:length(file_list)
    push!(files, CSV.read(file_list[i], delim="\t"))
end
#create one dataframe
predators = vcat(files...)
# Select specific columns only
df = predators[:, [:species, :infraspecificEpithet, :taxonRank, :decimalLatitude, :decimalLongitude, :year]]
# create new column "new_sp" for subspecies naming
df.new_sp = copy(df.species)
for i in 1:length(df)
    if df.taxonRank[i] == "SUBSPECIES"
        df.new_sp[i] = string(df.species[i], "_", df.infraspecificEpithet[i])
    end
end

#save csv file
CSV.write("predators_onedf.csv", df)
