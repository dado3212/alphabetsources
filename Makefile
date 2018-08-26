ARCHS = armv7 armv7s arm64

THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222

FINALPACKAGE = 0
#DEBUG = 1

# SDKVERSION = 10.2
# TARGET = iphone:10.2
# TARGET_IPHONEOS_DEPLOYMENT_VERSION = 10.2

include theos/makefiles/common.mk

ADDITIONAL_CFLAGS = -Wno-unused-function -Wno-unused-variable

TWEAK_NAME = AlphabetSources
AlphabetSources_FILES = Tweak.xm
AlphabetSources_FRAMEWORKS = UIKit
AlphabetSources_LIBRARIES = substrate
AlphabetSources_CFLAGS = -fobjc-arc
AlphabetSources_LDFLAGS += -Wl,-segalign,4000

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Cydia"
