CREATE TABLE IF NOT EXISTS auction_sales(
    sale_id SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    vehicle_id SMALLINT,
    seller VARCHAR(50),
    state VARCHAR(50),
    condition NUMERIC(10,2),
    mmr NUMERIC(10,2),
    selling_price NUMERIC(10,2),
    sale_date TIMESTAMP,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id)
);