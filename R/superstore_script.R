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
  
data <- data %>%
  mutate(`Order Date` = dmy(`Order Date`))
  
top_seller_trend <- data %>%
  filter(`Product Name` == "Canon imageCLASS 2200 Advanced Copier") %>%
  mutate(order_month = floor_date(`Order Date`, "month")) %>%
  group_by(order_month) %>%
  summarise(
    total_sales = sum(Sales, na.rm = TRUE),   # total revenue
    total_orders = n()                        # number of orders
  )


top_seller_trend %>% 
  ggplot(aes(x = order_month, y = total_sales)) +
  geom_line(color = "blue", size = 1) +
  geom_point(color = "red", size = 2) +
  labs(title = "Monthly Sales Trend - Canon imageCLASS 2200 Advanced Copier",
       x = "Month", y = "Total Sales") +
  theme_minimal()

# Aggregate monthly for Phones
phones_monthly <- data %>%
  filter(`Sub-Category` == "Phones") %>%
  mutate(order_month = floor_date(`Order Date`, "month")) %>%
  group_by(order_month) %>%
  summarise(
    total_sales = sum(Sales, na.rm = TRUE),
    orders_count = n(),
    .groups = "drop"
  )

# Plot Monthly Sales
ggplot(phones_monthly, aes(x = order_month, y = total_sales)) +
  geom_line(color = "blue", size = 1) +
  geom_point(color = "darkblue") +
  scale_x_date(date_breaks = "1 month", date_labels = "%b-%Y") +
  labs(
    title = "Phones Sub-Category: Monthly Sales",
    x = "Month", y = "Total Sales"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))

# Plot Monthly Order Count
ggplot(phones_monthly, aes(x = order_month, y = orders_count)) +
  geom_line(color = "green", size = 1) +
  geom_point(color = "darkgreen") +
  scale_x_date(date_breaks = "1 month", date_labels = "%b-%Y") +
  labs(
    title = "Phones Sub-Category: Monthly Order Count",
    x = "Month", y = "Orders Count"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))

data <- data %>%
  mutate(`Order Date` = dmy(`Order Date`)) %>%
  mutate(order_month = floor_date(`Order Date`, "month"))

# Example: Top 5 phones by total sales
top_phones <- data %>%
  filter(`Sub-Category` == "Phones") %>%
  group_by(`Product Name`) %>%
  summarise(total_sales = sum(Sales, na.rm = TRUE)) %>%
  arrange(desc(total_sales)) %>%
  slice_head(n = 5)

# Filter dataset for just those phones
phones_trend <- data %>%
  filter(`Sub-Category` == "Phones", `Product Name` %in% top_phones$`Product Name`) %>%
  group_by(order_month, `Product Name`) %>%
  summarise(monthly_sales = sum(Sales, na.rm = TRUE),
            monthly_orders = n(),
            .groups = "drop")

# Plot monthly sales trend of top phones
ggplot(phones_trend, aes(x = order_month, y = monthly_sales, color = `Product Name`)) +
  geom_line(size = 1) +
  labs(title = "Monthly Sales Trend of Top 5 Phones",
       x = "Month", y = "Sales") +
  theme_minimal()
