# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{10,11,12,13} )
inherit cmake distutils-r1

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

src_prepare() {
	default
	cmake_src_prepare
}

src_configure() {
	default
	cmake_src_configure
}

src_install() {
	default

	cmake_src_install
	distutils-r1_src_install

	#dodir /var/lib/munin/plugin-state
	#dodir /var/log/munin-node
	#dodir /usr/libexec/munin/plugins
	#dodir /etc/munin/plugins
	#dodir /etc/munin/plugin-conf.d

	#insinto /usr/libexec/munin/plugins
	#doins plugins/*
	#newins munin/plugins/node.d/df.in df_
	#newins munin/plugins/node.d/df_inode.in df_inode_
	#newins munin/plugins/node.d.linux/cpu.in cpu
	#newins munin/plugins/node.d.linux/if_.in if_
	#newins munin/plugins/node.d.linux/memory.in memory
	#newins munin/plugins/node.d.linux/uptime.in uptime
	#newins munin/plugins/plugin.sh.in plugin.sh
	chmod +x $D/usr/libexec/munin/plugins/*

	find $D/usr/libexec/munin/plugins/ -type f |
	while read line
	do
		sed -i 's,@@BASH@@,/bin/bash,' $line
		sed -i 's,@@GOODSH@@,/bin/sh,' $line
	done

	find $D/usr/libexec/munin/plugins/ -iname '*.in' -type f |
	while read line
	do
		NEWNAME=$(echo $line | sed 's,.in$,,')
		echo "DEBUG: fix $line $NEWNAME"
		mv $line $NEWNAME
	done

	newinitd "${FILESDIR}"/munin-node-python.init munin-node-python
	#dobin munin-node-configure

	keepdir /var/lib/munin/plugin-state
	keepdir /var/log/munin-node/
}

