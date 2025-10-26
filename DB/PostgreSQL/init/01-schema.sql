-- ==============================================
-- Actor Sites Database Schema - SIMPLIFIED
-- PostgreSQL 16
-- Minimal version for easy development start
-- ==============================================

-- ==============================================
-- Table: sites
-- Stores information about each actor's site
-- ==============================================
CREATE TABLE sites (
    id SERIAL PRIMARY KEY,
    slug VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    api_key VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sites_slug ON sites(slug);

-- ==============================================
-- Table: users
-- Stores user accounts (site owners)
-- ==============================================
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    site_id INTEGER NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_site_id ON users(site_id);

-- ==============================================
-- Table: pages
-- Stores page definitions for each site
-- ==============================================
CREATE TABLE pages (
    id SERIAL PRIMARY KEY,
    site_id INTEGER NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    slug VARCHAR(100) NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    is_published BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(site_id, slug)
);

CREATE INDEX idx_pages_site_id ON pages(site_id);
CREATE INDEX idx_pages_slug ON pages(slug);

-- ==============================================
-- Table: menu_items
-- Stores navigation menu
-- ==============================================
CREATE TABLE menu_items (
    id SERIAL PRIMARY KEY,
    site_id INTEGER NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    label VARCHAR(100) NOT NULL,
    page_id INTEGER REFERENCES pages(id) ON DELETE CASCADE,
    position INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_menu_items_site_id ON menu_items(site_id);
CREATE INDEX idx_menu_items_position ON menu_items(site_id, position);

-- ==============================================
-- Comments for documentation
-- ==============================================
COMMENT ON TABLE sites IS 'Actor sites (multi-tenant)';
COMMENT ON TABLE users IS 'Site owners - one user per site';
COMMENT ON TABLE pages IS 'Pages with simple text content';
COMMENT ON TABLE menu_items IS 'Navigation menu - links to pages';
