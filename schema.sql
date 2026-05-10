---- Postgres
CREATE USER my_username WITH PASSWORD 'my_password';
CREATE DATABASE art_commission;
GRANT ALL PRIVILEGES ON DATABASE art_commission TO my_username;

CREATE TABLE artists (
    artist_id SERIAL PRIMARY KEY,               -- Unique identifier for the artist
    name VARCHAR(255) NOT NULL,                 -- Name of the artist
    profile_url TEXT,                           -- URL to the artist's portfolio
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Timestamp when the artist joined
);

CREATE TABLE commissions (
    commission_id SERIAL PRIMARY KEY,           -- Unique commission ID
    artist_id INT REFERENCES artists(artist_id), -- Foreign key to the artist
    customer_id INT,                            -- ID of the customer who made the commission
    description TEXT,                           -- Description of the art commission request
    total_amount DECIMAL(10, 2) NOT NULL,        -- Total price of the commission
    commission_status VARCHAR(50),               -- Commission status (e.g., completed, in-progress)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when the commission was created
    completed_at TIMESTAMP,                     -- Timestamp when the commission is completed (if applicable)
    due_date TIMESTAMP                          -- Due date for the commission (when it is expected to be completed)
);

CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,               -- Unique payment ID
    commission_id INT REFERENCES commissions(commission_id), -- Foreign key to the commission
    amount_paid DECIMAL(10, 2) NOT NULL,          -- Amount the customer paid
    payment_method VARCHAR(100),                  -- Payment method (Credit Card, PayPal)
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp of the payment
    customer_id INT                               -- ID of the customer who made the payment
);

CREATE TABLE fees (
    fee_id SERIAL PRIMARY KEY,                   -- Unique fee ID
    commission_id INT REFERENCES commissions(commission_id), -- Foreign key to the commission
    fee_amount DECIMAL(10, 2) NOT NULL,           -- Amount of the fee charged for this commission
    fee_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- When the fee was calculated or applied
);

CREATE PUBLICATION payment_pub FOR TABLE public.payments;

-- Click House
CREATE TABLE payments
(
    payment_id UInt64,
    commission_id UInt64,
    amount_paid Decimal(10,2),
    payment_method String,
    payment_date DateTime,
    customer_id UInt64
)
ENGINE = MergeTree
ORDER BY (payment_date, customer_id);

CREATE TABLE artist_contributions (
    artist_id UInt64,                            -- Artist ID
    month Date,                                  -- Month for which contribution is calculated
    total_commissions UInt64,                    -- Total number of commissions for the artist
    total_sales DECIMAL(10, 2),                   -- Total sales made by the artist
    total_fees_paid DECIMAL(10, 2),               -- Total fees the artist has paid
    PRIMARY KEY (artist_id, month)                -- Artist ID and month for partitioning and efficient queries
) ENGINE = MergeTree()
ORDER BY (artist_id, month);