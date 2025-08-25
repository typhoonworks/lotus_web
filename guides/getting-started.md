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
- **Timeouts** - Long-running queries will timeout automatically

## Tips for Success

- **Start Simple** - Begin with basic SELECT queries
- **Use Descriptive Names** - Give your saved queries clear, meaningful names
- **Test First** - Run queries before saving them
- **Check Results** - Always verify your query results make sense

## What's Next?

- Explore your database schema using the Schema Explorer
- Create useful reports by saving commonly-used queries
- Share query results with your team (export features coming soon)