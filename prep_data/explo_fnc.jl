#### Gab's fncs for exploration
using DataFrames
using SimpleSDMLayers

# Prepare data
function prepare_csvdata(csvdata::DataFrame)
    # Subset with specific columns
    df = csvdata[:, [:new_sp, :year, :decimalLatitude, :decimalLongitude]]
    # Rename coordinate names
    rename!(df, :decimalLatitude => :latitude)
    rename!(df, :decimalLongitude => :longitude)
    rename!(df, :new_sp => :species)
    # Replace spaces by underscores in species names
    df.species .= replace.(df.species, " " .=> "_")
    # Remove entries with missing year, latitude and lontitude
    dropmissing!(df, [:year, :latitude, :longitude])
    return df
end
