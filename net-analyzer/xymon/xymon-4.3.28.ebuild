# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils user

DESCRIPTION="Xymon is a tool for monitoring servers, applications and networks."
HOMEPAGE="http://www.xymon.com"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm arm64 x86"
IUSE="apache2 fping ldap ssl +server"

DEPEND="dev-libs/libpcre
	ssl? ( dev-libs/openssl:0= )
	fping? ( net-analyzer/fping[suid] )
	server? ( net-analyzer/rrdtool
		net-dns/c-ares
	)
	ldap? ( net-nds/openldap )
	sys-apps/findutils
	sys-apps/grep
	sys-apps/net-tools
	sys-apps/sed
	sys-process/procps[ncurses]" # for top
RDEPEND="${DEPEND}
	!net-analyzer/xymon-client"

pkg_setup() {
	GROUP="xymon"
	enewgroup xymon || die
	enewuser xymon -1 -1 /usr/xymon/home $GROUP || die
}

src_prepare() {
	cp "${S}"/web/showgraph.c "${S}"/web/showgraph.c.orig || die
	cp "${S}/web/history.c" "${S}/web/history.c.orig" || die
	epatch "${FILESDIR}"/history.patch || die
	epatch "${FILESDIR}"/logfetch.patch || die
#	find -name *.c | xargs sed -i 's,static char rcsid,static const char rcsid,' || die
	if ! use ldap ; then
		rm build/test-ldap.c || die
	fi
##	epatch ${FILESDIR}/makefile_common.patch || die
#	cp client/Makefile client/Makefile.old || die
	sed -i 's,$(CFLAGS) -o,$(CFLAGS) $(LDFLAGS) -o,' client/Makefile || die
#	diff -u client/Makefile.old client/Makefile
	sed -i 's,$(CFLAGS) -o,$(CFLAGS) $(LDFLAGS) -o,' xymond/Makefile || die
	sed -i 's,$(CFLAGS) -o,$(CFLAGS) $(LDFLAGS) -o,' xymonproxy/Makefile || die
	sed -i 's,$(CFLAGS) -o,$(CFLAGS) $(LDFLAGS) -o,' xymonnet/Makefile || die
	sed -i 's,$(CFLAGS) -o,$(CFLAGS) $(LDFLAGS) -o,' web/Makefile || die

	sed -i 's,sleep 5,,' client/xymonclient-linux.sh || die

	einfo "Remove bundled c-ares"
#	cp xymonnet/Makefile xymonnet/Makefile.orig || die
#	epatch "${FILESDIR}"/use_system_c-ares.patch || die
	rm xymonnet/c-ares-1.12.0.tar.gz || die

	# fix pid locations
	sed -i 's,\(xymond.pid.*\)xgetenv("XYMONSERVERLOGS"),\1"/run/xymond/",' xymond/xymond.c || die
	sed -i 's,\(xymond_history.pid.*\)xgetenv("XYMONSERVERLOGS"),\1"/run/xymond/",' xymond/trimhistory.c || die
	sed -i 's,\(xymond_history.pid.*\)xgetenv("XYMONSERVERLOGS"),\1"/run/xymond/",' xymond/xymond_history.c || die
	sed -i 's,@XYMONLOGDIR@/xymond.pid,/run/xymond/xymond.pid,' xymond/xymon.sh.DIST || die
	sed -i 's,@XYMONLOGDIR@/xymonlaunch.pid,/run/xymond/xymonlaunch.pid,' xymond/xymon.sh.DIST || die
	sed -i 's,--pidfile=.*/xymond.pid,--pidfile=/run/xymond/xymond.pid,' xymond/etcfiles/tasks.cfg.DIST || die
	sed -i 's,--pidfile=$XYMONSERVERLOGS,--pidfile=/run/xymond/,' xymond/etcfiles/tasks.cfg.DIST || die

	default
}

