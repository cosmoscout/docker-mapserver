FROM ghcr.io/cosmoscout/mapserver-base:latest

COPY storage /storage
WORKDIR /tmp

#Copying the shell file which will download the dataset
ADD datas.sh /tmp

RUN apt update && \
    apt install --no-install-recommends -y \
                curl \
                unzip \
                gdal-bin \
    && rm -rf /var/lib/apt/lists/*;

RUN ./datas.sh
RUN rm -rf /tmp/*
WORKDIR /storage/mapserver-datasets
