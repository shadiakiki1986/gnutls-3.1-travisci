prepare:
	sudo apt-get update
	sudo apt-get install libgmp-dev autogen pkg-config make m4 php5-cli php5-curl build-essential

check:
	whoami
	ls -al /usr/local/lib
	ls -al /usr/lib/x86_64-linux-gnu/libgnutls*
	ls -al /usr/lib/x86_64-linux-gnu/libcurl*
	dpkg -l|grep 7\.22 || echo "None"
	dpkg -l|grep 2\.12 || echo "None"
	echo '<?php phpinfo(); ?>' | php |grep -i ssl
	echo '<?php var_dump(curl_version()); ?>' | php 
	pkg-config --modversion gnutls || echo "pkg-config --modversion gnutls failed"
	ldd /usr/lib/x86_64-linux-gnu/libcurl-gnutls.so.4|grep gnut # Not sure what this is for
	(ldd /usr/lib/php5/20090626/curl.so|grep gnutls)|| echo "no package curl.so in /usr/lib/php5" # after installCurl, this should link to libcurl.so...28 instead of 26
	ls $(HOME)

installNettle:
	# nettle .. 2.7.1 is the specific version that gnutls 3.1 requires
	wget ftp://ftp.gnu.org/gnu/nettle/nettle-2.7.1.tar.gz
	tar -xzf nettle-2.7.1.tar.gz
	cd nettle-2.7.1 && ./configure && make && make check && sudo make install
	sudo ldconfig -v

installGnutls:
	# gnutls ..  3.1 is current stable
	wget ftp://ftp.gnutls.org/gcrypt/gnutls/stable/gnutls-3.1.28.tar.xz
	unxz gnutls-3.1.28.tar.xz
	tar -xvf gnutls-3.1.28.tar
	cd gnutls-3.1.28 && ./configure && make && make check && sudo make install
	sudo ldconfig -v

installCurl:
	# compiling curl
	cd /usr/lib/x86_64-linux-gnu/ && sudo rm libcurl* libgnutls*
	sudo ldconfig -v
	wget http://curl.haxx.se/download/curl-7.42.1.tar.gz
	tar -xzf curl-7.42.1.tar.gz
	cd curl-7.42.1 && ./configure --without-ssl --with-gnutls && make && ( make check || echo "curl/make check failed" ) && sudo make install
	cd /usr/lib/x86_64-linux-gnu/ && sudo rm libcurl* libgnutls*
	sudo ldconfig -v
