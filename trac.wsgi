# vim: ft=python

import os
from trac.web.main import dispatch_request


def set_env(key, value):
    if key not in os.environ:
        os.environ[key] = value

set_env('TRAC_ENV', '/var/www/localhost/trac')

def application(environ, start_response):
    return dispatch_request(environ, start_response)
