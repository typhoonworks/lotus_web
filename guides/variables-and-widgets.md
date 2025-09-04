# Variables and Widgets Guide

LotusWeb's variables and widgets feature allows you to create dynamic, reusable SQL queries with user-friendly input controls. This guide covers everything you need to know about using variables effectively.

## Overview

Variables in LotusWeb use a simple `{{variable_name}}` syntax that gets automatically detected in your SQL queries. When detected, variables appear as input controls in the query toolbar, making your queries interactive and reusable.

## Basic Variable Syntax

### Adding Variables to Queries

Simply wrap any variable name in double curly braces:

```sql
SELECT * 
FROM orders 
WHERE status = {{order_status}}
  AND created_at >= {{start_date}}
  AND total_amount >= {{minimum_amount}}
```

### Variable Names

- Must contain only letters, numbers, and underscores
- Case-sensitive (`{{Status}}` and `{{status}}` are different variables)
- Automatically converted to friendly labels (e.g., `min_age` becomes "Min Age")

## Variable Types

### Text Variables
- **Purpose**: String values, text input
- **Usage**: `WHERE name = {{customer_name}}`
- **Output**: Automatically quoted for SQL safety
- **Example**: Input "John" becomes `'John'` in the query

### Number Variables  
- **Purpose**: Integers and decimal numbers
- **Usage**: `WHERE price >= {{min_price}}`
- **Output**: Raw number, no quotes
- **Example**: Input "99.99" becomes `99.99` in the query

### Date Variables
- **Purpose**: Date values with calendar picker
- **Usage**: `WHERE created_at >= {{start_date}}`
- **Output**: ISO date format (YYYY-MM-DD)
- **Widget**: Always uses date picker (no input/select option)

## Widget Types

### Input Widgets
- **Best for**: Free-form text and number entry
- **Available for**: Text and Number variables
- **User experience**: Simple text input field

### Dropdown Widgets
- **Best for**: Predefined lists of options  
- **Available for**: Text and Number variables
- **Configuration**: Custom list or SQL query options

#### Static Options Format

**Simple values** (one option per line):
```
active
pending
completed
cancelled
```

**Value and label pairs** (using `|` separator):
```
active | Active
pending | Pending  
completed | Completed
cancelled | Cancelled
```

#### SQL Query Options

**Dynamic dropdown options** populated from database queries:

**Single column query** (value = label):
```sql
SELECT status FROM orders GROUP BY status ORDER BY status
```

**Two column query** (first = value, second = label):
```sql
SELECT user_id, email FROM users WHERE active = true ORDER BY email
```

**Query requirements**:
- Must return 1 or 2 columns
- If 2+ columns, first is used as value, second as label
- Results are cached for performance
- Queries executed with current data source and search path
- Built-in "Test Query" button validates before saving

### Date Picker Widgets
- **Automatic**: All date variables use date picker
- **User experience**: Calendar interface
- **Output**: Always ISO date format

## Variable Settings Panel

### Accessing Settings
1. Add variables to your query using `{{variable_name}}` syntax
2. Variables automatically appear in the toolbar
3. Click the "Variable settings" {x} icon in the toolbar
4. Settings panel opens on the right side

The settings panel has two tabs:
- **Help Tab** - Shows when no variables are configured, contains syntax examples and usage information
- **Settings Tab** - Shows when variables exist, allows configuration of variable types, widgets, labels and defaults

### Variable Persistence
When you save a query, **all variable configurations are saved with it**:
- Variable types (Text, Number, Date)
- Widget types (Input, Dropdown)  
- Labels and static options
- Default values

**What is NOT saved**: The actual values users enter in the widgets. Each time the query loads, widgets start empty unless you set default values.

**Pro tip**: Set default values in the variable settings if you want the query to auto-run with meaningful values when loaded.

## Advanced Usage Examples

### Multi-Filter Dashboard Query
```sql
SELECT 
  DATE(created_at) as date,
  status,
  COUNT(*) as order_count,
  SUM(total_amount) as total_revenue
FROM orders 
WHERE status = {{order_status}}
  AND created_at BETWEEN {{start_date}} AND {{end_date}}
  AND total_amount >= {{min_amount}}
GROUP BY DATE(created_at), status
ORDER BY date DESC
```

