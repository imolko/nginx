FROM nginx:1.13

MAINTAINER Yohany Flores <yohanyflores@gmail.com>

LABEL com.imolko.group=imolko
LABEL com.imolko.type=base

#configuramos la zona horaria
RUN echo "America/Caracas" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

# Necesitamos unzip y curl
RUN set -x \
	&& apt-get update \
	&& apt-get install -y curl unzip openssl --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*


# creamos la carpeta para los scripts.
RUN mkdir -p /scripts.d

#templates
COPY nginx-templates/ /nginx-templates

# El dhparam por default.
COPY dhparam.pem.default /dhparam.pem.default

# Nuevo Entry point
COPY imolko-entrypoint.sh /imolko-entrypoint.sh

# Volumen para certificados y dhparam
VOLUME ["/etc/ngnix/certs", "/etc/nginx/dhparam"]

ENTRYPOINT ["/imolko-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
