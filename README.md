# Intro
`doomemacs` rocks but sometimes it doesn't work out of the box. This repos is trying to fix the problem of `doomemacs` that needs to be solved upstream.

# Problems
* `basedpyright` doesn't work in `doomemacs` but it works in vanilla `emacs`.
* `treesitter` doesn't work in `linux/arm`. `treesitter` has been integrated in recent versions of `emacs` but `doomemacs` needs to continue to use `treesitter` from GitHub to support the older version of emacs.

# Structure
This repo has two branches.
* master is the fork of doomemacs
* doomdir is the content of `~/.doom.d`
