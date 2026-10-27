BEGIN;

INSERT INTO cities (name, region) VALUES
    ('Минск',       'Минская область'),
    ('Гомель',      'Гомельская область'),
    ('Брест',       'Брестская область'),
    ('Витебск',     'Витебская область'),
    ('Гродно',      'Гродненская область');

INSERT INTO streets (city_id, name) VALUES
    ((SELECT id FROM cities WHERE name = 'Минск'),   'пр. Независимости'),
    ((SELECT id FROM cities WHERE name = 'Минск'),   'ул. Притыцкого'),
    ((SELECT id FROM cities WHERE name = 'Минск'),   'ул. Немига'),
    ((SELECT id FROM cities WHERE name = 'Гомель'),  'ул. Советская'),
    ((SELECT id FROM cities WHERE name = 'Гомель'),  'пр. Ленина'),
    ((SELECT id FROM cities WHERE name = 'Брест'),   'ул. Советская'),
    ((SELECT id FROM cities WHERE name = 'Витебск'), 'ул. Ленина'),
    ((SELECT id FROM cities WHERE name = 'Гродно'),  'ул. Советская');

INSERT INTO addresses (street_id, house, apartment, postal_code) VALUES
    ((SELECT id FROM streets WHERE name = 'пр. Независимости' AND city_id = (SELECT id FROM cities WHERE name = 'Минск')), '12',  '45',  '220012'),
    ((SELECT id FROM streets WHERE name = 'ул. Притыцкого'   AND city_id = (SELECT id FROM cities WHERE name = 'Минск')), '88',  '101', '220017'),
    ((SELECT id FROM streets WHERE name = 'ул. Немига'       AND city_id = (SELECT id FROM cities WHERE name = 'Минск')), '5',   '7',   '220030'),
    ((SELECT id FROM streets WHERE name = 'ул. Советская'    AND city_id = (SELECT id FROM cities WHERE name = 'Гомель')), '3',   NULL,  '246000'),
    ((SELECT id FROM streets WHERE name = 'пр. Ленина'       AND city_id = (SELECT id FROM cities WHERE name = 'Гомель')), '15',  '22',  '246017'),
    ((SELECT id FROM streets WHERE name = 'ул. Советская'    AND city_id = (SELECT id FROM cities WHERE name = 'Брест')),  '7',   '3',   '224000'),
    ((SELECT id FROM streets WHERE name = 'ул. Ленина'       AND city_id = (SELECT id FROM cities WHERE name = 'Витебск')), '42', '8',   '210000'),
    ((SELECT id FROM streets WHERE name = 'ул. Советская'    AND city_id = (SELECT id FROM cities WHERE name = 'Гродно')),  '9',   '14',  '230000');

INSERT INTO roles (name, description) VALUES
    ('admin',    'Администратор системы'),
    ('manager',  'Менеджер по работе с клиентами'),
    ('engineer', 'Технический специалист'),
    ('support',  'Сотрудник службы поддержки'),
    ('client',   'Абонент');

INSERT INTO users (email, password, full_name, phone, is_active) VALUES
    ('admin@netconnect.by',     '123456', 'Иванов Иван Иванович',     '+375291111111', TRUE),
    ('manager@netconnect.by',   '123456', 'Петров Пётр Петрович',     '+375292222222', TRUE),
    ('engineer@netconnect.by',  '123456', 'Сидоров Сергей Сергеевич', '+375293333333', TRUE),
    ('support@netconnect.by',   '123456', 'Кузнецова Анна Ивановна',  '+375294444444', TRUE),
    ('client1@example.com',     '123456', 'Смирнов Алексей Петрович', '+375295555555', TRUE),
    ('client2@example.com',     '123456', 'Морозова Ольга Сергеевна', '+375296666666', TRUE),
    ('client3@example.com',     '123456', 'Волков Дмитрий Андреевич', '+375297777777', TRUE),
    ('client4@example.com',     '123456', 'Соколова Екатерина Ивановна','+375298888888', TRUE),
    ('client5@example.com',     '123456', 'Новиков Павел Олегович',   '+375299999999', TRUE);

