#!/bin/csh -f
# era5 land data
set var_name =(evaporation_from_bare_soil evaporation_from_the_top_of_canopy evaporation_from_vegetation_transpiration potential_evaporation runoff skin_reservoir_content skin_temperature soil_temperature_level_1 soil_temperature_level_2 soil_temperature_level_3 soil_temperature_level_4 sub_surface_runoff surface_latent_heat_flux surface_runoff surface_sensible_heat_flux total_evaporation volumetric_soil_water_layer_1 volumetric_soil_water_layer_2 volumetric_soil_water_layer_3 volumetric_soil_water_layer_4)

set r_start                = 1
set r_end                  = 20


# directory
set mdir   = /share/kkraid/yangx2/dataset/ob_data/era5_land


# loop
    foreach ii (`seq -f "%01g" $r_start  $r_end`)
        echo $ii
        set  var             = ${var_name[$ii]}
        echo $var


#==============================================================================================
rm -f ${mdir}/or/${var}.py

cat > ${mdir}/or/${var}.py<< EOF

import cdsapi

c = cdsapi.Client()

c.retrieve(
    'reanalysis-era5-land-monthly-means',
    {
        'format': 'netcdf',
        'product_type': 'monthly_averaged_reanalysis',
        'variable': [
            '${var}',
        ],
        'year': [
            '1981', '1982', '1983',
            '1984', '1985', '1986',
            '1987', '1988', '1989',
            '1990', '1991', '1992',
            '1993', '1994', '1995',
            '1996', '1997', '1998',
            '1999', '2000', '2001',
            '2002', '2003', '2004',
            '2005', '2006', '2007',
            '2008', '2009', '2010',
            '2011', '2012', '2013',
            '2014', '2015', '2016',
            '2017', '2018', '2019',
            '2020',
        ],
        'month': [
            '01', '02', '03',
            '04', '05', '06',
            '07', '08', '09',
            '10', '11', '12',
        ],
        'time': '00:00',
    },
    '/share/kkraid/yangx2/dataset/ob_data/era5_land/${var}.1981-2020.monthly.nc')

EOF

python3 ${mdir}/or/${var}.py

cdo remapbil,r360x180 ${var}.1981-2020.monthly.nc ${var}.1981-2020.monthly.1x1.nc

rm -f ${var}.1981-2020.monthly.nc

end

echo "well done, Teresa, I deeply love you!"
