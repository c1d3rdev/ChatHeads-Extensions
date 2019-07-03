THEOS_DEVICE_IP = 6s.local
ARCHS = arm64 arm64e
TARGET = iphone:clang:11.2:12.1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MHSMSSupport
MHSMSSupport_FILES = Tweak.xm
MHSMSSupport_LIBRARIES = rocketbootstrap
MHSMSSupport_FRAMEWORKS = Foundation UIKit
MHSMSSupport_PRIVATE_FRAMEWORKS = AppSupport

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall MobileSMS"
