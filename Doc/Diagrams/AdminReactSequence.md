
```mermaid
sequenceDiagram
  autonumber
  participant Owner as Site Owner (Browser)
  participant FE as React /admin
  participant API as Flask API (Auth)
  participant DB as DB
  participant S3 as Object Storage

  Owner->>API: POST /auth/login (email + password hash)
  API-->>Owner: 200 JWT (stored client-side)
  Owner->>FE: Navigate to /admin (JWT attached on requests)
  FE->>API: POST /v1/admin/menu (CRUD)
  API->>DB: Upsert menu items for site_id
  DB-->>API: OK
  API-->>FE: 200 Updated menu JSON
  Owner->>FE: Upload image (admin)
  FE->>API: POST /media/presign (JWT)
  API-->>FE: 200 Presigned URL
  FE->>S3: PUT file (direct upload)
  FE->>API: PATCH page/components with new asset URL
  API->>DB: Save component config
  API-->>FE: 200 OK (public site reflects changes)