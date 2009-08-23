
MYSQL_TAR=/home/mheiges/mysql-5.1.37.tar.gz
MYSQL_SRC=$(BUILD_DIR)/mysql
DBI_SRC=DBI-1.609.tar.gz
DBD_MYSQL_SRC=DBD-mysql-4.012.tar.gz

BUNDLE_DIR=$(PWD)
BUILD_DIR=$(PWD)/.BUILD
DIST_DIR=/home/mheiges/OrthoMCL-vBLAH

export LANG :=  en_US
export PERL5LIB := $(DIST_DIR)/lib/perl


all: dbi mysql dbd-mysql mysql-dist

	
dbi:
	test -d "$(BUILD_DIR)/DBI" || mkdir -p "$(BUILD_DIR)/DBI"
	tar -zxf src/$(DBI_SRC) -C $(BUILD_DIR)/DBI --strip-components 1
	cd $(BUILD_DIR)/DBI \
	&& perl Makefile.PL \
		INSTALLDIRS=perl \
		PREFIX=$(DIST_DIR)/lib/perl \
		INSTALLPRIVLIB=$(DIST_DIR)/lib/perl \
		INSTALLMAN1DIR=none \
		INSTALLMAN3DIR=none \
		INSTALLBIN=none \
		INSTALLSCRIPT=none \
	&& make \
	&& make install

mysql :
	test -d "$(BUILD_DIR)/mysql" || mkdir -p "$(BUILD_DIR)/mysql"
	tar -zxf $(MYSQL_TAR) -C $(MYSQL_SRC) --strip-components 1
	if test "no$$(ldd /usr/lib/libncursesw.so.5 | grep libtinfo)" != "no" ; then \
		ltinfo="-ltinfo"; \
	fi; \
	cd $(BUILD_DIR)/mysql \
	&& 	patch  -Nb Makefile.in < $(BUNDLE_DIR)/src/Makefile.in.patch \
	&& CFLAGS="-O3" CXX=gcc CXXFLAGS="-O3 -felide-constructors \
		-fno-exceptions -fno-rtti" ./configure \
		--prefix=$(DIST_DIR) --enable-assembler \
		--libexecdir=$(DIST_DIR)/bin \
		--datarootdir=$(DIST_DIR)/data \
		--with-unix-socket-path=$(DIST_DIR)/tmp/my.socket \
		--with-mysqld-ldflags="-all-static" \
		--with-client-ldflags="-all-static $$ltinfo" \
		--enable-local-infile \
		--without-uca \
		--without-docs \
		--without-debug \
		--without-ndb-binlog \
		--without-ndb-debug \
		--disable-community-features \
		--with-plugins=none \
		--without-man \
		--without-mysqlmanager \
		--without-geometry \
		--without-query-cache \
		--without-embedded-server \
		--without-debug \
		--disable-dependency-tracking \
		--without-libwrap \
	&& make \
	#&& make install

mysql-dist:
	test -d "mkdir $(DIST_DIR)/db/data" || mkdir -p $(DIST_DIR)/db/data
	test -d "mkdir $(DIST_DIR)/db/bin" || mkdir -p $(DIST_DIR)/db/bin
	test -d "mkdir $(DIST_DIR)/db/share" || mkdir -p $(DIST_DIR)/db/share
	cp $(BUILD_DIR)/mysql/sql/mysqld $(DIST_DIR)/db/bin
	cp $(BUILD_DIR)/mysql/extra/my_print_defaults $(DIST_DIR)/db/bin
	cp $(BUILD_DIR)/mysql/client/mysql $(DIST_DIR)/db/bin
	cp $(BUILD_DIR)/mysql/scripts/mysqld_safe $(DIST_DIR)/db/bin
	cp -R $(BUILD_DIR)/mysql/sql/share/english $(DIST_DIR)/db/share
	$(BUILD_DIR)/mysql/scripts/mysql_install_db --srcdir=$(BUILD_DIR)/mysql --datadir=$(BUILD_DIR)/mysql/data
	cp -R $(BUILD_DIR)/mysql/data/mysql $(DIST_DIR)/db/data
	test -d "$(DIST_DIR)/db/tmp" || mkdir $(DIST_DIR)/db/tmp
	
dbd-mysql:
	test -d "$(BUILD_DIR)/DBD-mysql" || mkdir -p "$(BUILD_DIR)/DBD-mysql"
	tar -zxf src/$(DBD_MYSQL_SRC) -C $(BUILD_DIR)/DBD-mysql --strip-components 1
	test -d "$(BUILD_DIR)/mysql/libmysql/.libs-static" || mkdir -p "$(BUILD_DIR)/mysql/libmysql/.libs-static"
	cp $(BUILD_DIR)/mysql/libmysql/.libs/*.a $(BUILD_DIR)/mysql/libmysql/.libs-static
	cd $(BUILD_DIR)/DBD-mysql \
	&& perl Makefile.PL \
		--mysql_config=$(BUILD_DIR)/mysql/scripts/mysql_config \
		--cflags=-I$(BUILD_DIR)/mysql/include \
		--libs="-L$(BUILD_DIR)/mysql/libmysql/.libs-static -lmysqlclient -lz" \
		INSTALLDIRS=perl \
		PREFIX=$(DIST_DIR)/lib/perl \
		INSTALLPRIVLIB=$(DIST_DIR)/lib/perl \
		INSTALLMAN1DIR=none \
		INSTALLMAN3DIR=none \
		INSTALLBIN=none \
		INSTALLSCRIPT=none \
	&& make \
	&& make install


clean:
	rm -rf  "$(BUILD_DIR)"

clean-mysql:
	rm -rf  "$(MYSQL_SRC)"

clean-dbd-mysql:
	rm -rf  "$(BUILD_DIR)/DBD-mysql"
