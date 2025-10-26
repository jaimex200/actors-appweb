#!/usr/bin/env bash

# ==============================================
# Submodules Management Script
# ==============================================
# Script para gestionar submódulos del proyecto Actors-AppWeb
#
# Uso:
#   source Tools/submodules.sh
#   submodules_init      # Inicializar y clonar todos los submódulos
#   submodules_update    # Actualizar todos los submódulos al último commit
#   submodules_pull      # Pull del branch configurado en cada submódulo
#   submodules_status    # Ver el estado de todos los submódulos
#   submodules_checkout  # Checkout al branch correcto en cada submódulo
#   submodules_help      # Mostrar ayuda

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Obtener el directorio raíz del repositorio
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"

if [ -z "$REPO_ROOT" ]; then
    echo -e "${RED}Error: No estás en un repositorio git${NC}"
    return 1 2>/dev/null || exit 1
fi

# ==============================================
# Función: Inicializar submódulos
# ==============================================
submodules_init() {
    echo -e "${BLUE}=== Inicializando submódulos ===${NC}"
    
    if [ ! -f "$REPO_ROOT/.gitmodules" ]; then
        echo -e "${RED}Error: No se encontró el archivo .gitmodules${NC}"
        return 1
    fi
    
    cd "$REPO_ROOT" || return 1
    
    echo -e "${YELLOW}Inicializando submódulos...${NC}"
    git submodule init
    
    echo -e "${YELLOW}Clonando submódulos...${NC}"
    git submodule update --init --recursive
    
    echo -e "${GREEN}✓ Submódulos inicializados correctamente${NC}"
    submodules_status
}

# ==============================================
# Función: Actualizar submódulos
# ==============================================
submodules_update() {
    echo -e "${BLUE}=== Actualizando submódulos ===${NC}"
    
    cd "$REPO_ROOT" || return 1
    
    echo -e "${YELLOW}Actualizando submódulos al último commit registrado...${NC}"
    git submodule update --recursive
    
    echo -e "${GREEN}✓ Submódulos actualizados${NC}"
    submodules_status
}

# ==============================================
# Función: Pull de los branches configurados
# ==============================================
submodules_pull() {
    echo -e "${BLUE}=== Pulling branches de submódulos ===${NC}"
    
    cd "$REPO_ROOT" || return 1
    
    # Leer los submódulos del archivo .gitmodules
    git config --file .gitmodules --get-regexp path | while read -r key path; do
        submodule_path="$path"
        submodule_name=$(echo "$key" | sed 's/submodule\.\(.*\)\.path/\1/')
        submodule_branch=$(git config --file .gitmodules --get "submodule.$submodule_name.branch")
        
        if [ -z "$submodule_branch" ]; then
            submodule_branch="main"
        fi
        
        echo -e "\n${YELLOW}Procesando: ${submodule_path} (branch: ${submodule_branch})${NC}"
        
        if [ -d "$submodule_path" ]; then
            (
                cd "$submodule_path" || exit 1
                
                # Verificar si hay cambios sin commitear
                if ! git diff-index --quiet HEAD --; then
                    echo -e "${RED}  ⚠ Hay cambios sin commitear en ${submodule_path}${NC}"
                    echo -e "${YELLOW}  → Saltando pull para evitar conflictos${NC}"
                    return
                fi
                
                # Checkout al branch correcto
                echo -e "  Cambiando a branch ${submodule_branch}..."
                git checkout "$submodule_branch" 2>/dev/null || git checkout -b "$submodule_branch"
                
                # Pull
                echo -e "  Haciendo pull..."
                git pull origin "$submodule_branch"
                
                echo -e "${GREEN}  ✓ Actualizado correctamente${NC}"
            )
        else
            echo -e "${RED}  ✗ Submódulo no encontrado: ${submodule_path}${NC}"
        fi
    done
    
    echo -e "\n${GREEN}✓ Pull completado${NC}"
}

