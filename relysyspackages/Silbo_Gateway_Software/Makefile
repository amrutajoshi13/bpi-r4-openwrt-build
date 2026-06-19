include $(TOPDIR)/rules.mk

PKG_NAME:=Silbo_Gateway_Software
PKG_RELEASE:=1.20_RC2

include $(INCLUDE_DIR)/package.mk

#LDFLAGS = -llibc -lconfig -lmosquitto -lssl -lresolv -lpthread  -lcrypto

define Package/Silbo_Gateway_Software
    SECTION:=utils
    CATEGORY:=RelySys Packages
    DEPENDS:=+busybox +libconfig +libmosquitto +libopenssl +libmodbus +libcurl +libsqlite3 +libuuid +libuci +libjson-c +libc
    TITLE:=InterfaceManager scripts
endef

define Package/Silbo_Gateway_Software/description
InterfaceManager scripts for interface monitoring
endef

define Build/Compile
endef

define Package/Silbo_Gateway_Software/install
	$(CP) ./files/* $(1)
	#ln -sf /home/amurtha/Build/Test_build/Test_build-master/build_dir/toolchain-mipsel_24kc_gcc-7.5.0_musl/musl-1.1.24/lib/libc.so $(1)/lib/libc.so.6
endef

$(eval $(call BuildPackage,Silbo_Gateway_Software,+libopenssl))
