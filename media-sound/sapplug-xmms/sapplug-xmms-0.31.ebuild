# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit eutils

DESCRIPTION="SAP plug in for xmms"
HOMEPAGE="http://asma.atari.org/bin/"
SRC_URI="http://asma.atari.org/bin/${P}.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="media-sound/xmms"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch ${FILESDIR}/sapEngine_const.patch
	epatch ${FILESDIR}/makefile.patch
#	epatch ${FILESDIR}/makefile_cflag.patch
#	epatch ${FILESDIR}/deref.patch
#	epatch ${FILESDIR}/deref2.patch
}

src_compile() {
#	emake -j1 CFLAGS="${CFLAGS} `xmms-config --cflags` -fno-strict-aliasing"|| die
	emake -j1 || die
}

src_install() {
	insinto "`xmms-config --input-plugin-dir`"
	doins libsap.so || die
}
