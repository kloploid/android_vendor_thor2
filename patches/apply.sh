#!/usr/bin/env bash
# Applies thor2's patches to a LineageOS source tree:
#
#   vendor/thor2/patches/apply.sh [path to the tree, default: the current directory]
#
# patches/<project>/ holds the patches for one repository, with "/" in its path written as "_"
# (frameworks_base -> frameworks/base). Each is applied with `git am`, in order. A patch whose
# subject is already in that repository's recent history is skipped, so this is safe to run
# again after every `repo sync` (which drops them) or without one (when they're still there).
set -euo pipefail

ROOT="$(cd "${1:-.}" && pwd)"
PATCHES="$(cd "$(dirname "$0")" && pwd)"
G=(git -c safe.directory='*')

for dir in "$PATCHES"/*/; do
    name="$(basename "$dir")"
    project="$ROOT/${name//_//}"
    [ -d "$project" ] || { echo "no $project, skipping $name" >&2; continue; }
    recent="$("${G[@]}" -C "$project" log --format=%s -200)"
    for patch in "$dir"*.patch; do
        # git mailinfo unfolds a subject wrapped over several lines and drops "[PATCH n/m]".
        subject="$("${G[@]}" mailinfo /dev/null /dev/null < "$patch" | sed -n 's/^Subject: //p')"
        if grep -qxF -- "$subject" <<<"$recent"; then
            echo "already applied: ${name//_//} $(basename "$patch")"
            continue
        fi
        echo "applying: ${name//_//} $(basename "$patch")"
        "${G[@]}" -C "$project" am --3way --keep-cr "$patch"
    done
done
