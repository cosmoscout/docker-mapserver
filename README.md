# Docker-Mapserver

A dockerized mapserver for CosmoScout [csp-lod bodies](https://github.com/cosmoscout/cosmoscout-vr/tree/main/plugins/csp-lod-bodies#readme). The repo contains two dockerfiles `base.Dockerfile` and `example.Dockerfile`.

## base.Dockerfile
This docker mapserver allows user to use their own dataset. The webserver is exposed on port 80.


### To build the docker image:
``` console
docker buildx build -f base.Dockerfile . -t image_name
```
### To run a container and bind your dataset in pwd:

```console
docker run -p 8080:80 \ 
-v "$(pwd)":/storage/mapserver-datasets \  
image_name
```
The command above runs a container, binds `localhost port 8080 to container port 80`, and `mounts the dataset in the pwd to containers  /storage/mapserver-datasets `directory.


## example.Dockerfile
This docker file uses `base.Dockerfile` as its base image and contains NASA's `Blue Marble` and the `Natural Earth image` datasets and `ETOPO1` elevation data. The shell file `datas.sh` downloads the dataset and copies them to the containers working directory. The `storage` directory in the repository consists of the `epsg` and `.map` files.


### To build a image:
``` console
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
