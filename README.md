## Mac Setup

- Install brew
- Trust the third-party taps once: `brew trust nikitabobko/tap felixkratz/formulae` (untrusted taps are gated)
- Use `brew bundle install --file=Brewfile` (or the `brew-install` helper) to install all packages.
- Run up script to link dotfiles into place

## Linux Setup
- TBC

### Audio device test

After running `./up.sh`, use `~/.local/bin/find-audio-device.sh` to list ALSA
playback devices and play a two-second test tone on each. It requires `aplay`
and `speaker-test` from your distribution's `alsa-utils` package. Press Ctrl+C
to stop the test.

