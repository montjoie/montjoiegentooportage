# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PATCHSET=1

inherit java-pkg-opt-2 systemd tmpfiles

MY_P=${P/_/-}

DESCRIPTION="Munin Server Monitoring Tool"
HOMEPAGE="https://munin-monitoring.org/"
SRC_URI="
	https://github.com/munin-monitoring/munin/archive/${PV}.tar.gz -> ${P}.tar.gz
	https://dev.gentoo.org/~graaff/munin/${P}-gentoo-${PATCHSET}.tar.xz
	https://github.com/munin-monitoring/munin/commit/47a2ea75899a6395a80918d043a21d61fe712b44.patch -> munin-remove-Date-Manip-DM5.patch
	"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm arm64 ppc x86"
IUSE="apache2 asterisk doc irc java ldap memcached minimal mysql postgres selinux ssl snmp test cgi ipv6 syslog systemd ipmi http dhcpd"
REQUIRED_USE="cgi? ( !minimal ) apache2? ( cgi )"
RESTRICT="!test? ( test )"

# Upstream's listing of required modules is NOT correct!
# Some of the postgres plugins use DBD::Pg, while others call psql directly.
# Some of the mysql plugins use DBD::mysql, while others call mysqladmin directly.
# We replace the original ipmi plugins with the freeipmi_ plugin which at least works.
DEPEND_COM="
	acct-user/munin
	acct-group/munin
	dev-lang/perl
	dev-perl/Net-CIDR
	dev-perl/Net-Server[ipv6(-)?]
	apache2? ( www-servers/apache[apache2_modules_cgi,apache2_modules_cgid,apache2_modules_rewrite] )
	asterisk? ( dev-perl/Net-Telnet )
	cgi? (
		dev-perl/FCGI
		dev-perl/CGI-Fast
		)
	dhcpd? (
		>=net-misc/dhcp-3[server]
		dev-perl/Net-IP
		dev-perl/HTTP-Date
		)
	snmp? ( dev-perl/Net-SNMP )
	doc? ( dev-python/sphinx )
	http? ( dev-perl/libwww-perl )
	irc? ( dev-perl/Net-IRC )
	ldap? ( dev-perl/perl-ldap )
	kernel_linux? ( sys-process/procps )
	memcached? ( dev-perl/Cache-Memcached )
	mysql? (
		virtual/mysql
		dev-perl/Cache-Cache
		dev-perl/DBD-mysql
		)
	postgres? ( dev-perl/DBD-Pg dev-db/postgresql:* )
	ssl? ( dev-perl/Net-SSLeay )
	syslog? ( virtual/perl-Sys-Syslog )
	!minimal? (
	dev-perl/DBI
	dev-perl/Date-Manip
	dev-perl/File-Copy-Recursive
	dev-perl/List-MoreUtils
	dev-perl/Log-Log4perl
	dev-perl/Net-DNS
	dev-perl/Net-Netmask
	virtual/perl-Digest-MD5
	virtual/perl-Getopt-Long
	virtual/perl-MIME-Base64
	virtual/perl-Storable
	virtual/perl-Text-Balanced
	virtual/perl-Time-HiRes
		dev-perl/HTML-Template
		dev-perl/IO-Socket-INET6
		dev-perl/URI
		>=net-analyzer/rrdtool-1.3[graph,perl]
		virtual/ssh
		)
	"

# Keep this seperate, as previous versions have had other deps here
DEPEND="${DEPEND_COM}
	dev-perl/Module-Build
	java? ( >=virtual/jdk-1.8 )
	test? (
		dev-perl/Test-Deep
		dev-perl/Test-Exception
		dev-perl/Test-LongString
		dev-perl/Test-Differences
		dev-perl/Test-MockModule
		dev-perl/Test-MockObject
		dev-perl/File-Slurp
		dev-perl/IO-stringy
		dev-perl/IO-Socket-INET6
	)"
RDEPEND="${DEPEND_COM}
		app-alternatives/awk
		ipmi? ( >=sys-libs/freeipmi-1.1.6-r1 )
		java? (
			>=virtual/jre-1.8:*
			|| ( net-analyzer/netcat net-analyzer/openbsd-netcat )
		)
		!minimal? (
			acct-user/munin-async
			virtual/cron
			media-fonts/dejavu
		)
		selinux? ( sec-policy/selinux-munin )"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	java-pkg-opt-2_pkg_setup
}

