# Map-Server Container for CosmoScout VR

A dockerized mapserver for CosmoScout [csp-lod bodies](https://github.com/cosmoscout/cosmoscout-vr/tree/main/plugins/csp-lod-bodies#readme). This repo has been created taking three use-cases into consideration - `loading example map data`, `loading custom map data` and `creating custom map data containers`. Each of the use-cases are discussed briefly below.

## Loading Example Map Data
Here you run a dockerized mapserver using NASA's `Blue Marble` and the `Natural Earth image` datasets and `ETOPO1` elevation data.

### Running the Server
To run the dockerized mapserver, you can pull the docker image (built from the `example.Dockerfile`) from GHCR using the command:

```bash
docker run -ti --rm -p 8080:80 ghcr.io/cosmoscout/mapserver-example
```
The command binds localhost port 8080 to container port 80.

To ensure that everything is working as intended, see if you can access the example-datasets using the following links:

```bash
# EPSG:4326
http://localhost:8080/cgi-bin/mapserv?map=/mapserver-datasets/meta.map&service=wms&version=1.3.0&request=GetMap&layers=earth.naturalearth.rgb&bbox=-90,-180,90,180&width=1600&height=800&crs=epsg:4326&format=pngRGB

# Custom CosmoScout projection (HEALPix)
http://localhost:8080/cgi-bin/mapserv?map=/mapserver-datasets/meta.map&service=wms&version=1.3.0&request=GetMap&layers=earth.naturalearth.rgb&bbox=0,0,5,5&width=800&height=800&crs=epsg:900914&format=pngRGB

# One base patch.
http://localhost:8080/cgi-bin/mapserv?map=/mapserver-datasets/meta.map&service=wms&version=1.3.0&request=GetMap&layers=earth.naturalearth.rgb&bbox=3,2,4,3&width=800&height=800&crs=epsg:900914&format=pngRGB
```
### Configuring CosmoScout VR:

Now that the datasets are working, we only need to include them into CosmoScout VR. To do this, add the following section to the "plugins" array in your `"share/config/simple_desktop.json"`. You will have to adjust the mapserver links according to the location of your meta.map file.

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

## Loading Custom Map Data
Here you can run a dockerized mapserver using your own custom dataset.

### Preparing the Map Data
As you are using your own custom dataset some changes need to be made to the `meta.map` file in the `mapserver-datasets` directory. The lines `42,43 and 44` need to change accordingly to the location of your `.map` files.

### Running the Server
To run the dockerized mapserver, you can pull the docker image (built from `base.Dockerfile`) from GHCR using the command:

```bash
docker run -ti --rm -p 8080:80 -v "$(pwd)":/mapserver-datasets ghcr.io/cosmoscout/mapserver-base
```
The command pulls the docker image from GHCR, binds localhost port 8080 to container port 80, and mounts the datasets in your `pwd` to the containers `mapserver-datasets` directory.

## Creating Custom Map Data Containers
Here you can build the docker image locally using `docker build` instead of pulling it from `GHCR` and run a dockerized mapserver using your own custom dataset.

### Preparing the Map Data
As you are using your own custom dataset some changes need to be made to the `meta.map` file in the `mapserver-datasets` directory. The lines `42,43 and 44` need to change accordingly to the location of your `.map` files.

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
