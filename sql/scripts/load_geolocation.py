import pandas as pd
import pyodbc
from pathlib import Path

# ============================================================
# CONFIGURATION
# ============================================================

CSV_PATH = Path("data/raw/olist_geolocation_dataset.csv")

BATCH_SIZE = 10_000

EXPECTED_ROWS = 1_000_163

CONNECTION_STRING = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    r"SERVER=DESKTOP-Q7I6VKD\SQLEXPRESS;"
    "DATABASE=EcommerceAnalytics;"
    "Trusted_Connection=yes;"
)

DESTINATION_TABLE = "dbo.olist_geolocation_unicode"


# ============================================================
# STEP 1: READ THE SOURCE CSV
# ============================================================

def read_source_data():
    print("=" * 60)
    print("STEP 1: READING SOURCE DATA")
    print("=" * 60)

    if not CSV_PATH.exists():
        raise FileNotFoundError(
            f"CSV file not found: {CSV_PATH.resolve()}"
        )

    df = pd.read_csv(
        CSV_PATH,
        encoding="utf-8",
        dtype={
            "geolocation_zip_code_prefix": str,
            "geolocation_city": str,
            "geolocation_state": str,
        },
    )

    print(f"Source file: {CSV_PATH}")
    print(f"Total source rows: {len(df):,}")

    if len(df) != EXPECTED_ROWS:
        raise ValueError(
            f"Unexpected row count. Expected {EXPECTED_ROWS:,}, "
            f"found {len(df):,}."
        )

    return df


# ============================================================
# STEP 2: VALIDATE SOURCE DATA
# ============================================================

def validate_source_data(df):
    print("\n" + "=" * 60)
    print("STEP 2: VALIDATING SOURCE DATA")
    print("=" * 60)

    expected_columns = [
        "geolocation_zip_code_prefix",
        "geolocation_lat",
        "geolocation_lng",
        "geolocation_city",
        "geolocation_state",
    ]

    if list(df.columns) != expected_columns:
        raise ValueError(
            f"Unexpected columns: {df.columns.tolist()}"
        )

    missing_values = df[expected_columns].isnull().sum()

    print("\nMissing values:")
    print(missing_values.to_string())

    if missing_values.sum() > 0:
        raise ValueError(
            "Source contains missing values. "
            "Review them before loading."
        )

    # Validate postal code format.
    invalid_postal_codes = ~df[
        "geolocation_zip_code_prefix"
    ].str.fullmatch(r"\d{5}")

    print(
        "\nInvalid postal codes:",
        int(invalid_postal_codes.sum()),
    )

    if invalid_postal_codes.any():
        raise ValueError(
            "Invalid postal codes found in the source."
        )

    # Validate coordinate conversions.
    latitude = pd.to_numeric(
        df["geolocation_lat"],
        errors="coerce",
    )

    longitude = pd.to_numeric(
        df["geolocation_lng"],
        errors="coerce",
    )

    invalid_coordinates = (
        latitude.isnull()
        | longitude.isnull()
        | ~latitude.between(-90, 90)
        | ~longitude.between(-180, 180)
    )

    print(
        "Invalid coordinates:",
        int(invalid_coordinates.sum()),
    )

    if invalid_coordinates.any():
        raise ValueError(
            "Invalid geographic coordinates found."
        )

    # Verify original city names are not accidentally modified.
    suspicious_names = df[
        "geolocation_city"
    ].str.contains(r"Ã|Â", regex=True, na=False)

    print(
        "City names with suspicious encoding patterns:",
        int(suspicious_names.sum()),
    )

    if suspicious_names.any():
        print(
            "Warning: Inspect suspicious city names "
            "before proceeding."
        )

    # Preserve the source strings and accents.
    df["geolocation_lat"] = latitude
    df["geolocation_lng"] = longitude

    print("\nSource validation completed.")

    return df


# ============================================================
# STEP 3: CONNECT TO SQL SERVER
# ============================================================

def connect_to_sql_server():
    print("\n" + "=" * 60)
    print("STEP 3: CONNECTING TO SQL SERVER")
    print("=" * 60)

    conn = pyodbc.connect(
        CONNECTION_STRING,
        autocommit=False,
    )

    print("Connected to EcommerceAnalytics.")

    return conn


# ============================================================
# STEP 4: CHECK DESTINATION TABLE
# ============================================================

