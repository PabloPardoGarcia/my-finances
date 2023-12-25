import streamlit as st


def sidebar():
    with st.sidebar:
        st.link_button(label="`dbt` documentation", url="/dbt/")
        st.link_button(label="API documentation", url="/api/docs")