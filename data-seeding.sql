INSERT INTO payments (
    commission_id,
    amount_paid,
    payment_method,
    payment_date,
    customer_id
)
SELECT
    gs AS commission_id,
    ROUND((10 + random() * 990)::NUMERIC, 2),
    (
        ARRAY[
            'Credit Card',
            'Bank Transfer',
            'PayPal',
            'Stripe',
            'Apple Pay',
            'Google Pay',
            'Crypto'
        ]
    )[floor(random() * 7 + 1)],
    NOW() - (random() * interval '3 years'),
    (random() * 50000)::INT + 1
FROM generate_series(1, 5000000) gs;


INSERT INTO payments
SELECT
    number + 1 AS payment_id,
    number + 1 AS commission_id,
    toDecimal32(
        (cityHash64(number * 13) % 99000) / 100.0 + 10,
        2
    ) AS amount_paid,
    arrayElement(
        [
            'Credit Card',
            'Bank Transfer',
            'PayPal',
            'Stripe',
            'Apple Pay',
            'Google Pay',
            'Crypto'
        ],
        cityHash64(number * 17) % 7 + 1
    ) AS payment_method,
    now() - toIntervalSecond(cityHash64(number * 19) % 94608000),
    cityHash64(number * 23) % 50000 + 1
FROM numbers(5000000);