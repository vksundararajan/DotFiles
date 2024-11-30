#!/bin/bash

# =====================================================================
# Script to Manage User and Hostname
# Instructions:
# 1. Save this script as `setup_user.sh`.
# 2. Make the script executable: `chmod +x setup_user.sh`.
# 3. Run the script as root: `sudo ./setup_user.sh`.
# 4. Choose one of the following options:
#    a. Change username (optionally update/upgrade system first).
#    b. Change hostname.
#    c. Delete user.
# 5. Follow the prompts. Reboot your system after the script completes.
# =====================================================================

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo -e "\033[1;31mError:\033[0m This script must be run as root!"
  exit 1
fi

# Add color variables for better readability
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
RESET="\033[0m"

# Stylish ASCII Banner
function display_banner() {
  echo -e "${GREEN}"
  cat << "EOF"
   _____      __                 __  __              
  / ___/___  / /___  ______     / / / /_______  _____
  \__ \/ _ \/ __/ / / / __ \   / / / / ___/ _ \/ ___/
 ___/ /  __/ /_/ /_/ / /_/ /  / /_/ (__  )  __/ /    
/____/\___/\__/\__,_/ .___/   \____/____/\___/_/     
                   /_/                               
EOF
  echo -e "${CYAN}Author: dR3dMonkey${RESET}"
  echo -e "${CYAN}Welcome to the User and Hostname Setup Script!${RESET}"
  echo -e "${CYAN}Follow the prompts below to configure your system.${RESET}\n"
}

# Show recommended update message
function recommend_update() {
  echo -e "${YELLOW}Highly Recommended:${RESET} Before running this script, ensure your system is up-to-date."
  echo -e "${YELLOW}Run the following command:${RESET}"
  echo -e "${CYAN}sudo apt update && sudo apt upgrade -y${RESET}\n"
  echo -n "Have you updated your system? (yes/no): "
  read -r UPDATED
  if [[ "$UPDATED" != "yes" ]]; then
    echo -e "${RED}Please update your system before proceeding! Exiting now.${RESET}"
    exit 1
  fi
}

# Function to log steps
function log_step() {
  local message=$1
  echo -e "${CYAN}+ ${message}${RESET}"
}

# Function to show a success message
function log_success() {
  local message=$1
  echo -e "${GREEN}✔ ${message}${RESET}"
}

# Function to show an error message
function log_error() {
  local message=$1
  echo -e "${RED}✖ ${message}${RESET}"
}

# Function to show a loading animation
function loading() {
  local message=$1
  local pid=$2
  local spin='|/-\'
  local i=0
  while kill -0 "$pid" 2>/dev/null; do
    i=$(( (i+1) % 4 ))
    printf "\r${YELLOW}${message} ${spin:$i:1}${RESET}"
    sleep 0.1
  done
  printf "\r${GREEN}${message} ✔${RESET}\n"
}

# Display the banner
display_banner

# Show the update recommendation
recommend_update

# Prompt the user for an action
echo -e "${BLUE}What would you like to do?${RESET}"
echo -e "${YELLOW}1. Change Username${RESET}"
echo -e "${YELLOW}2. Change Hostname${RESET}"
echo -e "${YELLOW}3. Delete User${RESET}"
echo -n "Choose 1, 2, or 3: "
read -r CHOICE