src_configure() {
	if use fping ; then
		FPING=n
	else
		FPING=y
	fi
	if use ssl ; then
		SSL=y
	else
		SSL=n
	fi
	if use ldap ; then
		LDAP=y
	else
		LDAP=n
	fi
	TYPE='--client'
	if use server ; then
		TYPE='--server'
		XYMONTOPDIR='/usr/xymon/'
	else
		XYMONTOPDIR='/usr/xymon/client/'
	fi
	#no econf since xymon configure is a fake configure
	USEXYMONPING=${FPING} ENABLESSL=${SSL} ENABLELDAP=${LDAP} XYMONUSER=xymon \
	XYMONTOPDIR=$XYMONTOPDIR XYMONHOSTURL=/xymon \
	CGIDIR=/usr/xymon/cgi-bin XYMONCGIURL=/xymon-cgi \
	SECURECGIDIR=/usr/xymon/cgi-secure SECUREXYMONCGIURL=/xymon-seccgi \
	HTTPDGID=apache XYMONLOGDIR=/var/log/xymon XYMONHOSTNAME=`hostname` \
	SYSTEMCARES=no \
	XYMONHOSTIP=127.0.0.1 MANROOT=/usr/share/man ./configure $TYPE || die
}

src_compile() {
	#sed -i 's,ifndef PKGBUILD,ifdef PKGBUILD,g' build/Makefile.Linux || die
#	sed -i 's,ifndef PKGBUILD,ifdef PKGBUILD,g' build/Makefile.rules || die
#	sed -i 's,ifndef PKGBUILD,ifdef PKGBUILD,g' web/Makefile || die
#	sed -i 's,ifndef PKGBUILD,ifdef PKGBUILD,g' xymond/Makefile || die
#	sed -i 's,ifndef PKGBUILD,ifdef PKGBUILD,g' client/Makefile || die
	sed -i 's,-Wall,-D_FORTIFY_SOURCE=2 -fstack-protector-all -fPIE,g' build/Makefile.Linux || die
	PKGBUILD=1 emake -j1 LDFLAGS="$LDFLAGS -pie -Wl,-z,relro,-z,now" || die
#	./build/genconfig.sh || die
#	make lib-build || die
#	make lib-client || die
#	emake lib-build || die
#	emake lib-build || die
#	emake || die
}