src_prepare() {
	echo ${PV} > RELEASE || die

	eapply "${WORKDIR}"/patches/*.patch
	# Quick hack to make the munin-remove-Date-Manip-DM5.patch apply
	sed -i -e '/^BEGIN/,/Date::Manip::Backend/{ /no warnings;/d  }' "${S}"/master/_bin/munin-cgi-graph.in
	eapply "${DISTDIR}"/munin-remove-Date-Manip-DM5.patch

	eapply_user

	java-pkg-opt-2_src_prepare
}

src_configure() {
	local cgidir='$(DESTDIR)/usr/libexec/munin/cgi'
	use cgi || cgidir="${T}/useless/cgi-bin"

	local cgiuser=$(usex apache2 apache munin)

	cat >> "${S}"/Makefile.config <<- EOF || die
	PREFIX=\$(DESTDIR)/usr
	CONFDIR=\$(DESTDIR)/etc/munin
	DOCDIR=${T}/useless/doc
	MANDIR=\$(PREFIX)/share/man
	LIBDIR=\$(PREFIX)/libexec/munin
	HTMLDIR=\$(DESTDIR)/var/www/localhost/htdocs/munin
	CGIDIR=${cgidir}
	CGITMPDIR=\$(DESTDIR)/var/cache/munin-cgi
	CGIUSER=${cgiuser}
	DBDIR=\$(DESTDIR)/var/lib/munin
	DBDIRNODE=\$(DESTDIR)/var/lib/munin-node
	SPOOLDIR=\$(DESTDIR)/var/spool/munin-async
	LOGDIR=\$(DESTDIR)/var/log/munin
	PERLLIB=\$(DESTDIR)$(perl -V:vendorlib | cut -d"'" -f2)
	JCVALID=$(usex java yes no)
	STATEDIR=\$(DESTDIR)/run/munin
	EOF
}

# parallel make and install need to be fixed before, and I haven't
# gotten around to do so yet.
src_compile() {
	emake -j1
	use doc && emake -C doc html
}

src_test() {
	if [[ ${EUID} == 0 ]]; then
		eerror "You cannot run tests as root."
		eerror "Please enable FEATURES=userpriv before proceeding."
		return 1
	fi

	local testtargets="test-common test-node test-plugins"
	use minimal || testtargets+=" test-master"

	LC_ALL=C emake -j1 ${testtargets}
}

src_install() {
	local dirs="
		/var/log/munin
		/var/lib/munin/plugin-state
		/var/lib/munin-node/plugin-state
		/var/www/localhost/htdocs/munin
		/etc/munin/plugin-conf.d
		/etc/munin/plugins"
	use minimal || dirs+=" /etc/munin/munin-conf.d/"

	keepdir ${dirs}
	fowners munin:munin ${dirs}

	# parallel install doesn't work and it's also pointless to have this
	# run in parallel for now (because it uses internal loops).
	emake -j1 CHOWN=true DESTDIR="${D}" $(usex minimal "install-minimal install-man" install)

	# we remove /run from the install, as it's not the package's to deal
	# with.
	rm -rf "${D}"/run || die

	# remove the plugins for non-Gentoo package managers; use -f so that
	# it doesn't fail when installing on non-Linux platforms.
	rm -f "${D}"/usr/libexec/munin/plugins/{apt{,_all},yum} || die

	insinto /etc/munin/plugin-conf.d/
	newins "${FILESDIR}"/${PN}-1.3.2-plugins.conf munin-node

	newinitd "${FILESDIR}"/munin-node_init.d_2.0.19 munin-node
	newconfd "${FILESDIR}"/munin-node_conf.d_1.4.6-r2 munin-node

	if ! use minimal ;then
		newinitd "${FILESDIR}"/munin-asyncd.init.2 munin-asyncd
	else
		rmdir $"${D}"/var/spool/munin-async || die
		rmdir $"${D}"/var/spool/ || die
	fi

	newtmpfiles - ${CATEGORY}:${PN}:${SLOT}.conf <<-EOF || die
	d /run/munin 0700 munin munin - -
	EOF

	if ! use minimal && use systemd ;then
		systemd_dounit "${FILESDIR}"/munin-async.service
		systemd_dounit "${FILESDIR}"/munin-graph.{service,socket}
		systemd_dounit "${FILESDIR}"/munin-html.{service,socket}
	fi
	if use systemd ;then
		systemd_dounit "${FILESDIR}"/munin-node.service
	fi

	cat >> "${T}"/munin.env <<- EOF
	CONFIG_PROTECT=/var/spool/munin-async/.ssh
	EOF
	newenvd "${T}"/munin.env 50munin

	dodoc README ChangeLog INSTALL
	if use doc; then
		cd "${S}"/doc/_build/html || die
		docinto html
		dodoc -r *
		cd "${S}" || die
	else
		rm -f "${D}"/usr/bin/munindoc || die
	fi

	dodir /etc/logrotate.d/
	sed -e "s:@CGIUSER@:$(usex apache2 apache munin):g" \
		"${FILESDIR}"/logrotate.d-munin.3 > "${D}"/etc/logrotate.d/munin

	dosym ipmi_ /usr/libexec/munin/plugins/ipmi_sensor_

	if use syslog; then
		sed -i -e '/log_file/s| .*| Sys::Syslog|' \
			"${D}"/etc/munin/munin-node.conf || die
	fi

	# Use a simpler pid file to avoid trouble with /run in tmpfs. The
	# munin-node service is ran as user root, and only later drops
	# privileges.
	sed -i -e 's:/run/munin/munin-node.pid:/run/munin-node.pid:' \
		"${D}"/etc/munin/munin-node.conf || die

	if ! use minimal;then
		keepdir /var/spool/munin-async/.ssh
		touch "${D}"/var/spool/munin-async/.ssh/authorized_keys
		fowners munin-async:munin /var/spool/munin-async{,/.ssh/{,authorized_keys}}
		fperms 0750 /var/spool/munin-async{,/.ssh}
		fperms 0600 /var/spool/munin-async/.ssh/authorized_keys
	else
		rm "${D}"/usr/libexec/munin/munin-async || die
		rm "${D}"/usr/libexec/munin/munin-asyncd || die
	fi

	if use minimal; then
		# This requires the presence of munin-update, which is part of
		# the non-minimal install...
		rm "${D}"/usr/libexec/munin/plugins/munin_stats
		rm "${D}"/usr/sbin/munin-sched
	else
		# remove font files so that we don't have to keep them around
		rm "${D}"/usr/libexec/${PN}/*.ttf || die

		if use cgi; then
			sed -i -e '/#graph_strategy cgi/s:^#::' "${D}"/etc/munin/munin.conf || die

			keepdir /var/cache/munin-cgi
			touch "${D}"/var/log/munin/munin-cgi-{graph,html}.log
			fowners $(usex apache2 apache munin) \
				/var/cache/munin-cgi \
				/var/log/munin/munin-cgi-{graph,html}.log

			if use apache2; then
				insinto /etc/apache2/vhosts.d
				newins "${FILESDIR}"/munin.apache.include munin.include
				newins "${FILESDIR}"/munin.apache.include-2.4 munin-2.4.include
			fi
		else
			sed \
				-e '/#graph_strategy cgi/s:#graph_strategy cgi:graph_strategy cron:' \
				-i "${D}"/etc/munin/munin.conf || die
		fi

		keepdir /var/lib/munin/.ssh
		cat >> "${D}"/var/lib/munin/.ssh/config <<- EOF
		IdentityFile /var/lib/munin/.ssh/id_ecdsa
		IdentityFile /var/lib/munin/.ssh/id_rsa
		EOF

		fowners munin:munin /var/lib/munin/.ssh/{,config}
		fperms go-rwx /var/lib/munin/.ssh/{,config}

		dodir /usr/share/${PN}
		cat >> "${D}"/usr/share/${PN}/crontab <<- EOF
		# Force the shell to bash
		SHELL=/bin/bash
		# Mail reports to root@, not munin@
		MAILTO=root

		# This runs the munin task every 5 minutes.
		*/5	* * * *		/usr/bin/munin-cron

		# Alternatively, this route works differently
		# Update once a minute (for busy sites)
		#*/1 * * * *		/usr/libexec/munin/munin-update
		## Check for limit excess every 2 minutes
		#*/2 * * * *		/usr/libexec/munin/munin-limits
		## Update graphs every 5 minutes
		#*/5 * * * *		nice /usr/libexec/munin/munin-graph
		## Update HTML pages every 15 minutes
		#*/15 * * * *		nice /usr/libexec/munin/munin-html
		EOF

		cat >> "${D}"/usr/share/${PN}/fcrontab <<- EOF
		# Mail reports to root@, not munin@, only execute one at a time
		!mailto(root),serial(true)

		# This runs the munin task every 5 minutes.
		@ 5		/usr/bin/munin-cron

		# Alternatively, this route works differently
		# Update once a minute (for busy sites)
		#@ 1	/usr/libexec/munin/munin-update
		## Check for limit excess every 2 minutes
		#@ 2	/usr/libexec/munin/munin-limits
		## Update graphs every 5 minutes
		#@ 5	nice /usr/libexec/munin/munin-graph
		## Update HTML pages every 15 minutes
		#@ 15	nice /usr/libexec/munin/munin-html
		EOF
	fi

	if ! use snmp ;then
		rm "${D}"/usr/libexec/munin/plugins/snmp__* || die
	fi
	if ! use postgres ;then
		rm "${D}"/usr/libexec/munin/plugins/postgres_* || die
		rm "${D}"/usr/libexec/munin/plugins/slony_* || die
		rm "${D}"/usr/libexec/munin/plugins/pgbouncer_* || die
	fi
	if ! use dhcpd ;then
		rm "${D}"/usr/libexec/munin/plugins/dhcpd3 || die
	fi
	#if ! use asterisk ;then
	#	rm "${D}"/usr/libexec/munin/plugins/asterisk_* || die
	#fi
	if ! use ipmi ;then
		rm "${D}"/usr/libexec/munin/plugins/ipmi* || die
	fi
	if ! use ldap ;then
		rm "${D}"/usr/libexec/munin/plugins/slapd* || die
	fi
	if ! use memcached ;then
		rm "${D}"/usr/libexec/munin/plugins/memcached* || die
	fi
	if ! use mysql ;then
		rm "${D}"/usr/libexec/munin/plugins/mysql* || die
	fi
	if ! use selinux ;then
		rm "${D}"/usr/libexec/munin/plugins/selinux* || die
	fi

		# remove .htaccess file
		find "${D}" -name .htaccess -delete || die

	#nothing here anymore, remove it
	if [ -e "${D}"/var/www/localhost/htdocs/munin/ ];then
		rm "${D}"/var/www/localhost/htdocs/munin/.keep_net-analyzer_munin-0
		rmdir "${D}"/var/www/localhost/htdocs/munin/ || die
	fi
	if [ -e "${D}"/var/www/localhost/htdocs/ ];then
		rmdir "${D}"/var/www/localhost/htdocs/ || die
	fi
	if [ -e "${D}"/var/www/localhost/ ];then
		rmdir "${D}"/var/www/localhost/ || die
	fi
}

