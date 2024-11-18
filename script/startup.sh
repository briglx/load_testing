#!/bin/sh

SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)"

# Error handling that sleeps so logs are properly sent
handle_error () {
  echo "Error occurred. Sleeping to send error logs."
  # Sleep 2 seconds
  sleep 2
  exit 95
}

format_print () {
  echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") | gunicorn/run | $1"
}

format_print "Script $SCRIPT_PATH started with arguments: $*"

format_print ""
format_print "###############################################"
format_print "Runtime Information"
format_print "###############################################"
format_print ""
format_print "PATH environment variable: $PATH"
format_print "PYTHONPATH environment variable: $PYTHONPATH"
format_print ""
format_print "Pip Dependencies"
echo
pip freeze
echo
format_print ""
format_print "App directory: $APP_ROOT"
format_print ""

cd "${APP_ROOT:-/var/app}" || handle_error

format_print ""
format_print "Starting HTTP server"
format_print ""

# Start Gunicorn server
exec gunicorn -c "${APP_ROOT}/gunicorn.config.py" "wsgi:app"
