<!-- 
SPDX-FileCopyrightText: German Aerospace Center (DLR) <cosmoscout@dlr.de>
SPDX-License-Identifier: CC0-1.0
 -->
# Map-Server Container for CosmoScout VR

This repository provides a dockerized [MapServer](https://mapserver.org) for the [csp-lod bodies](https://github.com/cosmoscout/cosmoscout-vr/tree/main/plugins/csp-lod-bodies) plugin of [CosmoScout VR](https://github.com/cosmoscout/cosmoscout-vr).
It has been created taking three use-cases into consideration:
First, it provides an easy way for **loading example terrain data** in CosmoScout VR.
Second, it allows **loading custom terrain data**.
Finally, you can use this as a basis for **creating custom containers** for easy distribution of terrain data to others.
Each of the use-cases are discussed briefly below.

:information_source: _This guide works both on Linux and on Windows (using the Windows Subsystem for Linux)._

## 1. Loading Example Map Data

Here you run a dockerized map-server using NASA's [Blue Marble](https://visibleearth.nasa.gov/collection/1484/blue-marble) and the [Natural Earth](https://www.naturalearthdata.com/) datasets and [ETOPO1](https://www.ncei.noaa.gov/products/etopo-global-relief-model) elevation data.
To run the dockerized map-server, you can pull the docker image from the GitHub container registry using the command:

```bash
docker run -ti --rm -p 8080:80 ghcr.io/cosmoscout/mapserver-example
```
The command pulls the image, runs the server in the container, and binds localhost port 8080 to container port 80.
If everything is working as intended, you should be able to access these links: 
* [Natural Earth in WGS84](http://localhost:8080/cgi-bin/mapserv?map=/mapserver-datasets/meta.map&service=wms&version=1.3.0&request=GetMap&layers=earth.naturalearth.rgb&bbox=-90,-180,90,180&width=1600&height=800&crs=epsg:4326&format=pngRGB)
* [Blue Marble in CosmoScout's special HEALPix projection](http://localhost:8080/cgi-bin/mapserv?map=/mapserver-datasets/meta.map&service=wms&version=1.3.0&request=GetMap&layers=earth.bluemarble.rgb&bbox=0,0,5,5&width=800&height=800&crs=epsg:900914&format=pngRGB)

Now that the datasets are working, we only need to include them into CosmoScout VR.
To do this, add the following section to the "plugins" object in your `share/config/simple_desktop.json`.
You should also remove the "Earth" section from the "csp-simple-bodies" plugin configuration in the same file, else you will have two Earths drawn on top of each other!

```json
...
"csp-lod-bodies": {
  "maxGPUTilesColor": 1024,
  "maxGPUTilesDEM": 1024,
  "tileResolutionDEM": 128,
  "tileResolutionIMG": 256,
  "mapCache": "map-cache/",
  "bodies": {
    "Earth": {
      "activeImgDataset": "Blue Marble",
      "activeDemDataset": "ETOPO1",
      "imgDatasets": {
        "Blue Marble": {
          "copyright": "NASA",
          "url": "http://localhost:8080/cgi-bin/mapserv?map=/mapserver-datasets/meta.map&service=wms",
          "layers": "earth.bluemarble.rgb",
          "maxLevel": 6
        },
        "Natural Earth": {
          "copyright": "NASA",
          "url": "http://localhost:8080/cgi-bin/mapserv?map=/mapserver-datasets/meta.map&service=wms",
          "layers": "earth.naturalearth.rgb",
          "maxLevel": 6
        }
      },
      "demDatasets": {
        "ETOPO1": {
          "copyright": "NOAA",
          "url": "http://localhost:8080/cgi-bin/mapserv?map=/mapserver-datasets/meta.map&service=wms",
          "layers": "earth.etopo1.dem",
          "maxLevel": 6
        }
      }
    }
  }
},
...
```

Now restart CosmoScout VR and after a short delay, Earth should be visible showing the Blue-Marble imagery on top of the ETOPO elevation data.
Map tiles will be cached in the directory `bin/map-cache`.
You can change this location with the respective settings key in the configuration above. 


## 2. Loading Custom Map Data

This repository also provides an "empty" map-server container which you can use to serve your own custom data.
The map-server uses [gdal](https://gdal.org/) to load the data.
Hence it can be used to serve all data formats which are understood by gdal.

### Optimizing the Datasets

Before you start, you should try to optimize your data.
To optimize your dataset you can use the `gdal_translate` and `gdaladdo` commands.
To make the data access as fast as possible, you should always add overviews to your data and store it using a tiling scheme.
With [gdal](https://gdal.org/), this can be done using the following commands:

```bash
gdal_translate -co tiled=yes -co compress=deflate DATA_SET.tif DATA_SET_optimized.tif

# 2 4 8 16 are overview levels which you can change according to your specific requirement.
gdaladdo -r cubic DATA_SET_optimized.tif 2 4 8 16 32 64
```

### Preparing the Map Data

Then, you should prepare a directory similar to the `mapserver-datasets` directory in this repository.
Simply copy the `epsg`, the `meta.map`, and one of the other `.map` files.
You can also add some of the example datasets to serve as base layers (refer to the [download_example_data.sh](download_example_data.sh) script for how this data is downloaded).

Once everything is in place, your directory structure may look like this:

```bash
mapserver-datasets
    ├── earth
    │   ├── bluemarble
    │   │   ├── bluemarble.jpg
    │   │   └── bluemarble.map
    │   ├── etopo1
    │   │   ├── ETOPO1_Ice_c_geotiff.tif
    │   │   └── etopo1.map
    │   └── MY_DATA
    │       ├── DATA_SET_1.tif
    │       ├── DATA_SET_2.jp2
    │       ├── DATA_SET_3.png
    │       ├── ...
    │       └── MY_DATA.map
    ├── epsg
    └── meta.map
```

The `meta.map` file in the `mapserver-datasets` directory includes all the other map files.
You have to adapt the `INCLUDE` statements at the bottom of the file according to your directory structure.
For the example above, it would look like this:

```bash
...
 INCLUDE "earth/bluemarble/bluemarble.map"
 INCLUDE "earth/etopo1/etopo1.map"
 INCLUDE "earth/MY_DATA/MY_DATA.map"
END
```
To create the `MY_DATA.map` file for your data files, you can look at `.map` files in the `mapserver-datasets/earth` directory for reference.
Here is an example how this could look like.

:information_source: _For more information on the map file format, please refer to the [official MapServer documentation](https://mapserver.org/mapfile/layer.html)._


```bash
LAYER
  NAME "earth.DATA_SET_1.rgb"
  STATUS ON
  TYPE RASTER
  DATA "earth/MY_DATA/DATA_SET_1.tif"

  # Decreasing the oversampling factor will increase performance but reduce quality.
  PROCESSING "OVERSAMPLE_RATIO=2"
  PROCESSING "RESAMPLE=BILINEAR"

  # If the data is not fully geo-referenced, you could specifiy the projection here.
  PROJECTION
    AUTO
  END

  METADATA
    WMS_TITLE "earth.DATA_SET_1.rgb"
  END
END

# More Layers could be added here.
# LAYER
#  NAME "earth.DATA_SET_2.rgb"
# ...
```


### Running the Server & Configuring CosmoScout VR

To run the dockerized map-server, you can pull the docker image from GitHub container registry using the command:

```bash
cd mapserver-datasets
docker run -ti --rm -p 8080:80 -v "$(pwd)":/mapserver-datasets ghcr.io/cosmoscout/mapserver-base
```
The command mounts your current working directory (which contains the `epsg` and `meta.map` files) to the containers `/mapserver-datasets` directory.

Now that the server is running, we only need to include the new layers into CosmoScout VR.
To do this, add a new dataset to the configuration of "csp-lod-bodies" in your `share/config/simple_desktop.json`.
This could look like this:

```json
"Blue Marble + MY DATA": {
  "copyright": "NASA & MYSELF",
  "url": "http://localhost:8080/cgi-bin/mapserv?map=/mapserver-datasets/meta.map&service=wms",
  "layers": "earth.bluemarble.rgb,earth.DATA_SET_1.rgb",
  "maxLevel": 6
},
```

You can combine multiple layers in one dataset as shown above.
The layers will be drawn on top of each other as they are listed from left to right.
The `maxLevel` defines how often the planetary surface will be subdivided when this dataset is shown.
If you have a high-resolution dataset, you will have to increase this value.

On Earth, the base patches are about 7000 km by 7000 km.
A `maxLevel` of 6 would result in a minimum tile size of about 7000 km / 2^6 ≈ 109 km.
With a `tileResolutionIMG` of 256, this would result in a pixel size of about 0.4 km.
While this is sufficient for the example datasets, you may need higher values for your data.


## 3. Creating Custom Map Data Containers

You can also build the docker images locally using `docker build` instead of pulling them from the GitHub container registry.
Using this, you can create and distribute you own containerized map-servers using your own custom datasets.
You can have a look at the [`example.Dockerfile`](example.Dockerfile) to get an idea how this works.

In the most simple case, you would prepare the `mapserver-datasets` directory according to use-case 2) above.
Then create a `Dockerfile` with this content:

```docker
FROM ghcr.io/cosmoscout/mapserver-base:latest
COPY mapserver-datasets /mapserver-datasets
```

And build the container using this command:

```bash
docker buildx build -f Dockerfile . -t image_name
```

Now run a container using the following command:

```bash
docker run -ti --rm -p 8080:80 image_name
```

You can now push this image to a container registry and your colleagues will be able to run their own copy of the map-server!

