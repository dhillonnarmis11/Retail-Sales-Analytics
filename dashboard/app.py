from pathlib import Path

import pandas as pd
import streamlit as st
import matplotlib.pyplot as plt

# find project directory, regardless of where Streamlit is launched
PROJECT_ROOT = Path(__file__).resolve().parent.parent
DATA_DIR = PROJECT_ROOT / 'data' / 'processed'

st.set_page_config(page_title='Olist Retail Analytics', page_icon='📊', layout='wide')
st.title('Olist E-Commerce Analytics Dashboard')
st.caption('Historical Brazilian e-commerce data (2016–2018) | Monetary values in BRL (R$)')

@st.cache_data
def load_data():
    monthly = pd.read_csv(DATA_DIR / 'monthly_sales.csv')
    categories = pd.read_csv(DATA_DIR / 'category_sales.csv')
    states = pd.read_csv(DATA_DIR / 'state_sales.csv')
    delivery = pd.read_csv(DATA_DIR / 'delivery_reviews.csv')
    return monthly, categories, states, delivery

try:
    monthly, categories, states, delivery = load_data()
except FileNotFoundError:
    st.error('Processed CSV files are missing. Run `python3 export_dashboard_data.py` from the project root.')
    st.stop()

# the monthly CSV contains delivered merchandise revenue, excluding freight
total_revenue = monthly['revenue'].sum()
total_orders = monthly['orders'].sum()
aov = total_revenue / total_orders if total_orders else 0

m1, m2, m3 = st.columns(3)
m1.metric('Delivered merchandise revenue', f'R${total_revenue:,.2f}')
m2.metric('Delivered orders', f'{total_orders:,}')
m3.metric('Average order value', f'R${aov:,.2f}')

st.divider()
st.subheader('Monthly sales trend')
monthly_plot = monthly.copy()
monthly_plot['month'] = pd.to_datetime(monthly_plot['month'], format='%Y-%m')
monthly_plot = monthly_plot.set_index('month')
st.line_chart(monthly_plot[['revenue']], y_label='Merchandise revenue (R$)')

left, right = st.columns(2)
with left:
    st.subheader('Top 10 product categories')
    top_categories = categories.nlargest(10, 'revenue').sort_values('revenue')
    fig, ax = plt.subplots(figsize=(7, 5))
    ax.barh(top_categories['category'].str.replace('_', ' ', regex=False), top_categories['revenue'])
    ax.set_xlabel('Merchandise revenue (R$)')
    fig.tight_layout()
    st.pyplot(fig)
    plt.close(fig)

with right:
    st.subheader('Top 10 customer states')
    top_states = states.nlargest(10, 'revenue').sort_values('revenue')
    fig, ax = plt.subplots(figsize=(7, 5))
    ax.barh(top_states['state'], top_states['revenue'])
    ax.set_xlabel('Merchandise revenue (R$)')
    fig.tight_layout()
    st.pyplot(fig)
    plt.close(fig)

st.subheader('Delivery performance and customer reviews')
fig, ax = plt.subplots(figsize=(7, 3))
ax.bar(delivery['delivery_status'], delivery['average_review_score'])
ax.set_ylim(0, 5)
ax.set_ylabel('Average review score (out of 5)')
for i, score in enumerate(delivery['average_review_score']):
    ax.text(i, score + 0.08, f'{score:.2f}', ha='center')
fig.tight_layout()
st.pyplot(fig)
plt.close(fig)

with st.expander('View source data'):
    st.write('Monthly revenue')
    st.dataframe(monthly, use_container_width=True)
    st.write('Category revenue')
    st.dataframe(categories, use_container_width=True)
    st.write('State revenue')
    st.dataframe(states, use_container_width=True)
    st.write('Delivery reviews')
    st.dataframe(delivery, use_container_width=True)

st.caption('Methodology: Revenue is the sum of order-item prices for delivered orders, excluding freight. Review scores are averaged per order before grouping by delivery performance. Historical observations are not causal estimates.')
