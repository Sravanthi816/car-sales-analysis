Car Sales Analysis

Project Overview

This project analyzes used car auction sales data using PostgreSQL. The objective is to practice database design, SQL development, ETL workflows, data modeling, and business-oriented analysis commonly used by Data Analysts, Reporting Analysts, Financial Analysts, and Business Analysts.

The project uses a public used car auction dataset and demonstrates how raw CSV data can be transformed into a normalized relational database structure.

⸻

Technologies Used

* PostgreSQL
* SQL
* Git
* GitHub
* VS Code
* pgAdmin

⸻

Dataset

Source: Kaggle Used Car Auction Prices Dataset

The original dataset contains vehicle auction information including:

* Vehicle details
* Seller information
* Vehicle condition
* Auction pricing
* Sale information

For development and testing purposes, a lightweight sample dataset (car_prices_light.csv) containing 149 records was used.

⸻

Project Structure

Car_sales_analysis/
│
├── data/
│   ├── car_prices.csv
│   └── car_prices_light.csv
│
├── sql/
│   ├── 00_raw_car_prices.sql
│   ├── 01_vehicle_table.sql
│   ├── 02_auction_sales_table.sql
│   ├── 03_load_vehicles.sql
│   └── 04_load_auction_sales.sql
│
├── dashboards/
├── notebooks/
├── charts/
├── docs/
├── README.md
└── .gitignore

Database Design

Raw Staging Table

The raw CSV data is first loaded into:
raw_car_prices
This table acts as a staging layer for data ingestion.

Vehicles Table

Stores vehicle-specific information.

Fields include:

* vehicle_id
* vin
* year
* make
* model
* trim
* body
* transmission
* color
* interior
* odometer

⸻

Auction Sales Table

Stores auction transaction information.

Fields include:

* sale_id
* vehicle_id
* seller
* state
* condition
* mmr
* selling_price
* sale_date

A foreign key relationship is established between auction_sales.vehicle_id and vehicles.vehicle_id.

⸻

ETL Workflow

Step 1

Import CSV data into: raw_car_prices

Step 2

Load vehicle records into: vehicles

Step 3

Load sales records into: auction_sales

using a JOIN on VIN to retrieve the generated vehicle identifiers.

⸻

Work Completed

* Created PostgreSQL database
* Created staging table
* Imported CSV data
* Created normalized vehicle table
* Created auction sales table
* Implemented primary keys
* Implemented foreign key relationships
* Loaded data into both tables
* Connected project to GitHub
* Created feature branch workflow

## Database Schema

The project uses a normalized relational database design consisting of:

- raw_car_prices (staging table)
- vehicles
- auction_sales

Future versions will include an Entity Relationship Diagram (ERD).

## Business Questions

This project aims to answer questions such as:

1. Which vehicle makes generate the highest sales revenue?
2. Which vehicle models sell most frequently?
3. How does vehicle condition impact selling price?
4. How does odometer reading affect selling price?
5. Which states generate the highest auction sales volume?
6. What is the average selling price by vehicle make and model?


