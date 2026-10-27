SELECT 
    i.id AS invoice_id,
    u.full_name AS client_name,
    i.amount,
    i.period_start,
    i.status,
    AGE(NOW(), i.created_at) AS days_overdue
FROM invoices i
JOIN clients cl ON cl.id = i.client_id
JOIN users u ON u.id = cl.user_id
LEFT JOIN payments p ON p.invoice_id = i.id
WHERE i.status IN ('unpaid', 'overdue')
  AND p.id IS NULL
ORDER BY i.period_start;



WITH ClientBalances AS (
    SELECT 
        cl.id AS client_id,
        u.full_name,
        u.phone,
        COUNT(DISTINCT c.id) AS active_contracts,
        COALESCE(SUM(i.amount), 0) - COALESCE(SUM(p.amount), 0) AS debt
    FROM clients cl
    JOIN users u ON u.id = cl.user_id
    JOIN contracts c ON c.client_id = cl.id AND c.status = 'active'
    LEFT JOIN invoices i ON i.client_id = cl.id AND i.status IN ('unpaid', 'overdue')
    LEFT JOIN payments p ON p.invoice_id = i.id
    GROUP BY cl.id, u.full_name, u.phone
)
SELECT 
    full_name,
    phone,
    active_contracts,
    debt,
    RANK() OVER (ORDER BY debt DESC) AS debt_rank,
    CASE 
        WHEN debt > 100 THEN 'Критический долг'
        WHEN debt > 0 THEN 'Есть задолженность'
        ELSE 'Без долгов'
    END AS status
FROM ClientBalances
WHERE debt > 0
ORDER BY debt DESC;



SELECT 
    u.full_name,
    u.email,
    c.contract_number,
    (SELECT MAX(paid_at) FROM payments p JOIN invoices i ON i.id = p.invoice_id WHERE i.client_id = cl.id) AS last_payment_date
FROM clients cl
JOIN users u ON u.id = cl.user_id
JOIN contracts c ON c.client_id = cl.id AND c.status = 'active'
WHERE NOT EXISTS (
    SELECT 1 
    FROM payments p
    JOIN invoices i ON i.id = p.invoice_id
    WHERE i.client_id = cl.id 
      AND p.paid_at >= NOW() - INTERVAL '10 days'
)
ORDER BY last_payment_date NULLS FIRST;



SELECT 
    'Договор' AS event_type,
    c.contract_number AS details,
    c.signed_at::timestamp AS event_date,
    c.status AS status
FROM contracts c
WHERE c.client_id = 1

UNION ALL

SELECT 
    'Счёт' AS event_type,
    'Счет на сумму ' || i.amount || ' BYN' AS details,
    i.created_at AS event_date,
    i.status AS status
FROM invoices i
WHERE i.client_id = 1

UNION ALL

SELECT 
    'Платёж' AS event_type,
    'Оплата ' || p.amount || ' BYN (' || p.method || ')' AS details,
    p.paid_at AS event_date,
    'success' AS status
FROM payments p
JOIN invoices i ON i.id = p.invoice_id
WHERE i.client_id = 1

ORDER BY event_date DESC;



WITH ContractsServicesBundles AS(
	SELECT
		sub.contract_id,
    	STRING_AGG(s.name, ' + ' ORDER BY s.name) AS service_bundle,
		t.price AS tariff_price
	FROM subscriptions sub
	JOIN services s ON s.id = sub.service_id
	JOIN tariffs t ON t.id = sub.tariff_id
	GROUP BY sub.contract_id, t.price
	HAVING COUNT(sub.id) > 1
)
SELECT 
    service_bundle,
    COUNT(DISTINCT contract_id) AS contracts_count,
    ROUND(AVG(tariff_price), 2) AS avg_tariff_price
FROM ContractsServicesBundles
GROUP BY service_bundle
ORDER BY contracts_count DESC;



WITH ClientDebts AS (
    SELECT 
        cl.id,
        u.full_name,
        c.name AS city,
        COALESCE(SUM(i.amount), 0) - COALESCE(SUM(p.amount), 0) AS debt
    FROM clients cl
    JOIN users u ON u.id = cl.user_id
    LEFT JOIN addresses a ON a.id = cl.address_id
    LEFT JOIN streets s ON s.id = a.street_id
    LEFT JOIN cities c ON c.id = s.city_id
    LEFT JOIN invoices i ON i.client_id = cl.id
    LEFT JOIN payments p ON p.invoice_id = i.id
    GROUP BY cl.id, u.full_name, c.name
)
SELECT 
    city,
    full_name,
    debt,
    RANK() OVER (PARTITION BY city ORDER BY debt DESC) AS rank_in_city
FROM ClientDebts
WHERE debt > 0;