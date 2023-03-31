FROM ubuntu:23.04

#Following provides timezone while installing apache2
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone;

#Install required packages
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
    && rm -rf /var/lib/apt/lists/*;
 
#Copying apache config file
COPY etc /etc 
  
RUN a2enmod cgi fcgid

WORKDIR /storage/mapserver-datasets
RUN chown -R www-data: /storage ;
RUN chmod -R g+w /storage

EXPOSE 80
CMD ["apachectl", "-D", "FOREGROUND"]            
