#! /bin/sh

for f_in in *.haml; do
  echo "$f_in"
  f_out=$(echo "$f_in" | sed -e 's/.haml/.html/')
  haml < "$f_in" > "$f_out"
done
