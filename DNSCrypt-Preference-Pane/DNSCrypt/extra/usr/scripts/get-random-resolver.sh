#! /bin/sh

. ./common.inc

(read header; fgrep -v :: | cut -d, -f1 | egrep -v '^\s*$') \
  < "${RESOLVERS_LIST_BASE_DIR}/dnscrypt-resolvers.csv" | \
  perl -MList::Util=shuffle -e 'print shuffle(<STDIN>);' | \
  head -n1
