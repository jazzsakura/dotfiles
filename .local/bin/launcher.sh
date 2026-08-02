#!/bin/bash
TMPFILE=$(mktemp)

cleanup() {
  rm -f "$TMPFILE"
  exit 1
}

# .desktop files parse karke tmpfile mein store
for f in /usr/share/applications/*.desktop ~/.local/share/applications/*.desktop; do
  [[ -f "$f" ]] || continue
  grep -q "^NoDisplay=true" "$f" && continue
  grep -q "^Hidden=true" "$f" && continue
  name=$(grep "^Name=" "$f" | head -1 | cut -d= -f2)
  exec=$(grep "^Exec=" "$f" | head -1 | cut -d= -f2- | sed 's/%[uUfFdDnNickvm]//g' | sed 's/--$//' | sed 's/[[:space:]]*$//')
  [[ -n "$name" && -n "$exec" ]] && echo "$name|$exec" >> "$TMPFILE"
done

chosen=$(sort -u "$TMPFILE" | cut -d'|' -f1 | fzf --prompt=" Launch: " --reverse --border none)

if [[ -n "$chosen" ]]; then
  exec_cmd=$(awk -F'|' -v name="$chosen" '$1 == name {print $2; exit}' "$TMPFILE")
  trap cleanup INT TERM EXIT
  systemd-run --user --no-block bash -c "$exec_cmd"
else
  trap cleanup INT TERM EXIT
fi
