# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="AY/YM plugin for xmms"
HOMEPAGE="https://sourceforge.net/projects/libayemu/"
SRC_URI="mirror://sourceforge/libayemu/xmms-in-vtx/${P}.tar.gz"

LICENSE="GPLv2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=">=dev-libs/glib-1.2.3
	>=x11-libs/gtk+-1.2.3
	media-sound/libayemu
	media-sound/xmms"
RDEPEND="${DEPEND}"

src_install() {
	insinto "`xmms-config --input-plugin-dir`"
	doins .libs/libvtx.so || die
}

