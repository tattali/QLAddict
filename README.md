# QuickLookAddict
A QuickLook plugin that lets you view subtitles `.srt` files

![qladdict](https://cloud.githubusercontent.com/assets/10502887/26023744/72beaed2-37c3-11e7-8adc-6fac4e0d780a.png)

## Installation

### Homebrew
```bash
# To install
brew cask install qladdict

# To update
brew cask reinstall qladdict
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
