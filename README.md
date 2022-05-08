# bash-profile-switcher
Easily change environment variables and settings using bash

## About

This script aim to manage multiple profile files for bash. It's like having multiple `.bashrc` files to load or unload when needed.  
All you need to do is to create your custom profile files under `~/.bash_profiles` directory. Each profile must have extension `.load` where you define variables, aliases and so on. You can optionally create files with extension `.unload` to clear what is loaded with a speficic profile.
## Installation

Copy `bash_profile_switcher.sh` script in your homedir and source it at the end of your `~/.bashrc`. Reload your shell or close terminal.
## Usage
Use `switch_profile` function to manage profiles
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

PROFILE
  A profile to load in ~/.bash_profiles. Profile files end with extension '.load' for loading (set variables) and '.unload' for unloading (unset variables)
  Current profile is stored in environment variable BASH_CURRENT_PROFILE and in file ~/.bash_saved_profile

Example:

  ~]$ switch_profile dev

  To load profile dev from ~/.bash_profiles/dev.load and unload it from ~/.bash_profiles/dev.unload
```
## Example

Create the following profile files in `~/.bash_profiles`:  
> `myprofile.load`
```bash
export PS1="Funky Prompt:: \w ]\\$ "
```   
> `myprofile.unload`
```bash
unset PS1
```
Then load it with: `switch_profile myprofile`
## Issues

* Spaces and blank characters are not supported on profile filenames
* Unload files must be written manually to match exactly what you loaded or defined
* Be careful when managing special variables like `PATH`
