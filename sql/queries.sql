SELECT id, email, full_name, phone, is_active
FROM users
ORDER BY id;


SELECT id, email, full_name, is_active
FROM users
WHERE email = 'admin@netconnect.by';


SELECT id, name, description
FROM roles
ORDER BY id;


SELECT r.name, r.description
FROM user_roles ur
JOIN roles r ON r.id = ur.role_id
JOIN users u ON u.id = ur.user_id
WHERE u.email = 'admin@netconnect.by';


SELECT cl.id, u.full_name, u.phone, u.email, cl.client_type
FROM clients cl
JOIN users u ON u.id = cl.user_id
ORDER BY u.full_name;


SELECT id, client_id, contract_number, signed_at, status
FROM contracts
ORDER BY signed_at;


SELECT id, client_id, contract_number, signed_at
FROM contracts
WHERE status = 'active'
ORDER BY signed_at;


SELECT id, name, speed_mbps, price, is_archived
FROM tariffs
ORDER BY price;


SELECT s.name, ts.price_in_tariff, ts.is_included
FROM tariff_services ts
JOIN services s ON s.id = ts.service_id
JOIN tariffs t ON t.id = ts.tariff_id
WHERE t.name = 'Домашний 500';


SELECT t.name AS tariff, s.start_date, s.status
FROM subscriptions s
JOIN contracts c ON c.id = s.contract_id
JOIN clients cl ON cl.id = c.client_id
JOIN users u ON u.id = cl.user_id
JOIN tariffs t ON t.id = s.tariff_id
WHERE u.email = 'client1@example.com';


SELECT id, client_id, period_start, amount, status
FROM invoices
WHERE status = 'unpaid'
ORDER BY period_start;


SELECT id, invoice_id, amount, method, paid_at
FROM payments
ORDER BY paid_at DESC;


SELECT s.id, s.name
FROM streets s
JOIN cities c ON c.id = s.city_id
WHERE c.name = 'Минск'
ORDER BY s.name;


SELECT a.action, a.entity_type, a.created_at
FROM audit_logs a
JOIN users u ON u.id = a.user_id
WHERE u.email = 'admin@netconnect.by'
ORDER BY a.created_at DESC;


SELECT COUNT(*) AS clients_count
FROM clients;