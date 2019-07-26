using Plots
using GDAL
using Shapefile
using StatsBase
using CSV
using DataFrames
using Statistics

cd("/Users/kiristern/Documents/GitHub/SDM")
include("../BioClim/lib/SDMLayer.jl")
include("../BioClim/lib/gdal.jl")
include("../BioClim/lib/worldclim.jl")
include("../BioClim/lib/bioclim.jl")
include("../BioClim/lib/shapefiles.jl")
include("explo_fnc.jl")

df = CSV.read("../SDM/data/.csv", header=true, delim="\t")

df = df[:, [:species, :infraspecificEpithet, :taxonRank, :decimalLatitude, :decimalLongitude, :year]]
df.new_sp = copy(df.species)
for i in 1:length(df)
    if df.taxonRank[i] == "SUBSPECIES"
        df.new_sp[i] = string(df.species[i], "_", df.infraspecificEpithet[i])
    end
end
