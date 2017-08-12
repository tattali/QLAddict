# QuickLookAddict
[![GitHub release](https://img.shields.io/github/release/tattali/QLAddict.svg)](https://github.com/tattali/QLAddict/releases/latest)
[![Github Downloads](https://img.shields.io/github/downloads/tattali/QLAddict/total.svg)](https://github.com/tattali/QLAddict/releases/latest)

A QuickLook plugin that lets you view subtitles `.srt` files

![qladdict](https://user-images.githubusercontent.com/10502887/29235459-4c4e6bce-7eff-11e7-8417-b8f9d3415b9d.png)

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


## Settings

### Theme

See [all available themes](available-themes.md)

#### Switch between themes

```bash
defaults write com.sub.QLAddict theme NAME_OF_THEME
```

#### Create a new theme

Add your `.css` file in lowercase title

```bash
open ~/Library/QuickLook/QLAddict.qlgenerator/Contents/Resources/themes/
```
