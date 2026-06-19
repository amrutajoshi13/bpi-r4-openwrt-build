include $(TOPDIR)/rules.mk

PKG_NAME:=Modbus_Package
PKG_RELEASE:=1.01

include $(INCLUDE_DIR)/package.mk

#LDFLAGS = -llibc -lconfig -lmosquitto -lssl -lresolv -lpthread  -lcrypto

define Package/Modbus_Package
    SECTION:=utils
    CATEGORY:=RelySys Packages
    DEPENDS:=+busybox +libconfig +libmosquitto +libopenssl +libmodbus +libcurl +libsqlite3 +libuuid
    TITLE:=InterfaceManager scripts
endef

define Package/Modbus_Package/description
InterfaceManager scripts for interface monitoring
endef

define Build/Compile
endef

define Package/Modbus_Package/install
$(CP) ./files/* $(1)
endef

$(eval $(call BuildPackage,Modbus_Package,+libopenssl))
