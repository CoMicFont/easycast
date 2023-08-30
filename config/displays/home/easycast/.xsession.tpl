#!/usr/bin/env bash
xset s noblank
xset s off
xset -dpms

{{{station_config.easycast_user_home}}}/easycast/bin/open-displays&

tail -f /dev/null
