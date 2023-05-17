# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION="Serial To Network Proxy"
SRC_URI="mirror://sourceforge/ser2net/${P}.tar.gz"
HOMEPAGE="https://sourceforge.net/projects/ser2net"

KEYWORDS="amd64 ~ppc x86"
SLOT="4"
LICENSE="GPL-2"

DEPEND="
	dev-libs/gensio
	dev-libs/libyaml"
RDEPEND="${DEPEND}"

src_install () {
	default

	mv ${D}/usr/sbin/ser2net ${D}/usr/sbin/ser2net4

	insinto /etc
	newins ${PN}.yaml ${PN}.yaml.dist

	newinitd "${FILESDIR}/${PN}4.initd" ${PN}4
	newconfd "${FILESDIR}/${PN}4.confd" ${PN}4

	mv ${D}/usr/share/man/man5/ser2net.yaml.5 ${D}/usr/share/man/man5/ser2net4.yaml.5
	mv ${D}/usr/share/man/man8/ser2net.8 ${D}/usr/share/man/man8/ser2net4.8
}
