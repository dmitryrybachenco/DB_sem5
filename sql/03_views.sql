CREATE OR REPLACE VIEW v_active_contracts AS
SELECT 
    c.id AS contract_id,
    c.contract_number,
    c.signed_at,
    u.full_name AS client_name,
    u.phone,
    u.email
FROM contracts c
INNER JOIN clients cl ON cl.id = c.client_id
INNER JOIN users u ON u.id = cl.user_id
WHERE c.status = 'active';



CREATE OR REPLACE VIEW v_tariffs_popularity AS
SELECT 
    t.id AS tariff_id,
    t.name AS tariff_name,
    t.price,
    t.is_archived,
    COUNT(s.id) AS active_subscriptions
FROM tariffs t
LEFT JOIN subscriptions s ON s.tariff_id = t.id AND s.status = 'active'
GROUP BY t.id, t.name, t.price, t.is_archived;



CREATE OR REPLACE VIEW v_tariff_service_audit AS
SELECT 
    t.name AS tariff_name,
    s.name AS service_name,
    ts.price_in_tariff,
    ts.is_included
FROM tariffs t
FULL JOIN tariff_services ts ON ts.tariff_id = t.id
FULL JOIN services s ON s.id = ts.service_id;



CREATE OR REPLACE VIEW v_role_assignments AS
SELECT 
    target_user.full_name AS assigned_to,
    r.name AS role_name,
    ur.assigned_at,
    admin_user.full_name AS assigned_by_admin
FROM user_roles ur
JOIN users target_user ON target_user.id = ur.user_id
JOIN roles r ON r.id = ur.role_id
LEFT JOIN users admin_user ON admin_user.id = ur.assigned_by;



CREATE OR REPLACE VIEW v_client_balances AS
SELECT 
    cl.id AS client_id,
    u.full_name,
    u.email,
    COALESCE(SUM(i.amount), 0) AS total_invoiced,
    COALESCE(SUM(p.amount), 0) AS total_paid,
    COALESCE(SUM(i.amount), 0) - COALESCE(SUM(p.amount), 0) AS current_balance
FROM clients cl
JOIN users u ON u.id = cl.user_id
LEFT JOIN invoices i ON i.client_id = cl.id
LEFT JOIN payments p ON p.invoice_id = i.id
GROUP BY cl.id, u.full_name, u.email
ORDER BY cl.id;



CREATE OR REPLACE VIEW v_debtors AS
SELECT 
    full_name,
    email,
    current_balance,
    current_balance AS debt_amount
FROM v_client_balances
WHERE current_balance > 0
ORDER BY current_balance;