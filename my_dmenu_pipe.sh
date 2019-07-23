#!/usr/bin/env bash
unset XMODIFIERS # This is set in Ubuntu and fucks up dmenu
dmenu -i -nb "#282828" -nf "#ebdbb2" -fn "Fira Code-${FONT_SIZE:-16}:medium" -sb "#b8bb26" -sf "#282828" -p " run:" <&0
