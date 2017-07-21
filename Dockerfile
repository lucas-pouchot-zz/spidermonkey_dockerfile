FROM resin/armv7hf-debian-qemu

RUN [ "cross-build-start" ]

ENV SHELL /bin/bash

ENV LIB /usr/local/lib/
ENV INCLUDE /usr/local/include/

ENV DEPENDENCIES_SOURCES https://s3-us-west-2.amazonaws.com/dependencies/

ENV M4_NAME    m4
ENV M4_VERSION 1.4.1
ENV M4_EXT     .tar.gz
ENV M4_FOLDER  $M4_NAME-$M4_VERSION
ENV M4_FILE    $M4_FOLDER$M4_EXT
ENV M4_SOURCE  $DEPENDENCIES_SOURCES$M4_FILE

ENV AUTOCONF_NAME    autoconf
ENV AUTOCONF_VERSION 2.13
ENV AUTOCONF_EXT     .tar.gz
ENV AUTOCONF_FOLDER  $AUTOCONF_NAME-$AUTOCONF_VERSION
ENV AUTOCONF_FILE    $AUTOCONF_FOLDER$AUTOCONF_EXT
ENV AUTOCONF_SOURCE  $DEPENDENCIES_SOURCES$AUTOCONF_FILE

ENV SPDIERMONKEY_NAME     Spidermonkey
ENV SPDIERMONKEY_VERSION  v34
ENV SPIDERMONKEY_EXT      .zip
ENV SPIDERMONKEY_FOLDER   $SPDIERMONKEY_NAME-$SPDIERMONKEY_VERSION
ENV SPIDERMONKEY_FILE     $SPIDERMONKEY_FOLDER$SPIDERMONKEY_EXT
ENV SPIDERMONKEY_SOURCE   $DEPENDENCIES_SOURCES$SPIDERMONKEY_FILE

RUN apt-get update && apt-get install -yq wget unzip build-essential python python2.7-dev &&\
	cd /tmp &&\
	wget $M4_SOURCE &&\
	tar -xzf $M4_FILE &&\
	cd $M4_FOLDER &&\
	./configure &&\
	make &&\
	make install &&\
	cd /tmp &&\
	rm /tmp/$M4_FOLDER* -r &&\
	wget $AUTOCONF_SOURCE &&\
	tar -xzf $AUTOCONF_FILE &&\
	cd $AUTOCONF_FOLDER &&\
	./configure &&\
	make &&\
	make install &&\
	ln -s /usr/local/bin/autoconf /usr/local/bin/$AUTOCONF_FOLDER &&\
	cd /tmp &&\
	rm /tmp/$AUTOCONF_FOLDER* -r &&\
	wget $SPIDERMONKEY_SOURCE &&\
	unzip $SPIDERMONKEY_FILE -d $SPIDERMONKEY_FOLDER &&\
	cd $SPIDERMONKEY_FOLDER/js/src &&\
	$AUTOCONF_FOLDER &&\
	mkdir build_OPT.OBJ &&\
	cd build_OPT.OBJ &&\
	../configure --enable-optimize \
	             --disable-shared-js \
	             --disable-tests \
	             --disable-debug \
	             --without-intl-api \
	             --disable-threadsafe &&\
	make &&\
	strip -S js/src/libjs_static.a &&\
	mkdir -p $LIB$SPDIERMONKEY_NAME &&\
	mkdir -p $INCLUDE$SPDIERMONKEY_NAME &&\
	cd /root &&\
	cp -L /tmp/$SPIDERMONKEY_FOLDER/js/src/build_OPT.OBJ/dist/lib/* $LIB$SPDIERMONKEY_NAME/ -R &&\
	cp -L /tmp/$SPIDERMONKEY_FOLDER/js/src/build_OPT.OBJ/dist/include $INCLUDE$SPDIERMONKEY_NAME/ -R &&\
	rm /tmp/$SPIDERMONKEY_FOLDER* -r &&\
	apt-get --purge autoremove wget &&\
	apt-get --purge autoremove unzip &&\
	apt-get --purge autoremove build-essential &&\
	apt-get --purge autoremove python &&\
	apt-get --purge autoremove python2.7-dev &&\
	rm -rf /var/lib/apt/lists/*

RUN [ "cross-build-end" ]
