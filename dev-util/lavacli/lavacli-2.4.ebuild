# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )
DISTUTILS_SINGLE_IMPL=1
inherit distutils-r1

DESCRIPTION="lava CLI"
HOMEPAGE="https://gitlab.com/lava/lavacli"
SRC_URI="https://gitlab.com/lava/lavacli/-/archive/v${PV}/lavacli-v${PV}.tar.gz"

LICENSE="AGPL-3+"
SLOT="0"
KEYWORDS="amd64 arm arm64 x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND} dev-python/pyzmq
	dev-python/ruamel-yaml
	dev-python/aiohttp
	dev-python/voluptuous"
RESTRICT="test"
# test need dev-python/pytest-runner

#PATCHES="${FILESDIR}/notest-1.5.1.patch"
S="${WORKDIR}/lavacli-v${PV}"
