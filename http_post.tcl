#!/usr/bin/env tclsh8.5
#
# Yate Script: HTTP POST request
#
# Author: Ben Fuhrmannek <bef@eventphone.de>
# Date: 2013-12-28
#
# Copyright (c) 2013, Ben Fuhrmannek
# All rights reserved.
# 
#
# example regexroute.conf entry:
# ^84$=external/nodata/http_post.tcl;url=...;query=...
#

set auto_path [linsert $auto_path 0 [file dirname $::argv0]]
package require ygi

::ygi::script_timeout 5
::ygi::start_ivr

## debugging
#::ygi::print_env
#set ::ygi::debug true

if {![info exists ::ygi::env(url)]} {
	::ygi::log "ERROR: url parameter missing"
	exit 1
}

::ygi::log "POST to $::ygi::env(url) for $::ygi::env(caller)"

after 1 {
	package require http
	package require tls
	::http::register https 443 ::tls::socket
	::ygi::log $::ygi::env(query)
	::http::geturl $::ygi::env(url) -method POST -query $::ygi::env(query)
	exit 0
}

::ygi::loop_forever


