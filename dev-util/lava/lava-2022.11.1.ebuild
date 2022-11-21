# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_REQ_USE="sqlite"
PYTHON_COMPAT=( python3_{10} )
inherit autotools distutils-r1 user

DESCRIPTION="LAVA"
HOMEPAGE="https://validation.linaro.org"

if [[ "${PV}" != "9999" ]]; then
	SRC_URI="https://git.lavasoftware.org/lava/lava/-/archive/${PV}/${P}.tar.gz"
	KEYWORDS="amd64 arm arm64 x86"
else
	inherit git-r3
	EGIT_REPO_URI="https://git.linaro.org/lava/lava.git"
fi

PATCHES="
	${FILESDIR}/yaml_load-2019.10.patch
	${FILESDIR}/pkg-version.patch
	${FILESDIR}/remove_junit-2022.08.patch
	"

#TODO feature check for NFS LXC

distutils_enable_tests pytest

LICENSE="GPL-2"
SLOT="0"
IUSE="apache2 dispatcher doc docker ldap lxc nbd nfs qemu master screen telnet test tftp"

DEPEND=""
RDEPEND="${DEPEND}
	master? ( dev-db/postgresql )
	master? (
		dev-python/celery[${PYTHON_USEDEP}]
		dev-python/defusedxml[${PYTHON_USEDEP}]
		<dev-python/django-3[${PYTHON_USEDEP}]
		>=dev-python/django-tables2-1.21.2[${PYTHON_USEDEP}]
		dev-python/django-restricted-resource[${PYTHON_USEDEP}]
		>=dev-python/django-rest-framework-3.12.1[${PYTHON_USEDEP}]
		dev-python/django-rest-framework-filters[${PYTHON_USEDEP}]
		>=dev-python/django-rest-framework-extensions-0.6.0[${PYTHON_USEDEP}]
		<dev-python/django-filter-2.6[${PYTHON_USEDEP}]
		dev-python/django-environ[${PYTHON_USEDEP}]
		dev-python/psycopg[${PYTHON_USEDEP}]
		dev-python/py-amqp[${PYTHON_USEDEP}]
		dev-python/tappy[${PYTHON_USEDEP}]
		dev-python/whitenoise[${PYTHON_USEDEP}]
		www-servers/gunicorn[${PYTHON_USEDEP}]
	)
	ldap? ( dev-python/django-auth-ldap )
	apache2? ( www-servers/apache )
	docker? ( app-containers/docker )
	lxc? ( app-emulation/lxc )
	nbd? ( sys-block/nbd )
	nfs? ( net-fs/nfs-utils )
	screen? ( app-misc/screen )
	telnet? ( net-misc/telnet-bsd )
	dev-python/simplejson[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	dev-python/jinja[${PYTHON_USEDEP}]
	dev-python/pexpect[${PYTHON_USEDEP}]
	dev-python/voluptuous[${PYTHON_USEDEP}]
	dev-python/netifaces[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/pytz[${PYTHON_USEDEP}]
	dev-python/pyzmq[${PYTHON_USEDEP}]
	dev-python/python-dateutil[${PYTHON_USEDEP}]
	doc? (
		dev-python/sphinx
		dev-python/sphinx-bootstrap-theme
	)
	dispatcher? (
		app-emulation/libguestfs[python]
		dev-embedded/u-boot-tools
		tftp? ( net-ftp/tftp-hpa )
		qemu? (
			app-emulation/supermin
			)
		dev-python/aiohttp[${PYTHON_USEDEP}]
		dev-python/configobj[${PYTHON_USEDEP}]
		dev-python/nose[${PYTHON_USEDEP}]
		dev-python/pyserial[${PYTHON_USEDEP}]
		dev-python/pyudev[${PYTHON_USEDEP}]
		dev-python/python-magic[${PYTHON_USEDEP}]
	)"

pkg_pretend() {
	if ! use master;then
		for duse in apache2 ldap
		do
			if use $duse;then
				ewarn "USE $duse is useless without master"
			fi
		done
	fi
	if ! use dispatcher;then
		for duse in qemu nfs lxc nbd screen telnet
		do
			if use $duse;then
				ewarn "USE $duse is useless without dispatcher"
			fi
		done
	fi
}

src_prepare() {
	default
	#epatch "${FILESDIR}/no-celery.patch"
	#find ${S} -name '__pycache__' -type f | xargs rm -v
}

pkg_setup() {
	enewgroup lavaserver
	enewuser lavaserver -1 -1 /var/lib/lava-server/home lavaserver
}

src_compile() {
	if use doc;then
		emake html -C doc/v2/
	fi
	default
}

src_install() {
	default
	#python_foreach_impl distutils-r1_python_install || die
	#python_foreach_impl python_newexe ${S}/manage.py lava-server || die
	#python_foreach_impl python_fix_shebang ${D}/usr/
	#distutils-r1_python_install
	# HACK
	EPYTHON=python3.10
	$EPYTHON setup.py install --root="${D}"

	if use master;then
		dodir /etc
		insinto /etc/lava-server/

		doins -r "${S}/etc/dispatcher-config"

		newinitd "${FILESDIR}/lava-publisher.init" lava-publisher
		newinitd "${FILESDIR}/lava-scheduler.init" lava-scheduler
		newinitd "${FILESDIR}/lava-server-gunicorn.init" lava-server-gunicorn

		dodir /etc/lava-server
		insinto /etc/lava-server
		#newins etc/instance.conf.template instance.conf
		doins etc/env.yaml
		doins etc/settings.conf

		dodir /var/log/lava-server
		keepdir /var/log/lava-server
		fowners lavaserver:lavaserver /var/log/lava-server

		dodir /usr/share/lava-server
		dodir /usr/share/lava-server/static

		dodir /etc/lava-server/dispatcher-config/devices
		dodir /etc/lava-server/dispatcher-config/health-checks
		#dodir /etc/lava-server/dispatcher-config/device-types/
		dodir /usr/share/lava-server/device-types/
		mv "${D}/etc/lava-server/dispatcher-config/device-types/"* "${D}/usr/share/lava-server/device-types/"

		ln -s "/usr/lib/$EPYTHON/site-packages/django/contrib/admin/static/admin/" "${D}/usr/share/lava-server/static/admin" || die
		ln -s "/usr/lib/$EPYTHON/site-packages/lava_server/static/lava_server" "${D}/usr/share/lava-server/static/lava_server" || die
		ln -s "/usr/lib/$EPYTHON/site-packages/lava_scheduler_app/static/lava_scheduler_app" "${D}/usr/share/lava-server/static/lava_scheduler_app" || die
		ln -s /"usr/lib/$EPYTHON/site-packages/lava_results_app/static/lava_results_app" "${D}/usr/share/lava-server/static/lava_results_app" || die

		if ! use ldap;then
			sed -i 's,import ldap,,' "${D}/usr/lib/$EPYTHON/site-packages/lava_scheduler_app/utils.py"
		fi

		#apache2
		if use apache2; then
			dodir /etc/apache2/vhosts.d/
			insinto /etc/apache2/vhosts.d/
			doins "${S}/etc/lava-server.conf"
		fi

		# I found too ugly to install nodejs just for that
		# TODO add a real-minify use flag which depend on nodejs
		cd "${D}/usr/lib/$EPYTHON/site-packages/lava_server/static/lava_server/js/" || die
		sh "${FILESDIR}/minify" || die
		cd "${D}/usr/lib/$EPYTHON/site-packages/lava_scheduler_app/static/lava_scheduler_app/js" || die
		sh "${FILESDIR}/minify" || die

		dodir /var/lib/lava-server/default/
		dodir /var/lib/lava-server/default/media/
		keepdir /var/lib/lava-server/default/media/
		fowners -R lavaserver:lavaserver /var/lib/lava-server/default/
		dobin "${FILESDIR}/lava-postinstall"

		if use doc;then
			dodir /usr/share/lava-server/static/docs/
			insinto /usr/share/lava-server/static/docs/
			cd "${S}"
			doins -r doc/v2/_build/html/*
		fi
	else
		einfo "Clean unused master files"
		EPYTHON=python3.9
		rm -r "${D}/usr/$(get_libdir)/$EPYTHON/site-packages/lava_server/"
		rm -r "${D}/usr/$(get_libdir)/$EPYTHON/site-packages/linaro_django_xmlrpc/"
		rm -r "${D}/usr/$(get_libdir)/$EPYTHON/site-packages/linaro_scheduler/"
		rm -r "${D}/usr/$(get_libdir)/$EPYTHON/site-packages/lava_results_app/"
		rm -r "${D}/usr/$(get_libdir)/$EPYTHON/site-packages/dashboard_app/"
	fi

	if use dispatcher;then
		newinitd "${FILESDIR}/lava-worker.init" lava-worker

		dodir /var/lib/lava/dispatcher/lava-worker
		fowners lavaserver:lavaserver /var/lib/lava/dispatcher/lava-worker

		dodir /var/log/lava-dispatcher
		keepdir /var/log/lava-dispatcher
		fowners lavaserver:lavaserver /var/log/lava-dispatcher

		if use tftp;then
			dodir /etc/default/
			echo '# fake tftpd-hpa config file for LAVA' > "${D}/etc/default/tftpd-hpa"
			echo 'TFTP_DIRECTORY="/var/lib/lava/dispatcher/tmp/"' >> "${D}/etc/default/tftpd-hpa"
		fi
	fi
	python_optimize

	rm -r "${D}/lib/systemd"
	rm -r "${D}/etc/systemd"
}

pkg_postinst() {
	if use dispatcher;then
		einfo 'Please set INTFTPD_PATH="/var/lib/lava/dispatcher/tmp/"'
	fi

	if use master;then
		einfo "On the first install, simply run lava-postinstall"
		einfo "Create an admin account with lava-server manage users add --passwd adminpassword --staff --superuser admin"
		einfo "Then you can add workers via lavacli"
		einfo "Dont forget to add ALLOWED_HOSTS in /etc/lava-server/settings.conf"
		einfo "if you upgrade LAVA, please run lava-server manage migrate (see share/postinst.py TODO)"
	fi

	if use qemu;then
		einfo "Please check that libguestfs works with libguestfs-test-tool"
	fi
}
