library(tidyverse)
setwd("/home/zellha/Documents/Dataset/Superstore_Dataset/")
data <- read_csv("superstore_raw.csv")

# Count customer per segment
segment_count <- data %>%
  group_by(Segment) %>%
  summarise(
    num_customers = n_distinct(`Customer ID`),
    total_sales = sum(Sales, na.rm = TRUE),
    avg_sales_per_customer = total_sales / num_customers
  ) %>%
  arrange(desc(total_sales))

segment_count

# Top products by total sales
top_products <- data %>%
  group_by(`Product Name`) %>%
  summarise(total_sales = sum(Sales, na.rm = TRUE)) %>%
  top_n(10, total_sales) %>%
  pull(`Product Name`)

# Filter data for top 10
product_segment_sales_top <- data %>%
  filter(`Product Name` %in% top_products) %>%
  group_by(`Product Name`, Segment) %>%
  summarise(total_sales = sum(Sales, na.rm = TRUE)) %>%
  ungroup() %>%
  # Truncate product names for readability
  mutate(Product_Short = substr(`Product Name`, 1, 20))

# Plot horizontal bar chart
ggplot(product_segment_sales_top, aes(x = reorder(Product_Short, -total_sales), 
                                      y = total_sales, fill = Segment)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  labs(title = "Top 10 Products by Segment",
       x = "Product Name",
       y = "Total Sales") +
  theme_minimal()

# Calculate frequency and monetary for each person
customer_summary <- data %>%
  group_by(`Customer ID`, `Customer Name`) %>%
  summarise(
    Frequency = n(),
    Monetary = sum(Sales, na.rm = TRUE)
  ) %>%
  ungroup()

# Define VIP: top 5% in monetary or frequency
vip_threshold_freq <- quantile(customer_summary$Frequency, 0.95)
vip_threshold_money <- quantile(customer_summary$Monetary, 0.95)

customer_summary <- customer_summary %>%
  mutate(
    Status = case_when(
      Frequency >= vip_threshold_freq | Monetary >= vip_threshold_money ~ "VIP",
      TRUE ~ "Other"
    )
  )

risk_threshold_freq <- quantile(customer_summary$Frequency, 0.25)

customer_summary <- customer_summary %>%
  mutate(
    Status = case_when(
      Status == "VIP" ~ "VIP",
      Frequency <= risk_threshold_freq ~ "Re-engage",
      TRUE ~ "Other"
    )
  )

# Plot for VIP/Re-engage
ggplot(customer_summary, aes(x = Monetary, y = Frequency, color = Status, size = Monetary)) +
  geom_jitter(alpha = 0.7)
  scale_color_manual(values = c("VIP" = "gold", "Re-engage" = "red", "Other" = "blue")) +
  labs(
    title = "Customer Segmentation by Monetary and Frequency",
    x = "Total Spend (Monetary)",
    y = "Number of Orders (Frequency)",
    color = "Customer Status",
    size = "Total Spend"
  ) +
  theme_minimal()