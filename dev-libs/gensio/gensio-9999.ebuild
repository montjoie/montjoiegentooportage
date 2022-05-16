# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools

DESCRIPTION="General Stream I/O"
HOMEPAGE="https://github.com/cminyard/gensio"
if [[ "${PV}" != "9999" ]];
then
	SRC_URI=""
	KEYWORDS="amd64 arm arm64 x86"
else
	inherit git-r3
	EGIT_REPO_URI="https://github.com/cminyard/gensio.git"
	KEYWORDS=""
fi

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf
	return
	mycmakeargs=(
		"-DENABLE_PYTHON=OFF"
		"-DENABLE_SWIG=OFF"
		)

}

src_compile() {
	emake
}
