import time
import statistics
import psycopg2
import clickhouse_connect
import pandas as pd
from tabulate import tabulate

# --------------------------------
# CONFIG
# --------------------------------

POSTGRES_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "art_commission",
    "user": "postgres",
    "password": "postgres",
}

CLICKHOUSE_CONFIG = {
    "host": "localhost",
    "port": 8123,
    "username": "default",
    "password": "",
    "database": "default",
}

RUNS = 5

# --------------------------------
# QUERIES
# --------------------------------

QUERIES = {
    "Revenue by Payment Method": {
        "postgres": """
            SELECT payment_method,
                   SUM(amount_paid) AS revenue
            FROM payments
            GROUP BY payment_method
            ORDER BY revenue DESC
        """,
        "clickhouse": """
            SELECT payment_method,
                   SUM(amount_paid) AS revenue
            FROM payments
            GROUP BY payment_method
            ORDER BY revenue DESC
        """
    },

    "Monthly Revenue": {
        "postgres": """
            SELECT
                date_trunc('month', payment_date) AS month,
                SUM(amount_paid) AS revenue
            FROM payments
            GROUP BY month
            ORDER BY month
        """,
        "clickhouse": """
            SELECT
                toStartOfMonth(payment_date) AS month,
                SUM(amount_paid) AS revenue
            FROM payments
            GROUP BY month
            ORDER BY month
        """
    },

    "Top 100 Customers": {
        "postgres": """
            SELECT
                customer_id,
                SUM(amount_paid) AS revenue
            FROM payments
            GROUP BY customer_id
            ORDER BY revenue DESC
            LIMIT 100
        """,
        "clickhouse": """
            SELECT
                customer_id,
                SUM(amount_paid) AS revenue
            FROM payments
            GROUP BY customer_id
            ORDER BY revenue DESC
            LIMIT 100
        """
    },

    "Dashboard Query": {
        "postgres": """
            SELECT
                customer_id,
                payment_method,
                COUNT(*) AS payments,
                SUM(amount_paid) AS revenue
            FROM payments
            WHERE payment_date >= NOW() - INTERVAL '2 years'
            GROUP BY customer_id, payment_method
            ORDER BY revenue DESC
            LIMIT 1000
        """,
        "clickhouse": """
            SELECT
                customer_id,
                payment_method,
                COUNT(*) AS payments,
                SUM(amount_paid) AS revenue
            FROM payments
            WHERE payment_date >= now() - INTERVAL 2 YEAR
            GROUP BY customer_id, payment_method
            ORDER BY revenue DESC
            LIMIT 1000
        """
    }
}

# --------------------------------
# CONNECTIONS
# --------------------------------

pg_conn = psycopg2.connect(**POSTGRES_CONFIG)

ch_client = clickhouse_connect.get_client(
    host=CLICKHOUSE_CONFIG["host"],
    port=CLICKHOUSE_CONFIG["port"],
    username=CLICKHOUSE_CONFIG["username"],
    password=CLICKHOUSE_CONFIG["password"],
    database=CLICKHOUSE_CONFIG["database"]
)

# --------------------------------
# BENCHMARK HELPERS
# --------------------------------

def benchmark_postgres(sql):
    timings = []

    for _ in range(RUNS):
        cur = pg_conn.cursor()

        start = time.perf_counter()
        cur.execute(sql)
        cur.fetchall()
        end = time.perf_counter()

        timings.append(end - start)

        cur.close()

    return statistics.mean(timings)


def benchmark_clickhouse(sql):
    timings = []

    for _ in range(RUNS):
        start = time.perf_counter()
        ch_client.query(sql)
        end = time.perf_counter()

        timings.append(end - start)

    return statistics.mean(timings)

# --------------------------------
# RUN BENCHMARK
# --------------------------------

results = []

for query_name, query in QUERIES.items():

    print(f"Running: {query_name}")

    pg_time = benchmark_postgres(query["postgres"])
    ch_time = benchmark_clickhouse(query["clickhouse"])

    speedup = pg_time / ch_time

    results.append([
        query_name,
        round(pg_time * 1000, 2),
        round(ch_time * 1000, 2),
        round(speedup, 2)
    ])

# --------------------------------
# REPORT
# --------------------------------

df = pd.DataFrame(
    results,
    columns=[
        "Query",
        "PostgreSQL (ms)",
        "ClickHouse (ms)",
        "Speedup"
    ]
)

print()
print(tabulate(df, headers="keys", tablefmt="github", showindex=False))

df.to_csv("benchmark_results.csv", index=False)

print("\nSaved to benchmark_results.csv")