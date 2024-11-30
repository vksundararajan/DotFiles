#!/bin/bash

# ========================================================================
# CONFIGURATION MANAGEMENT SCRIPT
# ------------------------------------------------------------------------
# Description:
# This script backs up and updates configuration files for Fish, Tmux,
# Alacritty, and Terminator. It also sources the necessary configurations
# (Fish and Tmux) after updates.
#
# Prerequisites:
# 1. Install Fish to update Fish configuration.
# 2. Install Tmux to update Tmux configuration.
# 3. Install Alacritty to apply Alacritty configuration.
# 4. Install Terminator to apply Terminator configuration.
#
# Usage:
# 1. Place your updated configuration files in a folder named 'config' 
#    in the same directory as this script.
# 2. Ensure the files are named:
#       - fish_config for Fish
#       - tmux_config for Tmux
#       - alacritty_config for Alacritty
#       - terminator_config for Terminator
# 3. Run the script: ./update_configs.sh
# ========================================================================

# Define colors for output
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
CYAN="\033[36m"
RESET="\033[0m"

# Display banner
print_banner() {
  echo -e "${CYAN}"
  echo " _______  _______  __    _  _______  ___   _______    __   __  _______  __    _  _______  _______  _______  ______   "
  echo "|       ||       ||  |  | ||       ||   | |       |  |  |_|  ||   _   ||  |  | ||   _   ||       ||       ||    _ |  "
  echo "|       ||   _   ||   |_| ||    ___||   | |    ___|  |       ||  |_|  ||   |_| ||  |_|  ||    ___||    ___||   | ||  "
  echo "|       ||  | |  ||       ||   |___ |   | |   | __   |       ||       ||       ||       ||   | __ |   |___ |   |_||_ "
  echo "|      _||  |_|  ||  _    ||    ___||   | |   ||  |  |       ||       ||  _    ||       ||   ||  ||    ___||    __  |"
  echo "|     |_ |       || | |   ||   |    |   | |   |_| |  | ||_|| ||   _   || | |   ||   _   ||   |_| ||   |___ |   |  | |"
  echo "|_______||_______||_|  |__||___|    |___| |_______|  |_|   |_||__| |__||_|  |__||__| |__||_______||_______||___|  |_|"
  echo -e "${RESET}"
}

# Display prerequisites
show_prerequisites() {
  echo -e "${CYAN}"
  echo "=========================================="
  echo "          PREREQUISITES REQUIRED          "
  echo "=========================================="
  echo -e "${RESET}"
  echo -e "${YELLOW}1. Fish must be installed to update Fish configuration.${RESET}"
  echo -e "${YELLOW}2. Tmux must be installed to update Tmux configuration.${RESET}"
  echo -e "${YELLOW}3. Alacritty must be installed to apply Alacritty configuration.${RESET}"
  echo -e "${YELLOW}4. Terminator must be installed to apply Terminator configuration.${RESET}"
  echo ""
}