**Variable Configuration**:
- `order_status`: Text, Dropdown with static options: "active|Active", "pending|Pending", "completed|Completed"
- `start_date`: Date (automatic date picker)
- `end_date`: Date (automatic date picker)  
- `min_amount`: Number, Input with default value "0"

### User Analysis Query
```sql
SELECT 
  u.email,
  u.created_at,
  COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.created_at >= {{registration_date}}
  AND ({{user_email}} IS NULL OR u.email LIKE '%' || {{user_email}} || '%')
HAVING COUNT(o.id) >= {{min_orders}}
ORDER BY order_count DESC
```

**Variable Configuration**:
- `registration_date`: Date, default value "2024-01-01"
- `user_email`: Text, Input with label "Search Email", default value ""
- `min_orders`: Number, Input with default value "1"

### Dynamic Category Analysis Query
```sql
SELECT 
  c.name as category_name,
  COUNT(p.id) as product_count,
  AVG(p.price) as avg_price
FROM categories c
LEFT JOIN products p ON c.id = p.category_id
WHERE c.id = {{category_id}}
  AND p.active = {{product_status}}
GROUP BY c.id, c.name
ORDER BY product_count DESC
```

**Variable Configuration**:
- `category_id`: Number, Dropdown with SQL query: `SELECT id, name FROM categories WHERE active = true ORDER BY name`
- `product_status`: Text, Dropdown with static options: "true|Active", "false|Inactive"

## Best Practices

### Naming Conventions
- Use descriptive names: `{{start_date}}` not `{{d1}}`
- Use underscores for multi-word variables: `{{min_amount}}` not `{{minamount}}`
- Be consistent across related queries

### Default Values
- Always provide sensible defaults for a better user experience
- Use common filter values (e.g., "last 30 days" for dates)
- Consider empty/null defaults for optional filters
- **Set defaults if you want queries to auto-run** - widgets start empty unless defaults are configured

### Widget Selection
- **Use Static Dropdowns** for:
  - Status fields with known values
  - Boolean-like choices (Active/Inactive)
  - Small, fixed lists that rarely change
- **Use SQL Query Dropdowns** for:
  - User lists, category selections
  - Dynamic lookups from database tables
  - Lists that change frequently
- **Use Input fields** for:
  - Free-form text search
  - Numeric thresholds
  - Custom values not in predefined lists

### Query Design
- Design queries to handle empty/null variables gracefully
- Use `{{variable}} IS NULL OR` patterns for optional filters
- Test queries with different variable combinations

## Security Features

### Parameterized Queries
- All variables are sent as prepared statement parameters
- **No string interpolation** - prevents SQL injection attacks
- Values are properly escaped based on variable type

### Type Safety
- Text variables are automatically quoted
- Number variables are validated as numeric
- Date variables use ISO format validation

### Safe Defaults
- Empty variables default to NULL in SQL
- No direct database string concatenation
- All queries go through Lotus's security layer

## Troubleshooting

### Variables Not Appearing
- **Check syntax**: Must be exactly `{{variable_name}}`  
- **Check name**: Only letters, numbers, underscores allowed
- **Refresh editor**: Sometimes requires re-typing the variable

### Dropdown Options Not Working
- **Static options format**: One option per line
- **Custom options**: Either `value` (doubles as value/label) or `value | label` syntax
- **Empty lines**: Remove empty lines between options
- **SQL queries**: Use "Test Query" button to validate before saving
- **Query columns**: Must return 1 or 2 columns (value, label)

### Date Variables Issues
- **Widget type**: Date variables always use date picker (no input/dropdown)
- **Format**: Outputs ISO date format (YYYY-MM-DD)
- **Timezone**: Uses browser's local timezone for date picker

## Configuration Modal

### Accessing Dropdown Options Configuration
1. Set a variable to use a Dropdown widget in Variable Settings
2. Click the "Configure options" button next to the dropdown widget selection
3. Choose between "Custom list" or "From SQL" in the configuration modal

### Modal Features
- **Custom list**: Text area for entering static options (one per line)
- **From SQL**: Text area for SQL queries with syntax highlighting
- **Test Query**: Validate SQL queries and preview first 3 results before saving
- **Live preview**: Shows how options will appear in the dropdown
- **Error handling**: Clear error messages for invalid queries or syntax


