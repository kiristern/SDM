using CSV
using DataFrames

cd("/Users/kiristern/Documents/GitHub/SDM/data/prey_class/")

# Import and read all saved GBIF csv files from directory
file_list = readdir()
#remove .DS_Store
file_list = file_list[2:end]
#create an empty array of dimension Any
files = Any[]
#fill array with data from downloaded csv files
for i in 1:length(file_list)
    #see which data file is causing the error problems
    global j = i
    #push! into files, info from file_list
    push!(files, CSV.read(file_list[i], delim="\t"))
end
#create one dataframe
df_prey = vcat(files...)

# Select specific columns only
df = df_prey[:, [:class, :species, :infraspecificEpithet, :taxonRank, :decimalLatitude, :decimalLongitude, :year]]
# create new column "new_sp" for subspecies naming
df.new_sp = copy(df.species)
for i in 1:length(df)
    if df.taxonRank[i] == "SUBSPECIES"
        df.new_sp[i] = string(df.species[i], "_", df.infraspecificEpithet[i])
    end
end

#save csv file
CSV.write("prey_class_onedf.csv", df)
