# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_REQ_USE="sqlite"
PYTHON_COMPAT=( python3_6 )
inherit autotools distutils-r1 user

DESCRIPTION="LAVA"
HOMEPAGE="https://validation.linaro.org"

if [[ "${PV}" != "9999" ]]; then
	#SRC_URI="https://git.linaro.org/lava/lava.git/snapshot/${P}.tar.gz"
	SRC_URI="https://git.lavasoftware.org/lava/lava/-/archive/${PV}/${P}.tar.gz"
	KEYWORDS="amd64 arm arm64 x86"
else
	inherit git-r3
	EGIT_REPO_URI="https://git.linaro.org/lava/lava.git"
fi

#TODO feature check for NFS LXC

LICENSE="GPL-2"
SLOT="0"
IUSE="apache2 dispatcher ldap lxc nbd nfs qemu master screen telnet xnbd"

DEPEND=""
RDEPEND="${DEPEND}
	master? ( dev-db/postgresql )
	master? (
		>=dev-python/django-1.10[${PYTHON_USEDEP}]
		dev-python/django-tables2[${PYTHON_USEDEP}]
		dev-python/django-restricted-resource[${PYTHON_USEDEP}]
		www-servers/gunicorn[${PYTHON_USEDEP}]
	)
	ldap? ( dev-python/django-auth-ldap )
	apache2? ( www-servers/apache )
	nbd? ( sys-block/nbd )
	nfs? ( net-fs/nfs-utils )
	screen? ( app-misc/screen )
	telnet? ( net-misc/telnet-bsd )
	xnbd? ( sys-block/xnbd )
	dev-python/psycopg[${PYTHON_USEDEP}]
	dev-python/simplejson[${PYTHON_USEDEP}]
	dev-python/pyyaml[libyaml]
	dev-python/jinja[${PYTHON_USEDEP}]
	dev-python/pexpect[${PYTHON_USEDEP}]
	dev-python/voluptuous[${PYTHON_USEDEP}]
	dev-python/pyserial[${PYTHON_USEDEP}]
	dev-python/netifaces[${PYTHON_USEDEP}]
	dev-python/nose[${PYTHON_USEDEP}]
	dev-python/pyzmq[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-util/lava-tool
	dev-python/pytz[${PYTHON_USEDEP}]
	dev-python/python-dateutil[${PYTHON_USEDEP}]
	dispatcher? (
		app-emulation/libguestfs[python]
		dev-embedded/u-boot-tools
		net-ftp/tftp-hpa
	qemu? (
		app-emulation/libvirt
		app-emulation/supermin
		)
	dev-python/configobj[${PYTHON_USEDEP}]
	dev-python/pyudev[${PYTHON_USEDEP}]
	dev-python/python-magic[${PYTHON_USEDEP}]
	)"

pkg_setup() {
	python-single-r1_pkg_setup
	enewgroup lavaserver
	enewuser lavaserver -1 -1 /var/lib/lava-server/home lavaserver
}

src_prepare() {
	rm -r ${S}/google_analytics
	sed -i 's,.*google_analytics.*,,' lava_server/settings/common.py || die
	sed -i 's,.*google_analytics.*,,' lava_server/settings/development.py || die
	sed -i 's,.*analytics.*,,I' lava_server/settings/common.py || die
	sed -i 's,.*analytics.*,,' lava_server/templates/layouts/base.html || die

	#validate our cleaning
	grep -ri analytics lava_server && die

	eapply "${FILESDIR}"/version.patch
	default
}

src_install() {
	default
	dodir /etc
	insinto /etc

	if use master;then
	doins -r ${S}/etc/dispatcher-config

	newinitd ${FILESDIR}/lava-master.init lava-master
	newinitd ${FILESDIR}/lava-logs.init lava-logs
	newinitd ${FILESDIR}/lava-server-gunicorn.init lava-server-gunicorn
	if use dispatcher;then
		newinitd ${FILESDIR}/lava-slave.init lava-slave
	fi

	dodir /etc/lava-server
	insinto /etc/lava-server
	newins etc/instance.conf.template instance.conf
	doins etc/env.yaml
	doins etc/settings.conf

	dodir /var/log/lava-server
	fowners lavaserver:lavaserver /var/log/lava-server

	dodir /usr/share/lava-server
	dodir /usr/share/lava-server/static

	dodir /etc/lava-server/dispatcher-config/devices
	dodir /etc/lava-server/dispatcher-config/health-checks
	insinto /etc/lava-server/dispatcher-config/device-types/
	doins ${S}/lava_scheduler_app/tests/device-types/*

	fi

	python_foreach_impl distutils-r1_python_install || die
	python_foreach_impl python_newexe ${S}/lava_server/manage.py lava-server || die
	python_foreach_impl python_fix_shebang ${D}/usr/

	if use master;then
	# HACK
	EPYTHON=python3.6
	ln -s /usr/$(get_libdir)/$EPYTHON/site-packages/django/contrib/admin/static/admin/ ${D}/usr/share/lava-server/static/admin || die
	ln -s /usr/$(get_libdir)/$EPYTHON/site-packages/lava_server/static/lava_server ${D}/usr/share/lava-server/static/lava_server || die
	ln -s /usr/$(get_libdir)/$EPYTHON/site-packages/lava_scheduler_app/static/lava_scheduler_app ${D}/usr/share/lava-server/static/lava_scheduler_app || die
	ln -s /usr/$(get_libdir)/$EPYTHON/site-packages/lava_results_app/static/lava_results_app ${D}/usr/share/lava-server/static/lava_results_app || die

	if ! use ldap;then
		sed -i 's,import ldap,,' ${D}/usr/$(get_libdir)/$EPYTHON/site-packages/lava_scheduler_app/utils.py
	fi

	#apache2
	if use apache2; then
		dodir /etc/apache2/vhosts.d/
		insinto /etc/apache2/vhosts.d/
		doins ${S}/etc/lava-server.conf
	fi

	cd ${D}/usr/$(get_libdir)/$EPYTHON/site-packages/lava_server/static/lava_server/js/ || die
	sh ${FILESDIR}/minify
	cd ${D}/usr/$(get_libdir)/$EPYTHON/site-packages/lava_scheduler_app/static/lava_scheduler_app/js
	sh ${FILESDIR}/minify

	dodir /var/lib/lava-server/default/
	dodir /var/lib/lava-server/default/media/
	fowners -R lavaserver:lavaserver /var/lib/lava-server/default/
	else
		einfo "Clean unused master files"
		EPYTHON=python3.6
		rm -r ${D}/usr/$(get_libdir)/$EPYTHON/site-packages/lava_server/
		rm -r ${D}/usr/$(get_libdir)/$EPYTHON/site-packages/linaro_django_xmlrpc/
		rm -r ${D}/usr/$(get_libdir)/$EPYTHON/site-packages/linaro_scheduler/
		rm -r ${D}/usr/$(get_libdir)/$EPYTHON/site-packages/lava_results_app/
		rm -r ${D}/usr/$(get_libdir)/$EPYTHON/site-packages/dashboard_app/
	fi

	dodir /var/log/lava-dispatcher
	fowners lavaserver:lavaserver /var/log/lava-dispatcher
}

pkg_postinst() {
	einfo 'Please set INTFTPD_PATH="/var/lib/lava/dispatcher/tmp/"'
	einfo "if you upgrade LAVA, please run lava-server manage migrate (see share/postinst.py TODO)"
}
