# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{9..11} )

inherit distutils-r1

DESCRIPTION="Better filtering for Django REST Framework"
HOMEPAGE="https://www.django-rest-framework.org/api-guide/filtering/#django-rest-framework-filters-package"
SRC_URI="http://deb.debian.org/debian/pool/main/d/djangorestframework-filters/djangorestframework-filters_1.0.0.dev0.orig.tar.gz -> ${P}.tar.gz"
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

S=${WORKDIR}/django-rest-framework-filters-${PV}.dev0

#RESTRICT="test"

