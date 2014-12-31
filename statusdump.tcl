#!/usr/bin/env tclsh
#
# CLI Script: dump engine.status in human readable form
#
# Author: Ben Fuhrmannek <bef@eventphone.de>
# Date: 2014-12-31
#
# Copyright (c) 2014, Ben Fuhrmannek
# All rights reserved.

package require Tcl 8.5
set auto_path [linsert $auto_path 0 [file dirname $::argv0]]
package require ygi 0.3

set fd [::ygi::start_tcp 127.0.0.1 5039]
set ::ygi::onexit {catch {close $::fd}}

::ygi::connect global

foreach {info stats details} [::ygi::get_status] {
	set statsstring [join [lmap {k v} $stats {format "%s=%s" $k $v}] " / "]
	puts [format "==> %s \[%s\]  | %s" [dict get $info name] [dict get $info type] $statsstring]

	foreach {k v} $info {
		if {[lsearch -exact {name type format} $k] >= 0} { continue }
		puts "    $k -> $v"
	}

	if {$details eq "" || ![dict exists $info format]} { continue }
	foreach {id entry} $details {
		puts "  # $id: $entry"
	}
}
