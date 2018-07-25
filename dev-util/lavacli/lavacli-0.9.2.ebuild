# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{3_4,3_5,3_6} )
DISTUTILS_SINGLE_IMPL=1
inherit distutils-r1
#inherit python-single-r1

DESCRIPTION="lava CLI"
HOMEPAGE="https://git.linaro.org/lava/lavacli.git"
SRC_URI="https://git.linaro.org/lava/lavacli.git/snapshot/lavacli-${PV}.tar.gz"

LICENSE="GPL"
SLOT="0"
KEYWORDS="amd64 arm arm64 x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND} dev-python/pyzmq"
RESTRICT="test"

PATCHES="${FILESDIR}/notest.patch"
