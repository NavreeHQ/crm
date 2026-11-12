#!/usr/bin/env bash
# Points this repository's builds at a checkout of NavreeHQ/navree instead of the
# published crates and packages. It is what the `Framework main` workflow runs
# every night, and what you run to see whether a framework change breaks the CRM.
#
#   scripts/use-framework.sh ../navree [--no-build]
#
# It changes these files (`git checkout -- .` puts them back):
#   Cargo.toml                 a [patch.crates-io] block names every crate in the checkout
#                              (the CRM asks for `navree = "1"`, so any 1.x checkout fits)
#   web/pnpm-workspace.yaml    the @navree/* packages are linked from the checkout's
#   nuxt/pnpm-workspace.yaml   packages/js, which is built first unless --no-build
#
# Run `pnpm install --no-frozen-lockfile` in web and nuxt afterwards. Needs bash,
# sed and awk (Linux, macOS or WSL).
set -euo pipefail

framework="${1:?usage: scripts/use-framework.sh <path to a NavreeHQ/navree checkout> [--no-build]}"
build=1
[ "${2:-}" = "--no-build" ] && build=0
framework="$(cd "$framework" && pwd)"
cd "$(dirname "$0")/.."

[ -f "$framework/Cargo.toml" ] && [ -d "$framework/crates/navree" ] || {
  echo "$framework is not a checkout of NavreeHQ/navree" >&2
  exit 1
}
# Inside this folder, Cargo would take the framework's crates for members of the
# CRM's workspace, and they cannot inherit its dependency table.
case "$framework/" in
  "$PWD/"*)
    echo "$framework is inside the CRM's folder: check the framework out beside it, such as ../navree" >&2
    exit 1
    ;;
esac

version="$(sed -n '/^\[workspace\.package\]/,/^\[/{s/^version = "\(.*\)"/\1/p;}' "$framework/Cargo.toml" | head -1)"
[ -n "$version" ] || { echo "no version in $framework/Cargo.toml" >&2; exit 1; }

# 1. Rust: the patch block.
sed -i '/^# BEGIN framework checkout$/,/^# END framework checkout$/d' Cargo.toml
{
  echo
  echo "# BEGIN framework checkout"
  echo "[patch.crates-io]"
  for manifest in "$framework"/crates/*/Cargo.toml; do
    crate="$(dirname "$manifest")"
    grep -q '^publish = false' "$manifest" && continue
    name="$(sed -n 's/^name = "\(.*\)"/\1/p' "$manifest" | head -1)"
    echo "${name} = { path = \"${crate}\" }"
  done
  echo "# END framework checkout"
} >> Cargo.toml

# 2. JavaScript: link the packages.
if [ "$build" = 1 ]; then
  pnpm --dir "$framework/packages/js" install --frozen-lockfile
  pnpm --dir "$framework/packages/js" build
fi
for app in web nuxt; do
  file="$app/pnpm-workspace.yaml"
  sed -i '/# framework checkout$/d' "$file"
  lines=""
  for package in client bff next nuxt theme; do
    [ -d "$framework/packages/js/$package" ] && lines+="  '@navree/${package}': link:${framework}/packages/js/${package} # framework checkout"$'\n'
  done
  if grep -q '^overrides:' "$file"; then
    awk -v lines="$lines" '{ print } /^overrides:/ { printf "%s", lines }' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
  else
    printf '\noverrides:\n%s' "$lines" >> "$file"
  fi
done

echo "The builds in this checkout now use $framework (version $version)."
echo "Next: cargo test --workspace; pnpm --dir web install --no-frozen-lockfile; pnpm --dir nuxt install --no-frozen-lockfile"
