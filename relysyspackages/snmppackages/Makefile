include $(TOPDIR)/rules.mk

PKG_NAME:=snmppackages
PKG_RELEASE:=1.2

include $(INCLUDE_DIR)/package.mk

#LDFLAGS = -llibc -lconfig -lmosquitto -lssl -lresolv -lpthread  -lcrypto

define Package/snmppackages
    SECTION:=utils
    CATEGORY:=RelySys Packages
    TITLE:=snmppackages
endef

define Package/snmppackages/description
InterfaceManager scripts for interface monitoring
endef

define Build/Compile
endef

define Package/snmppackages/install
$(CP) ./files/* $(1)
endef

$(eval $(call BuildPackage,snmppackages))
