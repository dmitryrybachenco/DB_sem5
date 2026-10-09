# Даталогическая модель БД

**Проект:** Система интернет-провайдера.

**СУБД:** PostgreSQL 15+.

**Нормальная форма:** 3НФ / BCNF.

## 1. Общие сведения

| Параметр | Значение |
|----------|----------|
| СУБД | PostgreSQL 15+ |
| Кодировка | UTF-8 |
| Схема | `public` |
| Всего таблиц | 15 |
| Тип ключей | Суррогатные (`SERIAL`, `BIGSERIAL`) |
| Нормальная форма | 3НФ / BCNF |

## 2. Условные обозначения

| Обозначение | Значение |
|-------------|----------|
| **PK** | Primary Key — первичный ключ |
| **FK** | Foreign Key — внешний ключ |
| **UQ** | Unique — уникальное значение |
| **NN** | Not Null — обязательное поле |
| **CK** | Check — проверка условия |
| **DF** | Default — значение по умолчанию |
| **IX** | Index — индекс |

## 3. Описание таблиц

### 3.1. `cities` — Города

| № | Поле | Тип | Ключ | Ограничения | Описание |
|---|------|-----|------|-------------|----------|
| 1 | `id` | SERIAL | PK | NOT NULL | Идентификатор |
| 2 | `name` | VARCHAR(100) | | NOT NULL | Название города |
| 3 | `region` | VARCHAR(100) | | | Регион |

**Связи:** 1:M с `streets`.

---

### 4.2. `streets` — Улицы

| № | Поле | Тип | Ключ | Ограничения | Описание |
|---|------|-----|------|-------------|----------|
| 1 | `id` | SERIAL | PK | NOT NULL | Идентификатор |
| 2 | `city_id` | INTEGER | FK | NOT NULL → `cities(id)` | Город |
| 3 | `name` | VARCHAR(100) | | NOT NULL | Название улицы |

**Индексы:** PK по `id`, IX по `city_id`.
**Связи:** M:1 с `cities`; 1:M с `addresses`.

---

### 3.3. `addresses` — Адреса

| № | Поле | Тип | Ключ | Ограничения | Описание |
|---|------|-----|------|-------------|----------|
| 1 | `id` | BIGSERIAL | PK | NOT NULL | Идентификатор |
| 2 | `street_id` | INTEGER | FK | NOT NULL → `streets(id)` | Улица |
| 3 | `house` | VARCHAR(20) | | NOT NULL | Номер дома |
| 4 | `apartment` | VARCHAR(20) | | | Квартира |
| 5 | `postal_code` | VARCHAR(10) | | | Почтовый индекс |

**Индексы:** PK по `id`, IX по `street_id`.
**Связи:** M:1 с `streets`; 1:M с `clients`.

---

### 3.4. `users` — Пользователи

| № | Поле | Тип | Ключ | Ограничения | Описание |
|---|------|-----|------|-------------|----------|
| 1 | `id` | BIGSERIAL | PK | NOT NULL | Идентификатор |
| 2 | `email` | VARCHAR(255) | UQ | NOT NULL, UNIQUE | Email (логин) |
| 3 | `password_hash` | VARCHAR(255) | | NOT NULL | Хеш пароля |
| 4 | `full_name` | VARCHAR(255) | | NOT NULL | ФИО |
| 5 | `phone` | VARCHAR(20) | | | Телефон |
| 6 | `is_active` | BOOLEAN | | NOT NULL, DEFAULT true | Активен |
| 7 | `last_login_at` | TIMESTAMP | | | Последний вход |
| 8 | `created_at` | TIMESTAMP | | NOT NULL, DEFAULT now() | Дата создания |
| 9 | `updated_at` | TIMESTAMP | | | Дата обновления |

**Индексы:** PK по `id`, UQ по `email`.
**Связи:** 1:1 с `clients`; M:M с `roles` через `user_roles`; 1:M с `audit_logs`, `user_roles.assigned_by`.

---

### 3.5. `roles` — Роли

| № | Поле | Тип | Ключ | Ограничения | Описание |
|---|------|-----|------|-------------|----------|
| 1 | `id` | SERIAL | PK | NOT NULL | Идентификатор |
| 2 | `name` | VARCHAR(50) | UQ | NOT NULL, UNIQUE | Название роли |
| 3 | `description` | TEXT | | | Описание |

