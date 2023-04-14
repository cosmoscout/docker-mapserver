# SPDX-FileCopyrightText: German Aerospace Center (DLR) <cosmoscout@dlr.de>
# SPDX-License-Identifier: CC0-1.0

FROM ubuntu:23.04

# Following provides timezone while installing apache2.
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone;

# Install required packages.
RUN apt update && \
    apt install --no-install-recommends -y \
                        apache2 \
                        apache2-bin \
                        apache2-utils \
                        ca-certificates \
                        cgi-mapserver \
                        mapserver-bin \
                        mapserver-doc \
                        libmapscript-perl \
                        libapache2-mod-fcgid \
    && rm -rf /var/lib/apt/lists/*

# Copying apache config file.
COPY etc /etc

RUN a2enmod cgi fcgid

WORKDIR /mapserver-datasets
RUN chown -R www-data: /mapserver-datasets 
RUN chmod -R g+w /mapserver-datasets

EXPOSE 80

CMD ["apachectl", "-D", "FOREGROUND"]
