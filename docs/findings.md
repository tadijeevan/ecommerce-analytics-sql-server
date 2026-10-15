\# Business Findings — Olist E-commerce Analytics



\## 1. Project Overview



This document summarizes selected findings from the Olist E-commerce Analytics SQL project.



The analysis uses Microsoft SQL Server to examine order behavior, customer satisfaction, delivery performance, and other e-commerce business metrics.



The findings below are based on query results validated during the project. Additional results should be recorded only after their corresponding queries have been executed and verified.



\## 2. Delivery Performance and Customer Satisfaction



\### Finding 1: Early deliveries are associated with higher review scores



The delivery-performance analysis produced the following results:



| Delivery Performance | Review Count | Average Review Score |

|---|---:|---:|

| Early | 88,653 | 4.29 |

| On Time | 1,291 | 4.03 |

| Late | 6,409 | 2.27 |



Late deliveries had an average review score of 2.27, compared with 4.29 for early deliveries.



This represents a difference of 2.02 points on the five-point review scale.



\### Finding 2: Late deliveries have a higher negative-review rate



| Delivery Performance | Negative Reviews | Negative-Review Percentage |

|---|---:|---:|

| Early | 8,186 | 9.23% |

| On Time | 160 | 12.39% |

| Late | 4,000 | 62.41% |



Negative reviews are defined as review scores of 1 or 2.



The negative-review rate for late deliveries was substantially higher than that for early deliveries.



\### Finding 3: One-star reviews are more common among late deliveries



| Delivery Performance | One-Star Reviews | Percentage Within Group |

|---|---:|---:|

| Early | 5,851 | 6.60% |

| On Time | 110 | 8.52% |

| Late | 3,444 | 53.74% |



More than half of the reviews associated with late deliveries received one star.



This suggests that delivery reliability is an important area to investigate when improving customer satisfaction.



\### Business Recommendation



Investigate the operational causes of late deliveries, particularly for sellers or geographic areas with consistently poor delivery performance.



Potential follow-up analyses include:

\- Delivery delays by seller.

\- Delivery delays by customer state.

\- Delivery performance among high-volume sellers.

\- Review scores before and after operational improvements.



These findings demonstrate an association between delivery performance and customer reviews. They do not establish that delivery delays alone cause lower review scores.



\## 3. Delivery Performance by State



The delivery-time analysis produced the following results for selected states:



| Customer State | Delivered Orders | Average Delivery Time |

|---|---:|---:|

| SP | 40,494 | 8.70 days |

| MG | 11,354 | 11.94 days |

| PR | 4,923 | 11.94 days |

| RR | 41 | 29.34 days |

| AP | 67 | 27.18 days |

| AM | 145 | 26.36 days |



Delivery time is calculated from order purchase to customer delivery.



São Paulo (SP) had the shortest average delivery time among the states listed.



Roraima (RR) had the longest average delivery time among the states listed, but the result is based on only 41 delivered orders. The smaller sample size should be considered before drawing operational conclusions.



\### Business Recommendation



Investigate states with longer delivery times to understand whether distance, logistics capacity, seller location, or other operational factors contribute to delays.



Consider both average delivery time and the number of eligible orders when prioritizing improvements.



\## 4. Overall Review Performance



The customer-review analysis produced the following results:



| Review Category | Review Count | Percentage |

|---|---:|---:|

| Positive (4–5) | 76,470 | 77.07% |

| Neutral (3) | 8,179 | 8.24% |

| Negative (1–2) | 14,575 | 14.69% |

| Total | 99,224 | 100.00% |



Most reviews were positive, but approximately 14.69% were negative.



\### Business Recommendation



Investigate negative reviews alongside product category, delivery performance, and seller performance to identify opportunities for improving customer experience.



\## 5. Product Category Review Performance



Selected category results from the review analysis:



| Product Category | Review Associations | Average Review Score |

|---|---:|---:|

| cds\_dvds\_musicais | 12 | 4.67 |

| cama\_mesa\_banho | 9,432 | 3.97 |

| seguros\_e\_servicos | 2 | 2.50 |



The results show variation in average review scores across product categories.



However, categories with very few review associations should not be ranked alongside high-volume categories without considering sample size.



For example, the average score for `seguros\_e\_servicos` is based on only two review associations. It is not sufficient evidence on its own to conclude that the category consistently performs poorly.



\## 6. Delivery Delays



The delivery-performance analysis identified:



\- Eligible delivered orders with valid actual and estimated delivery dates: 96,470.

\- Orders delivered after the estimated date: 6,534.

\- Late-delivery percentage: 6.77%.



The late-delivery percentage is calculated using the eligible delivered orders as the denominator.



This metric provides a high-level view of delivery reliability.



\## 7. Metric Definitions and Limitations



\### Delivery Time



Delivery time is calculated as the number of calendar-day boundaries between order purchase and customer delivery.



\### Delivery Variance



Delivery variance is calculated using the difference between actual and estimated delivery dates.



\- Early: actual delivery date precedes the estimated date.

\- On Time: actual and estimated delivery dates fall on the same calendar day.

\- Late: actual delivery date follows the estimated date.



\### Review Classification



\- Positive reviews: scores of 4 or 5.

\- Neutral reviews: score of 3.

\- Negative reviews: scores of 1 or 2.



\### Limitations



\- Results describe the available dataset and may not represent every aspect of the underlying business.

\- Small sample sizes can make category or state rankings unstable.

\- Relationships between delivery performance and customer satisfaction do not prove causation.

\- Item value, freight value, and payment value are different measures and should not be treated as interchangeable.

\- Aggregations across related tables require care to avoid duplicate counting.



\## 8. Future Analysis Opportunities



Potential extensions to this project include:



1\. Identifying the product categories contributing most to negative reviews.

2\. Comparing delivery delays across sellers and geographic areas.

3\. Measuring repeat-purchase behavior by customer cohort.

4\. Comparing item value across product categories.

5\. Monitoring monthly order trends and rolling three-month item value.

6\. Investigating relationships between payment methods and order outcomes.



These analyses should be documented with their corresponding SQL logic and validated results before adding numerical conclusions.

