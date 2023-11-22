CREATE  FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_updated_at_transaction_categories
    BEFORE UPDATE
    ON sources.transaction_categories
    FOR EACH ROW
EXECUTE PROCEDURE update_updated_at();