def check_destination_table(conn):
    print("\n" + "=" * 60)
    print("STEP 4: CHECKING DESTINATION TABLE")
    print("=" * 60)

    cursor = conn.cursor()

    cursor.execute(
        f"SELECT COUNT_BIG(*) FROM {DESTINATION_TABLE}"
    )

    existing_rows = cursor.fetchone()[0]

    print(f"Existing destination rows: {existing_rows:,}")

    cursor.close()

    if existing_rows != 0:
        raise RuntimeError(
            f"{DESTINATION_TABLE} is not empty. "
            "No rows were inserted. Investigate the existing "
            "data before deciding whether to reload."
        )

    print("Destination table is empty and ready.")


# ============================================================
# STEP 5: LOAD DATA IN BATCHES
# ============================================================

def load_data(conn, df):
    print("\n" + "=" * 60)
    print("STEP 5: LOADING GEOLOCATION DATA")
    print("=" * 60)

    insert_sql = f"""
        INSERT INTO {DESTINATION_TABLE}
        (
            geolocation_zip_code_prefix,
            geolocation_lat,
            geolocation_lng,
            geolocation_city,
            geolocation_state
        )
        VALUES (?, ?, ?, ?, ?);
    """

    cursor = conn.cursor()
    cursor.fast_executemany = True

    total_rows = len(df)

    try:
        for start in range(0, total_rows, BATCH_SIZE):
            batch = df.iloc[start:start + BATCH_SIZE]

            records = list(
                batch[
                    [
                        "geolocation_zip_code_prefix",
                        "geolocation_lat",
                        "geolocation_lng",
                        "geolocation_city",
                        "geolocation_state",
                    ]
                ].itertuples(index=False, name=None)
            )

            cursor.executemany(
                insert_sql,
                records,
            )

            # Keep the whole load in one transaction.
            # If an error occurs, the transaction can be rolled back.
            print(
                f"Processed {min(start + len(batch), total_rows):,}"
                f" / {total_rows:,} rows"
            )

        conn.commit()

        print("\nAll rows committed successfully.")

    except Exception:
        conn.rollback()

        print(
            "\nAn error occurred. The current transaction "
            "has been rolled back."
        )

        raise

    finally:
        cursor.close()


# ============================================================
# STEP 6: VALIDATE THE LOADED DATA
# ============================================================

def validate_loaded_data(conn):
    print("\n" + "=" * 60)
    print("STEP 6: VALIDATING LOADED DATA")
    print("=" * 60)

    cursor = conn.cursor()

    cursor.execute(
        f"""
        SELECT
            COUNT_BIG(*) AS total_rows,
            COUNT(DISTINCT geolocation_zip_code_prefix)
                AS unique_postal_codes,
            COUNT(DISTINCT geolocation_state)
                AS unique_states,
            SUM(
                CASE
                    WHEN geolocation_lat NOT BETWEEN -90 AND 90
                    THEN 1 ELSE 0
                END
            ) AS invalid_latitudes,
            SUM(
                CASE
                    WHEN geolocation_lng NOT BETWEEN -180 AND 180
                    THEN 1 ELSE 0
                END
            ) AS invalid_longitudes
        FROM {DESTINATION_TABLE};
        """
    )

    result = cursor.fetchone()

    print(f"Total rows: {result[0]:,}")
    print(f"Unique postal codes: {result[1]:,}")
    print(f"Unique states: {result[2]:,}")
    print(f"Invalid latitudes: {result[3] or 0}")
    print(f"Invalid longitudes: {result[4] or 0}")

    if result[0] != EXPECTED_ROWS:
        raise RuntimeError(
            "Loaded row count does not match the expected count."
        )

    if (result[3] or 0) != 0 or (result[4] or 0) != 0:
        raise RuntimeError(
            "Invalid geographic coordinates were found."
        )

    # Check accented Portuguese names.
    cursor.execute(
        f"""
        SELECT TOP 10 geolocation_city
        FROM {DESTINATION_TABLE}
        WHERE geolocation_city LIKE N'%são paulo%'
           OR geolocation_city LIKE N'%água boa%'
        ORDER BY geolocation_city;
        """
    )

    print("\nSample accented city names:")

    for row in cursor.fetchall():
        print(row[0])

    cursor.close()

    print("\nDestination validation completed.")


# ============================================================
# MAIN EXECUTION
# ============================================================

def main():
    conn = None

    try:
        df = read_source_data()
        df = validate_source_data(df)

        conn = connect_to_sql_server()

        check_destination_table(conn)

        load_data(conn, df)

        validate_loaded_data(conn)

        print("\n" + "=" * 60)
        print("GEOLOCATION INGESTION COMPLETED SUCCESSFULLY")
        print("=" * 60)

    except Exception as exc:
        print(f"\nERROR: {exc}")

        raise

    finally:
        if conn is not None:
            conn.close()
            print("\nSQL Server connection closed.")


if __name__ == "__main__":
    main()