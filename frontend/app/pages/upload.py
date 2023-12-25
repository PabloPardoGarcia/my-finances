import logging
import streamlit as st

from api import upload
from components import sidebar

logger = logging.getLogger(st.__name__)

st.set_page_config(
    page_title="Upload Finances Data",
    page_icon=":floppy_disk:",
)
sidebar()

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

if st.button("Upload"):
    if uploaded_file and table_name:
        with st.spinner('Uploading ...'):
            response = upload(uploaded_file, table_name)
        if response.status_code != 200:
            logger.error(response.json()["message"])
            st.error(response.json()["message"])
        else:
            logger.info(response.json()["message"])
            st.success(response.json()["message"])
    elif uploaded_file is None:
        st.error("Missing file to upload.")
    else:
        st.error("Missing a table to upload your file to.")
