#!/usr/bin/env sh

# Genera un nuevo DHParams
function generateDHParams {
    local DHPARAM_BITS=${1:-2048}
    local PREGEN_DHPARAM_FILE="/dhparam.pem.default"
    local DHPARAM_FILE="/etc/nginx/dhparam/dhparam.pem"
    local GEN_LOCKFILE="/tmp/dhparam_generating.lock"
    local PREGEN_HASH=$(md5sum $PREGEN_DHPARAM_FILE | cut -d" " -f1)
    if [[ -f $DHPARAM_FILE ]]; then
        local CURRENT_HASH=$(md5sum $DHPARAM_FILE | cut -d" " -f1)
        if [[ $PREGEN_HASH != $CURRENT_HASH ]]; then
            # There is already a dhparam, and it's not the default
            echo "Custom dhparam.pem file found, generation skipped"
            return 0
        fi

        if [[ -f $GEN_LOCKFILE ]]; then
            # Generation is already in progress
            return 0
        fi
    fi

    cat >&2 <<-EOT
WARNING: $DHPARAM_FILE was not found. A pre-generated dhparam.pem will be used for now while a new one
is being generated in the background.  Once the new dhparam.pem is in place, nginx will be reloaded.
EOT

    cp $PREGEN_DHPARAM_FILE $DHPARAM_FILE
    touch $GEN_LOCKFILE

    # Generate a new dhparam in the background in a low priority and reload nginx when finished (grep removes the progress indicator).
    (
        (
            nice -n +5 openssl dhparam -out $DHPARAM_FILE $DHPARAM_BITS 2>&1 \
            && echo "dhparam generation complete, reloading nginx" \
            && nginx -s reload
        ) | grep -vE '^[\.+]+'
        rm $GEN_LOCKFILE
    ) &disown
}

# creamos dh params.
generateDHParams
