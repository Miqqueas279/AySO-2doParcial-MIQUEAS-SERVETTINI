#!/bin/bash

# Crear archivo de inventario
mkdir -p ~/2doParcial/ansible
cd ~/2doParcial/ansible

cat <<EOL > inventory.ini
[desarrollo]
192.168.56.9 ansible_ssh_user=vagrant ansible_ssh_private_key_file=~/.ssh/id_rsa
EOL

# Crear archivo de playbook
cat <<EOL > playbook.yml
---
- name: Configurar host de desarrollo
  hosts: desarrollo
  tasks:
    - name: Actualizar todos los paquetes
      apt:
        update_cache: yes
        upgrade: dist

    - name: Instalar Apache2
      apt:
        name: apache2
        state: present
EOL

# Ejecutar el playbook
ansible-playbook -i inventory.ini playbook.yml




ssh vagrant@192.168.56.9
dpkg -l | grep apache2  # Verificar que Apache2 fue instalado
