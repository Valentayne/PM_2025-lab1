#!/bin/sh
set -e

# echo "Initializing database..."
# python3 - << 'EOF'
# from app import init_db
# init_db()
# EOF

echo "Starting application..."
exec gunicorn -w 4 -b 0.0.0.0:$PORT wsgi:app
