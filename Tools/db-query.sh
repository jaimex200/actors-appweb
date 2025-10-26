#!/usr/bin/env bash

# db-query.sh (Tools)
# Provee funciones para ejecutar consultas en PostgreSQL dentro de Docker.
# Diseñado para usarse tanto ejecutándolo como haciendo `source Tools/db-query.sh`.

# Defaults (puedes sobreescribir pasando parámetros a las funciones)
DEFAULT_DB_USER="actor_admin"
DEFAULT_DB_NAME="actor_sites_db"
DEFAULT_CONTAINER="actor-sites-db"

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Helper para mostrar uso breve
_usage() {
    echo -e "${YELLOW}$1${NC}"
    if [ -n "$2" ]; then
        echo -e "Ejemplo: $2"
    fi
}

# Comprueba si un contenedor está corriendo
sql.check_container() {
    local container="${1:-$DEFAULT_CONTAINER}"
    if ! docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
        echo -e "${YELLOW}⚠️  El contenedor '${container}' no está corriendo.${NC}"
        echo "Inicia con: docker-compose up -d"
        return 1
    fi
    return 0
}

# Abrir consola psql: sql.open [container] [user] [db]
sql.open() {
    local container="${1:-$DEFAULT_CONTAINER}"
    local user="${2:-$DEFAULT_DB_USER}"
    local db="${3:-$DEFAULT_DB_NAME}"
    
    if [ -z "$container" ]; then
        _usage "Abre una consola psql dentro del contenedor Docker." "sql.open [actor-sites-db] [actor_admin] [actor_sites_db]"
        return 1
    fi
    
    sql.check_container "$container" || return 1
    docker exec -it "$container" psql -U "$user" -d "$db"
}

# Listar tablas: sql.tables [container] [user] [db]
sql.tables() {
    local container="${1:-$DEFAULT_CONTAINER}"
    local user="${2:-$DEFAULT_DB_USER}"
    local db="${3:-$DEFAULT_DB_NAME}"
    sql.check_container "$container" || return 1
    docker exec -it "$container" psql -U "$user" -d "$db" -c "\\dt"
}

# Describir tabla: sql.desc <table> [container] [user] [db]
sql.desc() {
    if [ -z "$1" ]; then
        _usage "Muestra la estructura de una tabla." "sql.desc sites [actor-sites-db] [actor_admin] [actor_sites_db]"
        return 1
    fi
    local table="$1"
    local container="${2:-$DEFAULT_CONTAINER}"
    local user="${3:-$DEFAULT_DB_USER}"
    local db="${4:-$DEFAULT_DB_NAME}"
    sql.check_container "$container" || return 1
    docker exec -it "$container" psql -U "$user" -d "$db" -c "\\d $table"
}

# Ejecutar query: sql.query "<SQL>" [container] [user] [db]
sql.query() {
    if [ -z "$1" ]; then
        _usage "Ejecuta una query SQL y muestra el resultado." "sql.query \"SELECT * FROM sites;\" [actor-sites-db] [actor_admin] [actor_sites_db]"
        return 1
    fi
    local query="$1"
    local container="${2:-$DEFAULT_CONTAINER}"
    local user="${3:-$DEFAULT_DB_USER}"
    local db="${4:-$DEFAULT_DB_NAME}"
    sql.check_container "$container" || return 1
    docker exec -i "$container" psql -U "$user" -d "$db" -c "$query"
}

# Ejecutar archivo SQL: sql.exec_file <path-to-sql> [container] [user] [db]
sql.exec_file() {
    if [ -z "$1" ]; then
        _usage "Ejecuta un archivo SQL dentro del contenedor." "sql.exec_file ./DB/PostgreSQL/init/02-seed-data.sql [actor-sites-db] [actor_admin] [actor_sites_db]"
        return 1
    fi
    local file_path="$1"
    local container="${2:-$DEFAULT_CONTAINER}"
    local user="${3:-$DEFAULT_DB_USER}"
    local db="${4:-$DEFAULT_DB_NAME}"
    if [ ! -f "$file_path" ]; then
        echo -e "${YELLOW}Archivo no encontrado: $file_path${NC}"
        return 1
    fi
    sql.check_container "$container" || return 1
    docker exec -i "$container" psql -U "$user" -d "$db" < "$file_path"
}

# Ver registros: sql.view <table> [container] [user] [db]
sql.view() {
    if [ -z "$1" ]; then
        _usage "Muestra todos los registros de una tabla." "sql.view sites [actor-sites-db] [actor_admin] [actor_sites_db]"
        return 1
    fi
    local table="$1"
    local container="${2:-$DEFAULT_CONTAINER}"
    local user="${3:-$DEFAULT_DB_USER}"
    local db="${4:-$DEFAULT_DB_NAME}"
    sql.check_container "$container" || return 1
    docker exec -it "$container" psql -U "$user" -d "$db" -c "SELECT * FROM $table;"
}

# Contar registros: sql.count <table> [container] [user] [db]
sql.count() {
    if [ -z "$1" ]; then
        _usage "Cuenta los registros de una tabla." "sql.count users [actor-sites-db] [actor_admin] [actor_sites_db]"
        return 1
    fi
    local table="$1"
    local container="${2:-$DEFAULT_CONTAINER}"
    local user="${3:-$DEFAULT_DB_USER}"
    local db="${4:-$DEFAULT_DB_NAME}"
    sql.check_container "$container" || return 1
    docker exec -it "$container" psql -U "$user" -d "$db" -c "SELECT COUNT(*) as total FROM $table;"
}

# Ayuda rápida: sql.help
sql.help() {
    cat <<EOF
Funciones disponibles (usar: sql.<comando> ...):
Contenedor por defecto: ${DEFAULT_CONTAINER}

  sql.open [container] [user] [db]
    - Abre una consola psql interactiva.

  sql.tables [container] [user] [db]
    - Lista todas las tablas.

  sql.desc <table> [container] [user] [db]
    - Muestra la estructura de una tabla.

  sql.query "<SQL>" [container] [user] [db]
    - Ejecuta una query SQL.

  sql.exec_file <path-to-sql> [container] [user] [db]
    - Ejecuta un archivo SQL.

  sql.view <table> [container] [user] [db]
    - Muestra registros de una tabla.

  sql.count <table> [container] [user] [db]
    - Cuenta registros de una tabla.

  sql.check_container [container]
    - Verifica si el contenedor está corriendo.

Ejemplos de uso:
  sql.tables
  sql.desc sites
  sql.query "SELECT * FROM users LIMIT 5;"
  sql.view pages
  sql.count menu_items

EOF
}

# Si el script se ejecuta directamente (no se hace source), mostrar ayuda.
_is_sourced() {
    # Si BASH_SOURCE[0] != $0 entonces fue source
    [[ "${BASH_SOURCE[0]}" != "${0}" ]]
}

if ! _is_sourced; then
    # Script ejecutado directamente: mostrar ayuda
    echo -e "${YELLOW}Este script está diseñado para usarse con 'source':${NC}"
    echo -e "${GREEN}source Tools/db-query.sh${NC}"
    echo ""
    echo "Luego podrás usar las funciones sql.* directamente:"
    echo ""
    sql.help
    exit 0
fi
