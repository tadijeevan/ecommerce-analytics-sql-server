from pathlib import Path

import pandas as pd
import pyodbc


# ==================================================
# CONFIGURATION
# ==================================================

CSV_PATH = Path("data/raw/product_category_name_translation.csv")

EXPECTED_ROWS = 71

CONNECTION_STRING = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    r"SERVER=DESKTOP-Q7I6VKD\SQLEXPRESS;"
    "DATABASE=EcommerceAnalytics;"
    "Trusted_Connection=yes;"
)

DESTINATION_TABLE = "dbo.product_category_name_translation"


def main():

    # STEP 1: CHECK WHETHER THE SOURCE CSV EXISTS

    if not CSV_PATH.exists():
        raise FileNotFoundError(
            f"CSV file not found: {CSV_PATH.resolve()}"
        )

    # STEP 2: READ THE CSV

    df = pd.read_csv(CSV_PATH, dtype=str)

    expected_columns = [
        "product_category_name",
        "product_category_name_english",
    ]

    if df.columns.tolist() != expected_columns:
        raise ValueError(
            f"Unexpected CSV columns: {df.columns.tolist()}"
        )

    print("Source CSV loaded successfully.")
    print(f"Source rows: {len(df)}")

    # STEP 3: VALIDATE THE SOURCE DATA

    if len(df) != EXPECTED_ROWS:
        raise ValueError(
            f"Expected {EXPECTED_ROWS} rows, found {len(df)}."
        )

    if df.isnull().any().any():
        raise ValueError("Missing values found in the CSV.")

    if df.duplicated().any():
        raise ValueError("Duplicate rows found in the CSV.")

    if df["product_category_name"].duplicated().any():
        raise ValueError(
            "Duplicate Portuguese category names found."
        )

    if df["product_category_name_english"].duplicated().any():
        raise ValueError(
            "Duplicate English category names found."
        )

    print("Source data quality checks passed.")

    # STEP 4: PREPARE THE DATA

    rows = list(df.itertuples(index=False, name=None))

    # STEP 5: CONNECT TO SQL SERVER

    connection = pyodbc.connect(CONNECTION_STRING)

    try:
        cursor = connection.cursor()

        # Do not insert the same data twice.
        cursor.execute(
            f"SELECT COUNT(*) FROM {DESTINATION_TABLE}"
        )

        existing_rows = cursor.fetchone()[0]

        if existing_rows != 0:
            raise RuntimeError(
                f"The destination table already contains "
                f"{existing_rows} rows. No data was inserted."
            )

        # STEP 6: INSERT THE DATA

        cursor.fast_executemany = True

        cursor.executemany(
            f"""
            INSERT INTO {DESTINATION_TABLE}
            (
                product_category_name,
                product_category_name_english
            )
            VALUES (?, ?)
            """,
            rows,
        )

        # STEP 7: VALIDATE THE INSERTED ROW COUNT

        cursor.execute(
            f"SELECT COUNT(*) FROM {DESTINATION_TABLE}"
        )

        loaded_rows = cursor.fetchone()[0]

        if loaded_rows != EXPECTED_ROWS:
            raise RuntimeError(
                f"Expected {EXPECTED_ROWS} rows after loading, "
                f"but found {loaded_rows}."
            )

        connection.commit()

        print("SQL Server import completed successfully.")
        print(f"Rows inserted: {loaded_rows}")
        print(f"Destination table: {DESTINATION_TABLE}")

    except Exception:
        connection.rollback()
        raise

    finally:
        connection.close()


if __name__ == "__main__":
    main()
    