#!/bin/sh
sh $(dirname $0)/../../bin/reown $(dirname "$0") $1 $(whoami)
