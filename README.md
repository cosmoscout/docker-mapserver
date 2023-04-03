# Docker-Mapserver

A dockerized mapserver for CosmoScout [csp-lod bodies](https://github.com/cosmoscout/cosmoscout-vr/tree/main/plugins/csp-lod-bodies#readme). The repo contains two dockerfiles `base.Dockerfile` and `example.Dockerfile`.

## base.Dockerfile

This docker mapserver allows user to use their own dataset. The webserver is exposed on port 80.

```bash
docker run -ti --rm -p 8080:80 -v "$(pwd)":/mapserver-datasets ghcr.io/cosmoscout/mapserver-base
```

The command above runs a container, binds `localhost port 8080 to container port 80`, and `mounts the dataset in the pwd to containers /mapserver-datasets `directory.


## example.Dockerfile

This docker file uses `base.Dockerfile` as its base image and contains NASA's `Blue Marble` and the `Natural Earth image` datasets and `ETOPO1` elevation data.

```bash
docker run -ti --rm -p 8080:80 ghcr.io/cosmoscout/mapserver-example
```

To ensure that everything is working as intended, see if you can access the following links:

```bash
# EPSG:4326
http://localhost:8080/cgi-bin/mapserv?map=/mapserver-datasets/meta.map&service=wms&version=1.3.0&request=GetMap&layers=earth.naturalearth.rgb&bbox=-90,-180,90,180&width=1600&height=800&crs=epsg:4326&format=pngRGB

# Custom CosmoScout projection (HEALPix)
http://localhost:8080/cgi-bin/mapserv?map=/mapserver-datasets/meta.map&service=wms&version=1.3.0&request=GetMap&layers=earth.naturalearth.rgb&bbox=0,0,5,5&width=800&height=800&crs=epsg:900914&format=pngRGB

# One base patch.
http://localhost:8080/cgi-bin/mapserv?map=/mapserver-datasets/meta.map&service=wms&version=1.3.0&request=GetMap&layers=earth.naturalearth.rgb&bbox=3,2,4,3&width=800&height=800&crs=epsg:900914&format=pngRGB
```


## Configuring CosmoScout VR:

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
