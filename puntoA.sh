#!/bin/bash

# Crear particiones en el disco de 10GB
DISK="/dev/sdc"

# Crear tres particiones primarias de 1GB cada una
for i in {1..3}; do
  echo -e "n\np\n\n\n+1G\nw" | fdisk $DISK
done

# Crear una partición extendida de 3GB
echo -e "n\ne\n\n\n+3G\nw" | fdisk $DISK

# Crear dos particiones lógicas de 1.5GB dentro de la extendida
for i in {1..2}; do
  echo -e "n\n\n\n+1.5G\nw" | fdisk $DISK
done

# Actualizar cambios en el sistema
partprobe $DISK

# Configurar la partición 1 como Swap
fdisk $DISK <<EOF
t
1
82
w
EOF
mkswap "${DISK}1"
swapon "${DISK}1"
free -h  # Verificar memoria SWAP

# Configurar las particiones para LVM
for PART in {2..6}; do
  fdisk $DISK <<EOF
t
${PART}
8e
w
EOF
done

# Crear Physical Volumes (PVs)
pvcreate ${DISK}2 ${DISK}3 ${DISK}5 ${DISK}6
sudo pvs  # Verificar PVs

# Crear Volume Groups (VGs)
sudo vgcreate vgAdmin /dev/sdc2 /dev/sdc3
sudo vgcreate vgDevelopers /dev/sdc5 /dev/sdc6
sudo vgs  # Verificar VGs

# Crear Logical Volumes (LVs)
sudo lvcreate -L 1G -n lvDevelopers vgDevelopers
sudo lvcreate -L 1G -n lvTesters vgDevelopers
sudo lvcreate -L 900M -n lvDevops vgDevelopers
sudo lvcreate -L 2G -n lvAdmin vgAdmin
sudo lvs  # Verificar LVs

# Formatear y montar los LVs
sudo mkfs.ext4 /dev/vgDevelopers/lvDevelopers
sudo mkfs.ext4 /dev/vgDevelopers/lvTesters
sudo mkfs.ext4 /dev/vgDevelopers/lvDevops
sudo mkfs.ext4 /dev/vgAdmin/lvAdmin

sudo mkdir -p /mnt/{lvDevelopers,lvTesters,lvDevops,lvAdmin}
sudo mount /dev/vgDevelopers/lvDevelopers /mnt/lvDevelopers
sudo mount /dev/vgDevelopers/lvTesters /mnt/lvTesters
sudo mount /dev/vgDevelopers/lvDevops /mnt/lvDevops
sudo mount /dev/vgAdmin/lvAdmin /mnt/lvAdmin

df -h  # Verificar montajes
lsblk -f
