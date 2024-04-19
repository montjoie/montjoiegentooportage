# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10,11,12} )
inherit distutils-r1 udev

DISTUTILS_USE_PEP517=setuptools

if [[ "${PV}" != "9999" ]]; then
	KEYWORDS="amd64 arm arm64 x86"
	SRC_URI="https://github.com/linux-automation/usbsdmux/archive/refs/tags/${PV}.tar.gz"
else
	inherit git-r3
	EGIT_REPO_URI="https://github.com/linux-automation/usbsdmux.git"
fi

DESCRIPTION="usbsdmux"
HOMEPAGE="https://github.com/linux-automation/usbsdmux/"

LICENSE="LGPL-2.1"
SLOT="0"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""
distutils_enable_tests pytest

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
