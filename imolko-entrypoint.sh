#!/usr/bin/env sh

set -e

# Nuevo manejador de plantillas con shell script y variables.
faketpl() {
    local _line=""

    while IFS= read -r _line
    do
        eval echo '"'"${_line}"'"'
    done
}

if [ "${1:0:1}" = '-' ]; then
	set -- nginx "$@"
fi

if [ "$DEPLOY_ZENKIU" == "true" ]; then
     # Verificamos la existencia de zenkiu para el dominio. Si ya existe no se instala...
    if ! [ -e /usr/share/nginx/zenkius/${domain}/zenkiu/index.html ]; then
        echo >&2 "Not Found! Zenkiu not found in /usr/share/nginx/zenkius/${domain}/zenkiu/ - copying now..."

        if [ -f "/zenkiu/zenkiu-js.war" ]; then
            echo >&2 "Descomprimimos zenkiu-js.war en /usr/share/nginx/zenkius/${domain}/zenkiu"

            mkdir -p /usr/share/nginx/zenkius/${domain}/zenkiu \
                && unzip -o /zenkiu/zenkiu-js.war -d /usr/share/nginx/zenkius/${domain}/zenkiu > /dev/null

            echo >&2 "Complete! Zenkiu has been successfully copied to /usr/share/nginx/zenkius/${domain}/zenkiu"
        else
            echo >&2 "WARNING: No se encontro /zenkiu-js.war"
        fi
    else
        echo >&2 "Found! Zenkiu found in /usr/share/nginx/zenkius/${domain}/zenkiu/"
    fi
fi

# Si se especifica la variable de entorno NGINX_TEMPLATE,
# entonces copia un conf, en el directorio conf.d
if ! [ -z "${NGINX_TEMPLATES}" ]; then
    # Eliminamos las configuraciones previas
    rm -rf /etc/nginx/conf.d/*

    for templ in ${NGINX_TEMPLATES}; do
        if [ ! -f /nginx-templates/${templ}.conf.ftpl ]; then
            echo >&2 "Warning: !! El archivo template especificado no existe: /nginx-templates/${templ}.conf.ftpl"
            continue
        fi
        faketpl < "/nginx-templates/${templ}.conf.ftpl" > "/etc/nginx/conf.d/${templ}.conf"
    done

        # Copiamos el archivo ejecutable
    if [ "${1}" = 'nginx' ]; then
        if [ -f /nginx-templates/${templ}.sh ]; then
            cp /nginx-templates/${templ}.sh /scripts.d/${templ}.sh
            chmod +x /scripts.d/${templ}.sh

            # Ejecutamos el script.
            source /scripts.d/${templ}.sh
        fi
    fi
fi

exec "$@"
