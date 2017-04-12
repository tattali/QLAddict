# QuickLookAddict
A QuickLook plugin that lets you view subtitles `.srt` files

![qladdict](https://cloud.githubusercontent.com/assets/10502887/24962343/00414f34-1f9c-11e7-9182-e5ffd74a4b59.png)

## Installation
<!--
### Homebrew
```bash
brew install qladdict
```
-->
### Manually

- [Download the latest version of QuickLookAddict](https://github.com/tattali/QLAddict/releases/latest)
- Unzip and move the .qlgenerator file to `~/Library/QuickLook` (Create the folder if it doesn’t exist)
- Run `qlmanage -r`


## Settings

### Theme

#### Availaible themes

##### addic7ed
![addic7ed](https://cloud.githubusercontent.com/assets/10502887/24963354/a18f7c74-1f9e-11e7-8600-4047d5bfd3f6.png)

##### farran
![farran](https://cloud.githubusercontent.com/assets/10502887/24963353/a18bc3c2-1f9e-11e7-9bf8-acf900ed37c6.png)

##### addic7ed-grey
![addic7ed-grey](https://cloud.githubusercontent.com/assets/10502887/24963351/a1876cd2-1f9e-11e7-8a92-a9a095f1f464.png)

#### Switch between themes

```bash
defaults write com.sub.QuickLookAddict theme NAME_OF_THEME
```

#### Create a new theme

Add your `.css` file

```bash
open ~/Library/QuickLook/QuickLookAddict.qlgenerator/Contents/Resources/
```
