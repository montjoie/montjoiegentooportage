# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools

DESCRIPTION="tool for building supermin appliances"
HOMEPAGE=""
#if [[ "${PV}" != "9999" ]]; then
#	SRC_URI="https://github.com/libguestfs/supermin/archive/v${PV}.tar.gz"
#	KEYWORDS="amd64 arm arm64 x86"
#else
	inherit git-r3
	EGIT_REPO_URI="https://github.com/libguestfs/supermin.git"
	EGIT_COMMIT="c9ca9af63d20d091433dd218cef3d85ad71ba3de"
	KEYWORDS="amd64 arm arm64 x86"
#fi

LICENSE=""
SLOT="0"
KEYWORDS="amd64 arm arm64 x86"
IUSE=""

DEPEND="dev-ml/ocamlbuild
	dev-ml/findlib
	app-arch/cpio"
RDEPEND="${DEPEND}"

src_prepare() {
	./bootstrap
	#./autogen.sh
	#sed -i 's, lib , ,' Makefile.am
	#sed -i 's,.*lib/Makefile.*, ,' configure.ac
	#sed -i 's,fts_,fts,' src/ext2fs-c.c
	eautoreconf
	default
}
