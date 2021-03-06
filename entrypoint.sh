#!/bin/sh -e

# Enable debugging
if [ ! -z "$DEBUG" ]; then
    set -x
    env
fi

# Set up environment
. apt-init.sh
. oci-init.sh
. project-init.sh
. apache-init.sh
. crunz-init.sh

## install project with git
if [ "$PROJECT_VCS_METHOD" = git ]; then
    if [ -n "$PROJECT_VCS_URL" ]; then
        git clone -b "$PROJECT_VCS_BRANCH" "$PROJECT_VCS_URL" "$(readlink -m .)"
        if [ -f "./composer.json" ]; then
            composer update
        fi
    fi

## install project with composer
else
    if [ ! -z "$PROJECT_NAME" ]; then
        /usr/bin/composer create-project \
          --stability=dev \
          --prefer-source \
          --no-interaction \
          --keep-vcs \
          $PROJECT_REPO/$PROJECT_NAME:dev-$PROJECT_VCS_BRANCH "$(readlink -m ..)"
    fi
fi

# Insure proper permissions
chown -R $APACHE_RUN_USER:$APACHE_RUN_GROUP "$(readlink -m ..)"

# Enable StrictHostKeyChecking (disabled in project-init)
if [ -f $HOME/.ssh/config ]; then
    sed -i "s/StrictHostKeyChecking no/StrictHostKeyChecking yes/"  $HOME/.ssh/config
fi

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
        set -- apache2-foreground "$@"
fi

exec "$@"
