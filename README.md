# bash-profile-switcher ![CI](https://github.com/gianluca-mascolo/bash-profile-switcher/actions/workflows/ci.yml/badge.svg)
Easily change environment variables and settings using bash

## About

This script aim to manage multiple profile files for bash. It's like having multiple `.bashrc` files to load or unload when needed.
You need to create your custom profile files under `~/.bash_profile.d` directory. Each profile must have extension `.profile` and it is a plain text file containing a list of "snippets" (one per line) to be loaded into your profile.
Snippets are `.sh` files where you can set variables/aliases/functions or any command you want to execute when you spawn a shell ([snippet example](examples/snippet-example.sh)).

## Installation

Use `make install`. It will install `bash_profile_switcher.sh` in `~/.bash_profile_switcher` and source it in your `~/.bashrc`. Reload your shell or open a new terminal to use it.<br>
_Note_: You can use `make install INSTALL_PATH=<path>` to install the script in a custom path.

## Usage

Use `switch_profile` function to change profile

```
 ~]$ switch_profile -h
switch_profile [options] profile

OPTIONS
  -k
    Keep env. Load selected profile without unloading current environment.
  -d
    Don't load profile. Unload current profile and don't load any profile in new bash shells
  -t
    Temporary profile. Load selected profile in current shell without starting it in new bash shells
  -l
    List available profiles
  -h Show help instructions (this help)
```

## Example

As an example take the following directory structure for `~/.bash_profile.d`
```
.bash_profile.d/
├── foo.profile
├── bar.profile
└── snippets
    ├── tools.sh
    ├── cloudvars.sh
    └── setpath.sh
```

```
]$ cat ~/.bash_profile.d/foo.profile
tools
cloudvars
setpath
]$ cat ~/.bash_profile.d/bar.profile
setpath
```

When you do `switch_profile foo` snippets `tools.sh`,`cloudvars.sh`,`setpath.sh` will be loaded (in the same order they are listed in profile).
On profile change `switch_profile bar` bash will first unload all the snippets applied by `foo` in reverse order then load the snippets listed in `bar`, that is `setpath.sh`
``
## Issues

* Spaces and blank characters are not supported on profile filenames
* Be careful when managing special variables like `PATH`

## Test automation

Bash command interaction is tested with `expect`. It requires the following packages to be installed:

* `expect`
* `docker`
* `docker-compose`
* `make`

To run tests locally use:
```
make clean && make test
```
