# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{4,5,6} )
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
	dev-embedded/u-boot-tools
	net-ftp/tftp-hpa
	app-emulation/libguestfs
	dev-python/configobj
	dev-python/pyudev
	dev-python/python-magic"

pkg_setup() {
	enewgroup lavaserver
	enewuser lavaserver -1 -1 /var/lib/lava-server/home lavaserver
}

src_prepare() {
	default
	sed -i 's,/etc/default/tftpd-hpa,/etc/conf.d/in.tftpd,' lava_dispatcher/utils/filesystem.py || die
	sed -i 's,TFTP_DIRECTORY,INTFTPD_PATH,' lava_dispatcher/utils/filesystem.py || die
}

src_install() {
	default
	dodir /etc/lava-dispatcher/
	insinto /etc/lava-dispatcher/
	doins etc/lava-slave

	dodir /var/log/lava-dispatcher

	newinitd ${FILESDIR}/lava-slave.init lava-slave

	python_foreach_impl distutils-r1_python_install || die

	dodir /var/lib/lava-server/default/media/
	fowners -R lavaserver:lavaserver /var/lib/lava-server/default/
}
