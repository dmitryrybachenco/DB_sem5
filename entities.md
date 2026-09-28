# Сущности базы данных

**Проект:** Система интернет-провайдера

## 1. Перечень сущностей

| № | Сущность | Назначение |
|---|----------|------------|
| 1 | `users` | Пользователи системы (сотрудники и абоненты) |
| 2 | `roles` | Роли в системе |
| 3 | `user_roles` | Связь M2M: пользователи ↔ роли |
| 4 | `audit_logs` | Журнал действий пользователей |
| 5 | `clients` | Профили абонентов (расширение users) |
| 6 | `contracts` | Договоры с абонентами |
| 7 | `tariffs` | Тарифные планы |
| 8 | `services` | Каталог услуг |
| 9 | `tariff_services` | Связь M2M: тарифы ↔ услуги |
| 10 | `subscriptions` | Подписки абонентов на тарифы/услуги |
| 11 | `payments` | Платежи абонентов |
| 12 | `invoices` | Счета на оплату |
| 13 | `addresses` | Адреса подключения |
| 14 | `cities` | Города |
| 15 | `streets` | Улицы |

## 2. Виды связей в модели

| Тип связи | Пример |
|-----------|--------|
| **1:1** | `users` ↔ `clients` |
| **1:M** | `clients` → `contracts`, `tariffs` → `subscriptions` |
| **M:M** | `users` ↔ `roles`, `tariffs` ↔ `services` |

## 3. Описание сущностей

### 3.1. Таблица `users`

| Поле | Тип | Ограничения |
|------|-----|-------------|
| id | BIGSERIAL | PK, NOT NULL |
| email | VARCHAR(255) | UNIQUE, NOT NULL |
| password_hash | VARCHAR(255) | NOT NULL |
| full_name | VARCHAR(255) | NOT NULL |
| phone | VARCHAR(20) | |
| is_active | BOOLEAN | DEFAULT true |
| last_login_at | TIMESTAMP | |
| created_at | TIMESTAMP | DEFAULT now() |
| updated_at | TIMESTAMP | |

**Связи:** 1:1 с `clients`; M:M с `roles` через `user_roles`; 1:M с `audit_logs`.

---

### 3.2. Таблица `roles`

| Поле | Тип | Ограничения |
|------|-----|-------------|
| id | SERIAL | PK |
| name | VARCHAR(50) | UNIQUE, NOT NULL |
| description | TEXT | |

**Связи:** M:M с `users` через `user_roles`.

---

### 3.3. Таблица `user_roles` (M:M с доп. данными)

| Поле | Тип | Ограничения |
|------|-----|-------------|
| id | BIGSERIAL | PK |
| user_id | BIGINT | FK → users.id, NOT NULL |
| role_id | INT | FK → roles.id, NOT NULL |
| assigned_at | TIMESTAMP | DEFAULT now() |
| assigned_by | BIGINT | FK → users.id |

**Уникальность:** UNIQUE(user_id, role_id)

---

### 3.4. Таблица `audit_logs`

| Поле | Тип | Ограничения |
|------|-----|-------------|
| id | BIGSERIAL | PK |
| user_id | BIGINT | FK → users.id |
| action | VARCHAR(100) | NOT NULL |
| entity_type | VARCHAR(50) | |
| entity_id | BIGINT | |
| old_value | JSONB | |
| new_value | JSONB | |
| ip_address | INET | |
| created_at | TIMESTAMP | DEFAULT now() |

**Связи:** M:1 с `users`.

---

### 3.5. Таблица `clients`

| Поле | Тип | Ограничения |
|------|-----|-------------|
| id | BIGSERIAL | PK |
| user_id | BIGINT | FK → users.id, UNIQUE, NOT NULL |
| passport_series | VARCHAR(10) | |
| passport_number | VARCHAR(20) | |
| birth_date | DATE | |
| address_id | BIGINT | FK → addresses.id |
| client_type | VARCHAR(20) | CHECK IN ('individual','legal') |
| created_at | TIMESTAMP | DEFAULT now() |

**Связи:** 1:1 с `users`; M:1 с `addresses`; 1:M с `contracts`, `invoices`.

---

### 3.6. Таблица `contracts`

