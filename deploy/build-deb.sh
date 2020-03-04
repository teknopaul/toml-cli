#!/bin/bash -e
#
# Build a binary .deb package
#
test $(id -u) == "0" || (echo "Run as root" && exit 1) # requires bash -e

name=toml-cli
arch=$(uname -m)
cd $(dirname $0)/..
project_root=$PWD

tmp_dir=/tmp/$name-debbuild
rm -rf $tmp_dir
mkdir -p $tmp_dir/DEBIAN $tmp_dir/usr/bin

. ./version
sed -e "s/@PACKAGE_VERSION@/$VERSION/" $project_root/deploy/DEBIAN/control.in > $tmp_dir/DEBIAN/control
cp --archive -R target/x86_64-unknown-linux-musl/release/toml $tmp_dir/usr/bin

size=$(du -sk $tmp_dir | cut -f 1)
sed -i -e "s/@SIZE@/$size/" $tmp_dir/DEBIAN/control

cp --archive -R $project_root/deploy/DEBIAN/p* $tmp_dir/DEBIAN

(
  cd $tmp_dir/
  find etc -type f | sed 's.^./.' > DEBIAN/conffiles
)

chown -R root.root $tmp_dir/*

#
# Build the .deb
#
mkdir -p target/
dpkg-deb --build $tmp_dir target/$name-$VERSION-1.$arch.deb

test -f target/$name-$VERSION-1.$arch.deb

echo "built target/$name-$VERSION-1.$arch.deb"

if [ -n "$SUDO_USER" ]
then
  chown $SUDO_USER target/ target/$name-$VERSION-1.$arch.deb
fi

# test -d $tmp_dir && rm -rf $tmp_dir
