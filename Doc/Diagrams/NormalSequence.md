```mermaid
sequenceDiagram
  autonumber
  participant U as User Browser (Actor Site)
  participant FE as React (Actor A Build)
  participant API as Flask API
  participant DB as DB (Postgres/MySQL)
  participant CDN as CDN (Images/Video)

  U->>FE: GET https://actorA.com (static assets)
  FE->>API: GET /v1/sites/actorA/menu (with API key/slug)
  API->>DB: Query menu for site_id(A)
  DB-->>API: Menu JSON
  API-->>FE: 200 Menu JSON
  FE->>API: GET /v1/sites/actorA/pages/home
  API->>DB: Load page + components for site_id(A)
  DB-->>API: Page JSON (component config + media refs)
  API-->>FE: 200 Page JSON
  FE->>CDN: GET images/video by URL
  CDN-->>FE: Media bytes
  FE-->>U: Render components dynamically