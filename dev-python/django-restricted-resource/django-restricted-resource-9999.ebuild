# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_7 python3_8 )
inherit distutils-r1

DESCRIPTION=""
HOMEPAGE="https://git.linaro.org/lava/django-restricted-resource.git/"

if [[ "${PV}" != "9999" ]]; then
	SRC_URI="https://git.linaro.org/lava/django-restricted-resource.git/snapshot/django-restricted-resource-release-${PV}.tar.gz"
	KEYWORDS="amd64 arm arm64 x86"
else
	inherit git-r3
	EGIT_REPO_URI="https://git.linaro.org/lava/django-restricted-resource.git"
fi

LICENSE=""
SLOT="0"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
