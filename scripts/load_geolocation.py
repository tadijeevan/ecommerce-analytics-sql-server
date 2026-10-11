import pandas as pd
import pyodbc
from pathlib import Path

# --------------------------------------------------
# CONFIGURATION
# --------------------------------------------------

CSV_PATH = Path("data/raw/olist_geolocation_dataset.csv")
EXPECTED_ROWS = 1_000_163
BATCH_SIZE = 10_000

CONNECTION_STRING = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    r"SERVER=DESKTOP-Q7I6VKD\SQLEXPRESS;"
    "DATABASE=EcommerceAnalytics;"
    "Trusted_Connection=yes;"
)

DESTINATION_TABLE = "dbo.olist_geolocation_unicode"


def main():
    print("=" * 60)
    print("GEOLOCATION DATA INGESTION")
    print("=" * 60)

    # 1. Read the original UTF-8 CSV.
    if not CSV_PATH.exists():
        raise FileNotFoundError(
            f"CSV not found: {CSV_PATH.resolve()}"
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

    print(f"Source rows: {len(df):,}")

    if len(df) != EXPECTED_ROWS:
        raise ValueError(
            f"Expected {EXPECTED_ROWS:,} rows, "
            f"found {len(df):,}."
        )

    expected_columns = [
        "geolocation_zip_code_prefix",
        "geolocation_lat",
        "geolocation_lng",
        "geolocation_city",
        "geolocation_state",
    ]

    if list(df.columns) != expected_columns:
        raise ValueError(
            f"Unexpected CSV columns: {list(df.columns)}"
        )

    if df.isnull().any().any():
        raise ValueError("Source CSV contains missing values.")

    # 2. Validate postal codes and coordinates.
    if not df["geolocation_zip_code_prefix"].str.fullmatch(
        r"\d{5}"
    ).all():
        raise ValueError("Invalid postal code found.")

    latitude = pd.to_numeric(
        df["geolocation_lat"], errors="coerce"
    )
    longitude = pd.to_numeric(
        df["geolocation_lng"], errors="coerce"
    )

    valid_coordinates = (
        latitude.notna()
        & longitude.notna()
        & latitude.between(-90, 90)
        & longitude.between(-180, 180)
    )

    if not valid_coordinates.all():
        raise ValueError("Invalid coordinates found.")

    # Keep coordinates as strings for the VARCHAR destination.
    df["geolocation_lat"] = df["geolocation_lat"].astype(str)
    df["geolocation_lng"] = df["geolocation_lng"].astype(str)

    print("Source validation passed.")
    print("Connecting to SQL Server...")

    # 3. Connect and check that the destination is empty.
    conn = pyodbc.connect(
        CONNECTION_STRING,
        autocommit=False,
    )

    try:
        cursor = conn.cursor()

        cursor.execute(
            f"SELECT COUNT_BIG(*) FROM {DESTINATION_TABLE}"
        )
        existing_rows = cursor.fetchone()[0]

        if existing_rows != 0:
            raise RuntimeError(
                f"{DESTINATION_TABLE} already contains "
                f"{existing_rows:,} rows. Stopping to prevent "
                "duplicate loading."
            )

        # 4. Insert the data in batches.
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

        cursor.fast_executemany = True
        total_rows = len(df)

        print("Starting SQL Server load...")

        for start in range(0, total_rows, BATCH_SIZE):
            batch = df.iloc[start:start + BATCH_SIZE]

            records = list(
                batch[expected_columns].itertuples(
                    index=False,
                    name=None,
                )
            )

            # Convert NumPy/Pandas values to Python strings.
            records = [
                tuple(str(value) for value in row)
                for row in records
            ]

            cursor.executemany(insert_sql, records)

            loaded = min(start + len(batch), total_rows)
            print(f"Processed {loaded:,} / {total_rows:,} rows")

        # Commit only after all batches succeed.
        conn.commit()
        print("Database transaction committed.")

        cursor.close()

        # 5. Validate the loaded data.
        cursor = conn.cursor()

        cursor.execute(f"""
            SELECT
                COUNT_BIG(*) AS total_rows,
                COUNT(DISTINCT geolocation_zip_code_prefix)
                    AS unique_postal_codes,
                COUNT(DISTINCT geolocation_state)
                    AS unique_states,
                SUM(
                    CASE
                        WHEN TRY_CONVERT(
                            FLOAT, geolocation_lat
                        ) NOT BETWEEN -90 AND 90
                        OR TRY_CONVERT(
                            FLOAT, geolocation_lng
                        ) NOT BETWEEN -180 AND 180
                        THEN 1
                        ELSE 0
                    END
                ) AS invalid_coordinates
            FROM {DESTINATION_TABLE};
        """)

        result = cursor.fetchone()

        print("\nFINAL VALIDATION")
        print("-" * 40)
        print(f"Total rows: {result[0]:,}")
        print(f"Unique postal codes: {result[1]:,}")
        print(f"Unique states: {result[2]:,}")
        print(
            "Invalid coordinates: "
            f"{result[3] if result[3] is not None else 0}"
        )

        if result[0] != EXPECTED_ROWS:
            raise RuntimeError("Loaded row count does not match.")

        # Verify Portuguese characters survived the import.
        cursor.execute(f"""
            SELECT TOP (10)
                geolocation_zip_code_prefix,
                geolocation_city,
                geolocation_state
            FROM {DESTINATION_TABLE}
            WHERE geolocation_city LIKE N'%são paulo%'
               OR geolocation_city LIKE N'%água boa%'
               OR geolocation_city LIKE N'%jundiaí%';
        """)

        print("\nUNICODE CITY NAME SAMPLES")
        print("-" * 40)

        samples = cursor.fetchall()

        if samples:
            for row in samples:
                print(row)
        else:
            print(
                "No matching sample found. "
                "We will inspect Unicode preservation separately."
            )

        cursor.close()

    except Exception:
        conn.rollback()
        raise

    finally:
        conn.close()

    print("\nGeolocation ingestion completed.")


if __name__ == "__main__":
    main()