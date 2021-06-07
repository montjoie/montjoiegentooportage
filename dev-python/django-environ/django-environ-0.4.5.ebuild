# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{8,9} )

inherit distutils-r1

DESCRIPTION="use Twelve-factor methodology to configure your application with env variables"
HOMEPAGE="https://github.com/joke2k/django-environ"
SRC_URI="https://github.com/joke2k/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm x86"

IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}
	dev-python/django[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
"

#RESTRICT="test"

