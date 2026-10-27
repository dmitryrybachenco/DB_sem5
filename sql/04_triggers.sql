CREATE OR REPLACE FUNCTION fn_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION fn_set_updated_at();



CREATE OR REPLACE FUNCTION fn_audit_tariffs()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_logs (action, entity_type, entity_id, old_value, new_value)
        VALUES ('UPDATE', 'tariffs', OLD.id, 
                to_jsonb(OLD), 
                to_jsonb(NEW));
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit_logs (action, entity_type, entity_id, old_value, new_value)
        VALUES ('DELETE', 'tariffs', OLD.id, 
                to_jsonb(OLD), 
                NULL);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_tariffs
AFTER UPDATE OR DELETE ON tariffs
FOR EACH ROW
EXECUTE FUNCTION fn_audit_tariffs();



CREATE OR REPLACE FUNCTION fn_update_invoice_status()
RETURNS TRIGGER AS $$
DECLARE
    v_invoice_amount NUMERIC;
    v_total_paid NUMERIC;
BEGIN
    SELECT amount INTO v_invoice_amount FROM invoices WHERE id = NEW.invoice_id;
    
    SELECT COALESCE(SUM(amount), 0) INTO v_total_paid FROM payments WHERE invoice_id = NEW.invoice_id;
    
    IF v_total_paid >= v_invoice_amount THEN
        UPDATE invoices SET status = 'paid' WHERE id = NEW.invoice_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_invoice_status
AFTER INSERT ON payments
FOR EACH ROW
EXECUTE FUNCTION fn_update_invoice_status();



CREATE OR REPLACE FUNCTION fn_prevent_tariff_delete()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM subscriptions WHERE tariff_id = OLD.id AND status = 'active') THEN
        RAISE EXCEPTION 'Невозможно удалить тариф "%". На нем есть активные подписки!', OLD.name;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_tariff_delete
BEFORE DELETE ON tariffs
FOR EACH ROW
EXECUTE FUNCTION fn_prevent_tariff_delete();



CREATE OR REPLACE FUNCTION fn_contracts_terminated_at()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'terminated' THEN
        NEW.terminated_at = now();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_contracts_terminated_at
BEFORE UPDATE OF status ON contracts
FOR EACH ROW
EXECUTE FUNCTION fn_contracts_terminated_at();



CREATE OR REPLACE FUNCTION fn_subscriptions_end_date()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'closed' THEN
        NEW.end_date = now();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_subscriptions_end_date
BEFORE UPDATE OF status ON subscriptions
FOR EACH ROW
EXECUTE FUNCTION fn_subscriptions_end_date();