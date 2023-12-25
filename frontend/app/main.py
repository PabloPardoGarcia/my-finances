import streamlit as st
from components import sidebar

st.set_page_config(
    page_title="My Finances",
    page_icon="👋",
)

st.write("# Welcome to My Finances! 👋")

sidebar()
