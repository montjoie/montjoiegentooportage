# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..11} )
inherit cmake

DESCRIPTION="xython"
HOMEPAGE=""
SRC_URI="xython-0.tar.gz"
S="${WORKDIR}/"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""
