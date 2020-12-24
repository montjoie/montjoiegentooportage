# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

DESCRIPTION="XFS tests"
HOMEPAGE=""
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="git://git.kernel.org/pub/scm/fs/xfs/xfstests-dev.git"
	S="${WORKDIR}/${PN}-${PV}"
else
	SRC_URI=""
fi

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="
	virtual/acl
	sys-apps/attr
	sys-fs/xfsprogs"
RDEPEND="${DEPEND}"
BDEPEND=""

src_prepare() {
	ls -l
	sed -i 's,dmiperf ,,' ${S}/src/Makefile

	eautoreconf

	default
}
