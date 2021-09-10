#!/bin/bash -e
#
# build.sh

base=$(git rev-parse --show-toplevel)

/bin/echo -e '\x1b[32mChanged packages:\x1b[0m'
git diff-tree -r --no-renames --name-only --diff-filter=AM \
	$(git rev-list -1 --parents HEAD) \
	-- "$base/srcpkgs/*/template" |
	cut -d/ -f 2 |
	tee /tmp/templates |
	sed "s/^/  /" >&2

ls -la $base
cat $base/srcpkgs/*/template

PKGS=$("$base/void-packages/xbps-src" sort-dependencies $(cat /tmp/templates))

for pkg in ${PKGS}; do
	"$base/void-packages/xbps-src" -j$(nproc) pkg "$pkg"
	[ $? -eq 1 ] && exit 1
done

exit 0
