#!/usr/bin/env sh

function testCaCertificates {

cat << EOF > openssl-server.cnf
HOME            = .
RANDFILE        = \$ENV::HOME/.rnd

####################################################################
[ req ]
default_bits       = 2048
default_keyfile    = privkey.pem
distinguished_name = server_distinguished_name
req_extensions     = server_req_extensions
string_mask        = utf8only

####################################################################
[ server_distinguished_name ]
countryName         = Country Name (2 letter code)
countryName_default = VE

stateOrProvinceName         = State or Province Name (full name)
stateOrProvinceName_default = Guarico

localityName         = Locality Name (eg, city)
localityName_default = Altagracia de Orituco

organizationName            = Organization Name (eg, company)
organizationName_default    = Imolko C.A.

commonName           = Common Name (e.g. server FQDN or YOUR name)
commonName_default   = Zauron Developer

emailAddress         = Email Address
emailAddress_default = info@imolko.com

####################################################################
[ server_req_extensions ]

subjectKeyIdentifier = hash
basicConstraints     = CA:FALSE
keyUsage             = digitalSignature, keyEncipherment
subjectAltName       = @alternate_names
nsComment            = "OpenSSL Generated Certificate"

####################################################################
[ alternate_names ]
DNS.1  = ${domain}
DNS.2  = www.${domain}
DNS.3  = imolko.dev
DNS.4  = www.imolko.dev
IP.1 = 127.0.0.1

EOF


cat << 'EOF' > openssl-ca.cnf
HOME            = .
RANDFILE        = $ENV::HOME/.rnd

####################################################################
[ ca ]
default_ca    = CA_default      # The default ca section

[ CA_default ]

default_days     = 1000         # how long to certify for
default_crl_days = 30           # how long before next CRL
default_md       = sha256       # use public key default MD
preserve         = no           # keep passed DN ordering

x509_extensions = ca_extensions # The extensions to add to the cert

email_in_dn     = no            # Don't concat the email in the DN
copy_extensions = copy          # Required to copy SANs from CSR to cert

base_dir      = .
certificate   = $base_dir/cacert.pem   # The CA certifcate
private_key   = $base_dir/cakey.pem    # The CA private key
new_certs_dir = $base_dir              # Location for new certs after signing
database      = $base_dir/index.txt    # Database index file
serial        = $base_dir/serial.txt   # The current serial number

unique_subject = no  # Set to 'no' to allow creation of
                     # several certificates with same subject.

####################################################################
[ req ]
default_bits       = 4096
default_keyfile    = cakey.pem
distinguished_name = ca_distinguished_name
x509_extensions    = ca_extensions
string_mask        = utf8only

####################################################################
[ ca_distinguished_name ]
countryName         = Country Name (2 letter code)
countryName_default = VE

stateOrProvinceName         = State or Province Name (full name)
stateOrProvinceName_default = Guarico

localityName                = Locality Name (eg, city)
localityName_default        = Altagracia de Orituco

organizationName            = Organization Name (eg, company)
organizationName_default    = Imolko Corp C.A.

organizationalUnitName         = Organizational Unit (eg, division)
organizationalUnitName_default = Investigacion y Desarrollo

commonName         = Common Name (e.g. server FQDN or YOUR name)
commonName_default = Imolko Corp.

emailAddress         = Email Address
emailAddress_default = info@imolko.com

####################################################################
[ ca_extensions ]

subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always, issuer
basicConstraints       = critical, CA:true
keyUsage               = keyCertSign, cRLSign

####################################################################
[ signing_policy ]
countryName            = optional
stateOrProvinceName    = optional
localityName           = optional
organizationName       = optional
organizationalUnitName = optional
commonName             = supplied
emailAddress           = optional

####################################################################
[ signing_req ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid,issuer
basicConstraints       = CA:FALSE
keyUsage               = digitalSignature, keyEncipherment

EOF


cat << EOF > cakey.pem
-----BEGIN PRIVATE KEY-----
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
x5DF27PdC2QzxkxcBbLd9rF6E6IuvQ==
-----END PRIVATE KEY-----

EOF

cat << EOF > cacert.pem
-----BEGIN CERTIFICATE-----
MIIGUTCCBDmgAwIBAgIJAL+kQaZ/S2RGMA0GCSqGSIb3DQEBCwUAMIG2MQswCQYD
VQQGEwJWRTEQMA4GA1UECAwHR3VhcmljbzEeMBwGA1UEBwwVQWx0YWdyYWNpYSBk
ZSBPcml0dWNvMRkwFwYDVQQKDBBJbW9sa28gQ29ycCBDLkEuMSMwIQYDVQQLDBpJ
bnZlc3RpZ2FjaW9uIHkgRGVzYXJyb2xsbzEVMBMGA1UEAwwMSW1vbGtvIENvcnAu
MR4wHAYJKoZIhvcNAQkBFg9pbmZvQGltb2xrby5jb20wHhcNMTcwOTEyMDUwNzIy
WhcNMjgxMTI5MDUwNzIyWjCBtjELMAkGA1UEBhMCVkUxEDAOBgNVBAgMB0d1YXJp
Y28xHjAcBgNVBAcMFUFsdGFncmFjaWEgZGUgT3JpdHVjbzEZMBcGA1UECgwQSW1v
bGtvIENvcnAgQy5BLjEjMCEGA1UECwwaSW52ZXN0aWdhY2lvbiB5IERlc2Fycm9s
bG8xFTATBgNVBAMMDEltb2xrbyBDb3JwLjEeMBwGCSqGSIb3DQEJARYPaW5mb0Bp
bW9sa28uY29tMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAnRtSc4Vf
mVKhAS11Xvuod0G/Gmw7CjirlevOrZnEU8cUvN5tdRJClTNBbwaXzLKMAK/qjlHS
3qOxA8D9kz5+tVVxniitZj5t7kOQphRYT4IhrWgp4gGi8TuyZ9+0+YOLpfLHXJo7
Vr6YkdoABITViXT9ZB8fwGj5kLrejNfRKGz30xOQ9ZqISuPxFk6tbWBz5iRaSevX
mCUZvLo8VQJ2r63cq6+sPHMYcxspBuJoc9rqIqbnWeXhiOXB8wHZvQf7BW/ObxvM
ii422itkcp9Ki38eLZ9yLno8qbRvFWITkneNrVpDRBZQNkyRE79n194iuqwIPgzY
gtOzMtbxEZxlxGs70HXX0YLygw0zBUTn6W/CtnyoGTq+Dk9T2tPwZdozl98FSEoo
rpbm9kDZtAN+Wu5nLdzC9BKuAYtyWypTKpvLB2vl7ZXflP8nWR3fEjyJ/Ni38NGp
Zu9D5x/lHCNoNAUWgWNeytlrUwP6kU7HC2r7YH9OXTYvP25VeOWCBQjTRykO7c/Z
jA+EostXhp1vxsoY8kxC4V1cxtw0xPRRZNAeF2xiypJgbXJptX/mTWkuO6S81xYw
rmgsMXORfUrrmGPOc8jKR5PB2gJsgLO4BhmO1xJHiRpGA06M0bzmsYM38SvFzwbD
LNCOj2udPKL//U41uJ5LGCkPzbrB8JqwKO8CAwEAAaNgMF4wHQYDVR0OBBYEFJUg
bv7vjph8OYgCd5eK6Ek9NHcLMB8GA1UdIwQYMBaAFJUgbv7vjph8OYgCd5eK6Ek9
NHcLMA8GA1UdEwEB/wQFMAMBAf8wCwYDVR0PBAQDAgEGMA0GCSqGSIb3DQEBCwUA
A4ICAQCBrYOND57r8aW/n4NOErXLCaEppW2KyCE3jgbyyBPW+TZLEB+8uiLB3AlO
Qko9crPirY1RyKTm48npc8Nc4174y9F71axT90QBvbBYYw9CT2B/+m0umefzfpVC
RvC5biGHC4oyGpSOoCdgh9LR9dwdQ3W0SB4kALFuK3v4/ONlgvYZ0rDXrsQqjk33
3FnoctsVhOm/jeWCxb0mYDDYUwD0OvD1viLP54JN4cDYU3RVtNElD7R5S2XHJdtS
O3whgG0uWo6iGcarz6bdqDvUEY1vonAPGQxtVwR9tcGiSOw7pegeuiV5ic3o5aNR
NIOT9Vs6QMl38sfP+JJUnr1ATvEL5A7Hobwl7352EW/F4Eu1Tq4ZJGsqQ2r4Atcv
HECXCTcKCnQ9G+WVGLqTjXyQWlZnpBaM8Slm9Kwxd6e7d63hxzfxMKZCsEZ839CV
3QXX4aYSNrtNlEUAZTAbFKEPl7l5zpx261cWtgTKr63FrvEGz3xBvie9i1792ylU
l7Qvl/ql10j6QLcOP0zR9h5syUpxwLbcPJA+dIgQOo0TtPF9NiUC9jgVYsbCArnI
c7rHG1NgIKbVK8pp7PnjwkUXlm+rjPCuP8GI/zbpZdqJRtft3ofOJcYzTAzFJfBU
DdT0e9hr+ac+88sRKZ9iyivCPvOjEW0rcmdwkn0MCE1KLD0E5A==
-----END CERTIFICATE-----

EOF

}

function createSelfSignedCert {
    local domain="${1}";
    local domain1="${domain}";
    local domain2="www.${domain}";
    local country="VE";
    local state="Guarico";
    local location="Altagracia de Orituco";
    local organization="Imolko C.A.";
    local departamento="Desarrollo";
    local emailAddress="info@${domain}"

    # Solo creamos un self signed certificado si este no existe.
    if [ ! -f "/etc/nginx/certs/${domain}/fullchain.pem" ]; then
        # Creamos directorio para guardar el certificado por defecto.
        mkdir -p "/etc/nginx/certs/${domain}/"

        local pwd=$(pwd)

        cd "/etc/nginx/certs/${domain}"

        touch index.txt
        touch index.txt.attr

        echo '01' > serial.txt

        testCaCertificates

        # Generamos un openssl cofiguration
        # cat /etc/ssl/openssl.cnf | sed -e "s/\[\s*v3_ca\s*\]/[alt_names]\nDNS.1 = ${domain1}\nDNS.2 = ${domain2}\n\n[v3_ca]\nsubjectAltName = @alt_names\n/" > openssl.cnf

        # Creamos el Key
        openssl genrsa -out /etc/nginx/certs/${domain}/privkey.pem 2048

        # Creamos el csr.
        openssl req -batch -new -nodes -sha256 \
                -key /etc/nginx/certs/${domain}/privkey.pem \
                -out /etc/nginx/certs/${domain}/fullchain.csr \
                -subj "/C=$country/ST=$state/L=$location/O=$organization/OU=$departamento/CN=$domain1/emailAddress=$emailAddress" \
                -config openssl-server.cnf

        # Formamos el csr
        openssl ca \
                -batch \
                -config openssl-ca.cnf \
                -policy signing_policy \
                -extensions signing_req \
                -out fullchain.pem \
                -infiles fullchain.csr

        cd "${pwd}"
    fi
}

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


# Creamos el self signed certificado.
createSelfSignedCert "${domain}"

# creamos dh params.
generateDHParams
