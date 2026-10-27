CREATE OR REPLACE PROCEDURE sp_register_client(
    p_email VARCHAR,
    p_password_hash VARCHAR,
    p_full_name VARCHAR,
    p_phone VARCHAR,
    p_passport_series VARCHAR,
    p_passport_number VARCHAR,
    p_address_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_user_id BIGINT;
    v_client_id BIGINT;
    v_role_id INT;
    v_contract_num VARCHAR;
BEGIN
    INSERT INTO users (email, password_hash, full_name, phone)
    VALUES (p_email, p_password_hash, p_full_name, p_phone)
    RETURNING id INTO v_user_id;

    SELECT id INTO v_role_id FROM roles WHERE name = 'client';

    INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, v_role_id);

    INSERT INTO clients (user_id, passport_series, passport_number, address_id, client_type)
    VALUES (v_user_id, p_passport_series, p_passport_number, p_address_id, 'individual')
    RETURNING id INTO v_client_id;

    v_contract_num := 'NC-' || EXTRACT(YEAR FROM CURRENT_DATE) || '-' || LPAD(v_client_id::text, 4, '0');
    
    INSERT INTO contracts (client_id, contract_number, signed_at, status)
    VALUES (v_client_id, v_contract_num, CURRENT_DATE, 'active');

    RAISE NOTICE 'Абонент успешно зарегистрирован. Договор: %', v_contract_num;
END;
$$;



CREATE OR REPLACE PROCEDURE sp_make_payment(
    p_invoice_id BIGINT,
    p_amount NUMERIC,
    p_method VARCHAR,
    p_external_id VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_invoice_amount NUMERIC;
    v_total_paid NUMERIC;
BEGIN
    SELECT amount INTO v_invoice_amount 
    FROM invoices 
    WHERE id = p_invoice_id AND status IN ('unpaid', 'overdue');

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Счет % не найден или уже оплачен.', p_invoice_id;
    END IF;

    INSERT INTO payments (invoice_id, amount, method, external_id)
    VALUES (p_invoice_id, p_amount, p_method, p_external_id);

    SELECT COALESCE(SUM(amount), 0) INTO v_total_paid 
    FROM payments WHERE invoice_id = p_invoice_id;

    IF v_total_paid >= v_invoice_amount THEN
        RAISE NOTICE 'Счет % полностью оплачен.', p_invoice_id;
    ELSE
        RAISE NOTICE 'Внесена частичная оплата. Остаток долга: %', (v_invoice_amount - v_total_paid);
    END IF;
END;
$$;



CREATE OR REPLACE PROCEDURE sp_change_tariff(
    p_contract_id BIGINT,
    p_new_tariff_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE subscriptions 
    SET status = 'closed', end_date = CURRENT_DATE
    WHERE contract_id = p_contract_id 
      AND status = 'active' 
      AND service_id = (SELECT id FROM services WHERE name = 'Интернет');

    INSERT INTO subscriptions (contract_id, tariff_id, service_id, start_date, status)
    VALUES (
        p_contract_id, 
        p_new_tariff_id, 
        (SELECT id FROM services WHERE name = 'Интернет'),
        CURRENT_DATE, 
        'active'
    );

    RAISE NOTICE 'Тариф успешно изменен.';
END;
$$;



CREATE OR REPLACE PROCEDURE sp_generate_monthly_invoices()
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
    v_period_start DATE := DATE_TRUNC('month', CURRENT_DATE)::DATE;
    v_period_end DATE := (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::DATE;
    v_days_in_month INT := EXTRACT(DAY FROM v_period_end);
    v_total_amount NUMERIC := 0;
BEGIN
    FOR r IN 
        SELECT 
            DISTINCT c.id AS contract_id, 
            c.client_id 
        FROM contracts c
        WHERE c.status = 'active'
    LOOP
        v_total_amount := 0;

        SELECT 1 t.price INTO v_total_amount
        FROM subscriptions s
        JOIN tariffs t ON t.id = s.tariff_id
        WHERE s.contract_id = r.contract_id 
          AND s.status = 'active';

        SELECT v_total_amount + COALESCE(SUM(
            CASE 
                WHEN s.status = 'active' THEN ts.price_in_tariff
                
                WHEN s.status = 'closed' AND s.end_date >= v_period_start THEN
                    ROUND(
                        (ts.price_in_tariff / v_days_in_month) * 
                        (s.end_date - GREATEST(s.start_date, v_period_start) + 1)
                    , 2)
                
                WHEN s.status = 'active' AND s.start_date > v_period_start THEN
                     ROUND(
                        (ts.price_in_tariff / v_days_in_month) * 
                        (v_period_end - s.start_date + 1)
                    , 2)
                
                ELSE 0
            END
        ),0) INTO v_total_amount
        FROM subscriptions s
        JOIN tariff_services ts ON ts.tariff_id = s.tariff_id AND ts.service_id = s.service_id
        WHERE s.contract_id = r.contract_id
          AND ts.is_included = false;

        SELECT v_total_amount - COALESCE(SUM(ts.price_in_tariff), 0) INTO v_total_amount
        FROM tariff_services ts
        WHERE ts.is_included = true AND ts.service_id  NOT IN (
        SELECT s.service_id FROM subscriptions s WHERE s.contract_id = r.id
        )
        GROUP BY ts.service_id, ts.price_in_tariff

        IF NOT EXISTS (
            SELECT 1 FROM invoices 
            WHERE client_id = r.client_id AND period_start = v_period_start
        ) THEN
            INSERT INTO invoices (client_id, period_start, period_end, amount, status)
            VALUES (r.client_id, v_period_start, v_period_end, r.price, 'unpaid');
        END IF;
    END LOOP;
    
    RAISE NOTICE 'Начисление за период % - % завершено.', v_period_start, v_period_end;
END;
$$;