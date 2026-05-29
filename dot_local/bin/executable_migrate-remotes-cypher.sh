#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/Users/nate/gitwork/github/mauvehed"
FORGEJO_BASE="git@git:mauvehed"

# Format: "local_dir|forgejo_repo_name"
REPOS=(
  # Standard repos (local dir name = forgejo repo name)
  "aha-art|aha-art"
  "austinhackers-hugo|austinhackers-hugo"
  "bm_monitor|bm_monitor"
  "certbot-nginx-deploy|certbot-nginx-deploy"
  "dotfiles_archived|dotfiles_archived"
  "dotfiles|dotfiles"
  "dracula-pro|dracula-pro"
  "fly-tailscale-exit|fly-tailscale-exit"
  "fork_auto_update|fork_auto_update"
  "github-gitea-mirror|github-gitea-mirror"
  "hackernewsdiscordfeed|hackernewsdiscordfeed"
  "homelab|homelab"
  "infra|infra"
  "k0mvh.io|k0mvh.io"
  "keebs|keebs"
  "kevvy-web|kevvy-web"
  "kevvy|kevvy"
  "komodo|komodo"
  "mauve.haus|mauve.haus"
  "mauveRANT|mauveRANT"
  "mvh.dev|mvh.dev"
  "nate.fail|nate.fail"
  "notes|notes"
  "pixelfed-import|pixelfed-import"
  "slidev|slidev"
  "tailscale|tailscale"
  "terraform|terraform"
  "tf-matrix-synapse|tf-matrix-synapse"
  "thesanders.lol|thesanders.lol"
  "trackerstatus_discord|trackerstatus_discord"
  "trackerstatus|trackerstatus"
  "watchkeepers.org|watchkeepers.org"
  "yourip.app|yourip.app"
  "youtube_watch_later_cleanup|youtube_watch_later_cleanup"
  # Name mismatches
  "yourIP|yourIP"
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

  if [[ "$current_origin" == *"git@git:"* || "$current_origin" == *"@gitea:"* || "$current_origin" == *"://gitea/"* ]]; then
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

echo "=== Migrate GitHub Remotes to Forgejo (cypher) ==="
echo "Mode: ${MODE}"
echo ""

for entry in "${REPOS[@]}"; do
  IFS='|' read -r local_dir forgejo_repo <<< "$entry"
  migrate_repo "$local_dir" "$forgejo_repo"
done

echo ""
if [[ "$MODE" == "dry-run" ]]; then
  echo "Dry-run complete. Run with --execute to apply changes."
fi
