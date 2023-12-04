import logging
import requests
import streamlit as st

logger = logging.getLogger(st.__name__)
st.set_page_config(
    page_title="Upload Finances Data",
    page_icon=":floppy_disk:",
)

st.write("# Upload")

uploaded_file = st.file_uploader(
    label="Upload CSV with transaction statements",
    type=["csv"],
    accept_multiple_files=False,
)

table_name = st.selectbox(
    label="Table",
    help="Name of the table where to load the uploaded CSV file",
    options=("transactions", "categories"),
)

if uploaded_file and table_name:
    files = {
        "file": (uploaded_file.name, uploaded_file.read(), "text/csv"),
    }
    payload = {"table_name": f"sources.{table_name}"}
    response = requests.post(
        url="http://my-finances-api/upload", files=files, data=payload
    )

    if response.status_code != 200:
        st.error(response.json()["message"])
    else:
        st.success(response.text)
