include $(TOPDIR)/rules.mk

PKG_NAME:=Silbo_TCP_Slave
PKG_RELEASE:=1.24

include $(INCLUDE_DIR)/package.mk

#LDFLAGS = -llibc -lconfig -lmosquitto -lssl -lresolv -lpthread  -lcrypto

define Package/Silbo_TCP_Slave
    SECTION:=utils
    CATEGORY:=RelySys Packages
    DEPENDS:=+libconfig +libmosquitto +libmodbus +libsqlite3 +libcurl
    TITLE:=InterfaceManager scripts
endef

define Package/Silbo_TCP_Slave/description
Silbo_TCP_Slave
endef

define Build/Compile
endef

define Package/Silbo_TCP_Slave/install
$(CP) ./files/* $(1)
endef

$(eval $(call BuildPackage,Silbo_TCP_Slave,+libopenssl))
