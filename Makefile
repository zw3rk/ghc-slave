LIBS=android/app/src/main/jniLibs
ARM64=arm64-v8a
ARM32=armeabi-v7a

${LIBS}/${ARM32}/iconv: ${ICONV}/arm-linux-androideabi/lib/libiconv.so ${ICONV}/arm-linux-androideabi/lib/libcharset.so
	@mkdir -p $(@D)
	cp $^ $(@D)

${LIBS}/${ARM64}/iconv: ${ICONV}/aarch64-linux-android/lib/libiconv.so ${ICONV}/aarch64-linux-android/lib/libcharset.so
	@mkdir -p $(@D)
	cp $^ $(@D)

${LIBS}/${ARM64}/libGHCSlave.so: hs/LineBuff.hs android/app/src/main/cpp/Dummy.c # android/app/src/main/cpp/GHCSlave.c
	@mkdir -p $(@D)
	@mkdir -p build
	aarch64-none-linux-android-ghc -o $@ $^ \
		-shared -threaded -debug -fllvm \
		-outputdir build/arm64-v8a \
		-stubdir . \
		-lHSrts_thr_debug -lCffi -lm -lc -llog -liconv -lcharset \
	 	-package iserv-bin

${LIBS}/${ARM32}/libGHCSlave.so: hs/LineBuff.hs android/app/src/main/cpp/Dummy.c # android/app/src/main/cpp/GHCSlave.c
	@mkdir -p $(@D)
	@mkdir -p build
	armv7-none-linux-androideabi-ghc -o $@ $^ \
		-shared -threaded -debug -fllvm \
		-outputdir build/armeabi-v7a \
		-stubdir . \
		-lHSrts_thr_debug -lCffi -lm -lc -llog -liconv -lcharset \
	 	-package iserv-bin

# Note: -all_load is needed to pull the iserv-bin archive into the dylib!
libGHCSlave.dylib: hs/LineBuff.hs
	aarch64-apple-darwin14-ghc -o $@ $^ \
		-shared -threaded -debug -fllvm \
		-outputdir build/arm64-ios \
		-stubdir . \
		-lHSrts_thr -lCffi -lm -lc -liconv -lcharset \
		-package iserv-bin \
		-optl-all_load

.phony:
android: ${LIBS}/${ARM32}/libGHCSlave.so ${LIBS}/${ARM32}/iconv ${LIBS}/${ARM64}/libGHCSlave.so ${LIBS}/${ARM64}/iconv

.phony:
ios: libGHCSlave.dylib

.phony:
clean:
	rm -fR build
	rm -fR ${LIBS}
	rm -f libGHCSlave.dylib
