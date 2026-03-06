#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/Users/nate/gitwork/github/mauvehed"
FORGEJO_BASE="git@git:mauvehed"

# Format: "local_dir|forgejo_repo_name"
# Standard repos (local dir name = forgejo repo name)
REPOS=(
  "aha-art|aha-art"
  "bm_monitor|bm_monitor"
  "discord_bot|discord_bot"
  "dotfiles|dotfiles"
  "fly-tailscale-exit|fly-tailscale-exit"
  "fork_auto_update|fork_auto_update"
  "fuckery|fuckery"
  "github-gitea-mirror|github-gitea-mirror"
  "homelab|homelab"
  "infra|infra"
  "k0mvh.io|k0mvh.io"
  "kevvy|kevvy"
  "kevvy-web|kevvy-web"
  "komodo|komodo"
  "mauve.haus|mauve.haus"
  "matrix-takeonme|matrix-takeonme"
  "mauvecraft|mauvecraft"
  "mauveRANT|mauveRANT"
  "mkdocs|mkdocs"
  "mvh.dev|mvh.dev"
  "nate.fail|nate.fail"
  "pixelfed-import|pixelfed-import"
  "samcrow|samcrow"
  "slidev|slidev"
  "starred|starred"
  "tailscale|tailscale"
  "terraform|terraform"
  "tf-matrix-synapse|tf-matrix-synapse"
  "trackerstatus|trackerstatus"
  "trackerstatus_discord|trackerstatus_discord"
  "ubuntu-server|ubuntu-server"
  "yourip|yourip"
  # Name mismatches (local dir name differs from forgejo repo name)
  "github-runner|GitHub-runner"
  "HackerNewsDiscordFeed|hackernewsdiscordfeed"
  "mauvehed-README|mauvehed"
  "mauvehed.github.io-ARCHIVED|mauvehed.github.io"
  "reaper-bot|discord-activity"
  "ombi-redirect|omni-redirect"
)

MODE="dry-run"
if [[ "${1:-}" == "--execute" ]]; then
  MODE="execute"
fi

migrate_repo() {
  local local_dir="$1"
  local forgejo_repo="$2"
  local repo_path="${BASE_DIR}/${local_dir}"
  local forgejo_url="${FORGEJO_BASE}/${forgejo_repo}.git"

  if [[ ! -d "${repo_path}/.git" ]]; then
    echo "[SKIP] ${local_dir} -- not a git repo"
    return
  fi

  local current_origin
  current_origin=$(git -C "$repo_path" remote get-url origin 2>/dev/null || echo "")

  if [[ -z "$current_origin" ]]; then
    echo "[SKIP] ${local_dir} -- no origin remote"
    return
  fi

  if [[ "$current_origin" == *"git@git:"* ]]; then
    echo "[SKIP] ${local_dir} -- origin already points to Forgejo (${current_origin})"
    return
  fi

  local has_github
  has_github=$(git -C "$repo_path" remote get-url github 2>/dev/null || echo "")

  if [[ -n "$has_github" ]]; then
    echo "[SKIP] ${local_dir} -- github remote already exists (${has_github})"
    return
  fi

  if [[ "$MODE" == "dry-run" ]]; then
    echo "[WOULD] ${local_dir}"
    echo "        rename origin -> github  (${current_origin})"
    echo "        add    origin             (${forgejo_url})"
  else
    git -C "$repo_path" remote rename origin github
    git -C "$repo_path" remote add origin "$forgejo_url"
    echo "[DONE] ${local_dir}"
    echo "       github = ${current_origin}"
    echo "       origin = ${forgejo_url}"
  fi
}

echo "=== Migrate GitHub Remotes to Forgejo ==="
echo "Mode: ${MODE}"
echo ""

for entry in "${REPOS[@]}"; do
  IFS='|' read -r local_dir forgejo_repo <<< "$entry"
  migrate_repo "$local_dir" "$forgejo_repo"
done

# --- Homelab submodule migration ---
echo ""
echo "=== Homelab Submodules ==="
echo ""

HOMELAB_PATH="${BASE_DIR}/homelab"

# Format: "submodule_section_name|new_url"
# Section names from .gitmodules (may differ from path)
SUBMODULES=(
  "websites/mauve.haus|git@git:mauvehed/mauve.haus.git"
  "websites/mauvehed.github.io|git@git:mauvehed/mauvehed.github.io.git"
  "websites/mauveRANT|git@git:mauvehed/mauveRANT.git"
  "websites/chezmoi|git@git:mauvehed/chezmoi.git"
  "websites/watchkeepers.org|git@git:mauvehed/watchkeepers.org.git"
  "websites/ombi-redirect|git@git:mauvehed/omni-redirect.git"
  "scripts/ansible|git@git:mauvehed/ansible.git"
  "shell-config/dotfiles|git@git:mauvehed/dotfiles.git"
)

for entry in "${SUBMODULES[@]}"; do
  IFS='|' read -r sub_name new_url <<< "$entry"

  current_url=$(git -C "$HOMELAB_PATH" config --file .gitmodules --get "submodule.${sub_name}.url" 2>/dev/null || echo "")

  if [[ -z "$current_url" ]]; then
    echo "[SKIP] ${sub_name} -- not found in .gitmodules"
    continue
  fi

  if [[ "$current_url" == *"git@git:"* ]]; then
    echo "[SKIP] ${sub_name} -- already points to Forgejo (${current_url})"
    continue
  fi

  if [[ "$MODE" == "dry-run" ]]; then
    echo "[WOULD] ${sub_name}"
    echo "        ${current_url}"
    echo "     -> ${new_url}"
  else
    git -C "$HOMELAB_PATH" config --file .gitmodules "submodule.${sub_name}.url" "$new_url"
    echo "[DONE] ${sub_name}"
    echo "       ${current_url} -> ${new_url}"
  fi
done

if [[ "$MODE" == "execute" ]]; then
  git -C "$HOMELAB_PATH" submodule sync
  echo ""
  echo "Ran 'git submodule sync' in homelab."
  echo "NOTE: .gitmodules has been modified but NOT committed."
  echo "      Review and commit when ready."
fi

echo ""
if [[ "$MODE" == "dry-run" ]]; then
  echo "Dry-run complete. Run with --execute to apply changes."
fi
