from .models import Database

import psycopg2
from typing import List, Optional, IO


def connect_db(database: Database):
    return psycopg2.connect(database.get_connection_str())


def copy_file(
        file: IO,
        database: Database,
        table_name: str,
        table_cols: Optional[List[str]] = None,
        options: Optional[List[str]] = None
):
    """Copy file to database"""
    conn = None
    try:
        conn = connect_db(database)
        cursor = conn.cursor()

        table_cols_str = f"({', '.join(table_cols)})" if table_cols is not None else ""
        options_str = f"WITH {' '.join(options)}" if options is not None else ""
        cursor.copy_expert(
            sql=f"COPY {table_name}{table_cols_str} FROM STDIN {options_str}",
            file=file
        )
        conn.commit()
    except (Exception, psycopg2.DatabaseError) as error:
        raise error
    finally:
        if conn is not None:
            conn.close()


def get_table_size(table_name: str, database: Database) -> int:
    conn = None
    try:
        conn = connect_db(database)
        cursor = conn.cursor()
        cursor.execute(f"SELECT count(*) FROM {table_name}")
        table_size = cursor.fetchone()[0]
        cursor.close()
    except (Exception, psycopg2.DatabaseError) as error:
        raise error
    finally:
        if conn is not None:
            conn.close()
    return table_size
