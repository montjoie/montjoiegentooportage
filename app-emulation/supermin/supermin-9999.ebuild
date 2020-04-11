# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools

DESCRIPTION="tool for building supermin appliances"
HOMEPAGE=""
if [[ "${PV}" != "9999" ]]; then
	SRC_URI="https://github.com/libguestfs/supermin/archive/v${PV}.tar.gz"
	KEYWORDS="amd64 arm arm64 x86"
else
	inherit git-r3
	EGIT_REPO_URI="https://github.com/libguestfs/supermin.git"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE=""

DEPEND="dev-ml/ocamlbuild"
RDEPEND="${DEPEND}"

src_prepare() {
	./bootstrap
	./autogen.sh
	#sed -i 's, lib , ,' Makefile.am
	#sed -i 's,.*lib/Makefile.*, ,' configure.ac
	#sed -i 's,fts_,fts,' src/ext2fs-c.c
	eautoreconf
	default
}
