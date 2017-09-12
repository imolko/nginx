FROM nginx:1.13-alpine

MAINTAINER Yohany Flores <yohanyflores@gmail.com>

LABEL com.imolko.group=imolko
LABEL com.imolko.type=base

ARG TZ=America/Caracas
ENV TZ ${TZ}

RUN apk --no-cache --update add tzdata \
    && cp "/usr/share/zoneinfo/${TZ}" /etc/localtime \
	&& echo "${TZ}" >  /etc/timezone \
    && apk del tzdata \
    && rm -rf /var/cache/apk/*

RUN apk --no-cache --update add \
		bash \
		openssl \
		ca-certificates \
    	curl \
		unzip \
	&& rm -rf /var/cache/apk/*

# Copiamos el certificado.
RUN  wget -O /usr/local/share/ca-certificates/cacert.crt https://imolko-dev.nyc3.digitaloceanspaces.com/certs/certs/ca-dev/cacert.crt \
    && update-ca-certificates

# creamos la carpeta para los scripts.
RUN mkdir -p /scripts.d

# Copiamos los templates.
COPY nginx-templates/ /nginx-templates

# Copiamos los snippets
COPY snippets/ /snippets

# Preparamos letsencript
RUN mkdir -p /usr/share/nginx/letsencrypt/.well-known/acme-challenge

# El dhparam por default.
COPY dhparam.pem.default /dhparam.pem.default

# Nuevo Entry point
COPY imolko-entrypoint.sh /imolko-entrypoint.sh

# Volumen para certificados y dhparam
#       Para certificados.  Para el dhparams,     Para el changelle
# VOLUME ["/etc/nginx/certs", "/etc/nginx/dhparam", "/usr/share/nginx/letsencrypt"]
ENTRYPOINT ["/imolko-entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
