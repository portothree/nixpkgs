{ lib
, stdenv
, fetchFromGitHub
, cmake
, vulkan-headers
, glfw
, catch2
}:

stdenv.mkDerivation rec {
  pname = "vk-bootstrap";
  version = "0.6";
  outputs = [ "out" "dev" ];

  src = fetchFromGitHub {
    owner = "charles-lunarg";
    repo = "vk-bootstrap";
    rev = "v${version}";
    sha256 = "sha256-T24SCJSGta4yuK58NcQnMeiO3sg9P9/O3kaFJFO/eOE=";
  };

  postPatch = ''
    # Upstream uses cmake FetchContent to resolve glfw and catch2
    # needed for examples and tests
    sed -iE 's=add_subdirectory(ext)==g' CMakeLists.txt
    sed -iE 's=Catch2==g' tests/CMakeLists.txt
  '';

  nativeBuildInputs = [ cmake ];
  buildInputs = [ vulkan-headers glfw catch2 ];

  cmakeFlags = [
    "-DVK_BOOTSTRAP_VULKAN_HEADER_DIR=${vulkan-headers}/include"
  ];

  meta = with lib; {
    description = "Vulkan Bootstrapping Library";
    license = licenses.mit;
    homepage = "https://github.com/charles-lunarg/vk-bootstrap";
    maintainers = with maintainers; [ shamilton ];
    platforms = platforms.all;
  };
}
