# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Atari ST and Amiga music player"
HOMEPAGE="http://sc68.atari.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="debug doc"
#debug is for debug68

DEPEND="debug? ( sys-libs/readline )
	sys-libs/zlib"
RDEPEND="${DEPEND}"

src_prepare() {
	eapply "${FILESDIR}"/doc.patch
	default
}

src_configure() {
	econf $(use_enable doc docs)
}

src_install() {
	emake install DESTDIR="${D}" || die
}
