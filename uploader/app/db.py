from .models import Database

import psycopg2
from typing import List, Optional, IO


def copy_file(
        file: IO,
        database: Database,
        table_name: str,
        table_cols: Optional[List[str]] = None,
        options: Optional[List[str]] = None
):
    """Copy file to database"""

    conn = psycopg2.connect(database.get_connection_str())
    cursor = conn.cursor()

    table_cols_str = f"({', '.join(table_cols)})" if table_cols is not None else ""
    options_str = f"WITH {' '.join(options)}" if options is not None else ""
    cursor.copy_expert(
        sql=f"COPY {table_name}{table_cols_str} FROM STDIN {options_str}",
        file=file
    )

    conn.commit()
    conn.close()
