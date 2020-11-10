# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python{3_7,3_8} )
DISTUTILS_SINGLE_IMPL=1
inherit distutils-r1

DESCRIPTION="lava CLI"
HOMEPAGE="https://git.lavasoftware.org/lava/lavacli.git"
#SRC_URI="https://git.lavasoftware.org/lava/lavacli.git/snapshot/lavacli-${PV}.tar.gz"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="AGPL-3+"
SLOT="0"
KEYWORDS="amd64 arm arm64 x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND} dev-python/pyzmq"
RESTRICT="test"
# test need dev-python/pytest-runner

PATCHES="${FILESDIR}/notest0.9.5.patch"
