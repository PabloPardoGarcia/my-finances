from unittest import mock

from app.db import get_table_size


@mock.patch("psycopg2.connect")
def test_get_table_size(mock_connect):
    mock_con = mock_connect.return_value
    mock_cur = mock_con.cursor.return_value
    mock_cur.fetchone.return_value = (42,)

    result = get_table_size(
        table_name="fake_table", connection_str="fake_connection_str"
    )

    assert result == 42

    mock_connect.assert_called_once_with("fake_connection_str")
    mock_cur.execute.assert_called_once_with("SELECT count(*) FROM fake_table")
    mock_cur.fetchone.assert_called_once()
