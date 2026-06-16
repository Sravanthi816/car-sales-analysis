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

## Database Schema

The project uses a normalized relational database design consisting of:

- raw_car_prices (staging table)
- vehicles
- auction_sales

Future versions will include an Entity Relationship Diagram (ERD).
SQL Analysis Performed

The following SQL analyses were completed:

Revenue Analysis

* Total Revenue
* Revenue by Make
* Revenue by State
* Revenue by Year

Vehicle Analysis

* Vehicle Count by Make
* Vehicle Count by Body Type
* Top Selling Vehicle Makes

Pricing Analysis

* Average Selling Price
* Average Selling Price by Transmission
* Average Selling Price by Make

Advanced SQL Concepts

* Aggregate Functions
* GROUP BY
* HAVING
* Common Table Expressions (CTEs)
* Window Functions
* Ranking Functions
* Joins
* Foreign Keys

⸻

## Tableau Dashboard

* An interactive Tableau dashboard was developed to visualize key business metrics and trends.
* The complete dataset contains over 550,000 vehicle auction records and was used for SQL analysis and Tableau dashboard development.

Dashboard KPIs

* Total Revenue
* Total Vehicle Count
* Average Selling Price
* Average Vehicle Condition

Dashboard Visualizations

* Revenue by Year
* Revenue by Make (Top 10)
* Vehicle Count by Make (Top 10)
* Revenue by State (Top 10)
* Vehicle Count by Body Type (Top 10)
* Average Selling Price by Transmission

Interactive Filters

Users can dynamically filter dashboard results by:

* Year
* Vehicle Make
* Body Type
* Transmission

All KPIs and charts automatically update based on filter selections.

⸻

## Dashboard Preview
Add your dashboard screenshot here: dashboards/dashboard_screenshot.png

Live Tableau Dashboard

View the published Tableau dashboard here:
https://public.tableau.com/app/profile/sravanthi.gandi/viz/Used_Car_Sales_Dashboard/Dashboard1?publish=yes


## Key Business Insights

Revenue Insights

* Ford generated the highest auction revenue.
* Chevrolet and Nissan were among the top revenue-generating brands.
* Florida and California generated the highest auction revenues.

Vehicle Insights

* Sedans and SUVs dominate auction inventory.
* Ford vehicles account for the largest share of auction transactions.

Pricing Insights

* Automatic transmission vehicles command higher average selling prices than manual transmission vehicles.
* Vehicle condition and mileage significantly influence selling price.

Market Trends

* Revenue increased significantly between 2010 and 2014 model years.
* Certain body types consistently outperform others in auction volume.

⸻

## Work Completed

Database & ETL

* Created PostgreSQL database
* Created staging table
* Imported CSV data
* Designed normalized schema
* Created vehicle table
* Created auction sales table
* Implemented primary keys
* Implemented foreign keys
* Loaded production data
* Built ETL workflow

SQL Development

* Created analytical SQL queries
* Built revenue analysis reports
* Built vehicle count reports
* Practiced advanced SQL concepts

Tableau Development

* Created KPI cards
* Built interactive visualizations
* Added dashboard filters
* Published Tableau dashboard
* Connected SQL insights with business reporting

Version Control

* Initialized Git repository
* Created GitHub repository
* Implemented Git workflow
* Maintained project documentation

⸻

Future Enhancements

* Create ERD diagram
* Add Python data analysis
* Add predictive price modeling
* Build Power BI version
* Automate ETL process using Python
* Deploy database in cloud environment

## Author

Sravanthi Gandi

SQL | PostgreSQL | Tableau | Data Analytics

GitHub: https://github.com/Sravanthi816/car-sales-analysis

LinkedIn: www.linkedin.com/in/sravanthi-gandi-97ba13246

