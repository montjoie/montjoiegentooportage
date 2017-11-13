# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools linux-info

DESCRIPTION="Linux Kernel Crypto API User Space Interface Library"
HOMEPAGE="http://www.chronox.de/libkcapi.html"
if [[ "${PV}" != "9999" ]];
then
	SRC_URI="http://www.chronox.de/libkcapi/${P}.tar.xz"
	KEYWORDS="amd64 arm arm64 x86"
else
	inherit git-r3
	EGIT_REPO_URI="git://github.com/smuellerDD/libkcapi.git"
	KEYWORDS=""
	#S="${WORKDIR}/${PN}"
fi

LICENSE="GPL"
SLOT="0"
IUSE="rngtool"

DEPEND=""
RDEPEND="${DEPEND}"

pkg_setup() {
	CONFIG_CHECK="~CRYPTO_USER ~CRYPTO_USER_API CRYPTO_USER_API_HASH CRYPTO_USER_API_SKCIPHER CRYPTO_USER_API_RNG CRYPTO_USER_API_AEAD"
	#check_extra_config
}

src_prepare() {
	epatch "${FILESDIR}/sun8i-ce.patch"
	eautoreconf
	default
}

src_configure() {
	econf --enable-kcapi-test=yes \
		$(use_enable rngtool kcapi-rngapp) \
		--enable-kcapi-speed=yes
}

src_install() {
	default
	newbin "${S}/test/test.sh" kcapi-test.sh
}
