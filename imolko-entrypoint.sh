#!/usr/bin/env bash

set -e

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

    # verificamos parametro sendfile_switch para colocar el defecto.
    sendfile_switch="${sendfile_switch:-on}"

    merge_template () {
        # Merge template files and do variable substitution
        #
        # $1: Template file
        #
        # Supported directives:
        #   #include filename : Include filename and process it.
        #   ${variable}       : substituted by the value of the variable.
        #
        [ -z "$1" ] && return
        set -f
        while IFS='' read -r line; do
            if [[ "$line" =~ \#include\ (.*) ]]; then
                $FUNCNAME ${BASH_REMATCH[1]}
            else
                while [[ "$line" =~ (\$\{[a-zA-Z_][a-zA-Z_0-9]*\}) ]] ; do
                    LHS="${BASH_REMATCH[1]}"
                    RHS="$(eval echo "\"$LHS\"")"
                    line="${line//$LHS/$RHS}"
                done
                printf "%s\n" "$line"
            fi
        done<$1
        set +f
    }

    # Recorremos cada template que queramos instalar
    for templ in ${NGINX_TEMPLATES}; do
        if [ ! -f /nginx-templates/${templ}.conf ]; then
            echo >&2 "Warning: !! El archivo template especificado no existe: /nginx-templates/$templ.conf"
            continue
        fi

        merge_template "/nginx-templates/${templ}.conf" > /etc/nginx/conf.d/${templ}.conf


        # Copiamos el archivo ejecutable
        if [ "${1}" = 'nginx' ]; then
            if [ -f /nginx-templates/${templ}.sh ]; then
                cp /nginx-templates/${templ}.sh /scripts.d/${templ}.sh
                chmod +x /scripts.d/${templ}.sh

                # Ejecutamos el script.
                source /scripts.d/${templ}.sh
            fi
        fi
    done
fi

exec "$@"

