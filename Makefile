include theos/makefiles/common.mk

TWEAK_NAME = EasyMaMaFaceTime
EasyMaMaFaceTime_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

ARCH = armv7 arm64
TARGET = iPhone:8.4:7.0

after-install::
	install.exec "killall -9 FaceTime"

EasyMaMaFaceTime_FRAMEWORKS = UIKit
THEOS_DEVICE_IP = localhost