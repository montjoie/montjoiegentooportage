# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

MYPV="${PV/_beta/b}"
PYTHON_COMPAT=( python3_{9..10} )

inherit distutils-r1

DESCRIPTION="Asynchronous task queue/job queue based on distributed message passing"
HOMEPAGE="
	https://github.com/pallets/click
"
SRC_URI="https://github.com/pallets/click/archive/refs/tags/${MYPV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${MYPV}"
LICENSE="BSD"
SLOT="0"
KEYWORDS="arm arm64 amd64"

RDEPEND="
"
DEPEND="
	${RDEPEND}
"
