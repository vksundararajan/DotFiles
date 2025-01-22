# DotFiles

DotFiles is a personal repository containing Ansible scripts created to automate the setup of a Red Team attack box. This project was designed for personal use, but it is shared for others who may find it helpful. Feel free to use it at your own risk.

## Getting Started

```bash
pipx install --include-deps ansible
git clone https://github.com/vickie-ks/DotFiles.git
cd DotFiles/playbooks
sudo whoami
ansible-playbook main.yml
```

### About setup_user.sh

The `setup_user.sh` script provides a straightforward and efficient way to create new user accounts as needed.

#### Usage Instructions for Setupuser:
1. Download the `setup_user.sh` script.
2. Grant execute permissions: `chmod +x setup_user.sh`
3. Run the script with elevated privileges: `sudo ./setup_user.sh`

---
