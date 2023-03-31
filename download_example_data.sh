#!/bin/bash

mkdir -p /tmp/download

# Downloading our dataset.
curl -s -L -o /tmp/download/NE1_HR_LC_SR_W_DR.zip https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/raster/NE1_HR_LC_SR_W_DR.zip
curl -s -L -o /tmp/download/ETOPO1_Ice_c_geotiff.zip https://www.ngdc.noaa.gov/mgg/global/relief/ETOPO1/data/ice_surface/cell_registered/georeferenced_tiff/ETOPO1_Ice_c_geotiff.zip
curl -s -L -o /mapserver-datasets/earth/bluemarble/bluemarble.jpg https://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73776/world.topo.bathy.200408.3x21600x10800.jpg

# Unzip the dataset and copy it to our workdir.
unzip /tmp/download/NE1_HR_LC_SR_W_DR.zip -d /mapserver-datasets/earth/naturalearth
#cp /tmp/download/NE1_HR_LC_SR_W_DR.tif /mapserver-datasets/earth/naturalearth/NE1_HR_LC_SR_W_DR.tif 

unzip /tmp/download/ETOPO1_Ice_c_geotiff.zip -d /mapserver-datasets/earth/etopo1
#cp /tmp/download/ETOPO1_Ice_c_geotiff.tif /mapserver-datasets/earth/etopo1/ORIGINAL_ETOPO1_Ice_c_geotiff.tif

# Optimizing the natural earth dataset.
#gdal_translate -co tiled=yes -co compress=deflate /mapserver-datasets/earth/naturalearth/NE1_HR_LC_SR_W_DR.tif /mapserver-datasets/earth/naturalearth/NE1_HR_LC_SR_W_DR.tif
#gdaladdo -r cubic /mapserver-datasets/earth/naturalearth/NE1_HR_LC_SR_W_DR.tif 2 4 8 16 

# Optimizing the etopo1 dataset.
#gdal_translate -co tiled=yes -co compress=deflate /mapserver-datasets/earth/etopo1/ORIGINAL_ETOPO1_Ice_c_geotiff.tif /mapserver-datasets/earth/etopo1/ETOPO1_Ice_c_geotiff.tif 
#gdaladdo -r cubic /mapserver-datasets/earth/etopo1/ETOPO1_Ice_c_geotiff.tif 2 4 8 16 

