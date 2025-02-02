/*
How to combine packages for use in development:
dotnetCombined = with dotnetCorePackages; combinePackages [ sdk_3_1 sdk_5_0 aspnetcore_5_0 ];

Hashes and urls below are retrieved from:
https://dotnet.microsoft.com/download/dotnet
*/
{ callPackage, icu70, icu }:
let
  buildDotnet = attrs: callPackage (import ./build-dotnet.nix attrs) {};
  buildAttrs = {
    buildAspNetCore = attrs: buildDotnet (attrs // { type = "aspnetcore"; });
    buildNetRuntime = attrs: buildDotnet (attrs // { type = "runtime"; });
    buildNetSdk = attrs: buildDotnet (attrs // { type = "sdk"; });
  };

  runtimeIdentifierMap = {
    "x86_64-linux" = "linux-x64";
    "aarch64-linux" = "linux-arm64";
    "x86_64-darwin" = "osx-x64";
    "aarch64-darwin" = "osx-arm64";
    "x86_64-windows" = "win-x64";
    "i686-windows" = "win-x86";
  };

  # Convert a "stdenv.hostPlatform.system" to a dotnet RID
  systemToDotnetRid = system: runtimeIdentifierMap.${system} or (throw "unsupported platform ${system}");

  ## Files in versions/ are generated automatically by update.sh ##
  dotnet_3_1 = import ./versions/3.1.nix (buildAttrs // { icu = icu70; });
  dotnet_6_0 = import ./versions/6.0.nix (buildAttrs // { inherit icu; });
  dotnet_7_0 = import ./versions/7.0.nix (buildAttrs // { inherit icu; });
in
rec {
  inherit systemToDotnetRid;

  combinePackages = attrs: callPackage (import ./combine-packages.nix attrs) {};

  # EOL
  sdk_2_1 = throw "Dotnet SDK 2.1 is EOL, please use 6.0 (LTS) or 7.0 (Current)";
  sdk_2_2 = throw "Dotnet SDK 2.2 is EOL, please use 6.0 (LTS) or 7.0 (Current)";
  sdk_3_0 = throw "Dotnet SDK 3.0 is EOL, please use 6.0 (LTS) or 7.0 (Current)";
  sdk_5_0 = throw "Dotnet SDK 5.0 is EOL, please use 6.0 (LTS) or 7.0 (Current)";
} // dotnet_3_1 // dotnet_6_0 // dotnet_7_0
