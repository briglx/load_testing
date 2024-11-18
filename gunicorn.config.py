"""Gunicorn configuration file."""

workers = 4
bind = "0.0.0.0:5001"
# bind = "unix:/tmp/gunicorn.sock"
timeout = 30
loglevel = "info"
