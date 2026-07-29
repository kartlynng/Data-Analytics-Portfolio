# 🎵 Spotify User Behavior & Churn Analytics Pipeline

![Python](https://img.shields.io/badge/Python-3.9+-3776AB?style=for-the-badge&logo=python&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-PostgreSQL%2FSQLite-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Power BI](https://img.shields.io/badge/Power_BI-Dashboard-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![Scikit-Learn](https://img.shields.io/badge/Scikit--Learn-ML-F7931E?style=for-the-badge&logo=scikit-learn&logoColor=white)

<p align="center">
  <img src="docs/images/spotify_logo.png" alt="Spotify" width="100%" />
</p>

---
## 📌 Executive Summary
An end-to-end data analytics and machine learning project analyzing **~50,000 Spotify user profiles** to discover engagement patterns, evaluate ad monetization conversion, predict account inactivity/churn, and deliver executive insights via an interactive dashboard.

---
## 📌 Executive Summary

Understanding user retention, listening habits, and subscription conversion dynamics is critical for digital audio streaming platforms. This project builds a production-grade analytics and predictive pipeline leveraging **Google Sheets**, **PostgreSQL**, **Python (Scikit-Learn)**, and **Power BI**.

### Key Business & Technical Goals
- **Churn Prediction**: Identify high-risk free and premium users before account cancellation using classification models.
- **Engagement Analysis**: Uncover streaming behaviors (listening hours, skip rates, playlist creation) driving subscription upgrades.
- **Monetization Levers**: Measure ad exposure thresholds that lead to subscription conversions versus app abandonment.
- **Executive BI**: Deliver an interactive executive dashboard with DAX-driven KPIs, dynamic cohort retention, and churn risk scoring.

---
## 💻 Tech Stack & Architecture

```text
                       DATA LIFECYCLE ARCHITECTURE
                      
  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
  │ Google Sheets│ ──> │  PostgreSQL  │ ──> │    Python    │ ──> │   Power BI   │
  │ (Raw Ingest) │     │ (EDA & Model)│     │  (ML & ETL)  │     │ (Executive)  │
  └──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘
```