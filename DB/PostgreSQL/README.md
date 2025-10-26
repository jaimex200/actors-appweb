# PostgreSQL Database Setup - SIMPLIFIED

Base de datos PostgreSQL **ultra simplificada** para iniciar el desarrollo rápidamente.

## ✨ ¿Qué tiene esta versión?

**Solo lo esencial:**
- ✅ 4 tablas básicas (sites, users, pages, menu_items)
- ✅ Sin UUIDs (IDs simples SERIAL)
- ✅ Sin JSONB ni complejidad
- ✅ Solo texto plano
- ✅ Perfecto para empezar

**Lo que NO tiene (puedes agregar después):**
- ❌ Componentes dinámicos
- ❌ Media assets
- ❌ Formularios de contacto
- ❌ Auditoría
- ❌ Metadatos complejos

---

## 🚀 Quick Start

### 1. Iniciar la base de datos

```bash
cd DB/PostgreSQL
docker-compose up -d
```

Esto iniciará:
- **PostgreSQL** en el puerto `5432`
- **pgAdmin** (interfaz web) en `http://localhost:5050`

### 2. Verificar que está corriendo

```bash
docker-compose ps
```

### 3. Ver las tablas creadas

```bash
docker-compose exec postgres psql -U actor_admin -d actor_sites_db -c "\dt"
```

Deberías ver:
```
           List of relations
 Schema |    Name     | Type  |    Owner
--------+-------------+-------+--------------
 public | menu_items  | table | actor_admin
 public | pages       | table | actor_admin
 public | sites       | table | actor_admin
 public | users       | table | actor_admin
```

---

## 📋 Credenciales de Acceso

### PostgreSQL Database
- **Host:** `localhost`
- **Port:** `5432`
- **Database:** `actor_sites_db`
- **User:** `actor_admin`
- **Password:** `actor_password_dev`

**Connection String:**
```
postgresql://actor_admin:actor_password_dev@localhost:5432/actor_sites_db
```

### pgAdmin (Web UI)
- **URL:** http://localhost:5050
- **Email:** `admin@actorsites.local`
- **Password:** `admin`

---

## 🗂️ Estructura Simplificada

### Tablas (solo 4)

```sql
sites           -- Sitios de actores
├── id (serial)
├── slug (varchar)
├── name (varchar)
└── api_key (varchar)

users           -- Un usuario por sitio
├── id (serial)
├── site_id (fk)
├── email (varchar)
└── password_hash (varchar)

pages           -- Páginas con contenido texto
├── id (serial)
├── site_id (fk)
├── slug (varchar)
├── title (varchar)
├── content (text)
└── is_published (boolean)

menu_items      -- Menú de navegación
├── id (serial)
├── site_id (fk)
├── label (varchar)
├── page_id (fk)
└── position (integer)
```

### Relaciones

```
sites (1) ─┬─> users (1)
           ├─> pages (N)
           └─> menu_items (N)
```

---

## 📊 Datos de Prueba

El script `02-seed-data.sql` crea:

### Sitios Demo:
1. **Sonia Benares** (`sonia-benares`)
   - Email: `sonia@example.com`
   - Password: `password123`
   - API Key: `dev_key_sonia_12345`
   - 3 páginas: home, bio, contact

2. **Juan Pérez** (`juan-perez`)
   - Email: `juan@example.com`
   - Password: `password123`
   - API Key: `dev_key_juan_67890`
   - 2 páginas: home, about

---

## 🛠️ Comandos Útiles

### Gestión de Contenedores

```bash
# Iniciar
docker-compose up -d

# Ver logs
docker-compose logs -f postgres

# Detener
docker-compose stop

# Eliminar todo y recrear
docker-compose down -v
docker-compose up -d
```

### Acceso a PostgreSQL CLI

```bash
# Conectar a psql
docker-compose exec postgres psql -U actor_admin -d actor_sites_db

# Ver tablas
docker-compose exec postgres psql -U actor_admin -d actor_sites_db -c "\dt"

# Ver datos de ejemplo
docker-compose exec postgres psql -U actor_admin -d actor_sites_db -c "SELECT * FROM sites;"
```

