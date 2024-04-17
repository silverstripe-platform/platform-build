#!/usr/bin/env bash
set -e

USER="$1"

if [ -z "$USER" ] ; then
    echo "Invalid build user given, failing."
    exit 1
fi

USER_ID=$(id -u "$USER")
USER_GID=$(id -g "$USER")

# Cache directory is mounted with root as owner so need to make it writeable by the non-root user. 
chown -R $USER_ID:$USER_GID /tmp/cache

# SSH key is mounted in root ssh directory, but we need it in the non-root user's home directory. 
cp ~/.ssh/id_rsa /home/"$USER"/.ssh/
chown "$USER_ID":"$USER_GID" /home/"$USER"/.ssh/id_rsa

export APP_DIR="/${PWD##*/}"

# Run as non-root user and make required environment variables available to the script.
su --command="/bin/bash /home/$USER/build-project.sh" \
    --shell=/bin/bash \
    --whitelist-environment="CLOUD_BUILD_DISABLED,PARSE_COMPOSER,IDENT_KEY,APP_DIR" \
    - "${USER}"

# Move artefact to the location dash expects it to be.
mv /home/"$USER"/payload-source* /