#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# Copyright (C) 2003-2004 Edgewall Software
# Copyright (C) 2003-2004 Jonas Borgstro"m <jonas@edgewall.com>
# All rights reserved.
#
# This software is licensed as described in the file COPYING, which
# you should have received as part of this distribution. The terms
# are also available at http://trac.edgewall.org/wiki/TracLicense.
#
# This software consists of voluntary contributions made by many
# individuals. For the exact contribution history, see the revision
# history and logs, available at http://trac.edgewall.org/log/.
#
# Author: Jonas Borgstrom <jonas@edgewall.com>

try:
	import os
	os.environ['TRAC_ENV'] = "/home/qufotoc/trac_env1"
	from trac.web import cgi_frontend
	cgi_frontend.run()
except SystemExit:
	raise
except Exception, e:
	import sys
	import traceback

	print>>sys.stderr, e
	traceback.print_exc(file=sys.stderr)

	print 'Status: 500 Internal Server Error'
	print 'Content-Type: text/plain'
	print
	print 'Oops...'
	print
	print 'Trac detected an internal error:', e
	print
	traceback.print_exc(file=sys.stdout)
