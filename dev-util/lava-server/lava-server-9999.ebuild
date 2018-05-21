# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{5,6} )
inherit git-r3 distutils-r1 user

DESCRIPTION="LAVA"
HOMEPAGE="https://validation.linaro.org"
#SRC_URI=""
EGIT_REPO_URI="https://git.linaro.org/lava/lava.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm arm64 x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	dev-db/postgresql
	dev-python/django
	dev-python/django-tables2
	dev-python/psycopg
	dev-python/simplejson
	dev-python/django-restricted-resource
	dev-python/python-ldap
	dev-python/pyyaml[libyaml]
	dev-python/jinja
	dev-python/pexpect
	dev-python/voluptuous
	dev-python/pyliblzma
	dev-python/pyserial
	dev-python/netifaces
	dev-python/nose
	dev-python/pyzmq
	dev-python/requests
	dev-util/lava-tool
	dev-util/lava-dispatcher
	dev-python/pytz
	dev-python/python-dateutil
	www-servers/gunicorn"

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
	default
}

src_install() {
	default
	dodir /etc
	insinto /etc
	doins -r ${S}/etc/dispatcher-config

	newinitd ${FILESDIR}/lava-master.init lava-master
	newinitd ${FILESDIR}/lava-logs.init lava-logs
	newinitd ${FILESDIR}/lava-server-gunicorn.init lava-server-gunicorn

	dodir /etc/lava-server
	insinto /etc/lava-server
	newins etc/instance.conf.template instance.conf
	doins etc/env.yaml
	doins etc/settings.conf

	dodir /var/log/lava-server

	dodir /usr/share/lava-server
	dodir /usr/share/lava-server/static

	dodir /etc/lava-server/dispatcher-config/devices
	dodir /etc/lava-server/dispatcher-config/health-checks
	insinto /etc/lava-server/dispatcher-config/device-types/
	doins ${S}/lava_scheduler_app/tests/device-types/*

	python_foreach_impl distutils-r1_python_install || die
	python_foreach_impl python_newexe ${S}/lava_server/manage.py lava-server || die
	python_foreach_impl python_fix_shebang ${D}/usr/

	# HACK
	EPYTHON=python3.5
	ln -s /usr/lib/$EPYTHON/site-packages/django/contrib/admin/static/admin/ ${D}/usr/share/lava-server/static/admin
	ln -s /usr/lib/$EPYTHON/site-packages/lava_server/static/lava_server ${D}/usr/share/lava-server/static/lava_server
	ln -s /usr/lib/$EPYTHON/site-packages/lava_scheduler_app/static/lava_scheduler_app ${D}/usr/share/lava-server/static/lava_scheduler_app
	ln -s /usr/lib/$EPYTHON/site-packages/lava_results_app/static/lava_results_app ${D}/usr/share/lava-server/static/lava_results_app

	#apache2
	dodir /etc/apache2/vhosts.d/
	insinto /etc/apache2/vhosts.d/
	doins ${S}/etc/lava-server.conf

	#TODO getlibdir	
	cd ${D}/usr/lib/$EPYTHON/site-packages/lava_server/static/lava_server/js/ || die
	#ln -s bootstrap-3.3.7.js bootstrap-3.3.7.min.js
	sh ${FILESDIR}/minify
	cd ${D}/usr/lib/$EPYTHON/site-packages/lava_scheduler_app/static/lava_scheduler_app/js
	sh ${FILESDIR}/minify

}