src_install() {
	INSTALLROOT=${D} PKGBUILD=1 make install || die

	dodir /usr/xymon/home || die
	fowners xymon:xymon /usr/xymon/home || die

	einfo "Deporting /etc/xymon-client"
	dodir /etc/xymon-client/ || die
	mv "${D}"/usr/xymon/client/etc/* "${D}"/etc/xymon-client/ || die
	rmdir "${D}"/usr/xymon/client/etc/ || die
	dosym /etc/xymon-client/ /usr/xymon/client/etc || die
	fowners -R root:xymon /etc/xymon-client || die
	fperms -R o-rwx /etc/xymon-client || die

	einfo "Deporting xymon-client tmp dir"
	dodir /var/tmp/xymon-client/ || die
	rmdir "${D}"/usr/xymon/client/tmp/ || die
	dosym /var/tmp/xymon-client/ /usr/xymon/client/tmp || die
	fowners -R xymon:xymon /usr/xymon/client/tmp || die
	fowners -R xymon:xymon /var/tmp/xymon-client || die
	fperms -R o-rwx /var/tmp/xymon-client/ || die

	einfo "Deporting client log directory"
	rmdir "${D}"/usr/xymon/client/logs || die
	dodir /var/log/xymon-client/ || die
	dosym /var/log/xymon-client/ /usr/xymon/client/logs
	fowners -R xymon:xymon /usr/xymon/client/logs || die
	fowners -R xymon:xymon /var/log/xymon-client || die
	fperms -R o-rwx /var/log/xymon-client/ || die

	einfo "Misc fix"
	rm "${D}"/usr/xymon/client/bin/xymonclient-{openbsd,sco_sv,irix,freebsd,sunos,unixware,hp-ux,aix,osf1,darwin,netbsd}.sh || die
	newconfd "${FILESDIR}"/xymon-client.confd xymon-client || die
	PATH_TO_IFCONFIG="`which ifconfig`"
	einfo "Setting ifconfig to $PATH_TO_IFCONFIG"
	sed -i "s,/sbin/ifconfig,$PATH_TO_IFCONFIG,g" "${D}"/usr/xymon/client/bin/xymonclient-linux.sh || die
	doinitd "${FILESDIR}"/xymon-client || die

	fperms -R o-rwx /usr/xymon/client || die
	fowners -R :xymon /usr/xymon/ || die
	fperms -R g-w /usr/xymon/ || die
	fperms 755 /usr/xymon/ || die

	if use server ; then
		einfo "Deporting /etc/xymon/"
		dodir /etc/xymon || die
		mv "${D}"/usr/xymon/server/etc/* "${D}"/etc/xymon/ || die
		rmdir "${D}"/usr/xymon/server/etc/ || die
		dosym /etc/xymon/ /usr/xymon/server/etc || die
		fowners -R :xymon /etc/xymon/ || die
		fperms -R g-w /etc/xymon/ || die
		fperms -R o-rwx /etc/xymon/ || die

		einfo "Deporting /var/tmp/xymon/"
		dodir /var/tmp/xymon/ || die
		rmdir "${D}"/usr/xymon/server/tmp/ || die
		dosym /var/tmp/xymon/ /usr/xymon/server/tmp || die
		fowners -R xymon:xymon /var/tmp/xymon || die
		fperms -R o-rwx /var/tmp/xymon/ || die

# 		a peter
#		fowners -R xymon:xymon /usr/xymon/server/tmp/ || die
#		fperms -R o-rwx /usr/xymon/server/tmp/ || die

		newinitd "${FILESDIR}"/xymon.init xymon || die

		fowners -R xymon:xymon /var/log/xymon/ || die
		fperms -R o-rwx /var/log/xymon/ || die

	#	dodir /var/xymon/data
		fowners -R xymon:xymon /usr/xymon/data/ || die
		fperms -R o-rwx /usr/xymon/data/ || die

		fowners -R root:xymon /usr/xymon/server/bin || die
		fperms -R o-rwx /usr/xymon/server/bin/ || die
		fowners -R root:xymon /usr/xymon/server/download || die
		fperms -R o-rwx /usr/xymon/server/download/ || die
		fowners -R root:xymon /usr/xymon/server/ext || die
		fperms -R o-rwx /usr/xymon/server/ext/ || die

		fowners -R xymon:xymon /usr/xymon/server/www/ || die

		touch "${D}"/etc/xymon/cookies.session || die
		fowners xymon:apache /etc/xymon/cookies.session || die
		fperms 640 /etc/xymon/cookies.session || die

		if use apache2 ; then
			dodir /etc/apache2/modules.d/ || die
			echo "<IfDefine XYMONSRV>" > "${D}"/etc/apache2/modules.d/99_xymon.conf || die
			cat xymond/etcfiles/xymon-apache.conf >> "${D}"/etc/apache2/modules.d/99_xymon.conf || die
			echo "</IfDefine>" >> "${D}"/etc/apache2/modules.d/99_xymon.conf || die
			fperms 640 /etc/apache2/modules.d/99_xymon.conf || die

#			sed -i 's,server/etc/,cgi-bin/,' "${D}"/usr/xymon/cgi-bin/cgioptions.cfg || die
#			sed -i 's,^XYMONTMP=.*,XYMONTMP=/tmp/,' "${D}"/usr/xymon/cgi-bin/xymonserver.cfg || die
#			sed -i 's,server/etc/,cgi-bin/,' "${D}"/usr/xymon/cgi-bin/showgraph.sh || die
#			sed -i 's,server/etc/,cgi-bin/,' "${D}"/usr/xymon/cgi-bin/svcstatus.sh || die
#			cp "${D}"/etc/xymon/cgioptions.cfg "${D}"/usr/xymon/cgi-bin/ || die
#			cp "${D}"/etc/xymon/xymonserver.cfg "${D}"/usr/xymon/cgi-bin/ || die

			einfo "Correcting cgis"
#			mv "${D}"/usr/xymon/server/bin/ackinfo.cgi "${D}"/usr/xymon/cgi-secure/ || die
			mv "${D}"/usr/xymon/server/bin/acknowledge.cgi "${D}"/usr/xymon/cgi-secure/ || die
			mv "${D}"/usr/xymon/server/bin/criticaleditor.cgi "${D}"/usr/xymon/cgi-secure/ || die
			mv "${D}"/usr/xymon/server/bin/enadis.cgi "${D}"/usr/xymon/cgi-secure/ || die
			mv "${D}"/usr/xymon/server/bin/ackinfo.cgi "${D}"/usr/xymon/cgi-secure/ || die
			mv "${D}"/usr/xymon/server/bin/useradm.cgi "${D}"/usr/xymon/cgi-secure/ || die
			mv "${D}"/usr/xymon/server/bin/*.cgi "${D}"/usr/xymon/cgi-bin/ || die
			#quick fix
			for cgifile in `ls "${D}"/usr/xymon/cgi-bin/`
			do
				ln -s /usr/xymon/cgi-bin/$cgifile "${D}"/usr/xymon/server/bin/$cgifile
			done
			for scgifile in `ls "${D}"/usr/xymon/cgi-secure/`
			do
				ln -s /usr/xymon/cgi-secure/$scgifile "${D}"/usr/xymon/server/bin/$scgifile
			done
			#no edit necessary since 4.3.2x since .sh are binary
			#sed -i 's,server/bin/,cgi-bin/,' "${D}"/usr/xymon/cgi-bin/*.sh || die
			#sed -i 's,server/bin/,cgi-bin/,' "${D}"/usr/xymon/cgi-secure/*.sh || die
			fowners -R :apache /usr/xymon/cgi-bin/ || die
			fowners -R :apache /usr/xymon/cgi-secure/ || die

			fperms 755 /var/log/xymon/ || die
			touch "${D}"/var/log/xymon/cgierror.err || die
			fowners apache /var/log/xymon/cgierror.err || die
			fowners -R :apache /usr/xymon/data/ || die
			fowners -R :apache /usr/xymon/cgi-bin/ || die
			fowners -R :apache /usr/xymon/cgi-secure/ || die
			fperms -R o+rX /usr/xymon/server/www/ || die
	#		fowners -R root:xymon /usr/xymon/server/www/help/ || die
			fperms 755 /usr/xymon/server/ || die
			fowners -R :apache /usr/xymon/server/web/ || die
			fperms 755 /usr/xymon/server/bin/ || die
#no because xymon read that for generating www
#		fperms -R o-rwx /usr/xymon/server/web/ || die

			fowners :apache /usr/xymon/server/www/rep || die
			fperms 770 /usr/xymon/server/www/rep || die

			fowners :apache /etc/xymon/graphs.cfg || die
			fowners :apache /etc/xymon/cgioptions.cfg || die
			fowners :apache /etc/xymon/columndoc.csv || die
			fperms 755 /etc/xymon/ || die

		fi
		#here after apache for conf files
		fperms -R o-rwx /usr/xymon/cgi-bin/ || die
		fperms -R o-rwx /usr/xymon/cgi-secure/ || die
	fi
	#rm ${D}/usr/xymon/server/bin/xymon.sh || die
}

pkg_postinst() {
	if use server ; then
		if ! use fping ; then
			#TODO POSIX CAPS
			chmod 4750 /usr/xymon/server/bin/xymonping || die
		else
			chmod 750 /usr/xymon/server/bin/xymonping || die
		fi
	fi
}
