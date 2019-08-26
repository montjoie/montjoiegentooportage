# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{3_4,3_5,3_6} )
DISTUTILS_SINGLE_IMPL=1
inherit distutils-r1
#inherit python-single-r1

DESCRIPTION="lava CLI"
HOMEPAGE="https://git.lavasoftware.org/lava/lavacli.git"
#SRC_URI="https://git.lavasoftwate.org/lava/lavacli.git/snapshot/lavacli-${PV}.tar.gz"
SRC_URI="http://ftp.debian.org/debian/pool/main/l/lavacli/lavacli_${PV}.orig.tar.gz"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="amd64 arm arm64 x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND} dev-python/pyzmq"
RESTRICT="test"

PATCHES="${FILESDIR}/notest0.9.5.patch"
