#!/sbin/sh
if [ -f "/data/misc/keystore/persistent.sqlite" ]; then
    mkdir -p /tmp/misc/keystore
    SRC_SZ=$(stat -c%s /data/misc/keystore/persistent.sqlite 2>/dev/null || echo 0)
    DST_SZ=$(stat -c%s /tmp/misc/keystore/persistent.sqlite 2>/dev/null || echo 0)
    if [ "$SRC_SZ" != "$DST_SZ" ] || [ "$DST_SZ" -lt 1000 ]; then
        cp -f /data/misc/keystore/persistent.sqlite /tmp/misc/keystore/persistent.sqlite
        chmod 0600 /tmp/misc/keystore/persistent.sqlite
        chown keystore:keystore /tmp/misc/keystore/persistent.sqlite 2>/dev/null || true
        setprop ctl.restart keystore2
        echo "DEBUG: OrangeFox: Synced persistent.sqlite and restarted keystore2 from Decrypt_DE" >> /tmp/recovery.log
        sleep 0.8
    fi
fi
