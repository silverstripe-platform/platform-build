#!/usr/bin/env bash
set -e

php -v | egrep '^PHP'
composer --version

USER="$1"

if [ -z "$USER" ] ; then
    echo "Invalid build user given, failing."
    exit 1
fi

USER_ID=$(id -u "$USER")
USER_GID=$(id -g "$USER")

# Cache directory is mounted with root as owner so need to make it writeable by the non-root user.
chown -R $USER_ID:$USER_GID /tmp/cache

# If SSH key is mounted in root ssh directory, we'll need it in the non-root user's home directory.
if [ -f ~/.ssh/id_rsa ]; then
    cp ~/.ssh/id_rsa /home/"$USER"/.ssh/
    chmod 400 /home/"$USER"/.ssh/id_rsa
    chown "$USER_ID":"$USER_GID" /home/"$USER"/.ssh/id_rsa
fi

export APP_DIR="/${PWD##*/}"

# Run as non-root user and make required environment variables available to the script.
su --command="/bin/bash /home/$USER/build-project.sh" \
    --shell=/bin/bash \
    --whitelist-environment="CLOUD_BUILD_DISABLED,IDENT_KEY,APP_DIR,HTTP_PROXY,HTTPS_PROXY,http_proxy,https_proxy" \
    - "${USER}"

# Move artefact to the same location as previous code builder versions for backward compatibility.
mv /home/"$USER"/payload-source* /