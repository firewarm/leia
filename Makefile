ARCHS = arm64 arm64e
TARGET = iphone:clang::13.4
THEOS_DEVICE_IP = 192.168.178.13

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Leia

Leia_FILES = Tweak.x
Leia_CFLAGS = -fobjc-arc
Leia_FRAMEWORKS = UIKit AudioToolbox

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += prefs
include $(THEOS_MAKE_PATH)/aggregate.mk