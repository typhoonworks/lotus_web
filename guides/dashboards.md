# Dashboards

Dashboards let you combine multiple queries into interactive, shareable views. They're perfect for creating reports, KPI displays, and data exploration interfaces.

## Overview

A dashboard consists of **cards** arranged in a flexible 12-column grid layout. Each card can display different types of content, making it easy to build comprehensive data views.

## Creating a Dashboard

1. **Click "New"** in the top navigation
2. **Select "Dashboard"** from the dropdown
3. **Enter Details**
   - **Name**: Give your dashboard a descriptive name
   - **Description**: Optionally add context about what the dashboard shows
4. **Click "Save"** to create your dashboard

## Adding Cards

Once you've created a dashboard, you can add cards to display your data:

1. **Click "Add Card"** - The large dashed button at the bottom of your dashboard
2. **Choose Card Type**:
   - **Query** - Display results from a saved query
   - **Text** - Add explanatory text using Markdown
   - **Heading** - Create section headers
   - **Link** - Add clickable links to external resources
3. **Configure the Card**:
   - For **Query cards**: Select which saved query to display
   - For **Text/Heading/Link cards**: Enter your content
4. **Click "Add Card"**

## Card Layout System

Cards are arranged in a **12-column grid** where you can control each card's position and size.

### Layout Properties

When you select a card, you can configure its layout using the settings drawer:

- **X Position** (0-11) - Which column the card starts at
- **Y Position** (0+) - Which row the card starts at
- **Width** (1-12) - How many columns the card spans
- **Height** (min 2) - How many rows the card spans

### Auto-Flow Layout

The dashboard uses an intelligent auto-flow system:
- Cards automatically stack vertically based on their **X position** (column)
- When you change a card's height, other cards reflow to fill the space
- No manual dragging required - just set the position values

### Layout Examples

```
Full-width header:
X: 0, Y: 0, W: 12, H: 2

Two side-by-side cards:
Left:  X: 0, Y: 2, W: 6, H: 4
Right: X: 6, Y: 2, W: 6, H: 4

Three equal columns:
Left:   X: 0, Y: 6, W: 4, H: 3
Middle: X: 4, Y: 6, W: 4, H: 3
Right:  X: 8, Y: 6, W: 4, H: 3
```

## Card Types in Detail

### Query Cards

Query cards display results from saved queries.

**Features:**
- Show query results as tables or visualizations
- Inherit visualization settings from the saved query
- Can override visualization on a per-card basis
- Display loading states while queries run
- Show error messages if queries fail

**To use:**
1. Create and save a query first
2. Add a Query card to your dashboard
3. Select the saved query from the dropdown
4. Optionally configure visualization in the card settings

### Text Cards

Add formatted text content using Markdown.

**Use cases:**
- Explain what the dashboard shows
- Add context to your data
- Create documentation
- Include analysis notes

**Markdown support:**
- Bold, italic, code formatting
- Lists (bulleted and numbered)
- Links
- Basic formatting

### Heading Cards

Create section headers to organize your dashboard.

**Features:**
- Large, prominent text
- Helps structure multi-section dashboards
- In public view, renders without card wrapper for cleaner look

**Best practices:**
- Use to separate different metric categories
- Keep headings short and clear
- Use at the start of each section

### Link Cards

Add clickable links to external resources.

**Use cases:**
- Link to related dashboards
- Reference external documentation
- Connect to other tools
- Provide additional context

**URL handling:**
- Automatically adds `https://` if missing
- Opens in new tab with security attributes
- Shows link icon for clarity

## Card Configuration

Select any card to open the settings drawer on the right:

### General Settings
- **Title** - Custom name for the card (overrides query name for Query cards)
- **Layout** - X, Y, Width, Height controls

### Query Card Settings
- **Visualization** - Configure chart type and fields
- **Title Override** - Custom display name

### Text/Heading/Link Settings
- **Content** - The actual text or URL to display

## Dashboard Settings

Click the gear icon in the top-right to access dashboard settings:

### Auto-Refresh

Set an interval for automatic card refreshing:
- **Disabled** (default)
- 1 minute
- 5 minutes
- 10 minutes
- 30 minutes
- 1 hour

When enabled, all cards refresh automatically at the specified interval.

### Public Sharing

Share your dashboard via a secure, public link:

1. **Enable Public Link** - Click the button (dashboard must be saved first)
2. **Copy URL** - Use the clipboard icon to copy the public URL
3. **Share** - Send the URL to anyone who needs access

**Public view features:**
- Read-only access - no editing allowed
- No login required
- Clean interface without edit controls
- All cards display their data
- Public links remain active until you disable sharing

**To disable:**
- Click "Disable Sharing" in the settings drawer
- The link immediately stops working

### Danger Zone

**Delete Dashboard** - Permanently removes the dashboard and all its cards.

⚠️ This action cannot be undone!

## Dashboard Workflow

### 1. Plan Your Dashboard
- Decide what metrics to show
- Create and save the necessary queries
- Sketch out the layout (which cards go where)

### 2. Build the Dashboard
- Create the dashboard
- Add a heading card for the title
- Add query cards for your metrics
- Add text cards for explanations
- Arrange cards using the layout settings

### 3. Configure Cards
- Set custom titles
- Configure visualizations
- Adjust layout positions
- Test with different screen sizes

### 4. Share
- Save your dashboard
- Enable public sharing if needed
- Copy the link and distribute

## Tips & Best Practices

### Layout
- Use full-width heading cards (W: 12) for section titles
- Keep related metrics together visually
- Leave some whitespace - don't fill every column
- Test on different screen sizes (dashboard is responsive)

### Query Cards
- Keep queries focused - one metric per card works best
- Use visualizations for trends, tables for detailed data
- Name queries clearly - the name shows in the card header
- Test queries independently before adding to dashboard

### Organization
- Group related cards in rows
- Use consistent card heights within a row
- Add text cards to explain complex metrics
- Use headings to create clear sections

### Performance
- Be mindful of query complexity on dashboards
- Use auto-refresh judiciously - shorter intervals mean more load
- Consider query timeouts for long-running queries
- Cache results at the Lotus level if supported

## What's Next?

- Learn more about [query variables](variables-and-widgets.md) to make your queries dynamic
- Explore [visualization options](visualizations.md) for better data presentation
- Read the [Getting Started guide](getting-started.md) for general LotusWeb usage
