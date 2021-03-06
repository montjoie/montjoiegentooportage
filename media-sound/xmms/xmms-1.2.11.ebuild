# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="multimedia player for unix systems"
HOMEPAGE="http://www.xmms.org/"
SRC_URI="http://www.xmms.org/files/1.2.x/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="=dev-libs/glib-1.2*
	=x11-libs/gtk+-1.2*"
RDEPEND="${DEPEND}"

src_configure(){
	econf --disable-oss || die
}

src_install() {
	emake install DESTDIR="${D}" || die
}
