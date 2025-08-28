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
  const builder = new RangeSetBuilder();
  const regex = /\{\{\s*(\w+)\s*\}\}/g;
  const text = view.state.doc.toString();
  let match;

  while ((match = regex.exec(text)) !== null) {
    const start = match.index;
    const end = match.index + match[0].length;

    builder.add(start, end, variableContainerDecoration);
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
});
