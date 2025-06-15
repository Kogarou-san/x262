# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic toolchain-funcs

DESCRIPTION="x264 with MPEG-2 support."
HOMEPAGE="https://github.com/Kogarou-san/x262/x262"

KEYWORDS="~alpha ~amd64 ~ppc ~ppc64 ~sparc ~x86"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/Kogarou-san/x262.git"
else
	SRC_URI="https://github.com/Kogarou-san/x262/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE="avs ffmpeg ffmpegsource interlaced +lto mp4 +threads"
REQUIRED_USE="ffmpegsource? ( ffmpeg )"

RDEPEND="
	ffmpeg? ( media-video/ffmpeg:= )
	ffmpegsource? ( media-libs/ffmpegsource )
	mp4? ( >=media-video/gpac-0.5.2:= )
	avs? ( media-video/avisynth+ )
"
ASM_DEP=">=dev-lang/nasm-2.13"
DEPEND="
	${RDEPEND}
	amd64? ( ${ASM_DEP} )
	x86? ( ${ASM_DEP} )
"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}/cflags_fasteropts_swap.patch"
)

src_configure() {
	tc-export CC

	if [[ ${ABI} == x86 || ${ABI} == amd64 ]]; then
		export AS="nasm"
	else
		export AS="${CC}"
	fi

	"${S}/configure" \
		--prefix="${EPREFIX}"/usr \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		--host="${CHOST}" \
		--disable-lsmash \
		$(usex avs "" "--disable-avisynth") \
		$(usex lto "--enable-lto" "") \
        --disable-opencl \
		$(usex ffmpeg "" "--disable-lavf --disable-swscale") \
		$(usex ffmpegsource "" "--disable-ffms") \
		$(usex interlaced "" "--disable-interlaced") \
		$(usex mp4 "" "--disable-gpac") \
		$(usex threads "" "--disable-thread") \
		--enable-pic --disable-lavf --disable-lsmash --disable-ffms --disable-gpac --disable-swscale --disable-gpl  --extra-cflags='-fPIE' || die
}

src_install(){
	#this is so cursed
	dodir "/usr/bin/"
	install x262 "${D}/usr/bin/"
}



