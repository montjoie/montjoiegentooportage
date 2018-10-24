# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

DESCRIPTION="yet another NBD (Network Block Device) server program"
HOMEPAGE="https://bitbucket.org/hirofuchi/xnbd/wiki/Home"
SRC_URI="https://bitbucket.org/hirofuchi/xnbd/downloads/${P}.tgz"

LICENSE=""
SLOT="0"
KEYWORDS="amd64 arm arm64 x86"
IUSE="doc"

DEPEND="dev-libs/jansson"
RDEPEND="${DEPEND}"
BDEPEND=""
#S=${S}/trunk
S=${WORKDIR}/${P}/trunk

src_prepare() {
	echo "" > ${S}/doc/Makefile.am
	eapply "${FILESDIR}"/00include_sysmacros.patch
	eautoreconf
	default
}

src_configure() {
	econf
}

src_compile() {
	emake
}