if [[ "$CHOICE" == "1" ]]; then
  # Option 1: Change Username
  echo -e "${BLUE}Changing Username...${RESET}"

  # Prompt for system update/upgrade
  echo -n "Would you like to update and upgrade the system before adding the user? (yes/no): "
  read -r UPDATE_SYSTEM
  if [[ "$UPDATE_SYSTEM" == "yes" ]]; then
    log_step "Updating and upgrading the system. This may take a while."
    apt update && apt upgrade -y &
    loading "Updating and upgrading the system" $!
  fi

  # Detect the default user
  DEFAULT_USER=$(awk -F: '$3 == 1000 {print $1}' /etc/passwd)

  if [ -z "$DEFAULT_USER" ]; then
    log_error "Unable to detect the default user (UID 1000)."
    echo -n "Please enter the default username manually: "
    read -r DEFAULT_USER
  fi

  log_step "Default user detected: $DEFAULT_USER"
  read -p "Enter the username for the new user: " NEW_USER

  # Detect if --badname is required
  if [[ "$NEW_USER" =~ [^a-zA-Z0-9._-] || "$NEW_USER" =~ [A-Z] ]]; then
    echo -e "\n${YELLOW}The username '$NEW_USER' does not meet standard Linux username rules.${RESET}"
    echo -n "Are you sure you want to proceed with this username? (yes/no): "
    read -r BADNAME_CONFIRM
    if [[ "$BADNAME_CONFIRM" != "yes" ]]; then
      log_error "Aborting script. Please provide a valid username."
      exit 1
    fi
    log_step "Proceeding with the username '$NEW_USER' using --badname."
    USE_BADNAME=true
  else
    USE_BADNAME=false
  fi

  # Create the new user
  log_step "Creating new user: $NEW_USER"
  if [ "$USE_BADNAME" = true ]; then
    if useradd --badname -m -s /bin/bash -G sudo "$NEW_USER" 2>/tmp/useradd_error.log; then
      log_success "User $NEW_USER created successfully."
    else
      log_error "Failed to create the user '$NEW_USER'. Details can be found in /tmp/useradd_error.log."
      exit 1
    fi
  else
    if useradd -m -s /bin/bash -G sudo "$NEW_USER" 2>/tmp/useradd_error.log; then
      log_success "User $NEW_USER created successfully."
    else
      log_error "Failed to create the user '$NEW_USER'. Details can be found in /tmp/useradd_error.log."
      exit 1
    fi
  fi

  # Set password for new user
  log_step "Setting password for $NEW_USER"
  echo "You will now set a password for the new user."
  if passwd "$NEW_USER"; then
    log_success "Password set successfully for $NEW_USER."
  else
    log_error "Failed to set the password for $NEW_USER."
    exit 1
  fi

elif [[ "$CHOICE" == "2" ]]; then
  # Option 2: Change Hostname
  echo -e "${BLUE}Changing Hostname...${RESET}"
  echo -n "Enter the new hostname (e.g., myhost): "
  read -r NEW_HOSTNAME

  if [ -n "$NEW_HOSTNAME" ]; then
    log_step "Updating hostname to $NEW_HOSTNAME"
    hostnamectl set-hostname "$NEW_HOSTNAME" &
    loading "Setting hostname to $NEW_HOSTNAME" $!

    # Update /etc/hosts
    log_step "Updating /etc/hosts file"
    sed -i "s/^127\.0\.1\.1.*/127.0.1.1 $NEW_HOSTNAME/" /etc/hosts &
    loading "Updating /etc/hosts" $!

    log_success "Hostname updated to '$NEW_HOSTNAME'."
  else
    log_error "Hostname not changed."
  fi

elif [[ "$CHOICE" == "3" ]]; then
  # Option 3: Delete User
  echo -e "${BLUE}Deleting User...${RESET}"
  echo -n "Enter the username you want to delete: "
  read -r DELETE_USER

  if id "$DELETE_USER" &>/dev/null; then
    log_step "Killing all processes for user $DELETE_USER"
    pkill -u "$DELETE_USER" || true &
    loading "Killing processes for $DELETE_USER" $!

    log_step "Deleting user $DELETE_USER and their home directory"
    if deluser --remove-home "$DELETE_USER"; then
      log_success "User $DELETE_USER deleted successfully."
    else
      log_error "Failed to delete user $DELETE_USER."
    fi
  else
    log_error "User $DELETE_USER does not exist."
  fi

else
  log_error "Invalid choice. Please run the script again and choose 1, 2, or 3."
  exit 1
fi

# Final message
echo -e "${GREEN}All tasks are completed!${RESET}"
echo -e "${YELLOW}Please run ${CYAN}sudo reboot${YELLOW} to apply the changes.${RESET}"

