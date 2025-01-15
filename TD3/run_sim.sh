#!/bin/bash

# Définition des chemins (à ajuster selon votre structure)
FIRMWARE_PATH="./firmware"
SIM_PATH="./sim"

# Couleurs pour les messages
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting simulation setup...${NC}"

# Compilation du firmware
echo -e "\n${GREEN}Building firmware...${NC}"
cd $FIRMWARE_PATH
if ./build.sh; then
    echo -e "${GREEN}Firmware build successful${NC}"
else
    echo -e "${RED}Firmware build failed${NC}"
    exit 1
fi

# Compilation de la simulation
echo -e "\n${GREEN}Building simulation...${NC}"
cd ../sim
if ./build.sh; then
    echo -e "${GREEN}Simulation build successful${NC}"
else
    echo -e "${RED}Simulation build failed${NC}"
    exit 1
fi