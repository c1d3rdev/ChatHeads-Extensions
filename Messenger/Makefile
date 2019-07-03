THEOS_DEVICE_IP = 6s.local
ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:11.2


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MHFBSupport
MHFBSupport_FILES = Tweak.xm
MHFBSupport_LIBRARIES = rocketbootstrap
MHFBSupport_FRAMEWORKS = Foundation UIKit
MHFBSupport_PRIVATE_FRAMEWORKS = AppSupport


include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Messenger"