# Function to check prerequisites
check_prerequisites() {
  local missing_tools=()

  command -v fish >/dev/null 2>&1 || missing_tools+=("fish")
  command -v tmux >/dev/null 2>&1 || missing_tools+=("tmux")
  command -v alacritty >/dev/null 2>&1 || missing_tools+=("alacritty")
  command -v terminator >/dev/null 2>&1 || missing_tools+=("terminator")

  if [ ${#missing_tools[@]} -ne 0 ]; then
    echo -e "${RED}Missing prerequisites:${RESET} ${missing_tools[*]}"
    echo -e "${YELLOW}Please install the missing tools and run the script again.${RESET}"
    exit 1
  fi

  echo -e "${GREEN}All prerequisites are met. Proceeding with the script...${RESET}"
}

# Function to back up a file
backup_file() {
  local file="$1"
  if [ -f "$file" ]; then
    local backup="${file}.backup.$(date +%Y%m%d%H%M%S)"
    cp "$file" "$backup"
    if [ $? -eq 0 ]; then
      echo -e "${GREEN}Backup created for $file at $backup${RESET}"
    else
      echo -e "${RED}Failed to create backup for $file. Aborting.${RESET}"
      exit 1
    fi
  else
    echo -e "${YELLOW}$file does not exist. Skipping backup.${RESET}"
  fi
}

# Function to update a file
update_file() {
  local src_file="$1"
  local dest_file="$2"

  backup_file "$dest_file"
  cp "$src_file" "$dest_file"
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}$dest_file updated successfully!${RESET}"
  else
    echo -e "${RED}Failed to update $dest_file. Aborting.${RESET}"
    exit 1
  fi

  # Source the file if necessary
  if [[ "$dest_file" == *config.fish || "$dest_file" == *tmux.conf ]]; then
    echo -e "${CYAN}Sourcing $dest_file...${RESET}"
    if [[ "$dest_file" == *config.fish ]]; then
      fish -c "source $dest_file" || echo -e "${RED}Failed to source $dest_file.${RESET}"
    elif [[ "$dest_file" == *tmux.conf ]]; then
      tmux source-file "$dest_file" || echo -e "${RED}Failed to source $dest_file.${RESET}"
    fi
  fi
}

# Menu function
show_menu() {
  echo -e "${BLUE}Select the configuration you want to update:${RESET}"
  echo -e "${CYAN}1. Fish Configuration${RESET}"
  echo -e "${CYAN}2. Tmux Configuration${RESET}"
  echo -e "${CYAN}3. Alacritty Configuration${RESET}"
  echo -e "${CYAN}4. Terminator Configuration${RESET}"
  echo -e "${CYAN}5. Update All Configurations${RESET}"
  echo -e "${CYAN}0. Exit${RESET}"
}

# Main script
print_banner
show_prerequisites
check_prerequisites

# Paths
CONFIG_DIR="config"
FISH_SRC="$CONFIG_DIR/fish_config"
TMUX_SRC="$CONFIG_DIR/tmux_config"
ALACRITTY_SRC="$CONFIG_DIR/alacritty_config"
TERMINATOR_SRC="$CONFIG_DIR/terminator_config"

FISH_DEST="$HOME/.config/fish/config.fish"
TMUX_DEST="$HOME/.tmux.conf"
ALACRITTY_DEST="$HOME/.config/alacritty/alacritty.toml"
TERMINATOR_DEST="$HOME/.config/terminator/config"

while true; do
  show_menu
  read -p "Enter your choice: " choice

  case $choice in
    1)
      echo -e "${BLUE}Updating Fish Configuration...${RESET}"
      update_file "$FISH_SRC" "$FISH_DEST"
      ;;
    2)
      echo -e "${BLUE}Updating Tmux Configuration...${RESET}"
      update_file "$TMUX_SRC" "$TMUX_DEST"
      ;;
    3)
      echo -e "${BLUE}Updating Alacritty Configuration...${RESET}"
      update_file "$ALACRITTY_SRC" "$ALACRITTY_DEST"
      ;;
    4)
      echo -e "${BLUE}Updating Terminator Configuration...${RESET}"
      update_file "$TERMINATOR_SRC" "$TERMINATOR_DEST"
      ;;
    5)
      echo -e "${BLUE}Updating All Configurations...${RESET}"
      update_file "$FISH_SRC" "$FISH_DEST"
      update_file "$TMUX_SRC" "$TMUX_DEST"
      update_file "$ALACRITTY_SRC" "$ALACRITTY_DEST"
      update_file "$TERMINATOR_SRC" "$TERMINATOR_DEST"
      ;;
    0)
      echo -e "${GREEN}Exiting the script. Goodbye!${RESET}"
      break
      ;;
    *)
      echo -e "${RED}Invalid choice. Please try again.${RESET}"
      ;;
  esac
done
