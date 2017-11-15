#! /bin/sh

. ./common.inc

ticket_file=$(mktemp "$TICKETS_DIR/ticket-XXXXXXXXXX")
[ -e "$ticket_file" ] || exit 1
basename "$ticket_file"
