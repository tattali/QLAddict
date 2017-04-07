# QuickLookAddict
A QuickLook plugin that lets you view subtitles `.srt` files

## Installation
<!---
### Homebrew

	brew install qladdict
--->
### Manually

- [Download the latest version of QuickLookAddict](https://github.com/tattali/QLAddict/releases/latest)
- Unzip and move the .qlgenerator file to `~/Library/QuickLook` (Create the QuickLook folder if it doesn’t exist)
- Run `qlmanage -r`


## Theme

#### Availaible themes

addic7ed
![addic7ed](https://cloud.githubusercontent.com/assets/10502887/24529312/1665c966-15ab-11e7-8f3f-3115a65c9453.png)

addic7ed-grey
![addic7ed-grey](https://cloud.githubusercontent.com/assets/10502887/24671105/beae94fe-1970-11e7-9a4e-3475cec59d96.png)

#### Switch between themes

```bash
defaults write com.sub.QuickLookAddict style NAME_OF_THEME
```

#### Create a new theme

Add your `.css` file

```
open ~/Library/QuickLook/QuickLookAddict.qlgenerator/Contents/Resources/
```
