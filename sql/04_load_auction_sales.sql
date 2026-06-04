INSERT INTO auction_sales (
    vehicle_id,
    seller,
    state,
    condition,
    mmr,
    selling_price
)
SELECT
    v.vehicle_id,
    r.seller,
    r.state,
    r.condition,
    r.mmr,
    r.sellingprice
FROM raw_car_prices r
JOIN vehicles v
    ON r.vin = v.vin;