using CSV
using DataFrames

cd("/Users/kiristern/Documents/GitHub/SDM/data/prey_sp")

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
df_prey = vcat(files)

# Select specific columns only
df = df_prey[:, [:species, :taxonRank, :decimalLatitude, :decimalLongitude, :year]]

#save csv file
CSV.write("prey_sp_onedf.csv", df)
