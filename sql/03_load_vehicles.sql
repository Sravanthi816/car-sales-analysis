INSERT INTO vehicles (
    vin,
    year,
    make,
    model,
    trim,
    body,
    transmission,
    color,
    interior,
    odometer
)
SELECT
    vin,
    year,
    make,
    model,
    trim,
    body,
    transmission,
    color,
    interior,
    odometer
FROM raw_car_prices;