# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

#PYTHON_COMPAT=( python2_7 python3_{4,5,6} )
PYTHON_COMPAT=( python2_7 )
inherit git-r3 distutils-r1 user

DESCRIPTION="LAVA"
HOMEPAGE="https://validation.linaro.ort"
#SRC_URI=""
EGIT_REPO_URI="https://github.com/Linaro/lava-server.git"

LICENSE="GPL"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	dev-db/postgresql
	dev-python/django
	dev-python/django-tables2
	dev-python/psycopg
	dev-python/python-daemon
	dev-python/simplejson
	dev-python/django-restricted-resource
	dev-python/json-schema-validator
	dev-python/python-ldap
	dev-python/pyyaml[libyaml]
	dev-python/jinja
	dev-python/pexpect
	dev-python/voluptuous
	dev-python/pyliblzma
	dev-python/configglue
	dev-python/pyserial
	dev-python/netifaces
	dev-python/twisted
	dev-python/nose
	dev-python/pyzmq
	dev-python/requests
	dev-util/lava-tool
	dev-util/lava-dispatcher
	dev-python/pytz
	dev-python/python-dateutil
	www-servers/gunicorn"
#	dev-python/linaro-python-dashboard-bundle

pkg_setup() {
	enewgroup lavaserver
	enewuser lavaserver -1 -1 /var/lib/lava-server/home lavaserver
}

src_prepare() {
	rm -r ${S}/google_analytics
	sed -i 's,.*google_analytics.*,,' lava_server/settings/common.py
	sed -i 's,.*google_analytics.*,,' lava_server/settings/development.py
	sed -i 's,.*analytics.*,,' lava_server/templates/layouts/base.html
	sed -i 's,.*analytics.*,,' lava_server/templates/layouts/base-bootstrap.html
	default
}

src_install() {
	default
	dodir /etc
	insinto /etc
	doins -r ${S}/etc/dispatcher-config

	newinitd ${S}/etc/lava-master.init lava-master
	newinitd ${FILESDIR}/lava-server.init lava-server
	newinitd ${FILESDIR}/lava-server-gunicorn.init lava-server-gunicorn

	dodir /etc/lava-server
	insinto /etc/lava-server
	newins instance.template instance.conf
	doins etc/env.yaml
	doins etc/settings.conf

	dodir /var/log/lava-server

	dodir /usr/share/lava-server
	dodir /usr/share/lava-server/static

	ln -s /usr/lib/python2.7/site-packages/django/contrib/admin/static/admin/ ${D}/usr/share/lava-server/static/admin
	ln -s /usr/lib/python2.7/site-packages/lava_server/lava-server ${D}/usr/share/lava-server/static/lava-server
	ln -s /usr/lib/python2.7/site-packages/lava_scheduler_app/static/lava_scheduler_app ${D}/usr/share/lava-server/static/lava_scheduler_app
	ln -s /usr/lib/python2.7/site-packages/lava_results_app/static/lava_results_app ${D}/usr/share/lava-server/static/lava_results_app

	dodir /etc/lava-server/dispatcher-config/devices
	dodir /etc/lava-server/dispatcher-config/health-checks
	insinto /etc/lava-server/dispatcher-config/device-types/
	doins ${S}/lava_scheduler_app/tests/device-types/*

#	ln -s /usr/lib/python/2.7/lava_server/manage.py lava-server
	python_foreach_impl distutils-r1_python_install || die
	#python_foreach_impl newbin ${W}/lib/lava_server/manage.py lava-server
	EPYTHON=python2.7
	python_newexe ${S}/lava_server/manage.py lava-server || die
	python_fix_shebang ${D}/usr/

	#apache2
	dodir /etc/apache2/vhosts.d/
	insinto /etc/apache2/vhosts.d/
	doins ${S}/etc/lava-server.conf
	
	cd ${D}/usr/lib64/python2.7/site-packages/lava_server/lava-server/js/
	#ln -s bootstrap-3.3.7.js bootstrap-3.3.7.min.js
	sh ${FILESDIR}/minify
	cd ${D}/usr/lib64/python2.7/site-packages/lava_scheduler_app/static/lava_scheduler_app/js
	sh ${FILESDIR}/minify

}
