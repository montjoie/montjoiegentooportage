# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/cfengine/cfengine-3.3.9.ebuild,v 1.1 2012/10/27 15:42:36 idl0r Exp $

EAPI=8

inherit autotools

MY_PV="${PV//_beta/b}"
MY_PV="${MY_PV/_p/p}"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="Automated suite of programs for configuring and maintaining Unix-like computers"
HOMEPAGE="http://www.cfengine.org/"
#SRC_URI="http://cfengine-package-repos.s3.amazonaws.com/tarballs/${MY_P}.tar.gz -> ${MY_P}.tar.gz"
SRC_URI="https://cfengine-package-repos.s3.amazonaws.com/tarballs/cfengine-community-${PV}.tar.gz -> ${MY_P}.tar.gz"
LICENSE="GPL-3"
SLOT="3"
KEYWORDS="amd64 arm arm64 ppc sparc x86"

IUSE="acl curl examples html libvirt lmdb mysql postgres +qdbm selinux server tests tokyocabinet vim-syntax yaml xml"

DEPEND="
	mysql? ( virtual/mysql )
	postgres? ( dev-db/postgresql:* )
	selinux? ( sys-libs/libselinux )
	tokyocabinet? ( dev-db/tokyocabinet )
	lmdb? ( dev-db/lmdb )
	qdbm? ( dev-db/qdbm )
	libvirt? ( app-emulation/libvirt )
	dev-libs/openssl
	dev-libs/libpcre
	yaml? ( dev-libs/libyaml )
	xml? ( dev-libs/libxml2 )
	acl? ( virtual/acl )"
RDEPEND="${DEPEND}"
PDEPEND="vim-syntax? ( app-vim/cfengine-syntax )"

REQUIRED_USE="qdbm? ( !tokyocabinet )
	tokyocabinet? ( !qdbm )
	!tokyocabinet? ( || ( qdbm lmdb ) )
	!qdbm? ( || ( tokyocabinet lmdb ) )"

S="${WORKDIR}/${MY_P}"

#PATCHES=(
#	"${FILESDIR}"/libntech-xml2.patch
#)
src_prepare() {
	default

	sed -i "s,/sbin/ifconfig,`which /bin/ifconfig`,g" libenv/unix_iface.c || die
	sed -i "s,/bin/getent,/usr/bin/getent,g" libpromises/unix.c || die

	eautoreconf
}

src_configure() {
	# Enforce /var/cfengine for historical compatibility
	econf \
		--enable-fhs \
		--docdir=/usr/share/doc/${PF} \
		--with-workdir=/var/cfengine \
		--with-pcre \
		$(use_with acl libacl) \
		$(use_with !curl libcurl no) \
		$(use_with qdbm) \
		$(use_with lmdb) \
		$(use_with tokyocabinet) \
		$(use_with postgres postgresql) \
		$(use_with mysql mysql check) \
		$(use_with libvirt) \
		$(use_with yaml libyaml) \
		$(use_with xml libxml2)
}

src_install() {
	newinitd "${FILESDIR}"/cf-monitord.rc6 cf-monitord || die
	newinitd "${FILESDIR}"/cf-execd.rc6 cf-execd || die

	emake DESTDIR="${D}" install || die

	# fix ifconfig path in provided promises
	find "${D}"/usr/share -name "*.cf" | xargs sed -i "s,/sbin/ifconfig,$(which ifconfig),g"

	dodoc AUTHORS

	if ! use examples; then
		rm -rf "${D}"/usr/share/doc/${PF}/example* || die
	fi

	# Create cfengine working directory
	dodir /var/cfengine/bin
	fperms 700 /var/cfengine

	# Copy cfagent into the cfengine tree otherwise cfexecd won't
	# find it. Most hosts cache their copy of the cfengine
	# binaries here. This is the default search location for the
	# binaries.
	dodir /usr/sbin/
	for bin in promises agent monitord execd runagent key; do
		#mv "${D}"/usr/bin/cf-$bin "${D}"/usr/sbin/cf-$bin || die
		dosym /usr/bin/cf-$bin /var/cfengine/bin/cf-$bin || die
	done
	if use server; then
		newinitd "${FILESDIR}"/cf-serverd.rc6 cf-serverd || die
		dosym /usr/bin/cf-serverd /var/cfengine/bin/cf-serverd
	else
		rm "${D}"/usr/bin/cf-serverd
	fi

	#No need for that
	rm "${D}"/usr/bin/rpmvercmp || die

	if use html; then
		docinto html
		dodoc -r docs/ || die
	fi
}

pkg_postinst() {
	echo
	einfo "Init scripts for cf-serverd, cf-monitord, and cf-execd are provided."
	einfo
	einfo "To run cfengine out of cron every half hour modify your crontab:"
	einfo "0,30 * * * *    /usr/sbin/cf-execd -F"
	echo

	elog "If you run cfengine the very first time, you MUST generate the keys for cfengine by running:"
	elog "emerge --config ${CATEGORY}/${PN}"
}

pkg_config() {
	if [ "${ROOT}" == "/" ]; then
		if [ ! -f "/var/cfengine/ppkeys/localhost.priv" ]; then
			einfo "Generating keys for localhost."
			/usr/sbin/cf-key
		fi
	else
		die "cfengine cfkey does not support any value of ROOT other than /."
	fi
}
