#!/usr/bin/env tclsh
#
# Yate Script: collect digits until timeout, then dial
#   -> hack for numbering schemes with variable length (or unknown length) numbers
#
# Author: Ben Fuhrmannek <bef@eventphone.de>
# Date: 2013-12-03
#
# Copyright (c) 2013, Ben Fuhrmannek
# All rights reserved.
# 
#
# example regexroute.conf entry:
# ^0.*=external/nodata/digitcollector.tcl;cut_digits=1;dialout_prefix=
#

set auto_path [linsert $auto_path 0 [file dirname $::argv0]]
package require ygi

proc bye {} {
	::ygi::quit
	exit
}

##

::ygi::idle_timeout 120 10
::ygi::script_timeout 60
::ygi::start_ivr

## we will send our own chan.disconnected message
::ygi::setlocal disconnected "true"

## debugging
# ::ygi::print_env
# set ::ygi::debug true

## collect extra digits
set digits [::ygi::getdigits digittimeout 3000 silence true maxdigits 42]
set alldigits "${::ygi::env(called)}${digits}"

if {[info exists ::ygi::env(cut_digits)]} {
	set alldigits [string range $alldigits $::ygi::env(cut_digits) end]
}
if {[info exists ::ygi::env(dialout_prefix)]} {
	set alldigits "${::ygi::env(dialout_prefix)}$alldigits"
}

## routing

set params [::ygi::filter_env id caller callername]
set success [::ygi::msg call.route {*}$params called $alldigits]
if {!$success} {
	::ygi::msg chan.disconnected id $::ygi::env(id) reason "no route" called $alldigits
	bye
}

## call.execute

set callto $::ygi::lastresult(retvalue)
set params $::ygi::lastresult(kv)
dict unset params handlers
dict set params called $alldigits

set success [::ygi::msg chan.masquerade {*}$params message call.execute callto $callto]
if {!$success} {
	::ygi::msg chan.disconnected id $::ygi::env(id) reason "call.execute failed" called $alldigits
	bye
}

exit