pkg_config() {
	if use minimal; then
		einfo "Nothing to do."
		return 0
	fi

	einfo "Press enter to install the default crontab for the munin master"
	einfo "installation from /usr/share/${PN}/f?crontab"
	einfo "If you have a large site, you may wish to customize it."
	read

	ebegin "Setting up cron ..."
	if has_version sys-process/fcron; then
		fcrontab - -u munin < /usr/share/${PN}/fcrontab
	else
		# dcron is very fussy about syntax
		# the following is the only form that works in BOTH dcron and vixie-cron
		crontab - -u munin < /usr/share/${PN}/crontab
	fi
	eend $?

	einfo "Press enter to set up the SSH keys used for SSH transport"
	read

	# generate one rsa (for legacy) and one ecdsa (for new systems)
	ssh-keygen -t rsa \
		-f /var/lib/munin/.ssh/id_rsa -N '' \
		-C "created by portage for ${CATEGORY}/${PN}" || die
	ssh-keygen -t ecdsa \
		-f /var/lib/munin/.ssh/id_ecdsa -N '' \
		-C "created by portage for ${CATEGORY}/${PN}" || die
	chown -R munin:munin /var/lib/munin/.ssh || die
	chmod 0600 /var/lib/munin/.ssh/id_{rsa,ecdsa} || die

	einfo "Your public keys are available in "
	einfo "  /var/lib/munin/.ssh/id_rsa.pub"
	einfo "  /var/lib/munin/.ssh/id_ecdsa.pub"
	einfo "and follows for convenience"
	echo
	cat /var/lib/munin/.ssh/id_*.pub
}

