\# Data Dictionary — Olist E-commerce Analytics



\## 1. Project Overview



This document describes the eight staging tables used in the Olist E-commerce Analytics SQL project.



The database is Microsoft SQL Server, and the tables are stored in the `staging` schema.



The data dictionary documents the available columns, their data types, and their business meanings.



\## 2. Database Tables



| Table | Description | Analytical Purpose |

|---|---|---|

| `staging.customers` | Customer records and geographic attributes | Customer distribution and repeat-purchase analysis |

| `staging.geolocation` | Geographic coordinates associated with ZIP-code prefixes | Geographic analysis |

| `staging.order\_items` | Individual products purchased within orders | Item value, freight, product, and seller analysis |

| `staging.order\_payments` | Payment records associated with orders | Payment methods, installments, and payment values |

| `staging.order\_reviews` | Customer reviews and review scores | Customer satisfaction and review analysis |

| `staging.orders` | Order status and lifecycle timestamps | Order trends, cancellations, and delivery analysis |

| `staging.products` | Product attributes and category information | Category and product performance |

| `staging.sellers` | Seller information and geographic attributes | Seller performance and geographic analysis |



\## 3. Table: staging.customers



\*\*Purpose:\*\* Stores customer identifiers and geographic information.



| Column | SQL Server Data Type | Nullable | Description |

|---|---|---|---|

| `customer\_id` | VARCHAR(32) | No | Customer identifier associated with an order |

| `customer\_unique\_id` | VARCHAR(32) | No | Identifier used to recognize the same customer across records |

| `customer\_zip\_code\_prefix` | VARCHAR(5) | Yes | Customer ZIP-code prefix |

| `customer\_city` | VARCHAR(100) | No | Customer city |

| `customer\_state` | CHAR(2) | No | Customer state abbreviation |



\*\*Analytical use cases:\*\*

\- Customer distribution by state and city

\- Customer-level purchase behavior

\- Repeat-purchase analysis using customer identifiers



\*\*Important consideration:\*\* `customer\_id` and `customer\_unique\_id` serve different purposes. Repeat-purchase analysis should use the appropriate customer identity definition.



\## 4. Table: staging.geolocation



\*\*Purpose:\*\* Stores geographic coordinates and location attributes associated with ZIP-code prefixes.



| Column | SQL Server Data Type | Nullable | Description |

|---|---|---|---|

| `geolocation\_zip\_code\_prefix` | VARCHAR(5) | No | ZIP-code prefix |

| `geolocation\_lat` | DECIMAL | No | Latitude |

| `geolocation\_lng` | DECIMAL | No | Longitude |

| `geolocation\_city` | VARCHAR(100) | No | Geographic city |

| `geolocation\_state` | CHAR(2) | No | Geographic state abbreviation |



\*\*Analytical use cases:\*\*

\- Geographic exploration

\- Location-based analysis

\- Mapping ZIP-code prefixes to coordinates



\*\*Important consideration:\*\* ZIP-code prefixes may have multiple geographic records. Validate the grain before joining this table to customer or seller data to avoid multiplying records.



\## 5. Table: staging.order\_items



\*\*Purpose:\*\* Stores individual items purchased within each order.



| Column | SQL Server Data Type | Nullable | Description |

|---|---|---|---|

| `order\_id` | VARCHAR(32) | No | Identifier of the associated order |

| `order\_item\_id` | INT | No | Item sequence identifier within an order |

| `product\_id` | VARCHAR(32) | No | Identifier of the purchased product |

| `seller\_id` | VARCHAR(32) | No | Identifier of the seller fulfilling the item |

| `shipping\_limit\_date` | DATETIME2 | No | Shipping limit timestamp |

| `price` | DECIMAL | No | Price of the individual item |

| `freight\_value` | DECIMAL | No | Freight value associated with the item |



\*\*Analytical use cases:\*\*

\- Item value by month

\- Product and category performance

\- Seller order volume

