# ------------------------------------------------------------------------------------------------ #
#                                This file is part of CosmoScout VR                                #
# ------------------------------------------------------------------------------------------------ #

# SPDX-FileCopyrightText: German Aerospace Center (DLR) <cosmoscout@dlr.de>
# SPDX-License-Identifier: MIT

ARG base_tag=latest
FROM ghcr.io/cosmoscout/mapserver-base:${base_tag}

COPY mapserver-datasets /mapserver-datasets

# Copying the shell file which will download the dataset
COPY download_example_data.sh /mapserver-datasets

RUN apt update && \
    apt install --no-install-recommends -y \
                curl \
                unzip \
                gdal-bin \
    && rm -rf /var/lib/apt/lists/*

RUN ./download_example_data.sh
