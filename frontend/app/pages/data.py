import logging

import streamlit as st
import pandas as pd

from api import get_transactions

logger = logging.getLogger(st.__name__)
st.set_page_config(
    page_title="Data",
    page_icon=":floppy_disk:",
)

st.write("# Data")

if st.button("Load transactions"):

    response = get_transactions(limit=100)
    if response.status_code != 200:
        logger.error(response.json()["detail"])
        st.error(response.json()["detail"])
    else:

        df = pd.DataFrame.from_records(response.json())
        st.dataframe(df)



