# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

#PYTHON_COMPAT=( python2_7 python3_{4,5,6} )
PYTHON_COMPAT=( python2_7 )
inherit git-r3 distutils-r1

DESCRIPTION="LAVA"
HOMEPAGE="https://validation.linaro.org"
#SRC_URI=""
EGIT_REPO_URI="https://github.com/Linaro/lava-dispatcher.git"

LICENSE="GPL"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	app-emulation/libguestfs
	dev-python/configobj
	dev-python/pyudev
	dev-python/python-magic"

src_install() {
	default
	dodir /etc/lava-dispatcher/
	insinto /etc/lava-dispatcher/
	doins etc/lava-slave

	dodir /var/log/lava-dispatcher

	newinitd ${FILESDIR}/lava-slave.init lava-slave

	dodir /var/lib/lava-server/default/media/
	fowners -R lavaserver:lavaserver /var/lib/lava-server/default/

	python_foreach_impl distutils-r1_python_install || die
}
