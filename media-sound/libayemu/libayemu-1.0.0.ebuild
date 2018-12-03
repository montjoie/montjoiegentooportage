# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

inherit autotools

DESCRIPTION="AY/YM sound chip (from ZX-Spectrum) emulation library. "
HOMEPAGE="https://sourceforge.net/projects/libayemu/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPLv2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_prepare() {
	sed -i 's,-ldconfig,echo,' ${S}/Makefile.am || die
	eautoreconf
	default
}

