# 🚀 Lantern Technical Test

Welcome to the Lantern technical assessment. This test is designed to evaluate your skills in **DBT** (Data Build Tool), **SQL**, and your ability to derive business insights from raw data.

---

## 🧩 Objective

Your goal is to demonstrate:
- Proficiency in using **DBT** with a **DuckDB** backend.
- Analytical thinking to answer key business questions.
- Ability to clean, transform, and model raw data into meaningful insights.

---

## 🗃️ Dataset Overview

You’ll be working with a **DuckDB** database: `transactions.duckdb`, which contains the following tables:

| Table Name        | Description                                                |
|-------------------|------------------------------------------------------------|
| `transactions`     | Raw transactional data for various companies.              |
| `company_report`   | Reported metrics by companies (e.g., revenue, growth).     |
| `fund_info`        | Links between companies and the funds that own them.       |
| `new_transactions` | Additional data including updates (e.g., company rename).  |

---

## 🛠️ Tasks

### 1. **Environment Setup**
- Create a DBT project.
- Configure a connection to `transactions.duckdb`.

---

### 2. **Data Validation & Insight Generation**

Answer the following questions using DBT models and SQL:

#### 🔍 Company-Level Analysis
- Are companies misreporting data (e.g., discrepancies between `transactions` and `company_report`)?
- Which company is performing the **best** and the **worst**?
- Which company shows **the most growth** over time?

> 📌 Tip: Define and justify your performance and growth metrics.

---

### 3. **Data Update Task**
Update your models to reflect the following data correction:
- The company **"TitanTech"** has been renamed to **"The Titan Tech"**.
- This update is present in the `new_transactions` table.
- Create a new company report with updated new_transactions 
---

### 4. **Fund-Level Analysis**

Each company is linked to a fund via `fund_info`. Analyze the following:

- Which **fund** is performing the **best** overall?
- Which fund has the **highest ROI**, based on Invested value and cash in bank?
- What **additional metric(s)** would you propose to evaluate fund performance?

> 💡 Bonus: Explain why your proposed metric(s) could be useful to stakeholders.

---

## 📬 Submission

Please share your DBT project (GitHub link or zip) and include a brief summary of your findings.