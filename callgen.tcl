#!/usr/bin/env tclsh
#
# Yate CLI Script: generate call from command line
#
# Author: Ben Fuhrmannek <bef@eventphone.de>
# Date: 2014-11-25
#
# Copyright (c) 2014, Ben Fuhrmannek
# All rights reserved.
#

set auto_path [linsert $auto_path 0 [file dirname $::argv0]]
package require ygi 0.2

lassign $argv targetA targetB
if {$targetA eq "" || $targetB eq ""} {
	puts "usage: $::argv0 <A> <B>"
	exit 1
}

set fd [::ygi::start_tcp 127.0.0.1 5039]
set ::ygi::onexit {catch {close $::fd}}
#set ::ygi::debug true

::ygi::connect global
::ygi::log "Call generator"

lassign [::ygi::callgen $targetA $targetB] success
if {!$success} {
	puts stderr "problem. callgen failed. $targetA -/-> $targetB"
} else {
	puts "success."
}

::ygi::_exit
::ygi::loop_forever

