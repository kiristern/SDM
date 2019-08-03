using Plots
using GDAL
using Shapefile
using StatsBase
using CSV
using DataFrames
using Statistics
using GBIF

cd("/Users/kiristern/Documents/GitHub/SDM")
include("../BioClim/src/lib/SDMLayer.jl")
include("../BioClim/src/lib/gdal.jl")
include("../BioClim/src/lib/worldclim.jl")
include("../BioClim/src/lib/bioclim.jl")
include("../BioClim/src/lib/shapefiles.jl")
include("explo_fnc.jl")

# Import csv file
df = CSV.read("data/prey_csv/prey_onedf.csv", header=true)

# prepare data according to explo_fnc function
df = prepare_csvdata(df)

#remove rows with missing latitude, longitude, and year
df = dropmissing(df, [:latitude, :longitude, :year])
