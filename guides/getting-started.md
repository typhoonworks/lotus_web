# Getting Started

This guide covers the basics of using LotusWeb to run SQL queries and manage your data.

## Prerequisites

- LotusWeb installed and mounted (see [Installation](installation.md))
- At least one database configured in Lotus

## Accessing the Dashboard

Visit the mounted path in your browser (e.g., `/lotus`). You should see:

- **Query Editor** - Write and run SQL queries
- **Queries List** - View saved queries
- **Schema Explorer** - Browse database tables

## Writing Your First Query

1. **Open the Query Editor** - Click "New Query" or navigate to the editor
2. **Select Database** - Choose from your configured repositories
3. **Write SQL** - Enter a simple query like:
   ```sql
   SELECT COUNT(*) as total_users FROM users;
   ```
4. **Run Query** - Click the play button or press Cmd+Enter
5. **View Results** - See the results displayed in a table

## Visualizing Query Results

LotusWeb includes built-in charting to visualize your query results.

### Switching Between Views
- **Table View** - Default tabular display (Cmd/Ctrl+1)
- **Chart View** - Interactive visualization (Cmd/Ctrl+2)

### Available Chart Types
- **Bar Chart** - Compare categorical data
- **Line Chart** - Show trends over time
- **Area Chart** - Visualize cumulative trends
- **Scatter Plot** - Explore relationships between variables
- **Pie Chart** - Display proportions of a whole

### Quick Configuration
1. **Open Settings** - Click the chart icon or press Cmd/Ctrl+G
2. **Select Chart Type** - Choose from the Chart Type tab
3. **Configure Axes** - Set X-Axis, Y-Axis, and optional Color/Series fields
4. **View Chart** - Press Cmd/Ctrl+2 to see your visualization

For detailed chart configuration, best practices, and troubleshooting, see the [Visualizations Guide](visualizations.md).

## Exploring Your Schema

1. **Open Schema Explorer** - Click the tables icon in the editor
2. **Browse Tables** - See all available tables and schemas
3. **View Column Details** - Click on tables to see column information
4. **Insert Names** - Click to insert table/column names into your query (coming soon)

## Saving Queries

1. **Write a Query** - Create a useful query in the editor
2. **Click Save** - Use the Save button in the editor
3. **Add Details** - Provide a name and optional description
4. **Save** - Your query is now saved and can be reused

## Managing Saved Queries

- **View All Queries** - Visit the Queries page to see all saved queries
- **Edit Queries** - Click on a query name to open and modify it
- **Delete Queries** - Use the Delete button when editing a query

## Working with Multiple Databases

If you have multiple repositories configured:

1. **Switch Databases** - Use the database dropdown in the editor
2. **Repository-Specific Queries** - Saved queries remember their database
3. **Cross-Database Analysis** - Save different queries for different data sources

## Security Features

LotusWeb inherits Lotus's security features:

- **Read-Only Queries** - Only SELECT statements are allowed
- **Table Visibility** - Some tables may be hidden based on configuration
- **Safe Parameters** - All queries use parameterized execution
- **Timeouts** - Long-running queries timeout automatically (default: 5 seconds)

### Configuring Query Timeouts

By default, queries timeout after 5 seconds. If you need to support long-running queries, enable the `:timeout_options` feature in your router:

```elixir
lotus_dashboard "/lotus",
  features: [:timeout_options]
```

This adds a timeout selector to the query editor toolbar where users can choose from preset durations (5s, 15s, 30s, 60s, 2m, 5m) or disable the timeout entirely on a per-query basis. Both the Lotus client timeout and the database statement timeout are set to the selected value.

## Using Variables in Queries

LotusWeb supports dynamic variables in your SQL queries using the `{{variable_name}}` syntax:

### Adding Variables
1. **Type Variables** - In your SQL query, use `{{variable_name}}` syntax:
   ```sql
   SELECT * FROM orders 
   WHERE status = {{status}} 
     AND created_at >= {{start_date}}
   ```
2. **Automatic Detection** - Variables appear automatically in the toolbar
3. **Configure Variables** - Click the "Variable settings" {x} icon in the toolbar to configure types and widgets

### Variable Types
- **Text** - Plain strings (automatically quoted for safety)
- **Number** - Integers and decimals  
- **Date** - Date picker with ISO format output

### Widget Types
- **Input** - Free text/number entry fields
- **Dropdown** - Select from predefined options (one option per line)
- **Date Picker** - Calendar interface for date variables

### Variable Settings
- **Access Settings** - Click the "Variable settings" {x} icon in the toolbar to open variable settings
- **Help Tab** - Contains detailed usage examples and syntax help
- **Settings Tab** - Configure labels, default values, and widget types

Variables are always sent as prepared parameters, preventing SQL injection attacks.

**Important**: When you save a query, all variable configurations (types, widgets, labels, defaults) are saved with it. However, the actual values users enter are NOT saved - widgets start empty each time unless you set default values in the settings.

## Tips for Success

- **Start Simple** - Begin with basic SELECT queries
- **Use Descriptive Names** - Give your saved queries clear, meaningful names
- **Test First** - Run queries before saving them
- **Check Results** - Always verify your query results make sense
- **Use Variables** - Make queries reusable with `{{variable}}` syntax

## What's Next?

- Explore your database schema using the Schema Explorer
- Create useful reports by saving commonly-used queries
- Visualize your data with the built-in charting - see [Visualizations Guide](visualizations.md)
- Combine queries into interactive dashboards - see [Dashboards Guide](dashboards.md)
- Use variables to make your queries dynamic and reusable
- Read the [Variables and Widgets Guide](variables-and-widgets.md) for advanced variable usage