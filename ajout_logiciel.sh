#!/usr/bin/env bash

set -e

CONFIG_FILE="/etc/nixos/configuration.nix"
MARKER="# NOUVEAUX_PAQUETS_ICI"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

usage() {
    echo "Usage: $0 [list|add <paquets...>|rm <paquets...>]"
    exit 1
}

verify_package() {
    local pkg=$1
    if nix-instantiate --eval -E "with import <nixpkgs> {}; pkgs.${pkg}.name" >/dev/null 2>&1; then
        return 0
    elif nix-instantiate --eval -E "with import <nixpkgs> {}; ${pkg}.name" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

list_packages() {
    echo -e "${GREEN}Paquets dans ${CONFIG_FILE}:${NC}"
    if grep -q "environment.systemPackages" "$CONFIG_FILE"; then
        awk '/environment.systemPackages = .* \[/,/\];/' "$CONFIG_FILE" | \
        grep -v "environment.systemPackages" | \
        grep -v "^\s*#" | \
        grep -v "^\s*\]" | \
        sed 's/^[[:space:]]*//' | \
        sort
    else
        echo -e "${RED}Section introuvable.${NC}"
    fi
}

add_package() {
    local pkg=$1
    echo -e "${YELLOW}Vérification de ${pkg}...${NC}"
    
    if ! verify_package "$pkg"; then
        echo -e "${RED}Erreur: ${pkg} n'existe pas. Ignoré.${NC}"
        return 1
    fi

    if grep -q "\b${pkg}\b" "$CONFIG_FILE"; then
        echo -e "${YELLOW}${pkg} déjà présent. Ignoré.${NC}"
        return 0
    fi

    if ! grep -q "$MARKER" "$CONFIG_FILE"; then
        echo -e "${RED}Erreur: Marqueur ${MARKER} manquant. Arrêt.${NC}"
        exit 1
    fi

    sudo sed -i "/${MARKER}/i\\  ${pkg}" "$CONFIG_FILE"
    echo -e "${GREEN}${pkg} ajouté.${NC}"
    return 0
}

remove_package() {
    local pkg=$1
    echo -e "${YELLOW}Suppression de ${pkg}...${NC}"

    if ! grep -q "\b${pkg}\b" "$CONFIG_FILE"; then
        echo -e "${YELLOW}${pkg} n'est pas dans la configuration. Ignoré.${NC}"
        return 0
    fi

    sudo sed -i "/^\s*${pkg}\s*$/d" "$CONFIG_FILE"
    echo -e "${GREEN}${pkg} supprimé du fichier.${NC}"
    return 0
}

# Gestion des arguments
case "${1:-}" in
    list)
        list_packages
        ;;
    add)
        shift
        if [ $# -eq 0 ]; then usage; fi
        for pkg in "$@"; do
            add_package "$pkg"
        done
        echo -e "${GREEN}Reconstruction du système...${NC}"
        sudo nixos-rebuild switch
        ;;
    rm|remove)
        shift
        if [ $# -eq 0 ]; then usage; fi
        for pkg in "$@"; do
            remove_package "$pkg"
        done
        echo -e "${GREEN}Reconstruction du système...${NC}"
        sudo nixos-rebuild switch
        echo -e "${YELLOW}Nettoyage...${NC}"
        sudo nix-collect-garbage -d
        ;;
    *)
        usage
        ;;
esac