\- Freight versus item value

\- Order value distribution



\*\*Important consideration:\*\* An order can contain multiple items. Summing `price` at the item level calculates item value, not necessarily total customer payment or accounting revenue.



\## 6. Table: staging.order\_payments



\*\*Purpose:\*\* Stores payment records associated with orders.



| Column | SQL Server Data Type | Nullable | Description |

|---|---|---|---|

| `order\_id` | VARCHAR(32) | No | Identifier of the associated order |

| `payment\_sequential` | INT | No | Sequence number of the payment within the order |

| `payment\_type` | VARCHAR(30) | No | Payment method |

| `payment\_installments` | INT | No | Number of payment installments |

| `payment\_value` | DECIMAL | No | Recorded payment value |



\*\*Analytical use cases:\*\*

\- Payment method distribution

\- Payment installment distribution

\- Payment value analysis



\*\*Important consideration:\*\* An order may have multiple payment records. Aggregate payments at the appropriate grain before joining them to item-level data.



\## 7. Table: staging.order\_reviews



\*\*Purpose:\*\* Stores customer review records associated with orders.



| Column | SQL Server Data Type | Nullable | Description |

|---|---|---|---|

| `review\_id` | VARCHAR(32) | No | Review identifier |

| `order\_id` | VARCHAR(32) | No | Identifier of the associated order |

| `review\_score` | INT | No | Customer review score |

| `review\_comment\_title` | VARCHAR(1000) | Yes | Review comment title |

| `review\_comment\_message` | VARCHAR(4000) | Yes | Review comment text |

| `review\_creation\_date` | DATETIME2 | No | Review creation timestamp |

| `review\_answer\_timestamp` | DATETIME2 | Yes | Timestamp when the review was answered |



\*\*Analytical use cases:\*\*

\- Review score distribution

\- Customer satisfaction analysis

\- Review scores by product category

\- Delivery performance versus review score



\*\*Important consideration:\*\* Review identifiers and order associations must be validated separately. Do not assume that `review\_id` is unique without checking the source data.



\## 8. Table: staging.orders



\*\*Purpose:\*\* Stores order identifiers, order status, and lifecycle timestamps.



| Column | SQL Server Data Type | Nullable | Description |

|---|---|---|---|

| `order\_id` | VARCHAR(32) | No | Unique identifier of an order |

| `customer\_id` | VARCHAR(32) | No | Identifier of the customer associated with the order |

| `order\_status` | VARCHAR(20) | No | Current or recorded order status |

| `order\_purchase\_timestamp` | DATETIME2 | No | Timestamp when the order was purchased |

| `order\_approved\_at` | DATETIME2 | Yes | Timestamp when the order was approved |

| `order\_delivered\_carrier\_date` | DATETIME2 | Yes | Timestamp when the order was handed to the carrier |

| `order\_delivered\_customer\_date` | DATETIME2 | Yes | Timestamp when the order was delivered to the customer |

| `order\_estimated\_delivery\_date` | DATETIME2 | Yes | Estimated delivery timestamp |



\*\*Analytical use cases:\*\*

\- Monthly order trends

\- Order status distribution

\- Cancellation analysis

\- Order lifecycle analysis

\- Delivery delay analysis

\- Delivery time by state

\- Delivery performance versus customer satisfaction



\*\*Important consideration:\*\* Missing delivery timestamps may be expected for orders that were canceled, unavailable, or not yet delivered. Interpret missing values in the context of order status.



\## 9. Table: staging.products



\*\*Purpose:\*\* Stores product attributes and category information.



| Column | SQL Server Data Type | Nullable | Description |

|---|---|---|---|

| `product\_id` | VARCHAR(32) | No | Product identifier |

| `product\_category\_name` | VARCHAR(100) | Yes | Product category name |

| `product\_name\_lenght` | INT | Yes | Recorded product name length |

| `product\_description\_lenght` | INT | Yes | Recorded product description length |

