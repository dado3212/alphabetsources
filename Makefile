ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = AlphabetSources
AlphabetSources_FILES = Tweak.xm
AlphabetSources_FRAMEWORKS = UIKit
AlphabetSources_LIBRARIES = substrate
AlphabetSources_CFLAGS = -fobjc-arc
AlphabetSources_LDFLAGS += -Wl,-segalign,4000

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Cydia"
