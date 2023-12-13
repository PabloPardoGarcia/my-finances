from typing import IO, List, Optional

import psycopg2
from psycopg2.extras import RealDictCursor


def copy_file(
    file: IO,
    connection_str: str,
    table_name: str,
    table_cols: Optional[List[str]] = None,
    options: Optional[List[str]] = None,
):
    """Copy file to database"""
    conn = None
    try:
        conn = psycopg2.connect(connection_str)
        cursor = conn.cursor()

        table_cols_str = f"({', '.join(table_cols)})" if table_cols is not None else ""
        options_str = f"WITH {' '.join(options)}" if options is not None else ""
        cursor.copy_expert(
            sql=f"COPY {table_name}{table_cols_str} FROM STDIN {options_str}", file=file
        )
        conn.commit()
    except (Exception, psycopg2.DatabaseError) as error:
        raise error
    finally:
        if conn is not None:
            conn.close()


def fetch_query_result(query: str, connection_str: str, **cursor_opt):
    conn = None
    try:
        conn = psycopg2.connect(connection_str)
        cursor = conn.cursor(**cursor_opt)
        cursor.execute(query)
        result = cursor.fetchall()
        cursor.close()
    except (Exception, psycopg2.DatabaseError) as error:
        raise error
    finally:
        if conn is not None:
            conn.close()
    return result


def fetch_table(
    table_name: str,
    connection_str: str,
    limit: Optional[int] = None,
    offset: Optional[int] = None,
):
    query = f"SELECT * FROM {table_name}"
    if limit:
        query += f" LIMIT {limit}"
    if offset:
        query += f" OFFSET {offset}"

    return fetch_query_result(
        query=query, connection_str=connection_str, cursor_factory=RealDictCursor
    )


def fetch_table_size(table_name: str, connection_str: str) -> int:
    return fetch_query_result(
        query=f"SELECT count(*) FROM {table_name}", connection_str=connection_str
    )[0]


def fetch_transaction_category(transaction_id: int, connection_str: str) -> int:
    return fetch_query_result(
        query=f"SELECT category_id "
        f"FROM transaction_categories "
        f"WHERE transactoin_id = {transaction_id}",
        connection_str=connection_str,
    )[0]
