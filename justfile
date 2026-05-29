check:
    nix flake check --no-build --all-systems

update:
    git ls-files '*flake.nix' \
      | grep -v '^modules/core/flake.nix$' \
      | xargs -n1 dirname \
      | sort -u \
      | xargs -P 8 -I{} bash -c 'echo "==> {}"; cd "{}" && nix flake update'
