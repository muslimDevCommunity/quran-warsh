بسم الله الرحمن الرحيم
la ilaha illa Allah Mohammed Rassoul Allah

<img src="quran-warsh.svg" alt="logo" width="200">
this is a desktop app for مصحف التجويد الملون

the files were got from [Tajweed Quran - دار المعرفة](https://easyquran.com/ar/) from [these links](https://easyquran.com/wp-content/uploads/2022/10/1-scaled.jpg)

![screenshots](application-pictures.png?raw=true)

# building
install `zig 0.13`
run the command `zig build` which puts the resulted binary in `zig-out`
and `zig build run` to run the app

# Usage
- `<-` left arrow: next page
- `->` right arrow: previous page
- `Shift`+`<-`: goto next surah
- `Shift`+`->`: goto previous surah
- `Ctrl`+`<-`: goto next hizb (حزب)
- `Ctrl`+`->`: goto previous hizb (حزب)
- `0-9`: goto bookmark
- `Shift`+`0-9`: set bookmark to current page

## dependencies
known dependencies are `csfml`

`main.zig` is replaced with `bismi_allah.zig`

