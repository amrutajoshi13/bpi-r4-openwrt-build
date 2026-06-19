include $(TOPDIR)/rules.mk

PKG_NAME:=packageManager
PKG_RELEASE:=1.00

include $(INCLUDE_DIR)/package.mk

#LDFLAGS = -llibc -lconfig -lmosquitto -lssl -lresolv -lpthread  -lcrypto

define Package/packageManager
    SECTION:=utils
    CATEGORY:=RelySys Packages
    TITLE:=InterfaceManager scripts
endef

define Package/packageManager/description
packageManager for installing IPKs externally
endef

define Build/Compile
endef

define Package/packageManager/install
$(CP) ./files/* $(1)
endef

$(eval $(call BuildPackage,packageManager,+libopenssl))
