-- ==============================================
-- Queries de Ejemplo para Actor Sites
-- ==============================================

-- ==============================================
-- 1. CONSULTAS BÁSICAS
-- ==============================================

-- Listar todos los sitios activos
SELECT 
    slug,
    name,
    domain,
    is_active,
    created_at
FROM sites
WHERE is_active = true
ORDER BY created_at DESC;

-- Ver detalles completos de un sitio
SELECT 
    s.*,
    COUNT(DISTINCT u.id) as total_users,
    COUNT(DISTINCT p.id) as total_pages,
    COUNT(DISTINCT m.id) as total_menu_items
FROM sites s
LEFT JOIN users u ON s.id = u.site_id
LEFT JOIN pages p ON s.id = p.site_id
LEFT JOIN menu_items m ON s.id = m.site_id
WHERE s.slug = 'sonia-benares'
GROUP BY s.id;

-- ==============================================
-- 2. QUERIES MULTI-TENANT
-- ==============================================

-- Obtener todas las páginas de un sitio específico
SELECT 
    p.key,
    p.title,
    p.meta_description,
    p.is_published,
    p.order_index,
    COUNT(c.id) as component_count
FROM pages p
JOIN sites s ON p.site_id = s.id
LEFT JOIN components c ON p.id = c.page_id
WHERE s.slug = 'sonia-benares'
GROUP BY p.id
ORDER BY p.order_index;

-- Obtener página completa con todos sus componentes
SELECT 
    p.id as page_id,
    p.key as page_key,
    p.title as page_title,
    c.id as component_id,
    c.type as component_type,
    c.config as component_config,
    c.order_index
FROM pages p
JOIN sites s ON p.site_id = s.id
LEFT JOIN components c ON p.id = c.page_id
WHERE s.slug = 'sonia-benares' 
  AND p.key = 'home'
  AND c.is_visible = true
ORDER BY c.order_index;

-- ==============================================
-- 3. MENÚ Y NAVEGACIÓN
-- ==============================================

-- Obtener menú completo de un sitio (incluyendo submenús)
WITH RECURSIVE menu_tree AS (
    -- Nivel 1: Items sin padre
    SELECT 
        m.id,
        m.label,
        m.url,
        m.order_index,
        m.parent_id,
        0 as level,
        CAST(m.label AS TEXT) as path
    FROM menu_items m
    JOIN sites s ON m.site_id = s.id
    WHERE s.slug = 'sonia-benares' 
      AND m.parent_id IS NULL
      AND m.is_visible = true
    
    UNION ALL
    
    -- Niveles siguientes: Items con padre
    SELECT 
        m.id,
        m.label,
        m.url,
        m.order_index,
        m.parent_id,
        mt.level + 1,
        mt.path || ' > ' || m.label
    FROM menu_items m
    JOIN menu_tree mt ON m.parent_id = mt.id
    WHERE m.is_visible = true
)
SELECT * FROM menu_tree
ORDER BY path, order_index;

-- ==============================================
-- 4. COMPONENTES Y CONTENIDO
-- ==============================================

-- Buscar componentes por tipo
SELECT 
    s.slug as site_slug,
    p.key as page_key,
    c.type,
    c.config,
    c.order_index
FROM components c
JOIN pages p ON c.page_id = p.id
JOIN sites s ON p.site_id = s.id
WHERE c.type = 'Hero'
ORDER BY s.slug, p.order_index;

-- Buscar en configuración JSON de componentes
SELECT 
    s.slug,
    p.key,
    c.type,
    c.config->>'title' as title,
    c.config->>'subtitle' as subtitle
FROM components c
JOIN pages p ON c.page_id = p.id
JOIN sites s ON p.site_id = s.id
WHERE c.config->>'title' IS NOT NULL
ORDER BY s.slug;

-- ==============================================
-- 5. MEDIA Y ASSETS
-- ==============================================

-- Listar todos los assets de un sitio
SELECT 
    filename,
    asset_type,
    mime_type,
    file_size / 1024 / 1024 as size_mb,
    width,
    height,
    created_at
FROM media_assets
WHERE site_id = (SELECT id FROM sites WHERE slug = 'sonia-benares')
ORDER BY created_at DESC;

-- Estadísticas de media por sitio
SELECT 
    s.slug,
    s.name,
    COUNT(m.id) as total_assets,
    SUM(m.file_size) / 1024 / 1024 as total_mb,
    COUNT(CASE WHEN m.asset_type = 'image' THEN 1 END) as images,
    COUNT(CASE WHEN m.asset_type = 'video' THEN 1 END) as videos
FROM sites s
LEFT JOIN media_assets m ON s.id = m.site_id
GROUP BY s.id
ORDER BY total_mb DESC;

-- ==============================================
-- 6. FORMULARIOS DE CONTACTO
-- ==============================================