| Поле | Тип | Ограничения |
|------|-----|-------------|
| id | BIGSERIAL | PK |
| client_id | BIGINT | FK → clients.id, NOT NULL |
| contract_number | VARCHAR(50) | UNIQUE, NOT NULL |
| signed_at | DATE | NOT NULL |
| terminated_at | DATE | |
| status | VARCHAR(20) | CHECK IN ('active','suspended','terminated') |

**Связи:** M:1 с `clients`; 1:M с `subscriptions`.

---

### 3.7. Таблица `tariffs`

| Поле | Тип | Ограничения |
|------|-----|-------------|
| id | SERIAL | PK |
| name | VARCHAR(100) | NOT NULL |
| speed_mbps | INT | CHECK > 0 |
| price | NUMERIC(10,2) | NOT NULL, CHECK >= 0 |
| is_archived | BOOLEAN | DEFAULT false |
| created_at | TIMESTAMP | DEFAULT now() |

**Связи:** 1:M с `subscriptions`; M:M с `services` через `tariff_services`.

---

### 3.8. Таблица `services`

| Поле | Тип | Ограничения |
|------|-----|-------------|
| id | SERIAL | PK |
| name | VARCHAR(100) | UNIQUE, NOT NULL |
| description | TEXT | |
| base_price | NUMERIC(10,2) | |

**Связи:** M:M с `tariffs` через `tariff_services`; 1:M с `subscriptions`.

---

### 3.9. Таблица `tariff_services` (M:M с доп. данными)

| Поле | Тип | Ограничения |
|------|-----|-------------|
| id | BIGSERIAL | PK |
| tariff_id | INT | FK → tariffs.id |
| service_id | INT | FK → services.id |
| price_in_tariff | NUMERIC(10,2) | |
| is_included | BOOLEAN | DEFAULT true |

**Уникальность:** UNIQUE(tariff_id, service_id)

---

### 3.10. Таблица `subscriptions`

| Поле | Тип | Ограничения |
|------|-----|-------------|
| id | BIGSERIAL | PK |
| contract_id | BIGINT | FK → contracts.id |
| tariff_id | INT | FK → tariffs.id |
| service_id | INT | FK → services.id, NULL |
| start_date | DATE | NOT NULL |
| end_date | DATE | |
| status | VARCHAR(20) | CHECK IN ('active','paused','closed') |

**Связи:** M:1 с `contracts`, `tariffs`, `services`.

---

### 3.11. Таблица `invoices`

| Поле | Тип | Ограничения |
|------|-----|-------------|
| id | BIGSERIAL | PK |
| client_id | BIGINT | FK → clients.id |
| period_start | DATE | NOT NULL |
| period_end | DATE | NOT NULL |
| amount | NUMERIC(10,2) | NOT NULL |
| status | VARCHAR(20) | CHECK IN ('unpaid','paid','overdue') |
| created_at | TIMESTAMP | DEFAULT now() |

**Связи:** M:1 с `clients`; 1:M с `payments`.

---

### 3.12. Таблица `payments`

| Поле | Тип | Ограничения |
|------|-----|-------------|
| id | BIGSERIAL | PK |
| invoice_id | BIGINT | FK → invoices.id |
| amount | NUMERIC(10,2) | NOT NULL |
| method | VARCHAR(20) | CHECK IN ('card','cash','transfer') |
| paid_at | TIMESTAMP | DEFAULT now() |
| external_id | VARCHAR(100) | |

**Связи:** M:1 с `invoices`.

---

### 3.13. Таблица `addresses`

| Поле | Тип | Ограничения |
|------|-----|-------------|
| id | BIGSERIAL | PK |
| street_id | INT | FK → streets.id |
| house | VARCHAR(20) | NOT NULL |
| apartment | VARCHAR(20) | |
| postal_code | VARCHAR(10) | |

**Связи:** M:1 с `streets`; 1:M с `clients`.

---

### 3.14. Таблица `streets`

| Поле | Тип | Ограничения |
|------|-----|-------------|
| id | SERIAL | PK |
| city_id | INT | FK → cities.id |
| name | VARCHAR(100) | NOT NULL |

**Связи:** M:1 с `cities`; 1:M с `addresses`.

---

### 3.15. Таблица `cities`

| Поле | Тип | Ограничения |
|------|-----|-------------|
| id | SERIAL | PK |
| name | VARCHAR(100) | NOT NULL |
| region | VARCHAR(100) | |

**Связи:** 1:M с `streets`.
