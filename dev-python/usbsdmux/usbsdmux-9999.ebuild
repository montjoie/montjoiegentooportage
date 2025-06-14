# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10,11,12,13} )
inherit distutils-r1 udev

if [[ "${PV}" != "9999" ]]; then
	KEYWORDS="amd64 arm arm64 x86"
else
	inherit git-r3
	KEYWORDS="amd64 arm arm64 x86"
	EGIT_REPO_URI="https://github.com/linux-automation/usbsdmux.git"
fi

DESCRIPTION="usbsdmux"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS=""

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

src_install() {
	distutils-r1_src_install
	udev_dorules contrib/udev/99-usbsdmux.rules
}

pkg_postinst() {
	udev_reload
}

pkg_postrm() {
	udev_reload
}