**Индексы:** PK по `id`, UQ по `name`.
**Связи:** M:M с `users` через `user_roles`.

---

### 3.6. `user_roles` — Роли пользователей (M:M)

| № | Поле | Тип | Ключ | Ограничения | Описание |
|---|------|-----|------|-------------|----------|
| 1 | `id` | BIGSERIAL | PK | NOT NULL | Идентификатор |
| 2 | `user_id` | BIGINT | FK | NOT NULL → `users(id)` ON DELETE CASCADE | Пользователь |
| 3 | `role_id` | INTEGER | FK | NOT NULL → `roles(id)` | Роль |
| 4 | `assigned_at` | TIMESTAMP | | NOT NULL, DEFAULT now() | Дата назначения |
| 5 | `assigned_by` | BIGINT | FK | → `users(id)` | Кто назначил |

**Индексы:** PK по `id`, UQ по `(user_id, role_id)`, IX по `user_id`, IX по `role_id`.
**Связи:** M:1 с `users` (дважды); M:1 с `roles`.

---

### 3.7. `audit_logs` — Журнал действий

| № | Поле | Тип | Ключ | Ограничения | Описание |
|---|------|-----|------|-------------|----------|
| 1 | `id` | BIGSERIAL | PK | NOT NULL | Идентификатор |
| 2 | `user_id` | BIGINT | FK | → `users(id)` | Пользователь |
| 3 | `action` | VARCHAR(100) | | NOT NULL | Действие |
| 4 | `entity_type` | VARCHAR(50) | | | Тип сущности |
| 5 | `entity_id` | BIGINT | | | ID сущности |
| 6 | `old_value` | JSONB | | | Старое значение |
| 7 | `new_value` | JSONB | | | Новое значение |
| 8 | `ip_address` | INET | | | IP-адрес |
| 9 | `created_at` | TIMESTAMP | | NOT NULL, DEFAULT now() | Дата |

**Индексы:** PK по `id`, IX по `user_id`, IX по `created_at`.
**Связи:** M:1 с `users`.

---

### 3.8. `clients` — Абоненты

| № | Поле | Тип | Ключ | Ограничения | Описание |
|---|------|-----|------|-------------|----------|
| 1 | `id` | BIGSERIAL | PK | NOT NULL | Идентификатор |
| 2 | `user_id` | BIGINT | UQ, FK | NOT NULL, UNIQUE → `users(id)` ON DELETE CASCADE | Пользователь (1:1) |
| 3 | `passport_series` | VARCHAR(10) | | | Серия паспорта |
| 4 | `passport_number` | VARCHAR(20) | | | Номер паспорта |
| 5 | `birth_date` | DATE | | | Дата рождения |
| 6 | `address_id` | BIGINT | FK | → `addresses(id)` | Адрес |
| 7 | `client_type` | VARCHAR(20) | | CHECK IN ('individual','legal') | Тип абонента |
| 8 | `created_at` | TIMESTAMP | | NOT NULL, DEFAULT now() | Дата создания |

**Индексы:** PK по `id`, UQ по `user_id`, IX по `address_id`.
**Связи:** 1:1 с `users`; M:1 с `addresses`; 1:M с `contracts`, `invoices`.

---

### 3.9. `contracts` — Договоры

| № | Поле | Тип | Ключ | Ограничения | Описание |
|---|------|-----|------|-------------|----------|
| 1 | `id` | BIGSERIAL | PK | NOT NULL | Идентификатор |
| 2 | `client_id` | BIGINT | FK | NOT NULL → `clients(id)` | Абонент |
| 3 | `contract_number` | VARCHAR(50) | UQ | NOT NULL, UNIQUE | Номер договора |
| 4 | `signed_at` | DATE | | NOT NULL | Дата подписания |
| 5 | `terminated_at` | DATE | | | Дата расторжения |
| 6 | `status` | VARCHAR(20) | | CHECK IN ('active','suspended','terminated') | Статус |

