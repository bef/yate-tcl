#!/usr/bin/env tclsh
#
# Yate CLI Script: generate scripted call from command line
#
# Author: Ben Fuhrmannek <bef@eventphone.de>
# Date: 2018-08-28
#
# Copyright (c) 2018, Ben Fuhrmannek
# All rights reserved.
#

set auto_path [linsert $auto_path 0 [file dirname $::argv0]]
package require ygi

## process command line
lassign $argv targetA
set soundfiles [lrange $argv 1 end]
puts "calling $targetA to play: $soundfiles"

if {$targetA eq "" || $soundfiles eq ""} {
	puts "usage: $::argv0 <target> <soundfiles...>"
	exit 1
}

set callerno {***}
if {[info exists ::env(CID)]} { set callerno $::env(CID) }


## init

set fd [::ygi::start_tcp 127.0.0.1 5039]
set ::ygi::onexit {catch {close $::fd}}
#set ::ygi::debug true

::ygi::connect global
::ygi::log "generating scripted call to $targetA"


## calling target

set success [::ygi::msg call.execute callto dumb/ target $targetA caller $callerno]
if {!$success} { ::ygi::_exit }

array set ::ygi::env $::ygi::lastresult(kv)

::ygi::install "chan.notify" ::ygi::_notify_handler 100 targetid $::ygi::env(id)
::ygi::install "chan.dtmf" ::ygi::_dtmf_handler 100 id $::ygi::env(id)
::ygi::install "chan.hangup" ::ygi::_hangup_handler 100 id $::ygi::env(id)

## trick ygi into behaving like a channel role instead of global
rename ::ygi::msg ::ygi::_msg
proc ::ygi::msg {name args} {
	return [::ygi::_msg chan.masquerade message $name id $::ygi::env(id) {*}$args]
}


## example script: play sound files.

::ygi::play_wait "yintro" 
foreach fn $soundfiles {
	::ygi::play_wait $fn
}

##

::ygi::_msg call.drop id $::ygi::env(id)

::ygi::_exit
::ygi::loop_forever

