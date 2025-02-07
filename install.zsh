#!/bin/zsh

set -e

THEME_URL='https://raw.githubusercontent.com/SKY-ALIN/alinsky-zsh-theme/main/alinsky.zsh-theme'
THEME_NAME='alinsky.zsh-theme'

function get_downloader() {
  if command -v curl &> /dev/null; then
    echo "curl"
  elif command -v wget &> /dev/null; then
    echo "wget"
  else
    echo "none"
  fi
}

function detect_ohmyzsh() {
  if [ -n "$ZSH" ]; then
    OHMYZSH_DIR="$ZSH"
  else
    OHMYZSH_DIR="${HOME}/.oh-my-zsh"
  fi
  
  if [ ! -d "${OHMYZSH_DIR}" ]; then
    echo "Error: Oh My Zsh not found in ${OHMYZSH_DIR}" >&2
    echo "Please install Oh My Zsh first: https://ohmyz.sh/#install" >&2
    exit 1
  fi
}

function install_theme() {
  THEMES_DIR="${OHMYZSH_DIR}/custom/themes"
  mkdir -p "${THEMES_DIR}"

  local downloader=$(get_downloader)

  echo "Downloading theme..."
  case $downloader in
    "curl")
      if ! curl -fsSL -o "${THEMES_DIR}/${THEME_NAME}" "${THEME_URL}"; then
        echo "Failed to download theme using curl!" >&2
        exit 1
      fi
      ;;
    "wget")
      if ! wget -q --show-progress -O "${THEMES_DIR}/${THEME_NAME}" "${THEME_URL}"; then
        echo "Failed to download theme using wget!" >&2
        exit 1
      fi
      ;;
    *)
      echo "Error: Need curl or wget to download theme" >&2
      echo "Please install one of them and try again" >&2
      exit 1
      ;;
  esac

  update_zshrc

  echo ""
  echo "Theme installed successfully!"
  source ~/.zshrc
}

function update_zshrc() {
  ZSHRC_FILE="${HOME}/.zshrc"
  
  if [ ! -w "${ZSHRC_FILE}" ]; then
    echo "Warning: No write permission for ${ZSHRC_FILE}" >&2
    echo "You need to manually set ZSH_THEME='alinsky' in your zsh config"
    return
  fi

  if grep -q '^ZSH_THEME=' "${ZSHRC_FILE}"; then
    sed -i.bak 's/^ZSH_THEME=.*/ZSH_THEME="alinsky"/' "${ZSHRC_FILE}"
  else
    echo 'ZSH_THEME="alinsky"' >> "${ZSHRC_FILE}"
  fi

  if [ -f "${ZSHRC_FILE}.bak" ]; then
    rm "${ZSHRC_FILE}.bak"
  fi
}

main() {
  detect_ohmyzsh
  install_theme
}

main "$@"
