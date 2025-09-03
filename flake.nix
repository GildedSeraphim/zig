{
  description = "Vulkan Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    zig.url = "github:mitchellh/zig-overlay";
    zls.url = "github:zigtools/zls";
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        lib = nixpkgs.lib;
        zig = inputs.zig.packages.x86_64-linux.master;
        zls = inputs.zls.packages.x86_64-linux.default;
        pkgs = import nixpkgs {
          system = "${system}";
          config = {
            allowUnfree = true;
            nvidia.acceptLicense = true;
          };
        };
      in
      rec {
        devShells = {
          default = pkgs.mkShell rec {
            buildInputs = with pkgs; [
              ##################
              ### VULKAN SDK ###
              vulkan-headers
              vulkan-loader
              vulkan-validation-layers
              vulkan-tools
              vulkan-tools-lunarg
              vulkan-utility-libraries
              vulkan-extension-layer
              vulkan-volk
              vulkan-validation-layers
              spirv-headers
              spirv-tools
              spirv-cross
              mesa
              glslang
              ##################

              ####################
              ### Compat Tools ###
              xorg.libX11
              xorg.libXrandr
              xorg.libXcursor
              xorg.libXi
              xorg.libXxf86vm
              xorg.libXinerama
              wayland
              wayland-protocols
              kdePackages.qtwayland
              kdePackages.wayqt
              ####################

              #################
              ### Libraries ###
              imgui
              glfw3
              glm
              cglm
              sdl3
              tinyobjloader
              vk-bootstrap
              vulkan-memory-allocator
              #################

              #################
              ### Compilers ###
              shaderc
              gcc
              clang
              #################
            ];

            packages = with pkgs; [
              (writeShellApplication {
                name = "compile-shaders";
                text = ''
                  exec ${shaderc.bin}/bin/glslc shader.vert -o vert.spv &
                  exec ${shaderc.bin}/bin/glslc shader.frag -o frag.spv &
                  exec ${shaderc.bin}/bin/glslc point.vert -o point.vert.spv &
                  exec ${shaderc.bin}/bin/glslc point.frag -o point.frag.spv
                '';
              })
              (writeShellApplication {
                ## Lets renderdoc run on wayland using xwayland
                name = "renderdoc";
                text = "QT_QPA_PLATFORM=xcb env -u WAYLAND_DISPLAY qrenderdoc";
              })

              #############
              ### Langs ###
              zig
              zls
              #############

              #############
              ### Tools ###
              cmake
              renderdoc
              #############
            ];

            LD_LIBRARY_PATH = "${lib.makeLibraryPath buildInputs}";
            VK_LAYER_PATH = "${pkgs.vulkan-validation-layers}/share/vulkan/explicit_layer.d";
            VULKAN_SDK = "${pkgs.vulkan-validation-layers}/share/vulkan/explicit_layer.d";
            XDG_DATA_DIRS = builtins.getEnv "XDG_DATA_DIRS";
            XDG_RUNTIME_DIR = "/run/user/1000";
            STB_INCLUDE_PATH = "./headers/stb";
          };
        };
      }
    );
}