INSERT INTO user_roles (user_id, role_id, assigned_by) VALUES
    ((SELECT id FROM users WHERE email = 'admin@netconnect.by'),    (SELECT id FROM roles WHERE name = 'admin'),    NULL),
    ((SELECT id FROM users WHERE email = 'manager@netconnect.by'),  (SELECT id FROM roles WHERE name = 'manager'),  (SELECT id FROM users WHERE email = 'admin@netconnect.by')),
    ((SELECT id FROM users WHERE email = 'engineer@netconnect.by'), (SELECT id FROM roles WHERE name = 'engineer'), (SELECT id FROM users WHERE email = 'admin@netconnect.by')),
    ((SELECT id FROM users WHERE email = 'support@netconnect.by'),  (SELECT id FROM roles WHERE name = 'support'),  (SELECT id FROM users WHERE email = 'admin@netconnect.by')),
    ((SELECT id FROM users WHERE email = 'client1@example.com'),    (SELECT id FROM roles WHERE name = 'client'),   (SELECT id FROM users WHERE email = 'manager@netconnect.by')),
    ((SELECT id FROM users WHERE email = 'client2@example.com'),    (SELECT id FROM roles WHERE name = 'client'),   (SELECT id FROM users WHERE email = 'manager@netconnect.by')),
    ((SELECT id FROM users WHERE email = 'client3@example.com'),    (SELECT id FROM roles WHERE name = 'client'),   (SELECT id FROM users WHERE email = 'manager@netconnect.by')),
    ((SELECT id FROM users WHERE email = 'client4@example.com'),    (SELECT id FROM roles WHERE name = 'client'),   (SELECT id FROM users WHERE email = 'manager@netconnect.by')),
    ((SELECT id FROM users WHERE email = 'client5@example.com'),    (SELECT id FROM roles WHERE name = 'client'),   (SELECT id FROM users WHERE email = 'manager@netconnect.by'));

INSERT INTO clients (user_id, passport_series, passport_number, birth_date, address_id, client_type) VALUES
    ((SELECT id FROM users WHERE email = 'client1@example.com'), 'MP', '1234567', '1990-05-15', 1, 'individual'),
    ((SELECT id FROM users WHERE email = 'client2@example.com'), 'MP', '7654321', '1985-11-22', 2, 'individual'),
    ((SELECT id FROM users WHERE email = 'client3@example.com'), 'MP', '1111111', '1992-03-08', 3, 'individual'),
    ((SELECT id FROM users WHERE email = 'client4@example.com'), 'MP', '2222222', '1988-07-19', 4, 'individual'),
    ((SELECT id FROM users WHERE email = 'client5@example.com'), 'MP', '3333333', '1995-09-30', 5, 'individual');

INSERT INTO contracts (client_id, contract_number, signed_at, status) VALUES
    (1, 'NC-2024-0001', '2024-01-10', 'active'),
    (2, 'NC-2024-0002', '2024-01-15', 'active'),
    (3, 'NC-2024-0003', '2024-01-20', 'active'),
    (4, 'NC-2024-0004', '2024-02-01', 'active'),
    (5, 'NC-2024-0005', '2024-02-10', 'active'),
    (3, 'NC-2024-0006', '2024-03-01', 'suspended');

INSERT INTO tariffs (name, speed_mbps, price, is_archived) VALUES
    ('Домашний 50',    50,   30.00, FALSE),
    ('Домашний 100',   100,  45.00, FALSE),
    ('Домашний 500',   500,  75.00, FALSE),
    ('Бизнес 1000',    1000, 150.00, FALSE),
    ('Архивный 25',    25,   20.00, TRUE);

INSERT INTO services (name, description, base_price) VALUES
    ('Интернет',        'Доступ в интернет',           0.00),
    ('IPTV',            'Интерактивное телевидение',   10.00),
    ('Статический IP',  'Выделенный IP-адрес',          5.00),
    ('Антивирус',       'Антивирусная защита',          8.00);

INSERT INTO tariff_services (tariff_id, service_id, price_in_tariff, is_included) VALUES
    (1, 1, 30.00, TRUE),
    (2, 1, 45.00, TRUE),
    (2, 2, 10.00, FALSE),
    (3, 1, 75.00, TRUE),
    (3, 2, 10.00, TRUE),
    (4, 1, 150.00, TRUE),
    (4, 2, 10.00, TRUE),
    (4, 3, 5.00, TRUE),
    (4, 4, 8.00, FALSE);

INSERT INTO subscriptions (contract_id, tariff_id, service_id, start_date, end_date, status) VALUES
    (1, 2, 1, '2024-01-15', NULL, 'active'),
    (1, 2, 2, '2024-01-15', NULL, 'active'),
    (2, 3, 1, '2024-01-20', NULL, 'active'),
    (2, 3, 2, '2024-01-20', NULL, 'active'),
    (3, 4, 1, '2024-01-25', NULL, 'active'),
    (3, 4, 3, '2024-01-25', NULL, 'active'),
    (4, 1, 1, '2024-02-05', NULL, 'active'),
    (5, 2, 1, '2024-02-15', NULL, 'active'),
    (5, 2, 2, '2024-02-15', '2024-04-15', 'closed');

