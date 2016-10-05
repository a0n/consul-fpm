#!/bin/sh

TIMESTAMP=`date +%s`
TYPES="rpm deb"
VERSION="0.7.0"
BASE_URL="https://releases.hashicorp.com/consul"

# Download sources
if [ ! -f rootfs/usr/bin/consul ]
then
  mkdir -p rootfs/usr/bin
  URL=${BASE_URL}/${VERSION}/consul_${VERSION}_linux_amd64.zip
  echo "Downloading $URL" 
  wget -qO tmp.zip $URL && unzip tmp.zip -d rootfs/usr/bin && rm tmp.zip
  chmod 0755 rootfs/usr/bin/consul
fi
if [ ! -d rootfs/usr/share/consul-ui ]
then
  mkdir -p rootfs/usr/share
  URL=${BASE_URL}/${VERSION}/consul_${VERSION}_web_ui.zip
  echo "Downloading $URL"
  wget -qO tmp.zip $URL && unzip tmp.zip -d rootfs/usr/share/consul-ui && rm tmp.zip
fi

# Delete existing packages
for TYPE in $TYPES
do
  rm *."$TYPE" -f
done

# Create package
for TYPE in $TYPES
do
  echo "Creating $TYPE package..."
  fpm -s dir -t $TYPE -C rootfs -n consul -v ${VERSION} \
  --iteration $TIMESTAMP --epoch $TIMESTAMP \
  --after-install meta/after-install.sh \
  --before-remove meta/before-remove.sh \
  --after-remove meta/after-remove.sh
done
