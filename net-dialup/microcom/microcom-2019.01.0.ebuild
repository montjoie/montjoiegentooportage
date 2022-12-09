# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools

DESCRIPTION="minimalistic terminal program for communicating with devices over a serial connection"
HOMEPAGE="https://github.com/pengutronix/microcom"
SRC_URI="https://github.com/pengutronix/microcom/archive/refs/tags/v2019.01.0.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm arm64"

DEPEND="sys-libs/readline"
RDEPEND="${DEPEND}"
BDEPEND=""

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf
}

src_compile() {
	emake
}
