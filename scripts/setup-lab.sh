#!/bin/bash

# Technical Certification Lab Setup Script
# This script helps set up the lab environment for different certification tracks

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Function to check system requirements
check_requirements() {
    print_header "Checking System Requirements"
    
    # Check CPU cores
    CPU_CORES=$(nproc)
    if [ $CPU_CORES -lt 4 ]; then
        print_warning "Only $CPU_CORES CPU cores detected. Recommended: 4+ cores"
    else
        print_status "CPU cores: $CPU_CORES ✓"
    fi
    
    # Check RAM
    RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
    if [ $RAM_GB -lt 8 ]; then
        print_error "Only ${RAM_GB}GB RAM detected. Minimum: 8GB, Recommended: 16GB+"
        exit 1
    else
        print_status "RAM: ${RAM_GB}GB ✓"
    fi
    
    # Check disk space
    DISK_SPACE_GB=$(df -BG / | awk 'NR==2{print $4}' | sed 's/G//')
    if [ $DISK_SPACE_GB -lt 100 ]; then
        print_warning "Only ${DISK_SPACE_GB}GB free space. Recommended: 500GB+"
    else
        print_status "Free disk space: ${DISK_SPACE_GB}GB ✓"
    fi
}

# Function to install common dependencies
install_dependencies() {
    print_header "Installing Common Dependencies"
    
    if command -v apt-get &> /dev/null; then
        # Ubuntu/Debian
        sudo apt-get update
        sudo apt-get install -y curl wget git vim htop tree unzip python3 python3-pip
        print_status "Ubuntu/Debian dependencies installed"
    elif command -v yum &> /dev/null; then
        # CentOS/RHEL
        sudo yum update -y
        sudo yum install -y curl wget git vim htop tree unzip python3 python3-pip
        print_status "CentOS/RHEL dependencies installed"
    elif command -v pacman &> /dev/null; then
        # Arch Linux
        sudo pacman -Syu --noconfirm curl wget git vim htop tree unzip python python-pip
        print_status "Arch Linux dependencies installed"
    else
        print_warning "Unknown package manager. Please install dependencies manually."
    fi
}

# Function to set up networking lab
setup_networking_lab() {
    print_header "Setting Up Networking Lab Environment"
    
    # Install GNS3
    if ! command -v gns3 &> /dev/null; then
        print_status "Installing GNS3..."
        if command -v apt-get &> /dev/null; then
            sudo add-apt-repository ppa:gns3/ppa -y
            sudo apt-get update
            sudo apt-get install -y gns3-gui gns3-server
        else
            print_warning "Please install GNS3 manually from https://gns3.com/"
        fi
    else
        print_status "GNS3 already installed ✓"
    fi
    
    # Install Wireshark
    if ! command -v wireshark &> /dev/null; then
        print_status "Installing Wireshark..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y wireshark
        fi
    else
        print_status "Wireshark already installed ✓"
    fi
    
    print_status "Networking lab setup complete!"
    print_warning "Don't forget to download Cisco IOS images for GNS3"
}

# Function to set up cloud computing environment
setup_cloud_lab() {
    print_header "Setting Up Cloud Computing Environment"
    
    # Install AWS CLI
    if ! command -v aws &> /dev/null; then
        print_status "Installing AWS CLI..."
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install
        rm -rf aws awscliv2.zip
    else
        print_status "AWS CLI already installed ✓"
    fi
    
    # Install Azure CLI
    if ! command -v az &> /dev/null; then
        print_status "Installing Azure CLI..."
        curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    else
        print_status "Azure CLI already installed ✓"
    fi
    
    # Install Google Cloud SDK
    if ! command -v gcloud &> /dev/null; then
        print_status "Installing Google Cloud SDK..."
        curl https://sdk.cloud.google.com | bash
        source ~/.bashrc
    else
        print_status "Google Cloud SDK already installed ✓"
    fi
    
    # Install Terraform
    if ! command -v terraform &> /dev/null; then
        print_status "Installing Terraform..."
        wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt update && sudo apt install terraform
    else
        print_status "Terraform already installed ✓"
    fi
    
    print_status "Cloud computing environment setup complete!"
    print_warning "Configure your cloud provider credentials:"
    echo "  AWS: aws configure"
    echo "  Azure: az login"
    echo "  GCP: gcloud init"
}

