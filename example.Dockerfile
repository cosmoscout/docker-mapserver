FROM ghcr.io/pdlayush/mapserver_base

COPY mapserver-datasets /mapserver-datasets

# Copying the shell file which will download the dataset
COPY download_example_data.sh /mapserver-datasets

RUN apt update && \
    apt install --no-install-recommends -y \
                curl \
                unzip \
                gdal-bin \
    && rm -rf /var/lib/apt/lists/*;

RUN ./download_example_data.sh
WORKDIR /mapserver-datasets
