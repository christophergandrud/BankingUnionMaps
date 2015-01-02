##############
# Shell script to convert country shapefile to GeoJSON, subset for Europe
# Christopher Gandrud
# 27 December 2014
##############

#!/bin/bash

# Subset for Europe, excluding Russia and keeping Cyprus
# Data from http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_map_subunits.zip
ogr2ogr \
    -f GeoJSON \
    -where "region_un IN ('Europe') OR SOVEREIGNT IN ('Cyprus') AND SOV_A3 NOT IN ('RUS')" \
    subunits.json \
    ne_10m_admin_0_map_subunits.shp

mv subunits.json ~/Desktop/europeTest/json

# Promote SU_A3 property to the object id
topojson \
    -o europeClean.json \
    --id-property SOV_A3 \
    subunits.json
