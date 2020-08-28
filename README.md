# Dotfiles for Wes

This repo is dedicated to storing my dotfiles. Yay!

I use [yadm](https://yadm.io/), a great Dotfiles management tool. This repo requires it.


## Bootstrap

First, install yadm:

```
$ curl -fLo /usr/local/bin/yadm https://github.com/TheLocehiliosan/yadm/raw/master/yadm && chmod a+x /usr/local/bin/yadm
```

Then, clone dotfiles:
```
$ yadm clone https://github.com/westhomas/dotfiles.git
```

You will be prompted to bootstrap. Choose `y` to continue the setup process. You will then be prompted to choose your environment mode.

`Developer` mode will install a bunch of stuff during bootstrap. It will install a bunch of stuff.

`Remote` mode will simply install shell goodies necessary for a pleasant shell experience.


## Other stuff

If you ever wish to change your environment mode, just run bootstrap again:

```
$ ~/.config/yadm/bootstrap
```

