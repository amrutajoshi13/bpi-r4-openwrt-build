include $(TOPDIR)/rules.mk

PKG_NAME:=Health_monitor
PKG_RELEASE:=2.4

include $(INCLUDE_DIR)/package.mk

#LDFLAGS = -llibc -lconfig -lmosquitto -lssl -lresolv -lpthread  -lcrypto
define Package/Health_monitor
  SECTION:=utils
  CATEGORY:=RelySys Packages
  TITLE:=Health monitoring package
  DEPENDS:=+libconfig +libmodbus +libmosquitto +libsqlite3 +libcurl +libopenssl +libuci
endef

define Package/Health_monitor/description
Health monitoring package for Invendis devices.
endef

define Build/Compile
endef

# Everything inside files/root/ goes to /root/ automatically
define Package/Health_monitor/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,Health_monitor))
