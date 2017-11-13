# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )
inherit distutils-r1

DESCRIPTION="lava-tool"
HOMEPAGE="https://git.linaro.org/lava/lava-tool.git/"
SRC_URI="https://git.linaro.org/lava/lava-tool.git/snapshot/lava-tool-release-0.23.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="amd64 ~x86"
IUSE=""
S="${WORKDIR}/$PN-release-${PV}"

DEPEND=""
RDEPEND="${DEPEND}"
