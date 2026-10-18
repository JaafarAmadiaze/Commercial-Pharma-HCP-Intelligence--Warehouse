import os
import random
import pandas as pd
from faker import Faker
from datetime import datetime, timedelta

fake = Faker()
Faker.seed(42)
random.seed(42)

OUTPUT_DIR = "./output"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# 1. Territories
TERRITORIES = ["NE_US", "SE_US", "MW_US", "SW_US", "NW_US"]
REPS = {f"REP_{i:03d}": random.choice(TERRITORIES) for i in range(1, 26)}

# 2. Products (Our Brand vs Competitors)
PRODUCTS = [
    {"product_id": "PRD_001", "brand_name": "OncoShield", "therapeutic_class": "Oncology", "is_our_brand": True, "wac_price": 4200.00},
    {"product_id": "PRD_002", "brand_name": "TumorStop", "therapeutic_class": "Oncology", "is_our_brand": False, "wac_price": 4500.00},
    {"product_id": "PRD_003", "brand_name": "CardioGuard", "therapeutic_class": "Cardiology", "is_our_brand": True, "wac_price": 850.00},
    {"product_id": "PRD_004", "brand_name": "VasoPure", "therapeutic_class": "Cardiology", "is_our_brand": False, "wac_price": 920.00},
    {"product_id": "PRD_005", "brand_name": "NeuroCalm", "therapeutic_class": "Neurology", "is_our_brand": True, "wac_price": 1200.00},
    {"product_id": "PRD_006", "brand_name": "SynapsePlus", "therapeutic_class": "Neurology", "is_our_brand": False, "wac_price": 1150.00}
]

df_products = pd.DataFrame(PRODUCTS)
df_products.to_csv(f"{OUTPUT_DIR}/products.csv", index=False)
print("Generated products.csv")

# 3. Physicians (HCP Master Data)
SPECIALTIES = ["Oncology", "Cardiology", "Neurology", "Internal Medicine"]
physicians = []
for i in range(1, 501):
    pid = f"HCP_{i:05d}"
    physicians.append({
        "physician_id": pid,
        "npi": str(fake.unique.random_number(digits=10, fix_len=True)),
        "dea_number": f"{fake.random_letter().upper()}{fake.random_letter().upper()}{fake.unique.random_number(digits=7, fix_len=True)}",
        "first_name": fake.first_name(),
        "last_name": fake.last_name(),
        "specialty": random.choice(SPECIALTIES),
        "phone_number": fake.phone_number(),
        "email": fake.email(),
        "state": fake.state_abbr(),
        "territory_id": random.choice(TERRITORIES)
    })

df_physicians = pd.DataFrame(physicians)
df_physicians.to_csv(f"{OUTPUT_DIR}/physicians.csv", index=False)
print("Generated physicians.csv")

# 4. Field Rep CRM Calls (Unstructured Text for Cortex AI)
SAMPLE_BARRIERS = [
    "Physician expressed serious hesitation around out-of-pocket patient co-pay costs and insurance reimbursement.",
    "HCP was concerned about grade 2 and 3 fatigue and gastrointestinal side effects observed in phase III data.",
    "Doctor noted high satisfaction and established patient loyalty with competitor therapy TumorStop.",
    "Very positive discussion. The prescriber praised efficacy data in refractory cases and requested clinical trial reprints.",
    "Physician stated hospital formulary committee has not yet approved our brand for inpatient discharge scripts.",
    "Routine sample delivery. Brief greeting with physician, no major objections or feedback shared."
]

calls = []
start_date = datetime(2025, 1, 1)
for i in range(1, 4001):
    rep = random.choice(list(REPS.keys()))
    territory = REPS[rep]
    # Pick a physician within the rep's territory
    eligible_hcps = df_physicians[df_physicians["territory_id"] == territory]["physician_id"].tolist()
    if not eligible_hcps:
        eligible_hcps = df_physicians["physician_id"].tolist()

    call_dt = start_date + timedelta(days=random.randint(0, 365))
    calls.append({
        "call_id": f"CALL_{i:06d}",
        "rep_id": rep,
        "physician_id": random.choice(eligible_hcps),
        "call_date": call_dt.strftime("%Y-%m-%d"),
        "samples_dropped_count": random.choice([0, 2, 5, 10]),
        "discussion_notes": random.choice(SAMPLE_BARRIERS)
    })

df_calls = pd.DataFrame(calls)
df_calls.to_csv(f"{OUTPUT_DIR}/field_calls.csv", index=False)
print("Generated field_calls.csv")

# 5. Prescription Claims (TRx / NRx)
claims = []
product_ids = [p["product_id"] for p in PRODUCTS]
for i in range(1, 25001):
    hcp = random.choice(physicians)
    claim_dt = start_date + timedelta(days=random.randint(0, 365))
    nrx = random.randint(0, 8)
    trx = nrx + random.randint(0, 20)
    claims.append({
        "claim_id": f"CLM_{i:08d}",
        "physician_id": hcp["physician_id"],
        "product_id": random.choice(product_ids),
        "territory_id": hcp["territory_id"],
        "claim_date": claim_dt.strftime("%Y-%m-%d"),
        "nrx_count": nrx,
        "trx_count": trx
    })

df_claims = pd.DataFrame(claims)
df_claims.to_csv(f"{OUTPUT_DIR}/prescription_claims.csv", index=False)
print("Generated prescription_claims.csv")
