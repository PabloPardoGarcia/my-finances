from unittest import mock

from app.db import fetch_query_result


@mock.patch("psycopg2.connect")
def test_fetch_query_result(mock_connect):
    mock_con = mock_connect.return_value
    mock_cur = mock_con.cursor.return_value
    mock_cur.fetchall.return_value = (42,)

    result = fetch_query_result(
        query="fake_query", connection_str="fake_connection_str"
    )

    assert result == (42,)

    mock_connect.assert_called_once_with("fake_connection_str")
    mock_cur.execute.assert_called_once_with("fake_query")
    mock_cur.fetchall.assert_called_once()
