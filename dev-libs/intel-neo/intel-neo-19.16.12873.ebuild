# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

MY_PN="compute-runtime"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Intel Graphics Compute Runtime for OpenCL, for Gen8 (Broadwell) and beyond"
HOMEPAGE="https://github.com/intel/compute-runtime"
SRC_URI="https://github.com/intel/${MY_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="vaapi"

COMMON="dev-libs/ocl-icd
	dev-util/intel-graphics-compiler
	>=media-libs/gmmlib-19.0.0
	vaapi? (
		x11-libs/libdrm[video_cards_intel]
		>=x11-libs/libva-2.0.0
	)"
DEPEND="${COMMON}
	virtual/pkgconfig"
RDEPEND="${COMMON}"

DOCS=(
	README.md
	documentation/FAQ.md
	documentation/LIMITATIONS.md
)

PATCHES=(
	"${FILESDIR}"/${PN}-19.16.12873_cmake_no_libva_automagic.patch
)

S="${WORKDIR}"/${MY_P}

src_configure() {
	local mycmakeargs=(
		-DENABLE_VAAPI_MEDIA_SHARING=$(usex vaapi "ON" "OFF")
		# If enabled, tests are automatically run during the compile phase
		# - and we cannot run them because they require permissions to access
		# the hardware.
		-DSKIP_UNIT_TESTS=ON
	)
	cmake-utils_src_configure
}

pkg_postinst() {
	"${ROOT}"/usr/bin/eselect opencl set --use-old ocl-icd
}
