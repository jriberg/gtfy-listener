#!/bin/bash
#
# This is just a simple script to help installing
#

#!/bin/bash

# Check if python3, python3-venv, and python3-pip are installed
if ! command -v python3 &> /dev/null || ! command -v python3-venv &> /dev/null || ! command -v python3-pip &> /dev/null; then
    echo "Python3, python3-venv, or python3-pip is not installed. Please install them."
    exit 1
fi

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --install-path ) install_path="$2"; shift ;;
        * ) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Set the installation path or default to /opt/gtfy
install_path=${install_path:-"/opt/gtfy"}

# Create the path to install_path
mkdir -p $install_path

# Create a virtual environment unless --install-path is set
if [ ! -d "$install_path" ]; then
    python3 -m venv "$install_path"
fi

# Create and fill the .env file
env_file="$install_path/.env"
cat <<EOF > "$env_file"
NTFY = "https://ntfy.example.com"
GOTIFY_HOST = "https://gotify.example.com"
GOTIFY_TOKEN = "<GOTIFY CLIENT TOKEN>"
EOF

source "$install_path/bin/activate"
pip3 install -r requirements.txt

cp gtfy.py $install_path/gtfy.py

# Install the service file gtfy_listneres.service
service_file="/etc/systemd/system/gtfy_listneres.service"
cat <<EOF > "$service_file"
[Unit]
Description=GTFT Listeners Service

[Service]
Type=simple
ExecStart=$install_path/bin/python3 $install_path/gtfy.py
WorkingDirectory=$install_path

[Install]
WantedBy=multi-user.target
EOF

echo "Setup completed successfully."
echo "Now, populate $install_path/.env with your variables"
