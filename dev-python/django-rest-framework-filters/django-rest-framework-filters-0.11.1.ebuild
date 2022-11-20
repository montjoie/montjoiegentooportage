# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{9,10} )

inherit distutils-r1

DESCRIPTION="Better filtering for Django REST Framework"
HOMEPAGE="https://www.django-rest-framework.org/api-guide/filtering/#django-rest-framework-filters-package"
SRC_URI="https://files.pythonhosted.org/packages/c5/e7/e94c0834cc345b160d51bc57e6145c4903ce0d08db0cdd3d44fa43cc2059/djangorestframework-filters-0.11.1.tar.gz -> ${P}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"

IUSE=""

RDEPEND=">=dev-python/markdown-2.6.4[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-3.10[${PYTHON_USEDEP}]
"

DEPEND="${RDEPEND}
	dev-python/django[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
"

S=${WORKDIR}/djangorestframework-filters-${PV}

#RESTRICT="test"

