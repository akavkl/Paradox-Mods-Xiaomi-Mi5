ui_print " "
  ui_print "   Installing Paradox Tweaks      "
  ui_print " "

  OLD=false; NEW=false;
# GET OLD/NEW FROM ZIP NAME
case $(basename $ZIP) in
  *old*|*Old*|*OLD*) OLD=true;;
  *new*|*New*|*NEW*) NEW=true;;
esac

# Keycheck binary by someone755 @Github, idea for code below by Zappo @xda-developers
chmod 755 $INSTALLER/common/keycheck

keytest() {
  ui_print "- Vol Key Test -"
  ui_print "   Press Vol Up:"
  (/system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $INSTALLER/events) || return 1
  return 0
}

chooseport() {
  #note from chainfire @xda-developers: getevent behaves weird when piped, and busybox grep likes that even less than toolbox/toybox grep
  while (true); do
    /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $INSTALLER/events
    if (`cat $INSTALLER/events 2>/dev/null | /system/bin/grep VOLUME >/dev/null`); then
      break
    fi
  done
  if (`cat $INSTALLER/events 2>/dev/null | /system/bin/grep VOLUMEUP >/dev/null`); then
    return 0
  else
    return 1
  fi
}

chooseportold() {
  # Calling it first time detects previous input. Calling it second time will do what we want
  $INSTALLER/common/keycheck
  $INSTALLER/common/keycheck
  SEL=$?
  if [ "$1" == "UP" ]; then
    UP=$SEL
  elif [ "$1" == "DOWN" ]; then
    DOWN=$SEL
  elif [ $SEL -eq $UP ]; then
    return 0
  elif [ $SEL -eq $DOWN ]; then
    return 1
  else
    ui_print "   Vol key not detected!"
    abort "   Use name change method in TWRP"
  fi
}

ui_print " "
if ! $OLD && ! $NEW; then
  if keytest; then
    FUNCTION=chooseport
  else
    FUNCTION=chooseportold
    ui_print "   ! Legacy device detected! Using old keycheck method"
    ui_print " "
    ui_print "- Vol Key Programming -"
    ui_print "   Press Vol Up Again:"
    $FUNCTION "UP"
    ui_print "   Press Vol Down"
    $FUNCTION "DOWN"
  fi
  ui_print " "
  ui_print "- Select Version -"
  ui_print "   Choose which android version you have installed:"
  ui_print "   Vol+ = Android 8.0.x-8.1.x, Vol- = Android 7.0.x-7.1.x"
  
    if $FUNCTION; then
      NEW=true
    else
      OLD=true
fi
if $OLD; then
  ui_print "   Old will be installed"
  cp_ch $INSTALLER/custom/thermal-engine-8996-lite.conf $INSTALLER/system/etc/thermal-engine-8996-lite.conf
  cp_ch $INSTALLER/custom/thermal-engine-8996.conf $INSTALLER/system/etc/thermal-engine-8996.conf
  cp -rf $INSTALLER/custom/$ARCH/* $INSTALLER/system
  sed -i "s/version=.*/version=v034(Nougat)/" $INSTALLER/module.prop
  else
    ui_print "   New will be installed"
  cp_ch $INSTALLER/custom/thermal-engine-8996-lite.conf $INSTALLER/system/vendor/etc/thermal-engine-8996-lite.conf
  cp_ch $INSTALLER/custom/thermal-engine-8996.conf $INSTALLER/system/vendor/etc/thermal-engine-8996.conf
  cp -rf $INSTALLER/custom/$ARCH/* $INSTALLER/system/vendor
sed -i "s/version=.*/version=v034(Oreo)/" $INSTALLER/module.prop
fi
fi
