### Model after Gab's code - Create basic CSV files

using CSV
using DataFrames

## Canis latrans observations
# change directory
## $(homedir()) to get it in cd(~[tab])
## "../" brings you back one folder. "../../" brings you back two folders
cd("$(homedir())/Documents/UdeM/ete2019/poisot_lab/pred_prey_proj/redlist_species_data/preds")

# Select 2019 observations
canis_latrans = CSV.read("Canis_latrans.csv")
# select all that are not "NA"
c_latrans = canis_latrans[canis_latrans.year .!= "NA", :]
# convert year "string" to "integer"
c_latrans.year = parse.(Int64, c_latrans.year)
describe(c_latrans_2019)
# select all from year 2019
c_latrans_2019 = c_latrans[c_latrans.year .=== 2019, :]

#write to CSV
CSV.write("/Users/kiristern/Documents/GitHub/SDM/data/c_latrans_2019.csv", c_latrans_2019)

#test CSV file
test = CSV.read("/Users/kiristern/Documents/GitHub/SDM/data/c_latrans_2019.csv")
first(test,6)
names(test)
