import logging

from streamlit_extras.dataframe_explorer import dataframe_explorer
import streamlit as st
import pandas as pd
import altair as alt

from api import get_transactions_page
from components import sidebar

AGG_PERIODS = ("day", "week", "month", "year")

logger = logging.getLogger(st.__name__)


@st.cache_data(show_spinner="Loading Transactions data ...")
def load_transactions():
    n_pages = get_transactions_page().pages
    df_pages = []
    for page in range(1, n_pages + 1):
        transactions = get_transactions_page(page)
        transactions_json = [i.model_dump() for i in transactions.items]
        df_pages.append(pd.DataFrame.from_records(transactions_json))
    if df_pages:
        df = pd.concat(df_pages, ignore_index=True, sort=True)

        df["booking"] = pd.to_datetime(df.booking, format="%d.%m.%Y")
        df["balance"] = pd.to_numeric(
            df.balance.str.replace(".", "").str.replace(",", ".")
        )

        df = df.sort_values("booking", ignore_index=True)
    else:
        df = pd.DataFrame()
    return df


@st.cache_data
def aggregate_balance(df: pd.DataFrame, period: str) -> pd.DataFrame:
    if period not in AGG_PERIODS:
        raise ValueError(f"Period can only be one of {AGG_PERIODS}")

    if period == "day":
        freq = "D"
    elif period == "week":
        freq = "W"
    elif period == "month":
        freq = "M"
    elif period == "year":
        freq = "Y"

    return df.groupby([pd.Grouper(key="booking", freq=freq)]).agg({
        "balance": "last"
    }).reset_index()


st.set_page_config(
    page_title="Data",
    page_icon=":floppy_disk:",
)
sidebar()

st.write("# Dashboard")

try:
    data = load_transactions()
except Exception as e:
    logger.error(e)
    raise e

if not data.empty:
    with st.sidebar:
        st.write("### Filters")
        filtered_df = dataframe_explorer(data, case=False)

    st.write("## Table Data")
    st.dataframe(filtered_df, use_container_width=True)

    st.write("## Account Balance")
    period = st.selectbox("Aggregation Period", options=AGG_PERIODS)
    balance_df = aggregate_balance(filtered_df, period=period)
    logger.info(balance_df.head())
    logger.info(balance_df.dtypes)
    chart = (
        alt.Chart(balance_df)
        .mark_line()
        .encode(x="booking:T", y="balance:Q")
    )
    st.altair_chart(chart, use_container_width=True)
