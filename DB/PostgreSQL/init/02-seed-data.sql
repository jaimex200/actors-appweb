-- ==============================================
-- Seed Data - SIMPLIFIED
-- Actor Sites Database
-- ==============================================

-- Insert demo sites
INSERT INTO sites (slug, name, api_key) VALUES
    ('sonia-benares', 'Sonia Benares', 'dev_key_sonia_12345'),
    ('juan-perez', 'Juan Pérez', 'dev_key_juan_67890');

-- Insert demo users (password: 'password123')
-- Password hash generated with: python3 -c "from werkzeug.security import generate_password_hash; print(generate_password_hash('password123'))"
INSERT INTO users (site_id, email, password_hash) VALUES
    (1, 'sonia@example.com', 'pbkdf2:sha256:260000$salt$hash'),
    (2, 'juan@example.com', 'pbkdf2:sha256:260000$salt$hash');

-- Insert demo pages for Sonia Benares (site_id = 1)
INSERT INTO pages (site_id, slug, title, content, is_published) VALUES
    (1, 'home', 'Inicio', 'Bienvenido a mi sitio web. Soy actriz profesional con más de 10 años de experiencia.', true),
    (1, 'bio', 'Biografía', 'Mi nombre es Sonia Benares. Comencé mi carrera en el teatro en 2010. He participado en numerosas producciones de teatro, cine y televisión.', true),
    (1, 'contact', 'Contacto', 'Email: sonia@example.com | Teléfono: +34 600 000 000', true);

-- Insert demo pages for Juan Pérez (site_id = 2)
INSERT INTO pages (site_id, slug, title, content, is_published) VALUES
    (2, 'home', 'Bienvenido', 'Hola, soy Juan Pérez, actor y director de teatro.', true),
    (2, 'about', 'Sobre mí', 'Actor profesional especializado en teatro clásico.', true);

-- Insert menu items for Sonia Benares
INSERT INTO menu_items (site_id, label, page_id, position) VALUES
    (1, 'Inicio', 1, 0),
    (1, 'Biografía', 2, 1),
    (1, 'Contacto', 3, 2);

-- Insert menu items for Juan Pérez
INSERT INTO menu_items (site_id, label, page_id, position) VALUES
    (2, 'Inicio', 4, 0),
    (2, 'Sobre mí', 5, 1);

-- ==============================================
-- Verify data
-- ==============================================
SELECT 
    (SELECT COUNT(*) FROM sites) as total_sites,
    (SELECT COUNT(*) FROM users) as total_users,
    (SELECT COUNT(*) FROM pages) as total_pages,
    (SELECT COUNT(*) FROM menu_items) as total_menu_items;
