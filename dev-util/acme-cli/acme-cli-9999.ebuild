# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION=""
HOMEPAGE="https://gitlab.com/baylibre-acme/acme-cli.git"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://gitlab.com/baylibre-acme/acme-cli.git"
	S="${WORKDIR}/${PN}-${PV}"
fi

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 arm arm64 x86"
IUSE=""

DEPEND=""
RDEPEND="dev-lang/python"
BDEPEND=""

src_install()
{
	dobin acme-cli
}
