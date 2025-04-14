# YACM - Yet Another Config Manager

Yacm is a config/dotfile manager that can automatically set up your config files based on a descriptive config file.

### Building

You will need V's compiler.

```sh
git clone https://github.com/jocadbz/yacm.git
cd yacm
v .
```

Or you can grab a linux build from Github's releases.

### Usage

Yacm works by reading a `.dcf` (Dumb Config File) and automatically moving the files into place.

```
// Comments are made with two slashes.
// No multiline support

conf local ~/.config/i3/config i3config
// Yacm will move the i3config file to ~/.config/i3/config

conf remote ~/.config/i3/config https://example.com/i3config
// Yacm will download i3config from the url and move it into it's designated place.

conf ssh ~/.config/i3/config user@local-server:~/i3config
// Yacm will download the file using ssh and move it into it's designated place.
```

If your path/url contains spaces (Come on, seriously?), you can use ""/'':
```
conf remote ~/.config/i3/config 'https://example.com/contains spaces/i3config'
```

All files are MIT licensed but I don't really care. This software comes with no warranty.
