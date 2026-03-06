import {
  EditorView,
  ViewPlugin,
  Decoration,
  MatchDecorator,
} from "@codemirror/view";
import { RangeSetBuilder } from "@codemirror/state";

const variableContainerDecoration = Decoration.mark({
  class: "cm-lotus-variable-container",
  attributes: { "data-variable": "true" },
});

const bracketDecoration = Decoration.mark({
  class: "cm-lotus-variable-bracket",
});

const variableNameDecoration = Decoration.mark({
  class: "cm-lotus-variable-name",
});

const optionalClauseDecoration = Decoration.mark({
  class: "cm-lotus-optional-clause",
});

const optionalBracketDecoration = Decoration.mark({
  class: "cm-lotus-optional-bracket",
});

export function extractVariables(content) {
  const variables = [];
  const seen = new Set();
  const regex = /\{\{\s*(\w+)\s*\}\}/g;
  let match;

  while ((match = regex.exec(content)) !== null) {
    const varName = match[1];
    if (!seen.has(varName)) {
      seen.add(varName);
      variables.push(varName);
    }
  }

  return variables;
}

function createVariableDecorations(view) {
  const decorations = [];
  const text = view.state.doc.toString();

  // Add optional clause decorations
  const optionalRegex = /\[\[(.*?)\]\]/gs;
  let optMatch;

  while ((optMatch = optionalRegex.exec(text)) !== null) {
    const start = optMatch.index;
    const end = start + optMatch[0].length;

    // Bracket decorations for [[ and ]]
    decorations.push(optionalBracketDecoration.range(start, start + 2));
    decorations.push(optionalBracketDecoration.range(end - 2, end));

    // Content decoration (between brackets)
    if (start + 2 < end - 2) {
      decorations.push(optionalClauseDecoration.range(start + 2, end - 2));
    }
  }

  // Add variable decorations
  const regex = /\{\{\s*(\w+)\s*\}\}/g;
  let match;

  while ((match = regex.exec(text)) !== null) {
    const start = match.index;
    const end = match.index + match[0].length;

    decorations.push(variableContainerDecoration.range(start, end));
  }

  // Sort by start position (required by RangeSetBuilder)
  decorations.sort((a, b) => a.from - b.from || a.to - b.to);

  const builder = new RangeSetBuilder();
  for (const deco of decorations) {
    builder.add(deco.from, deco.to, deco.value);
  }

  return builder.finish();
}

export function lotusVariablesPlugin(onVariableChange) {
  return ViewPlugin.define(
    (view) => {
      let lastVariables = extractVariables(view.state.doc.toString());

      return {
        decorations: createVariableDecorations(view),

        update(update) {
          if (update.docChanged || update.viewportChanged) {
            this.decorations = createVariableDecorations(update.view);
          }

          if (update.docChanged && onVariableChange) {
            const currentVariables = extractVariables(
              update.state.doc.toString(),
            );

            if (
              JSON.stringify(currentVariables) !== JSON.stringify(lastVariables)
            ) {
              lastVariables = currentVariables;
              onVariableChange(currentVariables);
            }
          }
        },
      };
    },
    {
      decorations: (v) => v.decorations,
    },
  );
}

export const lotusVariableStyles = EditorView.theme({
  ".cm-lotus-variable-container": {
    backgroundColor: "rgba(139, 92, 246, 0.15)",
    borderRadius: "3px",
    padding: "0 2px",
    border: "1px solid rgba(139, 92, 246, 0.3)",
    color: "#7c3aed",
  },
  ".cm-lotus-optional-bracket": {
    color: "#2563eb",
    fontWeight: "bold",
  },
  ".cm-lotus-optional-clause": {
    backgroundColor: "rgba(37, 99, 235, 0.06)",
  },
});