**Индексы:** PK по `id`, UQ по `contract_number`, IX по `client_id`.
**Связи:** M:1 с `clients`; 1:M с `subscriptions`.

---

### 3.10. `tariffs` — Тарифы

| № | Поле | Тип | Ключ | Ограничения | Описание |
|---|------|-----|------|-------------|----------|
| 1 | `id` | SERIAL | PK | NOT NULL | Идентификатор |
| 2 | `name` | VARCHAR(100) | | NOT NULL | Название тарифа |
| 3 | `speed_mbps` | INTEGER | | CHECK (speed_mbps > 0) | Скорость, Мбит/с |
| 4 | `price` | NUMERIC(10,2) | | NOT NULL, CHECK (price >= 0) | Цена |
| 5 | `is_archived` | BOOLEAN | | NOT NULL, DEFAULT false | Архивный |
| 6 | `created_at` | TIMESTAMP | | NOT NULL, DEFAULT now() | Дата создания |

**Индексы:** PK по `id`.
**Связи:** 1:M с `subscriptions`; M:M с `services` через `tariff_services`.

---

### 3.11. `services` — Услуги

| № | Поле | Тип | Ключ | Ограничения | Описание |
|---|------|-----|------|-------------|----------|
| 1 | `id` | SERIAL | PK | NOT NULL | Идентификатор |
| 2 | `name` | VARCHAR(100) | UQ | NOT NULL, UNIQUE | Название услуги |
| 3 | `description` | TEXT | | | Описание |
| 4 | `base_price` | NUMERIC(10,2) | | | Базовая цена |

**Индексы:** PK по `id`, UQ по `name`.
**Связи:** M:M с `tariffs` через `tariff_services`; 1:M с `subscriptions`.

---

### 3.12. `tariff_services` — Услуги в тарифах (M:M)

| № | Поле | Тип | Ключ | Ограничения | Описание |
|---|------|-----|------|-------------|----------|
| 1 | `id` | BIGSERIAL | PK | NOT NULL | Идентификатор |
| 2 | `tariff_id` | INTEGER | FK | NOT NULL → `tariffs(id)` ON DELETE CASCADE | Тариф |
| 3 | `service_id` | INTEGER | FK | NOT NULL → `services(id)` | Услуга |
| 4 | `price_in_tariff` | NUMERIC(10,2) | | | Цена услуги в тарифе |
| 5 | `is_included` | BOOLEAN | | NOT NULL, DEFAULT true | Включена |

**Индексы:** PK по `id`, UQ по `(tariff_id, service_id)`.
**Связи:** M:1 с `tariffs`; M:1 с `services`.

---

### 3.13. `subscriptions` — Подписки

| № | Поле | Тип | Ключ | Ограничения | Описание |
|---|------|-----|------|-------------|----------|
| 1 | `id` | BIGSERIAL | PK | NOT NULL | Идентификатор |
| 2 | `contract_id` | BIGINT | FK | NOT NULL → `contracts(id)` | Договор |
| 3 | `tariff_id` | INTEGER | FK | NOT NULL → `tariffs(id)` | Тариф |
| 4 | `service_id` | INTEGER | FK | → `services(id)` | Услуга (опц.) |
| 5 | `start_date` | DATE | | NOT NULL | Дата начала |
| 6 | `end_date` | DATE | | | Дата окончания |
| 7 | `status` | VARCHAR(20) | | CHECK IN ('active','paused','closed') | Статус |

**Индексы:** PK по `id`, IX по `contract_id`, IX по `tariff_id`, IX по `service_id`.
**Связи:** M:1 с `contracts`, `tariffs`, `services`.

---

### 3.14. `invoices` — Счета

| № | Поле | Тип | Ключ | Ограничения | Описание |
|---|------|-----|------|-------------|----------|
| 1 | `id` | BIGSERIAL | PK | NOT NULL | Идентификатор |
| 2 | `client_id` | BIGINT | FK | NOT NULL → `clients(id)` | Абонент |
| 3 | `period_start` | DATE | | NOT NULL | Начало периода |
| 4 | `period_end` | DATE | | NOT NULL | Конец периода |
| 5 | `amount` | NUMERIC(10,2) | | NOT NULL | Сумма |
| 6 | `status` | VARCHAR(20) | | CHECK IN ('unpaid','paid','overdue') | Статус |
| 7 | `created_at` | TIMESTAMP | | NOT NULL, DEFAULT now() | Дата создания |

