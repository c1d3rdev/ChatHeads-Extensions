THEOS_DEVICE_IP = 6s.local
ARCHS = arm64 arm64e
TARGET = iphone:clang:10.3:12.1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MHWhatsAppSupport
MHWhatsAppSupport_FILES = Tweak.xm
MHWhatsAppSupport_LIBRARIES = rocketbootstrap
MHWhatsAppSupport_FRAMEWORKS = Foundation UIKit
MHWhatsAppSupport_PRIVATE_FRAMEWORKS = AppSupport


include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 WhatsApp"
