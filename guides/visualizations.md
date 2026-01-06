# Visualizations

LotusWeb includes built-in charting capabilities to visualize your query results. This guide covers all available chart types, configuration options, and best practices.

## Overview

After running a query, you can switch between table and chart views to visualize your data:

- **5 chart types** - Bar, Line, Area, Scatter, and Pie charts
- **Flexible configuration** - Configure axes and grouping fields
- **Dark mode support** - Charts automatically adapt to your theme
- **Keyboard shortcuts** - Quick access to visualization features

## Chart Types

### Bar Chart

Best for comparing categorical data with discrete values.

**When to use:**
- Comparing values across categories (e.g., sales by region)
- Displaying counts or totals for different groups
- Showing rankings or relative sizes

**Example query:**
```sql
SELECT department, COUNT(*) as employee_count
FROM employees
GROUP BY department;
```

### Line Chart

Best for showing trends and changes over time.

**When to use:**
- Tracking metrics over time (e.g., daily active users)
- Showing continuous data with a natural order
- Comparing multiple series over the same time period

**Example query:**
```sql
SELECT DATE(created_at) as date, COUNT(*) as signups
FROM users
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(created_at)
ORDER BY date;
```

### Area Chart

Best for showing cumulative totals or volume over time.

**When to use:**
- Emphasizing the magnitude of change over time
- Showing stacked comparisons across categories
- Visualizing cumulative growth

**Example query:**
```sql
SELECT DATE(order_date) as date, SUM(amount) as revenue
FROM orders
GROUP BY DATE(order_date)
ORDER BY date;
```

### Scatter Plot

Best for exploring relationships between two numeric variables.

**When to use:**
- Finding correlations between two metrics
- Identifying outliers in your data
- Analyzing distribution patterns

**Example query:**
```sql
SELECT price, quantity_sold
FROM products
WHERE quantity_sold > 0;
```

### Pie Chart

Best for showing proportions of a whole. Use sparingly.

**When to use:**
- Displaying market share or percentage breakdowns
- Showing simple part-to-whole relationships
- When you have 5 or fewer categories

**Example query:**
```sql
SELECT status, COUNT(*) as count
FROM orders
GROUP BY status;
```

**Note:** Pie charts become hard to read with many categories. Consider using a bar chart instead for more than 5-6 categories.

## Configuring Charts

### Opening the Settings Drawer

Access visualization settings in two ways:
- Click the **chart icon** in the results toolbar
- Press **Cmd/Ctrl+G** keyboard shortcut

### Chart Type Tab

The first tab displays all 5 chart types as icon buttons. Click any icon to select that chart type.

### Configure Tab

The second tab contains the field configuration:

| Setting | Description | Required |
|---------|-------------|----------|
| **X-Axis Field** | The field for the horizontal axis | Yes |
| **Y-Axis Field** | The field for the vertical axis (should be numeric) | Yes |
| **Color/Series Field** | Optional field to group data by color | No |

### Axis Options

Fine-tune your chart display:

- **Show Labels** - Toggle axis labels on/off
- **X-Axis Title** - Custom label for the horizontal axis
- **Y-Axis Title** - Custom label for the vertical axis

### Configuration Status

A status indicator shows whether your chart is ready:
- **Green checkmark** - Configuration is valid
- **Amber warning** - Missing required fields

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| Cmd/Ctrl+G | Toggle visualization settings drawer |
| Cmd/Ctrl+1 | Switch to table view |
| Cmd/Ctrl+2 | Switch to chart view |

## Best Practices

### Choosing the Right Chart

| Data Type | Recommended Chart |
|-----------|-------------------|
| Categories with values | Bar chart |
| Time series data | Line or Area chart |
| Two numeric variables | Scatter plot |
| Simple proportions (≤5 items) | Pie chart |

### Preparing Your Data

For the best visualization results:

1. **Ensure numeric Y-axis data** - The Y-axis field should contain numbers for most chart types
2. **Use dates for time series** - When charting over time, use DATE or TIMESTAMP columns for the X-axis
3. **Limit categories** - For bar and pie charts, aim for fewer than 10 categories for readability
4. **Include grouping columns** - To create multi-series charts, include a category column for the Color/Series field
5. **Order your data** - For line and area charts, ORDER BY your date/time column

### Common Query Patterns

**Grouped bar chart (multiple series):**
```sql
SELECT
  DATE_TRUNC('month', created_at) as month,
  status,
  COUNT(*) as count
FROM orders
GROUP BY DATE_TRUNC('month', created_at), status
ORDER BY month;
```
Set X-Axis to `month`, Y-Axis to `count`, and Color/Series to `status`.

**Time series with aggregation:**
```sql
SELECT
  DATE(event_time) as date,
  SUM(value) as total
FROM metrics
WHERE event_time >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY DATE(event_time)
ORDER BY date;
```
Set X-Axis to `date` and Y-Axis to `total`.

## Troubleshooting

### Chart Not Rendering

- **Check field selection** - Ensure both X-Axis and Y-Axis fields are selected
- **Verify data types** - The Y-Axis field must contain numeric values
- **Check for empty results** - Run the query first and confirm data is returned

### Colors Not Showing

- **Add Color/Series field** - Select a grouping field to enable multi-series coloring
- **Verify distinct values** - The grouping field should have distinct values to differentiate series

### Chart Looks Wrong

- **Wrong chart type** - Consider if another chart type better suits your data
- **Too many categories** - Reduce categories or switch from pie to bar chart
- **Missing ORDER BY** - For time series, ensure data is ordered by the time column

### Performance Issues

- **Limit result size** - Large datasets may slow chart rendering; use LIMIT or aggregate data
- **Aggregate in SQL** - Perform grouping and aggregation in your query rather than charting raw data
