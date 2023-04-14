<!-- 
SPDX-FileCopyrightText: German Aerospace Center (DLR) <cosmoscout@dlr.de>
SPDX-License-Identifier: CC0-1.0
 -->
# Map-Server Container for CosmoScout VR

A dockerized mapserver for CosmoScout [csp-lod bodies](https://github.com/cosmoscout/cosmoscout-vr/tree/main/plugins/csp-lod-bodies#readme). This repo has been created taking three use-cases into consideration - `loading example map data`, `loading custom map data` and `creating custom map data containers`. Each of the use-cases are discussed briefly below.

## 1) Loading Example Map Data
Here you run a dockerized mapserver using NASA's [Blue Marble](https://visibleearth.nasa.gov/collection/1484/blue-marble) and the [Natural Earth image](https://www.naturalearthdata.com/) datasets and [ETOPO1](https://www.ncei.noaa.gov/products/etopo-global-relief-model) elevation data.

### Running the Server
To run the dockerized mapserver, you can pull the docker image (built from the `example.Dockerfile`) from GHCR using the command:

```bash
docker run -ti --rm -p 8080:80 ghcr.io/cosmoscout/mapserver-example
```
The command binds localhost port 8080 to container port 80.

To ensure that everything is working as intended, see if you can [access](http://localhost:8080/cgi-bin/mapserv?map=/mapserver-datasets/meta.map&service=wms&version=1.3.0&request=GetMap&layers=earth.naturalearth.rgb&bbox=0,0,5,5&width=800&height=800&crs=epsg:900914&format=pngRGB) the [example-datasets.](http://localhost:8080/cgi-bin/mapserv?map=/mapserver-datasets/meta.map&service=wms&version=1.3.0&request=GetMap&layers=earth.naturalearth.rgb&bbox=-90,-180,90,180&width=1600&height=800&crs=epsg:4326&format=pngRGB)

### Configuring CosmoScout VR:
<!-- The following configuration steps are described in use case 1 -->

Now that the datasets are working, we only need to include them into CosmoScout VR. To do this, add the following section to the "plugins" object in your `"share/config/simple_desktop.json"`. 

```json
...
"csp-lod-bodies": {
  "maxGPUTilesColor": 1024,
  "maxGPUTilesDEM": 1024,
  "tileResolutionDEM": 128,
  "tileResolutionIMG": 256,
  "mapCache": "/tmp/map-cache/",
  "bodies": {
    "Earth": {
      "activeImgDataset": "Blue Marble",
      "activeDemDataset": "ETOPO1",
      "imgDatasets": {
        "Blue Marble": {
          "copyright": "NASA",
          "url": "http://localhost/cgi-bin/mapserv?map=/mapserver-datasets/meta.map&service=wms",
          "layers": "earth.bluemarble.rgb",
          "maxLevel": 6
        },
        "Natural Earth": {
          "copyright": "NASA",
          "url": "http://localhost/cgi-bin/mapserv?map=/mapserver-datasets/meta.map&service=wms",
          "layers": "earth.naturalearth.rgb",
          "maxLevel": 6
        }
      },
      "demDatasets": {
        "ETOPO1": {
          "copyright": "NOAA",
          "url": "http://localhost/cgi-bin/mapserv?map=/mapserver-datasets/meta.map&service=wms",
          "layers": "earth.etopo1.dem",
          "maxLevel": 6
        }
      }
    }
  }
},
...
```
You should also remove the "Earth" section from the "csp-simple-bodies" plugin configuration in the same file, else you will have two Earths drawn on top of each other!

## 2) Loading Custom Map Data
Here you can run a dockerized mapserver using your own custom dataset.

### Preparing the Map Data
As you are using your own custom dataset some changes need to be made to the `meta.map` file. Also each of your `dataset` needs to have a appropriate `.map` file. The structure of  `mapserver-datasets` directory while using `example-datasets` in `use case 1` is below for reference:
```bash
mapserver-datasets
    ├── earth
    │   ├── bluemarble
    │   │   ├── bluemarble.jpg
    │   │   └── bluemarble.map
    │   ├── etopo1
    │   │   ├── ETOPO1_Ice_c_geotiff.tif
    │   │   └── etopo1.map
    │   └── naturalearth
    │       ├── naturalearth.map
    │       └── NE1_HR_LC_SR_W_DR.tif
    ├── epsg
    └── meta.map
```
Please follow similar directory structure for ease of use. Also please note that the `.map` file for each dataset has the same name as its directory.

### Changing meta.map and adding custom .map file for your tif files
The `meta.map` file in the `mapserver-datasets` directory caters to our example datasets and you need to make changes to the file while using your own custom dataset. You will have to make changes mainly in line `45-47` in `meta.map` file. Let's assume after adding your `custom dataset` to  the `mapserver-datasets` directory the directory structure looks like:
```bash
mapserver-datasets/
└── custom_earth
    └── asia
        ├── asia.map
        └── custom_asia.tif
```
You will have to remove line `45-47` in `meta.map` and replace it with:
```bash
...
 INCLUDE "custom_earth/asia/asia.map"
END
```
To create a custom `.map` file for your `tif` files, you can look at `.map` files in the `mapserver-datasets/earth` directory for reference. Here we will create the `asia.map` file taking the `custom_earth` example above:
```
LAYER
  NAME "custom_earth.asia.rgb" # Please make changes here accordingly
  STATUS ON
  TYPE RASTER
  DATA "custom_earth/asia/custom_asia.tif" # Please make changes here accordingly

  # Decreasing the oversampling factor will increase performance but reduce quality.
  PROCESSING "OVERSAMPLE_RATIO=2"
  PROCESSING "RESAMPLE=BILINEAR"

  # The GeoTiff is fully geo-referenced, so we can just use AUTO projection here.
  PROJECTION
    AUTO
  END

  METADATA
    WMS_TITLE "custom_earth.asia.rgb" # Please make changes here accordingly
  END
END
```
 
### Optimising the dataset
To optimise your dataset you can use `gdal_translate` and `gdaladdo` command. Let's assume you are in the `custom_earth` directory with the following structure:
```bash
custom_earth
    └── asia
        ├── asia.map
        └── custom_asia.tif
```
To optimise the `custom_asia.tif` file and copy it to our `mapserver-datasets/custom_earth/` directory, the command will be:
```bash
# Step 1: Optimize TIFF file and generate overviews using gdal_translate.
gdal_translate -co tiled=yes -co compress=deflate custom_earth/asia/custom_asia.tif /path to/mapserver-datasets/custom_earth/asia/custom_asia.tif 

# in `/path/to/mapserver-datasets/custom_earth/asia/custom_asia.tif` custom_asia.tif is the name of the optimised output tif file.

# gdal_translate will copy your tif file to the appropriate directory inside mapserver-datasets directory, here the custom_asia.tif file is copied to mapserver-datasets/custom_earth/asia directory.

# Step 2: Generate overviews using gdaladdo.
gdaladdo -r cubic /path/to/mapserver-datasets/custom_earth/asia/custom_asia.tif 2 4 8 16

# 2 4 8 16 are overview levels which you can change according to your specific requirement. 
```

### Running the Server
To run the dockerized mapserver, you can pull the docker image (built from `base.Dockerfile`) from GHCR using the command:

```bash
docker run -ti --rm -p 8080:80 -v "$(pwd)":/mapserver-datasets ghcr.io/cosmoscout/mapserver-base
```
The command pulls the docker image from GHCR, binds localhost port 8080 to container port 80, and mounts the datasets in your `pwd` to the containers `mapserver-datasets` directory.

### Adding your meta.map file and epsg file to the docker container:
When you pull the docker image from GHCR the docker image uses the `meta.map` file and the `epsg` file for `use case 1`, you will have to replace these files with your `meta.map` file and `epsg` file. You can do so using the following commands:
```bash
# To ensure that the docker image is running and to get the container id.
docker ps 

# Copying the meta.map and epsg file in the working directory to the mapserver-datasets directory in the container.
docker cp meta.map epsg [container id]:/mapserver-datasets

# To check if the copying was successful or not, make sure that the output is same as your meta.map file.
docker exec [container id] cat /mapserver-datasets/meta.map
```

### Configuring CosmoScout VR:
<!-- The following configuration steps are described in use case 2 -->

Now that the datasets are working, we only need to include them into CosmoScout VR. To do this, add the following section to the "plugins" object in your `"share/config/simple_desktop.json"`. 

```json
...
"csp-lod-bodies": {
  "maxGPUTilesColor": 1024,
  "maxGPUTilesDEM": 1024,
  "tileResolutionDEM": 128,
  "tileResolutionIMG": 256,
  "mapCache": "/tmp/map-cache",
  "bodies": {
    "Earth": {
      "activeImgDataset": "Blue Marble",
      "activeDemDataset": "ETOPO1",
      "imgDatasets": {
        "Blue Marble": {
          "copyright": "NASA",
          "url": "http://localhost/cgi-bin/mapserv?map=/mapserver-datasets/meta.map&service=wms",
          "layers": "earth.bluemarble.rgb",
          "maxLevel": 6
        },
        "Natural Earth": {
          "copyright": "NASA",
          "url": "http://localhost/cgi-bin/mapserv?map=/mapserver-datasets/meta.map&service=wms",
          "layers": "earth.naturalearth.rgb",
          "maxLevel": 6
        }
      },
      "demDatasets": {
        "ETOPO1": {
          "copyright": "NOAA",
          "url": "http://localhost/cgi-bin/mapserv?map=/mapserver-datasets/meta.map&service=wms",
          "layers": "earth.etopo1.dem",
          "maxLevel": 6
        }
      }
    }
  }
},
...
```
This `json` snippet caters to our `example dataset` in `use case 1`. Here we will briefly walk you through this `JSON` snippet so that you can make appropriate changes depending on the dataset you are using. You can start making changes from the `Earth` object.
- Replace `Earth` with the body whose data you are using eg: if it is Mars then it will be `"Mars": {`.
- `activeImgDataset`is a key for the currently active image for the body and `activeDemDataset` is a key for the elevation dataset being used.
- `imageDatasets` is a nested object where each of the dataset being used are defined as a object.
- `Blue Marble`, `Natural Earth` both are the datasets we are using in our `use case 1` which we have declared as objects. 
- `layers` is a key which specifies the layers to be used from the dataset. In our json snippet `.rgb` means Red-Green-Blue image of Earth.
- `maxLevel` is a key which specifies the maximum level of detail or zoom that can be displayed for the dataset.
- `demDatasets` is a object for the elevation data being used, the key `layers` specifies the layers to be used from the elevation dataset.

## 3) Creating Custom Map Data Containers
Here you can build the docker image locally using `docker build` instead of pulling it from `GHCR` and run a dockerized mapserver using your own custom dataset.

### Preparing the Map Data
As you are using your own custom dataset some changes need to be made to the `meta.map` file. Also each of your `dataset` needs to have a appropriate `.map` file. The structure of  `mapserver-datasets` directory while using `example-datasets` as in `use case 1` is below for reference:
```bash
mapserver-datasets
    ├── earth
    │   ├── bluemarble
    │   │   ├── bluemarble.jpg
    │   │   └── bluemarble.map
    │   ├── etopo1
    │   │   ├── ETOPO1_Ice_c_geotiff.tif
    │   │   └── etopo1.map
    │   └── naturalearth
    │       ├── naturalearth.map
    │       └── NE1_HR_LC_SR_W_DR.tif
    ├── epsg
    └── meta.map
```
Please use the `mapserver-datasets` directory, remove the `earth` directory with your `custom dataset` directory and follow similar directory structure for ease of use. Also please note that the `.map` file for each dataset has the same name as its directory.

### Changing meta.map and adding custom .map file for your tif files
Please refer to the [Changing meta.map and adding custom .map file for your tif files](#changing-metamap-and-adding-custom-map-file-for-your-tif-files) described in `use case 2`.
### Optimising the dataset
Please refer to the [Optimising the dataset](#optimising-the-dataset) described in `use case 2`.
### Running the Server
To run the dockerized mapserver, you will first have to build the docker image using the following command:

```bash
docker buildx build -f base.Dockerfile . -t image_name
```
You have built a docker image using the `base.Dockerfile`. Now to run a container and mount your custom dataset, you can use the following command:

```bash
docker run -p 8080:80 -v "$(pwd)":/storage/mapserver-datasets image_name
```
The command runs a docker container using the image `image_name` and binds localhost port 8080 to container port 80.
### Configuring CosmoScout VR:
<!-- The following configuration steps are described in use case 3 -->
Please refer to the [Configure Cosmoscout VR](#configuring-cosmoscout-vr-section-2) described in `use case 2`.

