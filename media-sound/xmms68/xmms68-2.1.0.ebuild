# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="sc68 plug in for xmms"
HOMEPAGE="http://sc68.atari.org/"
SRC_URI="http://www.montjoie.ovh/mods/${P}.tar.bz2"
#SRC_URI="mirror://sourceforge/sc68/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="media-sound/sc68
	media-sound/xmms"
RDEPEND="${DEPEND}"

src_install() {
	insinto "`xmms-config --input-plugin-dir`"
	doins .libs/libxmms68.so || die
}
