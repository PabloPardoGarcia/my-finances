import requests

import streamlit as st

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

table_name = st.text_input(
    label="Table Name",
    help="Name of the table where to load the uploaded CSV file"
)

if uploaded_file and table_name:
    files = {
        "file": (uploaded_file.name, uploaded_file.read(), "application/csv"),
    }
    payload = {"table_name": table_name}
    response = requests.post(
        url="/api/upload",
        files=files,
        data=payload
    )
    st.write(response)