# Function to set up virtualization lab
setup_virtualization_lab() {
    print_header "Setting Up Virtualization Lab Environment"
    
    # Install Docker
    if ! command -v docker &> /dev/null; then
        print_status "Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        rm get-docker.sh
    else
        print_status "Docker already installed ✓"
    fi
    
    # Install Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        print_status "Installing Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    else
        print_status "Docker Compose already installed ✓"
    fi
    
    # Install VirtualBox (if not already installed)
    if ! command -v virtualbox &> /dev/null; then
        print_status "Installing VirtualBox..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y virtualbox virtualbox-ext-pack
        fi
    else
        print_status "VirtualBox already installed ✓"
    fi
    
    print_status "Virtualization environment setup complete!"
    print_warning "You may need to log out and back in for Docker group permissions to take effect"
}

# Function to set up OS lab
setup_os_lab() {
    print_header "Setting Up Operating Systems Lab Environment"
    
    # Install Ansible
    if ! command -v ansible &> /dev/null; then
        print_status "Installing Ansible..."
        python3 -m pip install --user ansible
        export PATH="$HOME/.local/bin:$PATH"
    else
        print_status "Ansible already installed ✓"
    fi
    
    # Install Vagrant
    if ! command -v vagrant &> /dev/null; then
        print_status "Installing Vagrant..."
        wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt update && sudo apt install vagrant
    else
        print_status "Vagrant already installed ✓"
    fi
    
    print_status "Operating Systems lab environment setup complete!"
}

# Function to create project directories
create_project_structure() {
    print_header "Creating Project Directory Structure"
    
    mkdir -p ~/tech-cert-lab/{projects,configs,scripts,documentation,images}
    mkdir -p ~/tech-cert-lab/projects/{networking,cloud,virtualization,hardware,os}
    
    print_status "Project structure created in ~/tech-cert-lab/"
    
    # Create a basic gitignore
    cat > ~/tech-cert-lab/.gitignore << 'EOF'
# Sensitive files
*.key
*.pem
*.p12
credentials
secrets.txt

# Virtual machine files
*.vmdk
*.vdi
*.qcow2
*.iso

# Logs
*.log
logs/

# Temporary files
tmp/
temp/
.DS_Store
Thumbs.db
EOF

    print_status ".gitignore created"
}

# Main menu function
show_menu() {
    clear
    print_header "Technical Certification Lab Setup"
    echo "Choose your certification track:"
    echo
    echo "1) Networking (CCNA, Network+, CCNP)"
    echo "2) Cloud Computing (AWS, Azure, GCP)"
    echo "3) Virtualization (VMware, Hyper-V, KVM)"
    echo "4) Hardware (CompTIA A+, Server+)"
    echo "5) Operating Systems (Linux+, RHCSA, MCSA)"
    echo "6) Complete Setup (All domains)"
    echo "7) Exit"
    echo
    read -p "Enter your choice (1-7): " choice
}

# Main script execution
main() {
    # Check if running as root
    if [ "$EUID" -eq 0 ]; then
        print_error "Please do not run this script as root"
        exit 1
    fi
    
    while true; do
        show_menu
        
        case $choice in
            1)
                check_requirements
                install_dependencies
                setup_networking_lab
                create_project_structure
                print_status "Networking lab setup complete!"
                read -p "Press Enter to continue..."
                ;;
            2)
                check_requirements
                install_dependencies
                setup_cloud_lab
                create_project_structure
                print_status "Cloud computing lab setup complete!"
                read -p "Press Enter to continue..."
                ;;
            3)
                check_requirements
                install_dependencies
                setup_virtualization_lab
                create_project_structure
                print_status "Virtualization lab setup complete!"
                read -p "Press Enter to continue..."
                ;;
            4)
                check_requirements
                install_dependencies
                create_project_structure
                print_status "Hardware lab environment prepared!"
                print_warning "Hardware projects require physical components or simulators"
                read -p "Press Enter to continue..."
                ;;
            5)
                check_requirements
                install_dependencies
                setup_os_lab
                create_project_structure
                print_status "Operating Systems lab setup complete!"
                read -p "Press Enter to continue..."
                ;;
            6)
                check_requirements
                install_dependencies
                setup_networking_lab
                setup_cloud_lab
                setup_virtualization_lab
                setup_os_lab
                create_project_structure
                print_status "Complete lab environment setup finished!"
                read -p "Press Enter to continue..."
                ;;
            7)
                print_status "Thank you for using the Technical Certification Lab Setup!"
                print_status "Visit https://your-username.github.io for project guides"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please choose 1-7."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

# Run the main function
main "$@"