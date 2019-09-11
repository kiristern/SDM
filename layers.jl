using Distributed
using JLD2

@time @everywhere include("../BioClim/src/required.jl")

## Get & prepare data
@time @everywhere begin
    # Load data from CSV files
    df = CSV.read("/Users/kiristern/Documents/GitHub/SDM/data/pred_prey/Puma_concolor.csv", header=true)
    # Prepare data (select columns, arrange values)
    df = prepare_gbif_data(df)
    # Separate species
    taxa_occ = [df[df.species .== u,:] for u in unique(df.species)]
    # # Define coordinates range
    # lon_range = (-165.0, -30.0)
    # lat_range = (75.0, -60.0)
end

## Load predictions
@load "data/predictions.jld2" predictions
pred = predictions[1]
prey1 = predictions[2]
prey2 = predictions[3]

## expand
p1 = pred
p2 = prey1
p3 = prey2

# Get coordinates of predictions
#pred
lons_p1 = longitudes(p1)
lats_p1 = latitudes(p1)
#prey1
lons_p2 = longitudes(p2)
lats_p2 = latitudes(p2)
#prey2
lons_p3 = longitudes(p3)
lats_p3 = latitudes(p3)

# Get position of p2 on p1
m_lon = findmin(abs.(minimum(lons_p2) .- lons_p1))[2]
M_lon = findmin(abs.(maximum(lons_p2) .- lons_p1))[2]
m_lat = findmin(abs.(minimum(lats_p2) .- lats_p1))[2]
M_lat = findmin(abs.(maximum(lats_p2) .- lats_p1))[2]
p1[(m_lat:M_lat), (m_lon:M_lon)]
# Check if size matches
size(p2)
size(p3)

# Create new layer
new1 = fill(NaN, size(p1))
new2 = fill(NaN, size(p1))
new1[(m_lat:M_lat), (m_lon:M_lon)] .= p1[(m_lat:M_lat), (m_lon:M_lon)]
new2[(m_lat:M_lat), (m_lon:M_lon)] .= p2.grid
newlayer1 = SDMLayer(new1, p1.left, p1.right, p1.bottom, p1.top)
newlayer2 = SDMLayer(new2, p1.left, p1.right, p1.bottom, p1.top)

# Plot result
plotp1 = plotSDM(p1)
plotp2 = plotSDM(p2)
plotn1 = plotSDM(newlayer1)
plotn2 = plotSDM(newlayer2)

# Combine heatmaps
sdm_plot = plotSDM(newlayer1)
heatmap!(
    sdm_plot,
    longitudes(newlayer2), latitudes(newlayer2), # layer range
    newlayer2.grid, # evenness values
    aspectratio=92.60/60.75, # aspect ratio
    c=:viridis, # ~color palette
    clim=(0.0, maximum(filter(!isnan, newlayer2.grid))) # colorbar limits
)
plot!(
    sdm_plot,
    xlims=(p2.left, p2.right),
    ylims=(p2.bottom, p2.top),
    aspectratio=92.60/60.75
)
# Compare to p2
plotp2
