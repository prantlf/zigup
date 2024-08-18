# Zig Upgrader and Version Manager

Upgrades to the latest version of Zig, or manages more versions of Zig on the same machine, supporting all platforms including RISC-V, as simple es `rustup`.

* Small. Written in `bash`, easily extensible.
* Fast. Downloads and unpacks pre-built binary builds.
* Portable. Writes only to the user home directory.
* Simple. Switches the version globally, no environment variable changes needed.
* Efficient. Just run `zigup up`.

Platforms: `macos-x86_64`, `macos-aarch64`, `freebsd-x86_64`, `linux-x86`, `linux-x86_64`, `linux-aarch64`, `linux-armv7a`, `linux-powerpc64le`, `linux-riscv64`, `windows-x86`, `windows-x86_64`, `windows-aarch64`.

## Getting Started

Make sure that you have `bash` 4 or newer and `curl` available, execute the following command:

    curl -fSs https://raw.githubusercontent.com/prantlf/zigup/master/install.sh | bash

Install the latest version of Zig, if it hasn't been installed yet:

    zigup install latest

Upgrade both the installer script and the Zig language, if they're not the latest versions, and delete the previously active latest version from the disk too:

    zigup up

## Installation

Make sure that you have `bash` 4 or newer and `curl` available, execute the following command:

    curl -fSs https://raw.githubusercontent.com/prantlf/zigup/master/install.sh | bash

Both the `zigup` and `zig` should be executable in any directory via the `PATH` environment variable. The installer script will modify the RC-file of the shell, from which you launched it. The following RC-files are supported:

    ~/.bashrc
    ~/.zshrc
    ~/.config/fish/config.fish

If you use other shell or more shells, update the other RC-files by putting both the installer directory and the Zig binary directory to `PATH`, for example:

    $HOME/.zigup:$HOME/.zig:$PATH

Start a new shell after the installer finishes. Or extend the `PATH` in the current shell as the instructions on the console will tell you.

## Locations

| Path       | Description                                             |
|:-----------|:--------------------------------------------------------|
| `~/.zigup` | directory with the installer script and versions of Zig |
| `~/.zig`   | symbolic link to the currently active version of Zig    |

For example, with the Zig 1.23.0 activated:

    /home/prantlf/.zigup
      ├── 0.12.0   (another version)
      ├── 0.13.0   (linked to /home/prantlf/.zig)
      └── zigup    (installer script)

## Usage

    zigup <task> [version]

    Tasks:

      current              print the currently selected version of Zig
      latest               print the latest version of Zig for download
      local                print versions of Zig ready to be selected
      remote               print versions of Zig available for download
      update               update this tool to the latest version
      upgrade              upgrade Zig to the latest and remove the current version
      up                   perform both update and upgrade tasks
      install <version>    add the specified or the latest version of Zig
      uninstall <version>  remove the specified version of Zig
      use <version>        use the specified or the latest version of Zig
      help                 print usage instructions for this tool
      version              print the version of this tool

## Debugging

If you enable `bash` debugging, every line of the script will be printed on the console. You'll be able to see values of local variables and follow the script execution:

    bash -x zigup ...

You can debug the installer too:

    curl -fSs https://raw.githubusercontent.com/prantlf/zigup/master/install.sh | bash -x

## Contributing

In lieu of a formal styleguide, take care to maintain the existing coding style. Lint and test your code.

## License

Copyright (c) 2024 Ferdinand Prantl

Licensed under the MIT license.
