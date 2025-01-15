# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{10,11,12,13} )
inherit distutils-r1

DESCRIPTION="munin-node-python"
HOMEPAGE="https://github.com/montjoie/munin-node-python.git"
if [[ "${PV}" != "9999" ]];
then
	SRC_URI=""
	KEYWORDS="amd64 arm arm64 x86"
else
	inherit git-r3
	EGIT_REPO_URI="https://github.com/montjoie/munin-node-python.git"
	#KEYWORDS=""
	KEYWORDS="amd64 arm arm64 x86"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_install() {
	default

	distutils-r1_src_install

	dodir /var/lib/munin/plugin-state
	dodir /var/log/munin-node
	dodir /usr/libexec/munin/plugins
	dodir /etc/munin/plugins
	dodir /etc/munin/plugin-conf.d

	insinto /usr/libexec/munin/plugins
	doins plugins/*
	doins munin/plugins/node.d/df.in
	doins munin/plugins/node.d/df_inode.in
	doins munin/plugins/node.d.linux/cpu.in
	doins munin/plugins/node.d.linux/if_.in
	doins munin/plugins/node.d.linux/memory.in
	doins munin/plugins/node.d.linux/uptime.in
	doins munin/plugins/plugin.sh.in
	mv $D/usr/libexec/munin/plugins/plugin.sh.in $D/usr/libexec/munin/plugins/plugin.sh

	sed -i 's,@@BASH@@,/bin/bash,' $D/usr/libexec/munin/plugins/*
	sed -i 's,@@GOODSH@@,/bin/sh,' $D/usr/libexec/munin/plugins/*

	newinitd "${FILESDIR}"/munin-node-python.init munin-node-python
	dobin munin-node-configure
}

