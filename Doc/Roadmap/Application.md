::: mermaid
gantt
    title Actor Sites — Solo Delivery Plan
    dateFormat  YYYY-MM-DD
    axisFormat  %b %d
    excludes    weekends

    section Foundations
    Sprint 0 — Architecture, repos, CI     :done,   s0, 2025-10-20, 7d
    Sprint 1 — DB schema & migrations      :active, s1, after s0, 10d

    section API (Flask)
    Sprint 2 — Public Read API (menu/pages):        s2, after s1, 10d
    Sprint 3 — Auth (JWT) & /admin shell   :        s3, after s2, 10d

    section Frontend (React per actor)
    Sprint 4 — Public site scaffold & data :        s4, after s2, 10d
    Sprint 5 — Component registry & pages  :        s5, after s4, 10d

    section Admin (/admin served by Flask)
    Sprint 6 — Admin CRUD (menu/pages/comp):        s6, after s3, 12d
    Sprint 7 — Media: presign + uploads    :        s7, after s6, 10d

    section Hardening & Launch
    Sprint 8 — Multi-tenant + domains/CORS :        s8, after s5, 10d
    Sprint 9 — Hosting & pipelines         :        s9, after s8, 10d
    Sprint 10 — QA, obs, security          :        s10, after s9, 14d
    Sprint 11 — Pilot actors & polish      :        s11, after s10, 14d