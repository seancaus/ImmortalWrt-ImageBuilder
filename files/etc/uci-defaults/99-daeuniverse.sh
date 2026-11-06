#!/bin/sh
# 99-daeuniverse.sh - 默认添加 daeuniverse 软件源并导入签名公钥
# 仅在首次启动时执行一次
LOGFILE="/etc/config/uci-defaults-log.txt"
echo "Starting 99-daeuniverse.sh at $(date)" >> $LOGFILE

# 导入签名公钥
mkdir -p /etc/apk/keys /etc/apk/repositories.d
if [ ! -f /etc/apk/keys/daeuniverse.pem ]; then
    echo "Importing daeuniverse public key..." >> $LOGFILE
    wget -qO /etc/apk/keys/daeuniverse.pem https://openwrt.daeuniverse.org/public-key.pem
    if [ $? -eq 0 ]; then
        echo "daeuniverse public key imported" >> $LOGFILE
    else
        echo "Failed to import daeuniverse public key" >> $LOGFILE
    fi
fi

# 添加软件源
if [ ! -f /etc/apk/repositories.d/daeuniverse.list ]; then
    . /etc/openwrt_release
    FEED="https://openwrt.daeuniverse.org/$(echo "$DISTRIB_RELEASE" | cut -d. -f1-2)"
    # ImmortalWrt 内核自带 BTF，kmods 可选；这里只添加 packages 源，避免依赖 kmods
    cat > /etc/apk/repositories.d/daeuniverse.list << EOF
@daeuniverse $FEED/packages/$DISTRIB_ARCH/packages.adb
EOF
    echo "daeuniverse repository added: $FEED" >> $LOGFILE
fi

# 更新索引
apk update >> $LOGFILE 2>&1

# 默认安装 honk
if command -v apk >/dev/null 2>&1; then
    if ! apk info -e honk >/dev/null 2>&1; then
        echo "Installing honk from daeuniverse..." >> $LOGFILE
        apk add honk@daeuniverse luci-app-honk@daeuniverse luci-i18n-daeuniverse-zh-cn@daeuniverse >> $LOGFILE 2>&1
    fi
fi

exit 0