-- Mensajes nuevos por sitio
SELECT 
    s.slug,
    s.name,
    COUNT(*) as new_messages
FROM contact_submissions cs
JOIN sites s ON cs.site_id = s.id
WHERE cs.status = 'new'
GROUP BY s.id
ORDER BY new_messages DESC;

-- Ver últimos mensajes de contacto
SELECT 
    s.slug,
    cs.name,
    cs.email,
    cs.subject,
    LEFT(cs.message, 50) || '...' as message_preview,
    cs.status,
    cs.created_at
FROM contact_submissions cs
JOIN sites s ON cs.site_id = s.id
ORDER BY cs.created_at DESC
LIMIT 10;

-- ==============================================
-- 7. AUDITORÍA Y LOGS
-- ==============================================

-- Actividad reciente de usuarios
SELECT 
    s.slug as site,
    u.email as user,
    al.action,
    al.entity_type,
    al.created_at
FROM audit_logs al
JOIN users u ON al.user_id = u.id
JOIN sites s ON al.site_id = s.id
ORDER BY al.created_at DESC
LIMIT 20;

-- Resumen de acciones por usuario
SELECT 
    u.email,
    COUNT(*) as total_actions,
    COUNT(CASE WHEN al.action = 'CREATE' THEN 1 END) as creates,
    COUNT(CASE WHEN al.action = 'UPDATE' THEN 1 END) as updates,
    COUNT(CASE WHEN al.action = 'DELETE' THEN 1 END) as deletes,
    MAX(al.created_at) as last_action
FROM users u
LEFT JOIN audit_logs al ON u.id = al.user_id
GROUP BY u.id
ORDER BY total_actions DESC;

-- ==============================================
-- 8. PERFORMANCE Y ANÁLISIS
-- ==============================================

-- Sitios con más contenido
SELECT 
    s.slug,
    s.name,
    COUNT(DISTINCT p.id) as pages,
    COUNT(DISTINCT c.id) as components,
    COUNT(DISTINCT m.id) as menu_items,
    COUNT(DISTINCT ma.id) as media_assets,
    s.created_at
FROM sites s
LEFT JOIN pages p ON s.id = p.site_id
LEFT JOIN components c ON p.id = c.page_id
LEFT JOIN menu_items m ON s.id = m.site_id
LEFT JOIN media_assets ma ON s.id = ma.site_id
GROUP BY s.id
ORDER BY pages DESC, components DESC;

-- Componentes más usados
SELECT 
    c.type,
    COUNT(*) as usage_count,
    COUNT(DISTINCT p.site_id) as sites_using
FROM components c
JOIN pages p ON c.page_id = p.id
GROUP BY c.type
ORDER BY usage_count DESC;

-- Usuarios activos (con última actividad)
SELECT 
    u.email,
    u.first_name,
    u.last_name,
    s.slug as site,
    u.last_login_at,
    u.is_active,
    COUNT(al.id) as total_actions
FROM users u
JOIN sites s ON u.site_id = s.id
LEFT JOIN audit_logs al ON u.id = al.user_id
GROUP BY u.id, s.id
ORDER BY u.last_login_at DESC NULLS LAST;

-- ==============================================
-- 9. BÚSQUEDAS FULL-TEXT (Ejemplo básico)
-- ==============================================

-- Buscar en títulos y descripciones de páginas
SELECT 
    s.slug,
    p.key,
    p.title,
    p.meta_description,
    ts_rank(
        to_tsvector('spanish', p.title || ' ' || COALESCE(p.meta_description, '')),
        to_tsquery('spanish', 'actriz')
    ) as rank
FROM pages p
JOIN sites s ON p.site_id = s.id
WHERE to_tsvector('spanish', p.title || ' ' || COALESCE(p.meta_description, ''))
      @@ to_tsquery('spanish', 'actriz')
ORDER BY rank DESC;

-- ==============================================
-- 10. VALIDACIÓN DE INTEGRIDAD
-- ==============================================

-- Páginas sin componentes
SELECT 
    s.slug,
    p.key,
    p.title,
    p.is_published
FROM pages p
JOIN sites s ON p.site_id = s.id
LEFT JOIN components c ON p.id = c.page_id
WHERE c.id IS NULL
ORDER BY s.slug, p.key;

-- Menu items sin página asociada
SELECT 
    s.slug,
    m.label,
    m.url,
    m.page_id
FROM menu_items m
JOIN sites s ON m.site_id = s.id
WHERE m.page_id IS NULL
ORDER BY s.slug, m.order_index;

-- Sitios sin usuarios
SELECT 
    s.slug,
    s.name,
    s.created_at
FROM sites s
LEFT JOIN users u ON s.id = u.site_id
WHERE u.id IS NULL;
