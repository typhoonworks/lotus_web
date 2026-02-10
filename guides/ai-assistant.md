# AI Query Assistant

> ⚠️ **Experimental Feature**: The AI Query Assistant is experimental and disabled by default. The feature and API may change in future versions.

The AI Query Assistant helps you generate SQL queries from natural language descriptions. This guide covers how to use it effectively.

## Overview

The AI Assistant:
- **BYOK (Bring Your Own Key)** - You provide and manage your own API keys
- **Schema-aware** - Automatically understands your database structure
- **Respects visibility** - Only sees tables and columns you can access
- **Read-only** - Inherits Lotus's read-only safety guarantees
- **Multi-provider** - Supports OpenAI, Anthropic (Claude), and Google Gemini

## Enabling the Feature

AI features are disabled by default. To enable them, configure Lotus with your API key. See the [Lotus AI documentation](https://github.com/typhoonworks/lotus#ai-query-generation-experimental-byok) for detailed setup instructions.

Quick example:

```elixir
# config/runtime.exs
config :lotus, :ai,
  enabled: true,
  provider: "openai",
  api_key: System.get_env("OPENAI_API_KEY")
```

## Using the AI Assistant

### 1. Opening the Assistant

Click the **robot icon** (🤖) in the query editor toolbar. A drawer slides in from the left with a prompt input.

### 2. Writing Prompts

Be specific and descriptive:

**Good prompts:**
- "Show all users who signed up in the last 7 days"
- "Which customers have unpaid invoices with total amount owed"
- "Calculate monthly revenue grouped by product category"

**Too vague:**
- "Show users" ❌
- "Data" ❌

### 3. Reviewing Generated Queries

The AI inserts generated SQL directly into the editor. **Always review the query** before running:

1. Check that it queries the right tables
2. Verify JOINs are correct
3. Confirm filters match your intent
4. Check for appropriate LIMITs

### 4. Iterating

If the generated query isn't quite right:
- Click the robot icon again
- Refine your prompt with more details
- Try mentioning specific table or column names

## How It Works

### Schema Discovery

The AI uses four tools to understand your database:

1. **`list_schemas()`** - Discovers available schemas (e.g., `public`, `reporting`)
2. **`list_tables()`** - Gets schema-qualified table names
3. **`get_table_schema(table)`** - Retrieves column details, types, constraints
4. **`get_column_values(table, column)`** - Checks actual enum/status values

All tools respect your Lotus visibility rules.

### Example: Smart Status Handling

Instead of guessing status values:

```
Prompt: "Show invoices that aren't paid"
```

The AI will:
1. Find the `invoices` table
2. Get its schema and see a `status` column
3. Call `get_column_values("invoices", "status")`
4. Discover actual values: `["open", "paid", "overdue"]`
5. Generate: `WHERE status IN ('open', 'overdue')`

✅ Uses actual data instead of guessing!

## Tips for Better Results

### 1. Mention Table Names

Help the AI find the right tables:

```
"Show sales from the orders table in the last month"
```

### 2. Be Explicit About Time Ranges

```
"Users created in the last 30 days" ✅
"Recent users" ❌
```

### 3. Specify Aggregations

```
"Total revenue grouped by month" ✅
"Show revenue" ❌
```

### 4. Use Schema Explorer

Keep the schema explorer open (right side) while using the AI assistant (left side). Reference table and column names from it.

## Visibility and Security

### What the AI Can See

The AI assistant sees **exactly what you see** in the schema explorer:

- Tables you have access to
- Columns that aren't masked or omitted
- Schemas in your search path

Hidden tables (via Lotus visibility rules) are not visible to the AI.

### Example

If your visibility config hides sensitive tables:

```elixir
config :lotus,
  table_visibility: %{
    default: [
      deny: [
        {"public", "api_keys"},
        {"public", "user_sessions"}
      ]
    ]
  }
```

And you ask: "Show me all API keys"

The AI will respond: `UNABLE_TO_GENERATE: api_keys table not available`

## Limitations

### Current Limitations

- **No conversation history** - Each prompt is independent
- **No query refinement** - Can't ask follow-up questions to improve queries
- **English recommended** - Other languages may work but aren't tested
- **No query explanation** - Doesn't explain what generated SQL does

### When AI Can't Help

The AI will refuse to generate queries for:
- Non-database questions ("What's the weather?")
- Data not in visible tables
- Action requests ("Send emails to customers")

You'll see an error like: `UNABLE_TO_GENERATE: [reason]`

## Cost Management

Each AI query generation consumes tokens from your API provider. Costs vary by provider and model:

- **OpenAI GPT-4o**: Check [OpenAI Pricing](https://openai.com/pricing)
- **Anthropic Claude**: Check [Anthropic Pricing](https://www.anthropic.com/pricing)
- **Google Gemini**: Check [Google AI Pricing](https://ai.google.dev/pricing)

### Reducing Costs

1. Use cheaper models for simple queries (Gemini Flash, GPT-4o-mini)
2. Be specific in prompts to minimize tool calls
3. Save and reuse frequently-needed queries instead of regenerating

## Troubleshooting

### "AI features are not configured"

AI is disabled. Check your Lotus configuration includes:

```elixir
config :lotus, :ai,
  enabled: true,
  provider: "openai",
  api_key: "..."
```

### Robot Icon Not Visible

The robot icon only appears when:
1. AI is enabled in configuration
2. You have a valid API key
3. A data source is selected

### Slow Response Times

Query generation typically takes 2-10 seconds depending on:
- Database complexity (more tables = more tool calls)
- LLM provider and model
- Network latency

This is normal! The AI is introspecting your schema.

### Incorrect Queries

If generated queries are wrong:
- Try being more specific in your prompt
- Mention exact table/column names
- Reference relationships explicitly ("join orders with customers")
- Review and manually adjust the generated SQL

## Privacy

- **Your data stays private** - API calls go directly from your application to the LLM provider
- **No intermediaries** - Lotus doesn't proxy or log AI requests
- **BYOK model** - You control API keys and can revoke access anytime

## Getting Help

- [Lotus GitHub Issues](https://github.com/typhoonworks/lotus/issues)
- [Lotus Documentation](https://hexdocs.pm/lotus)
- [LotusWeb GitHub Issues](https://github.com/typhoonworks/lotus_web/issues)
