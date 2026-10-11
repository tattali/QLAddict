# QuickLookAddict

> [!WARNING]
> **This project is no longer maintained and will not be updated.**
>
> QLAddict is a Quick Look generator plugin (`.qlgenerator`). Apple has deprecated this kind of plugin in favour of Quick Look app extensions, and recent macOS versions no longer run it: users have reported it not working on macOS Catalina ([#6](https://github.com/tattali/QLAddict/issues/6), [#21](https://github.com/tattali/QLAddict/issues/21)), Big Sur ([#17](https://github.com/tattali/QLAddict/issues/17)), Sonoma ([#20](https://github.com/tattali/QLAddict/issues/20)) and macOS 26.2 Tahoe ([#22](https://github.com/tattali/QLAddict/issues/22)). The Homebrew cask has been deprecated as well. Supporting current macOS would mean rewriting it as a Quick Look app extension, which is not planned.
>
> The repository stays available, read-only, for reference. Thank you to everyone who used QLAddict, reported issues and contributed themes and fixes over the years.

[![GitHub release](https://img.shields.io/github/release/tattali/QLAddict.svg)](https://github.com/tattali/QLAddict/releases/latest)
[![Github Downloads](https://img.shields.io/github/downloads/tattali/QLAddict/total.svg)](https://github.com/tattali/QLAddict/releases/latest)

A QuickLook plugin that lets you view subtitles `.srt` files

![qladdict](/assets/default.png)

## Installation

### Homebrew
```bash
# To install
brew cask install qladdict

# To update
brew update && brew cask reinstall qladdict
```

### Manually

- [Download the latest version of QLAddict](https://github.com/tattali/QLAddict/releases/latest)
- Unzip and move the .qlgenerator file to `~/Library/QuickLook` (Create the folder if it doesn’t exist)
- Run `qlmanage -r` in Terminal

#### Catalina

Inspired by [this](https://github.com/sindresorhus/quick-look-plugins/issues/115#issuecomment-547334394) post, a process for this bundle could be:

[Download the latest version of QLAddict](https://github.com/tattali/QLAddict/releases/latest) and unzip
```
$ mv ~/Downloads/QLAddict.qlgenerator ~/Library/QuickLook/QLAddict.qlgenerator
$ xattr -rd com.apple.quarantine  ~/Library/QuickLook/QLAddict.qlgenerator
$ qlmanage -r
```
_try `xattr` without `sudo`, but you can use it if needed_

**Tell me in [this](https://github.com/tattali/QLAddict/issues/6) issue if this process work fine to you, if you need to use sudo or not, if you need to do extra work**
Thank you !

## Settings

### Theme

See [all available themes](available-themes.md)

#### Switch between themes

```bash
defaults write com.sub.QLAddict theme NAME_OF_THEME
```

#### Create a new theme

Add your `.css` file in lowercase title then create a pull request to share it with others

```bash
open ~/Library/QuickLook/QLAddict.qlgenerator/Contents/Resources/themes/
```
