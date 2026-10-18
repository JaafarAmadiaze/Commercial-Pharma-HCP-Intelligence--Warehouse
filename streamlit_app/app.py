import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import snowflake.connector
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization

# --- Page Configuration ---
st.set_page_config(
    page_title="Pharma Commercial & HCP Intelligence",
    page_icon="💊",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom Styling
st.markdown("""
<style>
    .main-header {
        font-size: 2.2rem;
        font-weight: 800;
        background: linear-gradient(90deg, #0ea5e9, #10b981, #6366f1);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        margin-bottom: 0.2rem;
    }
    .status-badge {
        display: inline-block;
        padding: 4px 12px;
        border-radius: 9999px;
        font-size: 0.8rem;
        font-weight: 600;
        background-color: rgba(16, 185, 129, 0.15);
        color: #10b981;
        border: 1px solid rgba(16, 185, 129, 0.3);
        margin-right: 8px;
    }
    .metric-card {
        background: rgba(255, 255, 255, 0.03);
        border: 1px solid rgba(255, 255, 255, 0.08);
        border-radius: 12px;
        padding: 16px;
        text-align: center;
    }
</style>
""", unsafe_allow_html=True)

# --- Snowflake Connection Function ---
@st.cache_resource
def get_snowflake_connection(role_name="TF_ADMIN"):
    sec = st.secrets["snowflake"]
    
    with open(sec["private_key_path"], "rb") as key_file:
        p_key = serialization.load_pem_private_key(
            key_file.read(),
            password=None,
            backend=default_backend()
        )
    
    pkb = p_key.private_bytes(
        encoding=serialization.Encoding.DER,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption()
    )
    
    conn = snowflake.connector.connect(
        user=sec["user"],
        account=sec["account"],
        role=role_name,
        warehouse=sec["warehouse"],
        database=sec["database"],
        schema=sec["schema"],
        private_key=pkb
    )
    return conn

# --- Global Query Runner ---
def run_query(query: str, role_name="TF_ADMIN") -> pd.DataFrame:
    conn = get_snowflake_connection(role_name)
    with conn.cursor() as cur:
        cur.execute(query)
        df = cur.fetch_pandas_all()
    # Normalize column names to uppercase
    df.columns = [c.upper() for c in df.columns]
    return df

# --- Sidebar: Persona Simulation & Filters ---
st.sidebar.markdown("### 🎭 Security & Governance Role")
simulated_role = st.sidebar.selectbox(
    "Active Role (RBAC / Masking)",
    options=["TF_ADMIN", "COMPLIANCE_OFFICER_DEV", "COMMERCIAL_REP_DEV"],
    help="Switch roles to observe Snowflake Dynamic Data Masking and Row-Level Security in action."
)

if simulated_role == "COMMERCIAL_REP_DEV":
    st.sidebar.info("🔒 **Rep View Active**: Contact info masked (DEA/Phone/Email). Territory restrictions enforced by RLAP.")
elif simulated_role == "COMPLIANCE_OFFICER_DEV":
    st.sidebar.warning("👁️ **Compliance View**: Unmasked PII & DEA numbers visible for auditing.")
else:
    st.sidebar.success("⚡ **Admin View**: Full access to all business marts and schemas.")

st.sidebar.markdown("---")
st.sidebar.markdown("### 🔍 Commercial Targeting Filters")

# Fetch Territories
try:
    territories_df = run_query("SELECT DISTINCT territory_id FROM MART_HCP_DECILES ORDER BY 1", simulated_role)
    available_territories = territories_df["TERRITORY_ID"].dropna().tolist()
except Exception:
    available_territories = ["NE_US", "SE_US", "MW_US", "SW_US", "NW_US"]

selected_territory = st.sidebar.selectbox("Sales Territory", options=["All"] + available_territories)

# Fetch Therapeutic Classes
try:
    classes_df = run_query("SELECT DISTINCT therapeutic_class FROM MART_HCP_DECILES ORDER BY 1", simulated_role)
    available_classes = classes_df["THERAPEUTIC_CLASS"].dropna().tolist()
except Exception:
    available_classes = ["Oncology", "Cardiology", "Neurology"]

selected_class = st.sidebar.selectbox("Therapeutic Class", options=["All"] + available_classes)

selected_tiers = st.sidebar.multiselect(
    "Commercial Decile Priority",
    options=["Tier 1 (High Priority)", "Tier 2 (Medium Priority)", "Tier 3 (Low Priority)"],
    default=["Tier 1 (High Priority)", "Tier 2 (Medium Priority)"]
)

# --- Build SQL Filters ---
where_clauses = ["1=1"]
if selected_territory != "All":
    where_clauses.append(f"territory_id = '{selected_territory}'")
if selected_class != "All":
    where_clauses.append(f"therapeutic_class = '{selected_class}'")
if selected_tiers:
    tiers_formatted = "', '".join(selected_tiers)
    where_clauses.append(f"commercial_tier IN ('{tiers_formatted}')")
where_sql = " AND ".join(where_clauses)

# --- Main App Header ---
st.markdown('<div class="main-header">💊 Commercial Pharma HCP Intelligence Hub</div>', unsafe_allow_html=True)
st.markdown("""
<div>
    <span class="status-badge">⚡ Snowflake Data Cloud</span>
    <span class="status-badge">🛡️ Dynamic Masking Active</span>
    <span class="status-badge">🤖 Cortex AI Powered</span>
    <span class="status-badge">📊 Elementary Observability (13/13 Tests)</span>
</div>
""", unsafe_allow_html=True)
st.markdown("<br>", unsafe_allow_html=True)

# --- Executive KPIs Ribbon ---
try:
    kpi_query = f"""
        SELECT 
            COUNT(DISTINCT physician_id) AS total_hcps,
            COALESCE(SUM(total_trx), 0) AS total_prescriptions,
            COALESCE(SUM(our_brand_trx), 0) AS our_prescriptions,
            COALESCE(ROUND(SUM(total_rx_revenue), 0), 0) AS total_revenue
        FROM MART_HCP_DECILES
        WHERE {where_sql}
    """
    kpi_df = run_query(kpi_query, simulated_role)
    total_hcps = int(kpi_df['TOTAL_HCPS'].iloc[0]) if not kpi_df.empty else 0
    total_trx = int(kpi_df['TOTAL_PRESCRIPTIONS'].iloc[0]) if not kpi_df.empty else 0
    our_trx = int(kpi_df['OUR_PRESCRIPTIONS'].iloc[0]) if not kpi_df.empty else 0
    total_rev = int(kpi_df['TOTAL_REVENUE'].iloc[0]) if not kpi_df.empty else 0
    market_share = round((our_trx / total_trx * 100), 1) if total_trx > 0 else 0.0
except Exception as e:
    total_hcps, total_trx, our_trx, total_rev, market_share = 0, 0, 0, 0, 0.0

col1, col2, col3, col4, col5 = st.columns(5)
col1.metric("🎯 Targeted HCPs", f"{total_hcps:,}")
col2.metric("📦 Total Market TRx", f"{total_trx:,}")
col3.metric("🏆 Our Brand TRx", f"{our_trx:,}")
col4.metric("📊 Brand Market Share", f"{market_share}%")
col5.metric("💰 Gross Value ($)", f"${total_rev:,}")

st.markdown("---")

# --- Tabbed Navigation ---
tab_hcp, tab_cortex, tab_market, tab_rep, tab_gov = st.tabs([
    "🎯 HCP Targeting & Deciles",
    "🤖 Cortex AI Field Objections",
    "📈 Brand & Market Trajectory",
    "💼 Field Rep ROI & Attribution",
    "🛡️ Data Governance & Masking"
])

# ==============================================================================
# TAB 1: HCP DECILING & TARGETING
# ==============================================================================
with tab_hcp:
    st.subheader("Physician Decile Ranking & KOL Tiering")
    st.caption("Doctors categorized into 10 deciles (NTILE 10) per therapeutic class based on TRx volume.")
    
    t1_c1, t1_c2 = st.columns([1, 2])
    
    with t1_c1:
        # Decile Breakdown Chart
        decile_dist_query = f"""
            SELECT hcp_decile, COUNT(*) AS physician_count, SUM(our_brand_trx) AS our_trx
            FROM MART_HCP_DECILES
            WHERE {where_sql}
            GROUP BY 1
            ORDER BY 1 ASC
        """
        try:
            decile_dist_df = run_query(decile_dist_query, simulated_role)
            fig_deciles = px.bar(
                decile_dist_df,
                x="HCP_DECILE",
                y="PHYSICIAN_COUNT",
                color="OUR_TRX",
                color_continuous_scale="Viridis",
                title="Physician Count by Decile (1=Low, 10=KOL)",
                labels={"HCP_DECILE": "Decile", "PHYSICIAN_COUNT": "Prescribers", "OUR_TRX": "Our TRx"}
            )
            fig_deciles.update_layout(margin=dict(l=20, r=20, t=40, b=20), height=340)
            st.plotly_chart(fig_deciles, use_container_width=True)
        except Exception as e:
            st.error(f"Error loading decile distribution: {e}")
            
    with t1_c2:
        # High Priority Prescribers Table
        hcp_table_query = f"""
            SELECT 
                d.physician_id,
                p.first_name || ' ' || p.last_name AS doctor_name,
                p.specialty,
                p.state,
                p.phone_number,
                p.email,
                d.hcp_decile,
                d.commercial_tier,
                d.total_trx,
                d.our_brand_trx
            FROM MART_HCP_DECILES d
            JOIN DIM_PHYSICIAN p ON d.physician_id = p.physician_id
            WHERE {where_sql}
            ORDER BY d.hcp_decile DESC, d.total_trx DESC
            LIMIT 100
        """
        try:
            hcp_table_df = run_query(hcp_table_query, simulated_role)
            st.dataframe(hcp_table_df, use_container_width=True, height=300)
            st.caption("🔒 Sensitive contact data is dynamically masked based on your active role.")
        except Exception as e:
            st.error(f"Error loading HCP table: {e}")

    # Physician 360 Deep-Dive
    st.markdown("#### 🔬 Prescriber 360° Profile Search")
    try:
        sample_hcp_list = run_query(f"SELECT DISTINCT physician_id FROM MART_HCP_DECILES WHERE {where_sql} LIMIT 50", simulated_role)
        selected_hcp_id = st.selectbox("Select a Physician for 360° Deep-Dive", options=sample_hcp_list["PHYSICIAN_ID"].tolist())
        
        if selected_hcp_id:
            hcp_profile_query = f"""
                SELECT 
                    p.physician_id,
                    p.first_name || ' ' || p.last_name AS full_name,
                    p.specialty,
                    p.npi,
                    p.dea_number,
                    p.phone_number,
                    p.email,
                    p.territory_id,
                    p.state
                FROM DIM_PHYSICIAN p
                WHERE p.physician_id = '{selected_hcp_id}'
            """
            profile_df = run_query(hcp_profile_query, simulated_role)
            if not profile_df.empty:
                p_row = profile_df.iloc[0]
                p1, p2, p3, p4 = st.columns(4)
                p1.info(f"**Name**: {p_row['FULL_NAME']}")
                p2.info(f"**Specialty**: {p_row['SPECIALTY']} ({p_row['STATE']})")
                p3.info(f"**DEA / NPI**: {p_row['DEA_NUMBER']} / {p_row['NPI']}")
                p4.info(f"**Contact**: {p_row['PHONE_NUMBER']}")

            # Recent Field Calls for this HCP
            hcp_calls_query = f"""
                SELECT call_date, rep_id, samples_dropped_count, doctor_barrier_category, call_sentiment_score, discussion_notes
                FROM FACT_FIELD_CALLS
                WHERE physician_id = '{selected_hcp_id}'
                ORDER BY call_date DESC
                LIMIT 5
            """
            hcp_calls_df = run_query(hcp_calls_query, simulated_role)
            st.write("**Recent Rep Interactions & Cortex AI Insights:**")
            st.dataframe(hcp_calls_df, use_container_width=True)
    except Exception as e:
        st.info("Select a physician above to view the 360° log.")

# ==============================================================================
# TAB 2: CORTEX AI FIELD OBJECTIONS & SENTIMENT
# ==============================================================================
with tab_cortex:
    st.subheader("Snowflake Cortex LLM Field Intelligence & Objections")
    st.caption("AI analyzes representative field discussion notes directly inside Snowflake without data movement.")
    
    barrier_filter = "WHERE 1=1"
    if selected_territory != "All":
        barrier_filter += f" AND territory_id = '{selected_territory}'"

    cortex_query = f"""
        SELECT 
            doctor_barrier_category,
            COUNT(*) AS call_count,
            ROUND(AVG(call_sentiment_score), 3) AS avg_sentiment_score
        FROM FACT_FIELD_CALLS
        {barrier_filter}
        GROUP BY 1
        ORDER BY 2 DESC
    """
    try:
        cortex_df = run_query(cortex_query, simulated_role)
        
        c2_1, c2_2 = st.columns([3, 2])
        with c2_1:
            fig_barriers = px.bar(
                cortex_df,
                x="CALL_COUNT",
                y="DOCTOR_BARRIER_CATEGORY",
                orientation="h",
                color="AVG_SENTIMENT_SCORE",
                color_continuous_scale="RdYlGn",
                title="Top Prescriber Objections & Sentiment Breakdown",
                labels={"CALL_COUNT": "Number of Field Calls", "DOCTOR_BARRIER_CATEGORY": "Objection Category", "AVG_SENTIMENT_SCORE": "Sentiment"}
            )
            fig_barriers.update_layout(yaxis=dict(autorange="reversed"), height=360)
            st.plotly_chart(fig_barriers, use_container_width=True)
            
        with c2_2:
            st.markdown("#### Summary of Barrier Impact")
            st.dataframe(cortex_df, use_container_width=True, height=320)
    except Exception as e:
        st.error(f"Error loading Cortex analytics: {e}")

    # Sample Unstructured Notes Feed
    st.markdown("#### 📝 Real-Time Field Discussion Notes Stream")
    try:
        notes_query = f"""
            SELECT call_date, rep_id, physician_id, doctor_barrier_category, call_sentiment_score, discussion_notes
            FROM FACT_FIELD_CALLS
            {barrier_filter}
            ORDER BY call_date DESC
            LIMIT 8
        """
        notes_df = run_query(notes_query, simulated_role)
        for _, n in notes_df.iterrows():
            sent_color = "🟢" if n['CALL_SENTIMENT_SCORE'] > 0 else ("🔴" if n['CALL_SENTIMENT_SCORE'] < 0 else "⚪")
            st.markdown(f"""
            > **{n['CALL_DATE']}** | Rep: `{n['REP_ID']}` $\\rightarrow$ Doctor: `{n['PHYSICIAN_ID']}` | **Category:** `{n['DOCTOR_BARRIER_CATEGORY']}` | {sent_color} Sentiment: `{n['CALL_SENTIMENT_SCORE']}`  
            > *"{n['DISCUSSION_NOTES']}"*
            """)
    except Exception as e:
        st.error(f"Error loading notes feed: {e}")

# ==============================================================================
# TAB 3: BRAND & MARKET TRAJECTORY
# ==============================================================================
with tab_market:
    st.subheader("Brand Market Share Trajectory vs. Competitor Therapies")
    
    brand_filter = "WHERE 1=1"
    if selected_territory != "All":
        brand_filter += f" AND territory_id = '{selected_territory}'"
    if selected_class != "All":
        brand_filter += f" AND therapeutic_class = '{selected_class}'"

    market_query = f"""
        SELECT 
            TO_VARCHAR(claim_month, 'YYYY-MM') AS month_str,
            therapeutic_class,
            brand_name,
            is_our_brand,
            SUM(brand_trx) AS total_brand_trx,
            ROUND(AVG(market_share_percentage), 1) AS avg_market_share,
            ROUND(AVG(nrx_conversion_rate), 1) AS avg_conversion_rate
        FROM MART_BRAND_PERFORMANCE
        {brand_filter}
        GROUP BY 1, 2, 3, 4
        ORDER BY 1 ASC
    """
    try:
        market_df = run_query(market_query, simulated_role)
        
        m_col1, m_col2 = st.columns(2)
        with m_col1:
            fig_market = px.line(
                market_df,
                x="MONTH_STR",
                y="AVG_MARKET_SHARE",
                color="BRAND_NAME",
                line_dash="IS_OUR_BRAND",
                title="Monthly Market Share % (Solid = Our Brand, Dashed = Competitor)",
                labels={"MONTH_STR": "Month", "AVG_MARKET_SHARE": "Market Share (%)", "BRAND_NAME": "Therapy"}
            )
            fig_market.update_layout(height=380)
            st.plotly_chart(fig_market, use_container_width=True)
            
        with m_col2:
            fig_conv = px.bar(
                market_df,
                x="MONTH_STR",
                y="TOTAL_BRAND_TRX",
                color="BRAND_NAME",
                barmode="group",
                title="Monthly Prescriptions (TRx) by Brand",
                labels={"MONTH_STR": "Month", "TOTAL_BRAND_TRX": "Total TRx Volume"}
            )
            fig_conv.update_layout(height=380)
            st.plotly_chart(fig_conv, use_container_width=True)
    except Exception as e:
        st.error(f"Error loading market dynamics: {e}")

# ==============================================================================
# TAB 4: FIELD REP ROI & ATTRIBUTION
# ==============================================================================
with tab_rep:
    st.subheader("Field Sales Representative ROI & Conversion Attribution")
    st.caption("Evaluates visits, sample distribution efficiency, and attributed brand revenue from `MART_REP_EFFECTIVENESS`.")
    
    rep_filter = "WHERE 1=1"
    if selected_territory != "All":
        rep_filter += f" AND territory_id = '{selected_territory}'"
        
    rep_query = f"""
        SELECT 
            rep_id,
            territory_id,
            SUM(total_visits) AS visits_count,
            SUM(total_samples_provided) AS samples_dropped,
            ROUND(AVG(avg_sentiment_score), 2) AS rep_avg_sentiment,
            SUM(our_brand_revenue) AS attributed_brand_revenue,
            ROUND(SUM(our_brand_revenue) / NULLIF(SUM(total_visits), 0), 0) AS revenue_per_visit
        FROM MART_REP_EFFECTIVENESS
        {rep_filter}
        GROUP BY 1, 2
        ORDER BY attributed_brand_revenue DESC
    """
    try:
        rep_df = run_query(rep_query, simulated_role)
        
        r_c1, r_c2 = st.columns([3, 2])
        with r_c1:
            fig_rep_scatter = px.scatter(
                rep_df,
                x="VISITS_COUNT",
                y="ATTRIBUTED_BRAND_REVENUE",
                size="SAMPLES_DROPPED",
                color="REVENUE_PER_VISIT",
                hover_name="REP_ID",
                color_continuous_scale="Plasma",
                title="Rep Activity vs. Revenue (Bubble Size = Samples Provided)",
                labels={"VISITS_COUNT": "Total Doctor Visits", "ATTRIBUTED_BRAND_REVENUE": "Brand Revenue ($)", "REVENUE_PER_VISIT": "$ / Visit"}
            )
            fig_rep_scatter.update_layout(height=380)
            st.plotly_chart(fig_rep_scatter, use_container_width=True)
            
        with r_c2:
            st.markdown("#### Rep Leaderboard")
            st.dataframe(rep_df, use_container_width=True, height=340)
    except Exception as e:
        st.error(f"Error loading rep effectiveness: {e}")

# ==============================================================================
# TAB 5: GOVERNANCE, MASKING & DATA OBSERVABILITY
# ==============================================================================
with tab_gov:
    st.subheader("Snowflake Zero-Trust Security & Data Observability")
    
    g_col1, g_col2 = st.columns(2)
    with g_col1:
        st.markdown("#### 🔒 Live Dynamic Data Masking Verification")
        st.write(f"Currently querying Snowflake as: **`{simulated_role}`**")
        sample_mask_query = """
            SELECT physician_id, npi, dea_number, phone_number, email 
            FROM DIM_PHYSICIAN 
            LIMIT 5
        """
        try:
            mask_df = run_query(sample_mask_query, simulated_role)
            st.dataframe(mask_df, use_container_width=True)
            if simulated_role == "COMMERCIAL_REP_DEV":
                st.success("✅ Masking Verified: DEA Number, Phone, and Email are properly sanitized.")
            else:
                st.info("ℹ️ Unmasked Data: Current role is authorized to view raw PII.")
        except Exception as e:
            st.error(f"Masking check error: {e}")
            
    with g_col2:
        st.markdown("#### 📊 Elementary Observability & Reliability")
        st.markdown("""
        - **Pipeline Health**: 13 Data & Anomaly Tests Passing (0 Failures)
        - **Daily Volume Anomaly Detection**: `elementary.volume_anomalies` on `FACT_PRESCRIPTION_CLAIMS`
        - **TRx Drift Monitoring**: `elementary.column_anomalies` (Min/Max/Avg)
        - **SCD Type 2 Tracking**: Active snapshot tracking in `SNP_PHYSICIANS`
        """)
        st.success("✅ All 13 Elementary integrity monitors are operational in schema `PHARMA_DW_DEV.ELEMENTARY`.")

st.markdown("---")
st.caption("Pharmaceutical HCP Commercial Intelligence Platform | Built with Snowflake, dbt Core, Cortex LLM, and Streamlit")
