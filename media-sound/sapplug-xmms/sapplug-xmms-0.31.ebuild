# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils

DESCRIPTION="SAP plug in for xmms"
HOMEPAGE="http://asma.atari.org/bin/"
SRC_URI="https://asma.atari.org/bin/obsolete/SAPPlug-XMMS/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="media-sound/xmms"
RDEPEND="${DEPEND}"

epatch() {
	echo "PATCH $1"
	patch --batch -p1 < $1
	if [ $? -ne 0 ];then
		patch --batch -p0 < $1 || exit $?
	fi
}

src_prepare() {
	epatch "${FILESDIR}/sapEngine_const.patch"
	epatch "${FILESDIR}/makefile.patch"
#	epatch ${FILESDIR}/makefile_cflag.patch
#	epatch ${FILESDIR}/deref.patch
#	epatch ${FILESDIR}/deref2.patch
	default
}

src_compile() {
#	emake -j1 CFLAGS="${CFLAGS} `xmms-config --cflags` -fno-strict-aliasing"|| die
	emake -j1 || die
}

src_install() {
	insinto "`xmms-config --input-plugin-dir`"
	doins libsap.so || die
}
