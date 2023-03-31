# Docker-Mapserver

A dockerized mapserver for CosmoScout [csp-lod bodies](https://github.com/cosmoscout/cosmoscout-vr/tree/main/plugins/csp-lod-bodies#readme). The repo contains two dockerfiles `base.Dockerfile` and `example.Dockerfile`.

## base.Dockerfile
This docker mapserver allows user to use their own dataset. The webserver is exposed on port 80.


### To build the docker image:
```bash
docker buildx build -f base.Dockerfile . -t image_name
```
### To run a container and bind your dataset in pwd:

```bash
docker run -p 8080:80 \ 
-v "$(pwd)":/storage/mapserver-datasets \  
image_name
```
The command above runs a container, binds `localhost port 8080 to container port 80`, and `mounts the dataset in the pwd to containers  /storage/mapserver-datasets `directory.


## example.Dockerfile
This docker file uses `base.Dockerfile` as its base image and contains NASA's `Blue Marble` and the `Natural Earth image` datasets and `ETOPO1` elevation data. The shell file `datas.sh` downloads the dataset and copies them to the containers working directory. The `storage` directory in the repository consists of the `epsg` and `.map` files.


### To build a image:
```bash
docker buildx build -f example.Dockerfile . -t image_name
```
### To run a container:
``` console
docker run -p 8080:80 image_name
```
To ensure that everything is working as intended, one can simply disable apache2 using the following command:
``` console
service apache2 stop

And see if you can access the following links:
# EPSG:4326
http://localhost:8080/cgi-bin/mapserv?map=/storage/mapserver-datasets/meta.map&service=wms&version=1.3.0&request=GetMap&layers=earth.naturalearth.rgb&bbox=-90,-180,90,180&width=1600&height=800&crs=epsg:4326&format=pngRGB

# HEALPix
http://localhost:8080/cgi-bin/mapserv?map=/storage/mapserver-datasets/meta.map&service=wms&version=1.3.0&request=GetMap&layers=earth.naturalearth.rgb&bbox=-3.142,-1.571,3.142,1.571&width=1600&height=800&crs=epsg:900915&format=pngRGB

# Rotated HEALPix
http://localhost:8080/cgi-bin/mapserv?map=/storage/mapserver-datasets/meta.map&service=wms&version=1.3.0&request=GetMap&layers=earth.naturalearth.rgb&bbox=0,0,5,5&width=800&height=800&crs=epsg:900914&format=pngRGB

# One base patch of rotated HEALPix
http://localhost:8080/cgi-bin/mapserv?map=/storage/mapserver-datasets/meta.map&service=wms&version=1.3.0&request=GetMap&layers=earth.naturalearth.rgb&bbox=3,2,4,3&width=800&height=800&crs=epsg:900914&format=pngRGB
```
## Configuring CosmoScout VR:
Now that the datasets are working, we only need to include them into CosmoScout VR. To do this, add the following section to the "plugins" array in your `"share/config/simple_desktop.json"`. You will have to adjust the mapserver links according to the location of your meta.map file.
``` json
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
          "url": "http://localhost/cgi-bin/mapserv?map=/storage/mapserver-datasets/meta.map&service=wms",
          "layers": "earth.bluemarble.rgb",
          "maxLevel": 6
        },
        "Natural Earth": {
          "copyright": "NASA",
          "url": "http://localhost/cgi-bin/mapserv?map=/storage/mapserver-datasets/meta.map&service=wms",
          "layers": "earth.naturalearth.rgb",
          "maxLevel": 6
        }
      },
      "demDatasets": {
        "ETOPO1": {
          "copyright": "NOAA",
          "url": "http://localhost/cgi-bin/mapserv?map=/storage/mapserver-datasets/meta.map&service=wms",
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
