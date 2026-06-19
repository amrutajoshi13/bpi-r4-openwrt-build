include $(TOPDIR)/rules.mk

PKG_NAME:=connectionDiagnostics
PKG_RELEASE:=1.02

include $(INCLUDE_DIR)/package.mk

#LDFLAGS = -llibc -lconfig -lmosquitto -lssl -lresolv -lpthread  -lcrypto

define Package/connectionDiagnostics
    SECTION:=utils
    CATEGORY:=RelySys Packages
    DEPENDS:=+libuci +libstdcpp +libmosquitto +libsqlite3 
    TITLE:=InterfaceManager scripts
endef

define Package/connectionDiagnostics/description
connectionDiagnostics for interface monitoring
endef

define Build/Compile
endef

define Package/connectionDiagnostics/install
$(CP) ./files/* $(1)
endef

$(eval $(call BuildPackage,connectionDiagnostics,+libopenssl))
