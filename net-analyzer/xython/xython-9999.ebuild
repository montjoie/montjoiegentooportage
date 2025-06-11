# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11,12,13} )
inherit cmake distutils-r1

DESCRIPTION="xython"
HOMEPAGE="http://xython"
if [[ "${PV}" != "9999" ]];
then
	SRC_URI=""
	KEYWORDS="amd64 arm arm64 x86"
else
	inherit git-r3
	EGIT_REPO_URI="https://github.com/xython-monitoring/xython.git"
	#KEYWORDS=""
	KEYWORDS="amd64 arm arm64 x86"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE="apache2 server"

DEPEND="server? (
	acct-user/xython
	dev-python/celery
	dev-python/redis
	dev-python/requests
	dev-python/click-didyoumean
	dev-python/click-plugins
	dev-python/click-repl
	dev-python/pytz
	net-analyzer/netcat
	)"
RDEPEND="
	apache2? ( www-servers/apache )
	server? ( dev-db/redis )
	${DEPEND}"

src_prepare() {
	default
	cmake_src_prepare
	sed -i "s,^CLIENTVERSION=.*,CLIENTVERSION=$PV," $S/client/xython-client
}

src_configure() {
	default
	cmake_src_configure
}

#src_compile() {
#}

src_install() {
	default

	dodir /etc/xython
	insinto /etc/xython
	doins etc/xython-client.cfg

	if use server;then
		cmake_src_install
		distutils-r1_src_install
		doins etc/analysis.cfg
		#doins etc/hosts.cfg
		doins etc/xython.cfg
		doins etc/xymonmenu.cfg

		keepdir var/lib/xython
		keepdir var/lib/xython/acks
		keepdir var/lib/xython/data
		keepdir var/lib/xython/hostdata
		keepdir var/lib/xython/logs
		keepdir var/lib/xython/www
		keepdir var/lib/xython/hist
		keepdir var/lib/xython/histlogs
		keepdir var/lib/xython/disabled
		keepdir var/lib/xython/rrd
		keepdir var/lib/xython/tmp

		dodir /var/log/xython
		keepdir var/log/xython

		fowners -R xython:xython /var/lib/xython
		fowners -R xython:xython /var/log/xython
		fowners -R :xython /etc/xython

		newinitd "${FILESDIR}"/xythond.init xythond
		newinitd "${FILESDIR}"/xython-tlsd.init xython-tlsd
		newinitd "${FILESDIR}"/xython-celery.init xython-celery
		if use apache2; then
			insinto /etc/apache2/vhosts.d
			newins ${S}/etc/apache2/xython.conf xython.include
		fi
	fi

	newinitd "${FILESDIR}"/xython-client.init xython-client
	dobin client/xython-client
	dobin client/xython-client.sh
	dobin client/xython-client-looper.sh
	#doman man/xython-client.cfg.5
}

pkg_postinst() {
	if ! test -e /etc/xython/hosts.cfg ; then
		einfo "Generating a default /etc/xython/hosts.cfg"
		cat > /etc/xython/hosts.cfg <<EOF
#
# Master configuration file for Xython
#
# This file defines several things:
#
# 1) By adding hosts to this file, you define hosts that are monitored by Xython
# 2) By adding "page", "subpage", "group" definitions, you define the layout
#    of the Xython webpages, and how hosts are divided among the various webpages
#    that Xython generates.
# 3) Several other definitions can be done for each host, see the hosts.cfg(5)
#    man-page.
#
# You need to define at least the Xython server itself here.

127.0.0.1	$(hostname)	# http://$(hostname)/

EOF
	fi
}
