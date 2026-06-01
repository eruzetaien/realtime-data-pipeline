---- Postgres
CREATE USER my_username WITH PASSWORD 'my_password';
CREATE DATABASE art_commission;
GRANT ALL PRIVILEGES ON DATABASE art_commission TO my_username;

CREATE TABLE artists (
    artist_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    profile_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE commissions (
    commission_id SERIAL PRIMARY KEY,
    artist_id INT,
    customer_id INT,
    description TEXT,
    total_amount DECIMAL(10, 2) NOT NULL,
    commission_status VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    due_date TIMESTAMP
);

CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    commission_id INT,
    amount_paid DECIMAL(10, 2) NOT NULL,
    payment_method VARCHAR(100),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    customer_id INT
);

CREATE TABLE fees (
    fee_id SERIAL PRIMARY KEY,
    commission_id INT,
    fee_amount DECIMAL(10, 2) NOT NULL,
    fee_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE PUBLICATION payment_pub FOR TABLE public.payments;

-- Click House
CREATE DATABASE art_commission;

CREATE TABLE payments
(
    payment_id UInt64,
    commission_id UInt64,
    amount_paid Decimal(10,2),
    payment_method String,
    payment_date DateTime64(6),
    customer_id UInt64
)
ENGINE = MergeTree
ORDER BY (payment_date, customer_id);

CREATE TABLE payments_kafka
(
    payment_id UInt64,
    commission_id UInt64,
    amount_paid Decimal(10,2),
    payment_method String,
    payment_date DateTime64(6),
    customer_id UInt64
)
ENGINE = Kafka
SETTINGS
    kafka_broker_list = 'localhost:9092',
    kafka_topic_list = 'payment.public.payments',
    kafka_group_name = 'clickhouse_payments',
    kafka_format = 'JSONEachRow',
    kafka_num_consumers = 1;

CREATE MATERIALIZED VIEW payments_mv
TO payments
AS
SELECT *
FROM payments_kafka;

CREATE TABLE artist_contributions (
    artist_id UInt64,                            -- Artist ID
    month Date,                                  -- Month for which contribution is calculated
    total_commissions UInt64,                    -- Total number of commissions for the artist
    total_sales DECIMAL(10, 2),                   -- Total sales made by the artist
    total_fees_paid DECIMAL(10, 2),               -- Total fees the artist has paid
    PRIMARY KEY (artist_id, month)                -- Artist ID and month for partitioning and efficient queries
) ENGINE = MergeTree()
ORDER BY (artist_id, month);