#!/bin/bash

# ──────────────────────────────────────────────
#  push_scripts.sh
# ──────────────────────────────────────────────

GITHUB_USER="papycopy"
BRANCH="main"

# ── Nom du repo ──
if [ -n "$1" ]; then
    REPO_NAME="$1"
else
    echo "📝 Nom du dépôt :"
    read -r REPO_NAME
    if [ -z "$REPO_NAME" ]; then
        echo "❌ Nom vide, abort."
        exit 1
    fi
fi

# ✅ Sanitiser : remplacer / et espaces par _, ne garder que caractères valides
REPO_NAME=$(echo "$REPO_NAME" | tr '/ ' '__' | tr -cd 'a-zA-Z0-9_-')

echo "📦 Dépôt : $GITHUB_USER/$REPO_NAME"

# ── Vérifier gh ──
if ! command -v gh &>/dev/null; then
    echo "❌ GitHub CLI (gh) n'est pas installé."
    exit 1
fi

if ! gh auth status &>/dev/null; then
    echo "❌ Non authentifié. Lance : gh auth login"
    exit 1
fi

# ── Init git ──
if [ ! -d ".git" ]; then
    echo "🔄 git init..."
    git init
    git branch -M "$BRANCH"
fi

# ── Ajouter tout ──
git add .

if git diff --cached --quiet; then
    echo "✅ Rien à pousser, tout est à jour."
    exit 0
fi

echo "📂 Fichiers à pousser :"
git diff --cached --name-only | sed 's/^/   /'
echo ""

COMMIT_MSG="Update — $(date '+%Y-%m-%d %H:%M')"
git commit -m "$COMMIT_MSG"

# ── Créer le dépôt + push ──
if ! gh repo view "$GITHUB_USER/$REPO_NAME" &>/dev/null; then
    echo "🔄 Création du dépôt..."
    gh repo create "$REPO_NAME" --private --source=. --push
else
    echo "📂 Dépôt existe déjà, push..."
    if ! git remote get-url origin &>/dev/null; then
        git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
    fi
    git push -u origin "$BRANCH"
fi

echo "✅ Push terminé !"
echo "📍 https://github.com/$GITHUB_USER/$REPO_NAME"   
