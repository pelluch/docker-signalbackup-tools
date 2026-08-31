#!/bin/sh
set -eu

if [ -n "${SIGNAL_PASSPHRASE_FILE:-}" ]; then
  [ -r "$SIGNAL_PASSPHRASE_FILE" ] \
    || { echo "ERROR: SIGNAL_PASSPHRASE_FILE is unreadable: $SIGNAL_PASSPHRASE_FILE" >&2; exit 1; }
  passphrase="$(cat "$SIGNAL_PASSPHRASE_FILE")"   # $() strips the trailing newline
  [ -n "$passphrase" ] \
    || { echo "ERROR: SIGNAL_PASSPHRASE_FILE is empty: $SIGNAL_PASSPHRASE_FILE" >&2; exit 1; }
  set -- "$@" --passphrase "$passphrase"
fi

exec signalbackup-tools "$@"
