# QuickLookAddict
A QuickLook plugin that lets you view subtitles `.srt` files

![qladdict](https://cloud.githubusercontent.com/assets/10502887/24962343/00414f34-1f9c-11e7-9182-e5ffd74a4b59.png)

## Installation

### Homebrew
```bash
brew cask install qladdict
```

### Manually

- [Download the latest version of QuickLookAddict](https://github.com/tattali/QLAddict/releases/latest)
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

Add your `.css` file

```bash
open ~/Library/QuickLook/QLAddict.qlgenerator/Contents/Resources/
```