# ==============================================
# Función: Ver estado de submódulos
# ==============================================
submodules_status() {
    echo -e "${BLUE}=== Estado de submódulos ===${NC}\n"
    
    cd "$REPO_ROOT" || return 1
    
    # Leer los submódulos del archivo .gitmodules
    git config --file .gitmodules --get-regexp path | while read -r key path; do
        submodule_path="$path"
        submodule_name=$(echo "$key" | sed 's/submodule\.\(.*\)\.path/\1/')
        submodule_branch=$(git config --file .gitmodules --get "submodule.$submodule_name.branch")
        submodule_url=$(git config --file .gitmodules --get "submodule.$submodule_name.url")
        
        if [ -z "$submodule_branch" ]; then
            submodule_branch="main"
        fi
        
        echo -e "${YELLOW}Submódulo: ${submodule_name}${NC}"
        echo -e "  Path: ${submodule_path}"
        echo -e "  URL: ${submodule_url}"
        echo -e "  Branch configurado: ${submodule_branch}"
        
        if [ -d "$submodule_path/.git" ]; then
            (
                cd "$submodule_path" || exit 1
                current_branch=$(git rev-parse --abbrev-ref HEAD)
                current_commit=$(git rev-parse --short HEAD)
                
                echo -e "  Branch actual: ${current_branch}"
                echo -e "  Commit actual: ${current_commit}"
                
                # Verificar si hay cambios
                if ! git diff-index --quiet HEAD --; then
                    echo -e "${RED}  ⚠ Hay cambios sin commitear${NC}"
                fi
                
                # Verificar si está adelantado/atrasado del remoto
                git fetch origin "$submodule_branch" 2>/dev/null
                LOCAL=$(git rev-parse @)
                REMOTE=$(git rev-parse @{u} 2>/dev/null)
                
                if [ -n "$REMOTE" ]; then
                    if [ "$LOCAL" = "$REMOTE" ]; then
                        echo -e "${GREEN}  ✓ Actualizado con origin/${submodule_branch}${NC}"
                    else
                        BASE=$(git merge-base @ @{u} 2>/dev/null)
                        if [ "$LOCAL" = "$BASE" ]; then
                            echo -e "${YELLOW}  ↓ Hay actualizaciones disponibles${NC}"
                        elif [ "$REMOTE" = "$BASE" ]; then
                            echo -e "${YELLOW}  ↑ Hay commits locales sin pushear${NC}"
                        else
                            echo -e "${RED}  ⚠ Las ramas han divergido${NC}"
                        fi
                    fi
                fi
            )
        else
            echo -e "${RED}  ✗ No inicializado${NC}"
        fi
        
        echo ""
    done
}

# ==============================================
# Función: Checkout al branch correcto
# ==============================================
submodules_checkout() {
    echo -e "${BLUE}=== Checkout de branches en submódulos ===${NC}"
    
    cd "$REPO_ROOT" || return 1
    
    git config --file .gitmodules --get-regexp path | while read -r key path; do
        submodule_path="$path"
        submodule_name=$(echo "$key" | sed 's/submodule\.\(.*\)\.path/\1/')
        submodule_branch=$(git config --file .gitmodules --get "submodule.$submodule_name.branch")
        
        if [ -z "$submodule_branch" ]; then
            submodule_branch="main"
        fi
        
        echo -e "\n${YELLOW}Procesando: ${submodule_path}${NC}"
        
        if [ -d "$submodule_path" ]; then
            (
                cd "$submodule_path" || exit 1
                
                current_branch=$(git rev-parse --abbrev-ref HEAD)
                
                if [ "$current_branch" != "$submodule_branch" ]; then
                    echo -e "  Cambiando de ${current_branch} a ${submodule_branch}..."
                    git checkout "$submodule_branch" 2>/dev/null || git checkout -b "$submodule_branch"
                    echo -e "${GREEN}  ✓ Checkout completado${NC}"
                else
                    echo -e "${GREEN}  ✓ Ya está en el branch ${submodule_branch}${NC}"
                fi
            )
        else
            echo -e "${RED}  ✗ Submódulo no encontrado${NC}"
        fi
    done
    
    echo -e "\n${GREEN}✓ Checkout completado${NC}"
}

# ==============================================
# Función: Ayuda
# ==============================================
submodules_help() {
    echo -e "${BLUE}=== Ayuda - Gestión de Submódulos ===${NC}\n"
    echo -e "${YELLOW}Comandos disponibles:${NC}"
    echo -e "  ${GREEN}submodules_init${NC}       - Inicializar y clonar todos los submódulos"
    echo -e "  ${GREEN}submodules_update${NC}     - Actualizar submódulos al commit registrado"
    echo -e "  ${GREEN}submodules_pull${NC}       - Pull del branch configurado en cada submódulo"
    echo -e "  ${GREEN}submodules_status${NC}     - Ver estado detallado de todos los submódulos"
    echo -e "  ${GREEN}submodules_checkout${NC}   - Checkout al branch correcto en cada submódulo"
    echo -e "  ${GREEN}submodules_help${NC}       - Mostrar esta ayuda"
    echo -e "\n${YELLOW}Uso típico:${NC}"
    echo -e "  1. Primera vez: ${GREEN}submodules_init${NC}"
    echo -e "  2. Actualizar:  ${GREEN}submodules_pull${NC}"
    echo -e "  3. Ver estado:  ${GREEN}submodules_status${NC}"
    echo -e "\n${YELLOW}Nota:${NC} Este script debe ejecutarse con 'source Tools/submodules.sh'"
}

# ==============================================
# Auto-mostrar ayuda si se ejecuta directamente
# ==============================================
echo -e "${GREEN}✓ Script de submódulos cargado${NC}"
echo -e "Escribe ${YELLOW}submodules_help${NC} para ver los comandos disponibles\n"
