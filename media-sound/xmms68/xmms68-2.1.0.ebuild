# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="sc68 plug in for xmms"
HOMEPAGE="http://sc68.atari.org/"
SRC_URI="http://www.montjoie.ovh/mods/${P}.tar.bz2"
#SRC_URI="mirror://sourceforge/sc68/${PN}/${P}.tar.bz2"

LICENSE="GPLv2"
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
