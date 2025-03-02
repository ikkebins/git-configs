#!/bin/bash
HOOKS_DIR=".git/hooks"
REPO_HOOKS_DIR="git-hooks"

echo "Installiere Git Hooks..."

for HOOK in pre-commit post-commit; do
    cp "$REPO_HOOKS_DIR/$HOOK" "$HOOKS_DIR/$HOOK"
    chmod +x "$HOOKS_DIR/$HOOK"
done

echo "Git Hooks installiert!"

# Vault-Passwort aus Umgebungsvariable oder Datei im Benutzerverzeichnis lesen
if [[ -z "$VAULT_PASS" && -f "$HOME/.vault_pass" ]]; then
    VAULT_PASS=$(cat "$HOME/.vault_pass")
fi

# Falls VAULT_PASS leer ist, abbrechen
if [[ -z "$VAULT_PASS" ]]; then
    echo "Fehler: VAULT_PASS ist nicht gesetzt! Setze es in der Umgebung oder speichere es in ~/.vault_pass"
    exit 1
fi

echo "Entschlüssele alle .vault-Dateien..."
find . -type f -name "*.vault" | while read -r FILE; do
    ORIGINAL_FILE="${FILE%.vault}"  # Entferne die .vault-Endung

    if [[ ! -f "$ORIGINAL_FILE" ]]; then
        echo "Entschlüssele: $FILE -> $ORIGINAL_FILE"
        ansible-vault decrypt "$FILE" --output "$ORIGINAL_FILE" --vault-password-file <(echo "$VAULT_PASS")
    else
        echo "Überspringe: $ORIGINAL_FILE existiert bereits."
    fi
done

echo "Alle .vault-Dateien wurden entschlüsselt!"

