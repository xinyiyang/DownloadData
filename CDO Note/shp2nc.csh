#!/bin/csh -f

# shapefile (.shp) to .nc file,  
# mask basin using cdo 

# (1)
# install gdal first
# convert shp to nc        resolution 0.01x0.01
gdal_rasterize -of netCDF -burn 1 -tr 0.01 0.01 basin.shp basin.nc


# if occurs "cdo remapbil (Abort): Variable lat_bnds has an unsupported generic grid!"
cdo select,name=precip,time,lat,lon precip.mon.mean.nc precip.mon.mean.postprocess.nc


# (2)
# regrid
cdo remapbil,precip.mon.mean.postprocess.nc basin.nc basin2.nc


# (3)
# mask
cdo ifthen basin2.nc infile.nc masked_infile.nc