# amiga-noclick
[![License](https://img.shields.io/github/license/islandcontroller/amiga-noclick)](LICENSE)

*Activates silent disk presence checking on your Amigaaaaaaaaaaaaaaaaaa*

## Building

* Requires AsmPro from [`AsmPro1.21`](https://aminet.net/package/dev/asm/ASMPro1.21)
* Requires headers from [`AsmPro1.21src`](https://aminet.net/package/dev/asm/ASMPro1.21src) installed in `AsmPro:include/`
* Open `noclick.S` in AsmPro and assemble with `ao`, then export the binary with `wo`.

## Usage
Run the program from a shell. 

> [!NOTE]
> Check compatibility with your drive before adding it to your `User-Startup`! Do not use this tool if it causes the drive to behave unexpectedly.

## Licensing

If not stated otherwise, the contents of this project are licensed under The MIT License. The full license text is provided in the [LICENSE](LICENSE) file.

    SPDX-License-Identifier: MIT

## Acknowledgements

This program was inspired by Patrik Axelsson's [NoClick](https://aminet.net/package/disk/misc/NoClick).