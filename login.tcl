#!/usr/bin/env tclsh8.5
#
# Yate Script: login example
#
# Author: Ben Fuhrmannek <bef@eventphone.de>
# Date: 2012-09-21
#
# Copyright (c) 2012, Ben Fuhrmannek
# All rights reserved.
# 
#
# example regexroute.conf entry:
# ^81$=external/nodata/login.tcl
#

## CONFIGURATION
## manually set custom soundpath and soundformats here instead of yate.conf section [ygi]
#set ::ygi::config(sndpath) {/usr/local/share/yate/sounds/ast}
#set ::ygi::config(sndformats) {slin}

## YGI setup
set auto_path [linsert $auto_path 0 [file dirname $::argv0]]
package require ygi

## start message handler 
::ygi::start_ivr

## debugging
#::ygi::print_env
#set ::ygi::debug true

## play beep and wait for the audio to come through properly
::ygi::play_wait "beep"
::ygi::sleep 500

## LOGIN

set secret "1234"
set loggedin false
for {set i 0} {$i < 3} {incr i} {
	::ygi::play "enter-password"
	set input [::ygi::getdigits 10]
	if {[join $input ""] eq $secret} {
		set loggedin true
		break
	}
	::ygi::log "INVALID PASSWORD FROM CALLER ${::ygi::env(caller)}"
	::ygi::play_wait "beeperr"
}
if {!$loggedin} {
	::ygi::play_wait "goodbye"
	exit
}

## some privileged business logic ...

::ygi::log "THE USER IS AUTHENTICATED."
::ygi::play_wait "welcome"


