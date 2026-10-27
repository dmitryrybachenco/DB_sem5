CREATE TABLE cities (
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(100) NOT NULL,
    region  VARCHAR(100)
);

CREATE TABLE streets (
    id       SERIAL PRIMARY KEY,
    city_id  INTEGER NOT NULL REFERENCES cities(id),
    name     VARCHAR(100) NOT NULL
);

CREATE INDEX idx_streets_city_id ON streets(city_id);

CREATE TABLE addresses (
    id           BIGSERIAL PRIMARY KEY,
    street_id    INTEGER NOT NULL REFERENCES streets(id),
    house        VARCHAR(20) NOT NULL,
    apartment    VARCHAR(20),
    postal_code  VARCHAR(10)
);

CREATE INDEX idx_addresses_street_id ON addresses(street_id);

CREATE TABLE users (
    id             BIGSERIAL PRIMARY KEY,
    email          VARCHAR(255) UNIQUE NOT NULL,
    password       VARCHAR(255) NOT NULL,
    full_name      VARCHAR(255) NOT NULL,
    phone          VARCHAR(20),
    is_active      BOOLEAN NOT NULL DEFAULT TRUE,
    last_login_at  TIMESTAMP,
    created_at     TIMESTAMP NOT NULL DEFAULT now(),
    updated_at     TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);

CREATE TABLE roles (
    id           SERIAL PRIMARY KEY,
    name         VARCHAR(50) UNIQUE NOT NULL,
    description  TEXT
);

CREATE TABLE user_roles (
    id           BIGSERIAL PRIMARY KEY,
    user_id      BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id      INTEGER NOT NULL REFERENCES roles(id),
    assigned_at  TIMESTAMP NOT NULL DEFAULT now(),
    assigned_by  BIGINT REFERENCES users(id),
    UNIQUE (user_id, role_id)
);

CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX idx_user_roles_role_id ON user_roles(role_id);

CREATE TABLE audit_logs (
    id           BIGSERIAL PRIMARY KEY,
    user_id      BIGINT REFERENCES users(id),
    action       VARCHAR(100) NOT NULL,
    entity_type  VARCHAR(50),
    entity_id    BIGINT,
    old_value    JSONB,
    new_value    JSONB,
    ip_address   INET,
    created_at   TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

CREATE TABLE clients (
    id               BIGSERIAL PRIMARY KEY,
    user_id          BIGINT UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    passport_series  VARCHAR(10),
    passport_number  VARCHAR(20),
    birth_date       DATE,
    address_id       BIGINT REFERENCES addresses(id),
    client_type      VARCHAR(20) CHECK (client_type IN ('individual','legal')),
    created_at       TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX idx_clients_user_id ON clients(user_id);

CREATE TABLE contracts (
    id               BIGSERIAL PRIMARY KEY,
    client_id        BIGINT NOT NULL REFERENCES clients(id),
    contract_number  VARCHAR(50) UNIQUE NOT NULL,
    signed_at        DATE NOT NULL,
    terminated_at    DATE,
    status           VARCHAR(20) CHECK (status IN ('active','suspended','terminated'))
);

CREATE INDEX idx_contracts_client_id ON contracts(client_id);

CREATE TABLE tariffs (
    id           SERIAL PRIMARY KEY,
    name         VARCHAR(100) NOT NULL,
    speed_mbps   INTEGER CHECK (speed_mbps > 0),
    price        NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    is_archived  BOOLEAN NOT NULL DEFAULT FALSE,
    created_at   TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE services (
    id           SERIAL PRIMARY KEY,
    name         VARCHAR(100) UNIQUE NOT NULL,
    description  TEXT,
    base_price   NUMERIC(10,2)
);

CREATE TABLE tariff_services (
    id               BIGSERIAL PRIMARY KEY,
    tariff_id        INTEGER NOT NULL REFERENCES tariffs(id) ON DELETE CASCADE,
    service_id       INTEGER NOT NULL REFERENCES services(id),
    price_in_tariff  NUMERIC(10,2),
    is_included      BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE (tariff_id, service_id)
);

CREATE TABLE subscriptions (
    id           BIGSERIAL PRIMARY KEY,
    contract_id  BIGINT NOT NULL REFERENCES contracts(id),
    tariff_id    INTEGER NOT NULL REFERENCES tariffs(id),
    service_id   INTEGER REFERENCES services(id),
    start_date   DATE NOT NULL,
    end_date     DATE,
    status       VARCHAR(20) CHECK (status IN ('active','paused','closed'))
);

CREATE INDEX idx_subscriptions_contract_id ON subscriptions(contract_id);

CREATE TABLE invoices (
    id            BIGSERIAL PRIMARY KEY,
    client_id     BIGINT NOT NULL REFERENCES clients(id),
    period_start  DATE NOT NULL,
    period_end    DATE NOT NULL,
    amount        NUMERIC(10,2) NOT NULL,
    status        VARCHAR(20) CHECK (status IN ('unpaid','paid','overdue')),
    created_at    TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX idx_invoices_client_id ON invoices(client_id);

CREATE TABLE payments (
    id           BIGSERIAL PRIMARY KEY,
    invoice_id   BIGINT NOT NULL REFERENCES invoices(id),
    amount       NUMERIC(10,2) NOT NULL,
    method       VARCHAR(20) CHECK (method IN ('card','cash','transfer')),
    paid_at      TIMESTAMP NOT NULL DEFAULT now(),
    external_id  VARCHAR(100)
);

CREATE INDEX idx_payments_invoice_id ON payments(invoice_id);