pkg_postinst() {
	tmpfiles_process ${CATEGORY}:${PN}:${SLOT}.conf

	elog "Please follow the munin documentation to set up the plugins you"
	elog "need, afterwards start munin-node."
	elog ""
	elog "To make use of munin-async, make sure to set up the corresponding"
	elog "SSH key in /var/lib/munin-async/.ssh/authorized_keys"
	elog ""
	if ! use minimal; then
		elog "Please run"
		elog "  emerge --config net-analyzer/munin"
		elog "to automatically configure munin's cronjobs as well as generate"
		elog "passwordless SSH keys to be used with munin-async."
	fi
	elog ""
	elog "Further information about setting up Munin in Gentoo can be found"
	elog "in the Gentoo Wiki: https://wiki.gentoo.org/wiki/Munin"

	if use cgi; then
		chown $(usex apache2 apache munin) \
			"${ROOT}"/var/cache/munin-cgi \
			"${ROOT}"/var/log/munin/munin-cgi-{graph,html}.log

		if use apache2; then
			elog "To use Munin with CGI you should include /etc/apache2/vhosts.d/munin.include"
			elog "or /etc/apache2/vhosts.d/munin-2.4.include (for Apache 2.4) from the virtual"
			elog "host you want it to be served."
			elog "If you want to enable CGI-based HTML as well, you have to add to"
			elog "/etc/conf.d/apache2 the option -D MUNIN_HTML_CGI."
		else
			elog "Effective CGI support has just been added in 2.0.7-r6."
			elog "Documentation on how to use it is still sparse."
		fi
	fi

	# we create this here as we don't want Portage to check /run
	# symlinks but we still need this to be present before the reboot.
	if ! use minimal && ! [[ -d "${ROOT}"/run/munin ]]; then
		mkdir "${ROOT}"/run/munin
		chown munin:munin "${ROOT}"/run/munin
		chmod 0700 "${ROOT}"/run/munin
	fi
}