**Индексы:** PK по `id`, IX по `client_id`.
**Связи:** M:1 с `clients`; 1:M с `payments`.

---

### 3.15. `payments` — Платежи

| № | Поле | Тип | Ключ | Ограничения | Описание |
|---|------|-----|------|-------------|----------|
| 1 | `id` | BIGSERIAL | PK | NOT NULL | Идентификатор |
| 2 | `invoice_id` | BIGINT | FK | NOT NULL → `invoices(id)` | Счёт |
| 3 | `amount` | NUMERIC(10,2) | | NOT NULL | Сумма |
| 4 | `method` | VARCHAR(20) | | CHECK IN ('card','cash','transfer') | Метод |
| 5 | `paid_at` | TIMESTAMP | | NOT NULL, DEFAULT now() | Дата платежа |
| 6 | `external_id` | VARCHAR(100) | | | ID во внешней системе |

**Индексы:** PK по `id`, IX по `invoice_id`.
**Связи:** M:1 с `invoices`.

---

## 4. Сводная таблица связей

| Родитель | Дочерняя | Тип | FK | ON DELETE |
|----------|----------|-----|-----|-----------|
| `cities` | `streets` | 1:M | `streets.city_id` | NO ACTION |
| `streets` | `addresses` | 1:M | `addresses.street_id` | NO ACTION |
| `addresses` | `clients` | 1:M | `clients.address_id` | NO ACTION |
| `users` | `clients` | 1:1 | `clients.user_id` | CASCADE |
| `users` | `user_roles` | 1:M | `user_roles.user_id` | CASCADE |
| `roles` | `user_roles` | 1:M | `user_roles.role_id` | NO ACTION |
| `users` | `audit_logs` | 1:M | `audit_logs.user_id` | NO ACTION |
| `clients` | `contracts` | 1:M | `contracts.client_id` | NO ACTION |
| `clients` | `invoices` | 1:M | `invoices.client_id` | NO ACTION |
| `contracts` | `subscriptions` | 1:M | `subscriptions.contract_id` | NO ACTION |
| `tariffs` | `subscriptions` | 1:M | `subscriptions.tariff_id` | NO ACTION |
| `services` | `subscriptions` | 1:M | `subscriptions.service_id` | NO ACTION |
| `tariffs` | `tariff_services` | 1:M | `tariff_services.tariff_id` | CASCADE |
| `services` | `tariff_services` | 1:M | `tariff_services.service_id` | NO ACTION |
| `invoices` | `payments` | 1:M | `payments.invoice_id` | NO ACTION |
| `users` | `user_roles` | 1:M | `user_roles.assigned_by` | NO ACTION |

**M:M-связи (через промежуточные таблицы):**
- `users` ↔ `roles` через `user_roles`
- `tariffs` ↔ `services` через `tariff_services`

---

## 5. Индексы

| Индекс | Таблица | Поля | Назначение |
|--------|---------|------|------------|
| `idx_users_email` | `users` | `email` | Поиск по email |
| `idx_clients_user_id` | `clients` | `user_id` | Связь 1:1 |
| `idx_contracts_client_id` | `contracts` | `client_id` | Договоры абонента |
| `idx_invoices_client_id` | `invoices` | `client_id` | Счета абонента |
| `idx_payments_invoice_id` | `payments` | `invoice_id` | Платежи по счёту |
| `idx_audit_logs_user_id` | `audit_logs` | `user_id` | Действия пользователя |
| `idx_audit_logs_created_at` | `audit_logs` | `created_at` | Фильтр по дате |
| `idx_user_roles_user_id` | `user_roles` | `user_id` | Роли пользователя |
| `idx_user_roles_role_id` | `user_roles` | `role_id` | Пользователи роли |
| `idx_subscriptions_contract_id` | `subscriptions` | `contract_id` | Подписки договора |
| `idx_streets_city_id` | `streets` | `city_id` | Улицы города |
| `idx_addresses_street_id` | `addresses` | `street_id` | Адреса улицы |
