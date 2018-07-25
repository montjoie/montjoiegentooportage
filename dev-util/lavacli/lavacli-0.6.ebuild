# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{3_4,3_5,3_6} )

inherit distutils-r1

DESCRIPTION="lava CLI"
HOMEPAGE="https://git.linaro.org/lava/lavacli.git"
SRC_URI="https://git.linaro.org/lava/lavacli.git/snapshot/lavacli-0.6.tar.gz"

LICENSE="GPL"
SLOT="0"
KEYWORDS="amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND} dev-python/pyzmq"
