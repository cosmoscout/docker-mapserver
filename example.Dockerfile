# ------------------------------------------------------------------------------------------------ #
#                                This file is part of CosmoScout VR                                #
# ------------------------------------------------------------------------------------------------ #

# SPDX-FileCopyrightText: German Aerospace Center (DLR) <cosmoscout@dlr.de>
# SPDX-License-Identifier: MIT

ARG base_tag=latest
FROM ghcr.io/cosmoscout/mapserver-base:${base_tag}

RUN apt update && \
    apt install --no-install-recommends -y \
                curl \
                unzip \
                gdal-bin \
    && rm -rf /var/lib/apt/lists/*

# Add the example datasets.
COPY mapserver-datasets /mapserver-datasets
COPY download_example_data.sh /tmp
RUN /tmp/download_example_data.sh
