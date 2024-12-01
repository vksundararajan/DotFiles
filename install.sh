#!/bin/bash

# Colorful output helpers
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Simple and clear banner
print_banner() {
  echo -e "${CYAN}"
  echo "#############################################"
  echo "#                                           #"
  echo "#       CONFIGURATION & SETUP TOOL          #"
  echo "#                                           #"
  echo "#############################################"
  echo -e "${RESET}"
}

# Define the configuration directory (replace with your directory path)
CONFIG_DIR=$(pwd)
BACKUP_DIR=~/backup-configs

# Function to create a backup of a file
backup_file() {
  local file=$1
  if [[ -f "$file" ]]; then
    mkdir -p "$BACKUP_DIR"
    local backup_file="$BACKUP_DIR/$(basename "$file").bak"
    cp "$file" "$backup_file"
    echo -e "${GREEN}Backup created: $backup_file${RESET}"
  fi
}

# Function to install oh-my-bash for a specific user
install_oh_my_bash_for_user() {
  local target_user=$1
  local home_dir

  # Get home directory for the user
  home_dir=$(eval echo "~$target_user")

  # Check if oh-my-bash is already installed
  if [[ -d "$home_dir/.oh-my-bash" ]]; then
    echo -e "${RED}oh-my-bash is already installed for $target_user.${RESET}"
    echo -e "${YELLOW}To reinstall, remove the directory: $home_dir/.oh-my-bash${RESET}"
    return 1
  fi

  echo -e "${CYAN}Installing oh-my-bash for $target_user...${RESET}"
  sudo -u "$target_user" bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" && \
    echo -e "${GREEN}oh-my-bash installed successfully for $target_user!${RESET}" || \
    { echo -e "${RED}Error installing oh-my-bash for $target_user.${RESET}"; return 1; }
}

# Function to install oh-my-bash for both user and root
install_oh_my_bash() {
  # Detect the non-root user
  local non_root_user
  non_root_user=$(logname)

  echo -e "${CYAN}Installing oh-my-bash for the current user ($non_root_user)...${RESET}"
  install_oh_my_bash_for_user "$non_root_user"

  echo -e "${CYAN}Installing oh-my-bash for root...${RESET}"
  install_oh_my_bash_for_user "root"
}

# Function to update the system
update_system() {
  echo -e "${YELLOW}Updating the system ensures compatibility with the latest packages.${RESET}"
  read -p "Would you like to update the system now? (yes/no): " update_choice

  if [[ "$update_choice" == "yes" ]]; then
    echo -e "${CYAN}Running system update...${RESET}"
    sudo apt update && sudo apt upgrade -y && \
      echo -e "${GREEN}System updated successfully!${RESET}" || \
      echo -e "${RED}System update failed. Please try manually.${RESET}"
  else
    echo -e "${YELLOW}Skipping system update.${RESET}"
  fi
}

# Function to append content to an existing file
append_to_file() {
  local source_file=$1
  local target_file=$2

  if [[ -f "$source_file" ]]; then
    backup_file "$target_file"
    cat "$source_file" >> "$target_file"
    echo -e "${GREEN}Content appended successfully to $target_file.${RESET}"
    source "$target_file"
    echo -e "${GREEN}Sourced $target_file successfully!${RESET}"
  else
    echo -e "${RED}Error: Source file $source_file not found. No changes made.${RESET}"
  fi
}

# Display the banner
print_banner

# Display system update message
update_system

# Menu options
while true; do
  echo -e "${BLUE}Choose an option to install:${RESET}"
  echo -e "  ${YELLOW}1.${RESET} Install oh-my-bash"
  echo -e "  ${YELLOW}2.${RESET} Install Alacritty"
  echo -e "  ${YELLOW}3.${RESET} Install Terminator"
  echo -e "  ${YELLOW}4.${RESET} Install Tmux"
  echo -e "  ${YELLOW}5.${RESET} Exit"
  read -p "Enter your choice: " choice

  case $choice in
    1)
      install_oh_my_bash
      ;;
    2 | 3 | 4)
      echo -e "${CYAN}Feature not implemented yet.${RESET}"
      ;;
    5)
      echo -e "${CYAN}Exiting script. Goodbye!${RESET}"
      exit 0
      ;;
    *)
      echo -e "${RED}Invalid choice. Please select a valid option.${RESET}"
      ;;
  esac
done
