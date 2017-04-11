# ghc-slave
iserv slave for ghc

## using ghc iserv slave
assuming libiconv in `$HOME/libiconv`, and `armv7-none-android-androideabi-ghc` as well as `aarch64-none-android-android-ghc` in path, 

```
$ ICONV=$HOME/libiconv make all
```

will build `libGHCSlave.so`, and copy the `iconv` and `charset` libs into the `jniLibs` folder.

Building the android project with Android Studio should yield the expected GHC iserv salve.
