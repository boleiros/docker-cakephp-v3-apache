#!/bin/sh -e

# Enable debugging
if [ ! -z "$DEBUG" ]; then
    set -x
fi

# Import apache environment
. $APACHE_ENVVARS

