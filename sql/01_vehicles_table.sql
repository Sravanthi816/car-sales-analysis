CREATE TABLE IF NOT EXISTS vehicles(
    vechile_id SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    vin VARCHAR(50) UNIQUE,
    year SMALLINT,
    make VARCHAR(50),
    model VARCHAR(50),
    trim VARCHAR(50),
    body VARCHAR(50),
    transmission VARCHAR(50),
    color VARCHAR(50),
    interior VARCHAR(50),
    odometer BIGINT
);