INSERT INTO invoices (client_id, period_start, period_end, amount, status) VALUES
    (1, '2024-01-01', '2024-01-31',  45.00, 'paid'),
    (2, '2024-01-01', '2024-01-31',  85.00, 'paid'),
    (3, '2024-01-01', '2024-01-31', 155.00, 'paid'),
    (1, '2024-02-01', '2024-02-29',  55.00, 'paid'),
    (2, '2024-02-01', '2024-02-29',  85.00, 'paid'),
    (3, '2024-02-01', '2024-02-29', 155.00, 'paid'),
    (4, '2024-02-01', '2024-02-29',  30.00, 'paid'),
    (5, '2024-02-01', '2024-02-29',  55.00, 'paid'),
    (1, '2024-03-01', '2024-03-31',  55.00, 'paid'),
    (2, '2024-03-01', '2024-03-31',  85.00, 'paid'),
    (3, '2024-03-01', '2024-03-31', 155.00, 'unpaid'),
    (4, '2024-03-01', '2024-03-31',  30.00, 'unpaid'),
    (5, '2024-03-01', '2024-03-31',  45.00, 'unpaid');

INSERT INTO payments (invoice_id, amount, method, external_id) VALUES
    (1,  45.00, 'card',     'PAY-2024-01-0001'),
    (2,  85.00, 'card',     'PAY-2024-01-0002'),
    (3, 155.00, 'transfer', 'PAY-2024-01-0003'),
    (4,  55.00, 'card',     'PAY-2024-02-0001'),
    (5,  85.00, 'card',     'PAY-2024-02-0002'),
    (6, 155.00, 'cash',     'PAY-2024-02-0003'),
    (7,  30.00, 'card',     'PAY-2024-02-0004'),
    (8,  55.00, 'transfer', 'PAY-2024-02-0005'),
    (9,  55.00, 'card',     'PAY-2024-03-0001'),
    (10, 85.00, 'card',     'PAY-2024-03-0002');

INSERT INTO audit_logs (user_id, action, entity_type, entity_id, old_value, new_value, ip_address) VALUES
    ((SELECT id FROM users WHERE email = 'admin@netconnect.by'),    'LOGIN',  'users', 1, NULL, '{"ip":"192.168.1.10"}', '192.168.1.10'),
    ((SELECT id FROM users WHERE email = 'manager@netconnect.by'),  'LOGIN',  'users', 2, NULL, '{"ip":"192.168.1.11"}', '192.168.1.11'),
    ((SELECT id FROM users WHERE email = 'client1@example.com'),    'LOGIN',  'users', 5, NULL, '{"ip":"10.0.0.5"}',     '10.0.0.5'),

    ((SELECT id FROM users WHERE email = 'admin@netconnect.by'),    'CREATE', 'users', 5, NULL,
        '{"email":"client1@example.com","full_name":"Смирнов Алексей Петрович"}', '192.168.1.10'),
    ((SELECT id FROM users WHERE email = 'admin@netconnect.by'),    'CREATE', 'users', 6, NULL,
        '{"email":"client2@example.com","full_name":"Морозова Ольга Сергеевна"}', '192.168.1.10'),

    ((SELECT id FROM users WHERE email = 'manager@netconnect.by'),  'UPDATE', 'clients', 1,
        '{"phone":"+375295555555"}', '{"phone":"+375295555000"}', '192.168.1.11'),
    ((SELECT id FROM users WHERE email = 'manager@netconnect.by'),  'UPDATE', 'tariffs', 2,
        '{"price":45.00}', '{"price":50.00}', '192.168.1.11'),

    ((SELECT id FROM users WHERE email = 'manager@netconnect.by'),  'CREATE', 'contracts', 1, NULL,
        '{"contract_number":"NC-2024-0001","status":"active"}', '192.168.1.11'),
    ((SELECT id FROM users WHERE email = 'manager@netconnect.by'),  'CREATE', 'contracts', 2, NULL,
        '{"contract_number":"NC-2024-0002","status":"active"}', '192.168.1.11'),

    ((SELECT id FROM users WHERE email = 'manager@netconnect.by'),  'CREATE', 'payments', 1, NULL,
        '{"invoice_id":1,"amount":45.00,"method":"card"}', '192.168.1.11'),

    ((SELECT id FROM users WHERE email = 'admin@netconnect.by'),    'UPDATE', 'contracts', 6,
        '{"status":"active"}', '{"status":"suspended"}', '192.168.1.10'),

    (NULL, 'LOGIN_FAILED', 'users', NULL,
        NULL, '{"email":"unknown@example.com"}', '203.0.113.42');

COMMIT;