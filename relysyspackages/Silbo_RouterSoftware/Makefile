include $(TOPDIR)/rules.mk

PKG_NAME:=Silbo_RouterSoftware
PKG_RELEASE:=1.19.3

include $(INCLUDE_DIR)/package.mk

#LDFLAGS = -llibc -lconfig -lmosquitto -lssl -lresolv -lpthread  -lcrypto

define Package/Silbo_RouterSoftware
    SECTION:=utils
    CATEGORY:=RelySys Packages
    DEPENDS:=+busybox +libconfig +libmosquitto +libopenssl +libsqlite3 +libstdcpp +libubus +libuci +libubox +libmodbus +libjson-c
    TITLE:=InterfaceManager scripts
endef

define Package/Silbo_RouterSoftware/description
InterfaceManager scripts for interface monitoring
endef

define Build/Compile
endef

define Package/Silbo_RouterSoftware/install
$(CP) ./files/* $(1)
endef

$(eval $(call BuildPackage,Silbo_RouterSoftware,+libopenssl))