---

## 🔧 Configuración Flask

Agrega esto a tu `.env`:

```env
DATABASE_URL=postgresql://actor_admin:actor_password_dev@localhost:5432/actor_sites_db
```

### Ejemplo con SQLAlchemy:

```python
from flask import Flask
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://actor_admin:actor_password_dev@localhost:5432/actor_sites_db'
db = SQLAlchemy(app)

# Modelo de ejemplo
class Site(db.Model):
    __tablename__ = 'sites'
    id = db.Column(db.Integer, primary_key=True)
    slug = db.Column(db.String(100), unique=True, nullable=False)
    name = db.Column(db.String(255), nullable=False)
    api_key = db.Column(db.String(255), unique=True, nullable=False)
```

---

## 📝 Queries Simples de Ejemplo

### Obtener un sitio por slug
```sql
SELECT * FROM sites WHERE slug = 'sonia-benares';
```

### Ver todas las páginas de un sitio
```sql
SELECT p.slug, p.title, p.content 
FROM pages p 
WHERE p.site_id = 1 AND p.is_published = true;
```

### Ver menú de un sitio
```sql
SELECT m.label, p.slug as page_slug
FROM menu_items m
JOIN pages p ON m.page_id = p.id
WHERE m.site_id = 1
ORDER BY m.position;
```

### Buscar usuario por email
```sql
SELECT u.*, s.slug as site_slug
FROM users u
JOIN sites s ON u.site_id = s.id
WHERE u.email = 'sonia@example.com';
```

## 🔧 Configuración Flask

Agrega esta configuración a tu `.env` en el backend Flask:

```env
# Database Configuration
DATABASE_URL=postgresql://actor_admin:actor_password_dev@localhost:5432/actor_sites_db

# Database Pool Settings
DB_POOL_SIZE=10
DB_MAX_OVERFLOW=20
```

### Ejemplo de conexión con SQLAlchemy:

```python
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import os

DATABASE_URL = os.getenv("DATABASE_URL")

engine = create_engine(
    DATABASE_URL,
    pool_size=10,
    max_overflow=20,
    pool_pre_ping=True  # Verifica conexiones antes de usarlas
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
```

---

## 📝 Queries de Ejemplo

### Listar todos los sitios
```sql
SELECT slug, name, domain, is_active FROM sites;
```

### Ver páginas de un sitio
```sql
SELECT p.key, p.title, p.is_published 
FROM pages p
JOIN sites s ON p.site_id = s.id
WHERE s.slug = 'sonia-benares'
ORDER BY p.order_index;
```

### Ver componentes de una página
```sql
SELECT c.type, c.config, c.order_index
FROM components c
JOIN pages p ON c.page_id = p.id
JOIN sites s ON p.site_id = s.id
WHERE s.slug = 'sonia-benares' AND p.key = 'home'
ORDER BY c.order_index;
```

### Ver menú de un sitio
```sql
SELECT m.label, m.url, m.order_index
FROM menu_items m
JOIN sites s ON m.site_id = s.id
WHERE s.slug = 'sonia-benares'
ORDER BY m.order_index;
```

---

##  Troubleshooting

### Error: "port 5432 is already allocated"
Ya tienes PostgreSQL local corriendo:
```bash
brew services stop postgresql
# O cambia el puerto en docker-compose.yml a "5433:5432"
```

### Recrear desde cero
```bash
docker-compose down -v
docker-compose up -d
```

---

## 🎯 Próximos Pasos

1. ✅ Iniciar base de datos
2. ⬜ Crear modelos en Flask
3. ⬜ Implementar endpoints básicos
4. ⬜ Más adelante: agregar componentes JSONB, media, etc.

---

## � Tips

- Esta versión es **intencionalmente simple** para empezar rápido
- Puedes agregar complejidad gradualmente según necesites
- El esquema completo anterior está disponible en el historial de Git si lo necesitas
