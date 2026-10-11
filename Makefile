PKG_NAME:=babelroutes
PKG_VERSION:=1.0.1
PKG_RELEASE:=1
PKGARCH:=all

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/package.mk

define Package/babelroutes
  SECTION:=net
  CATEGORY:=Network
  MAINTAINER:=Josh Samuelson <josh@km7hai.com>
  TITLE:=Babel installed-route metrics JSON API
  URL:=https://github.com/km7hai/babelroutes
endef

define Package/babelroutes/description
  Adds /a/babelroutes, which publishes this node's installed Babel
  IPv4 host-route metrics from dump-installed-routes (mesh table 20).
endef

define Package/babelroutes/install
	$(INSTALL_DIR) $(1)/app/main
	$(INSTALL_DATA) ./files/app/main/babelroutes.ut $(1)/app/main/babelroutes.ut
endef

define Package/babelroutes/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] && exit 0
/etc/init.d/uhttpd restart >/dev/null 2>&1 || true
exit 0
endef

define Build/Compile
endef

$(eval $(call BuildPackage,babelroutes))