| `product\_photos\_qty` | INT | Yes | Number of product photos |

| `product\_weight\_g` | INT | Yes | Product weight in grams |

| `product\_length\_cm` | INT | Yes | Product length in centimeters |

| `product\_height\_cm` | INT | Yes | Product height in centimeters |

| `product\_width\_cm` | INT | Yes | Product width in centimeters |



\*\*Analytical use cases:\*\*

\- Product category performance

\- Item value by category

\- Category review scores

\- Product attribute quality checks



\*\*Important consideration:\*\* The source column names `product\_name\_lenght` and `product\_description\_lenght` retain the spelling used in the dataset.



\## 10. Table: staging.sellers



\*\*Purpose:\*\* Stores seller identifiers and geographic attributes.



| Column | SQL Server Data Type | Nullable | Description |

|---|---|---|---|

| `seller\_id` | VARCHAR(32) | No | Seller identifier |

| `seller\_zip\_code\_prefix` | VARCHAR(10) | No | Seller ZIP-code prefix |

| `seller\_city` | VARCHAR(100) | No | Seller city |

| `seller\_state` | CHAR(2) | No | Seller state abbreviation |



\*\*Analytical use cases:\*\*

\- Seller order volume

\- Seller geographic distribution

\- Seller delivery performance

\- Identification of high-volume sellers with poor delivery performance



\## 11. Main Relationships



The following relationships are used in the project's analytical queries.



| Primary Table | Related Table | Join Column | Purpose |

|---|---|---|---|

| `staging.orders` | `staging.customers` | `customer\_id` | Customer and order analysis |

| `staging.orders` | `staging.order\_items` | `order\_id` | Order item analysis |

| `staging.orders` | `staging.order\_payments` | `order\_id` | Payment analysis |

| `staging.orders` | `staging.order\_reviews` | `order\_id` | Review analysis |

| `staging.order\_items` | `staging.products` | `product\_id` | Product and category analysis |

| `staging.order\_items` | `staging.sellers` | `seller\_id` | Seller analysis |

| `staging.customers` | `staging.geolocation` | ZIP-code prefix | Geographic exploration |

| `staging.sellers` | `staging.geolocation` | ZIP-code prefix | Geographic exploration |



These are analytical join paths. Validate uniqueness and relationship cardinality before treating them as enforced database constraints.



\## 12. Data Modeling and Aggregation Considerations



\### Different table grains



The tables represent different levels of detail:



\- `orders`: order-level records

\- `customers`: customer-record-level data

\- `order\_items`: order-item-level records

\- `order\_payments`: payment-record-level records

\- `order\_reviews`: review-record-level records

\- `products`: product-level records

\- `sellers`: seller-level records

\- `geolocation`: geographic-record-level data



\### Avoiding double counting



Joining multiple one-to-many tables can multiply rows. For example, joining an order with multiple items and multiple payments can repeat both item and payment values.



To prevent inflated metrics:

1\. Identify the required grain of the analysis.

2\. Aggregate each one-to-many table to the appropriate grain when necessary.

3\. Join the aggregated results to the relevant entity.

4\. Validate totals against the source tables.



\### Financial terminology



Use precise metric names:

\- \*\*Item value:\*\* Sum of `order\_items.price`.

\- \*\*Freight value:\*\* Sum of `order\_items.freight\_value`.

\- \*\*Payment value:\*\* Sum of `order\_payments.payment\_value`.



Do not treat these metrics as interchangeable or describe item value as accounting revenue or profit without an explicit business definition.



\## 13. Scope and Limitations



\- The dictionary documents the eight staging tables and their columns as inspected in SQL Server.

\- Descriptions explain the intended analytical meaning of the fields; they are not a substitute for source-system documentation.

\- Data quality, uniqueness, and relationship cardinality should be verified using the project's data-quality scripts.

\- Geographic ZIP-code prefixes may not uniquely identify one coordinate or city.

\- The staging schema may retain source-system naming conventions and limitations.

