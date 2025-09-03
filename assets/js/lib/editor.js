import { EditorView, basicSetup } from "codemirror";
import { placeholder, keymap } from "@codemirror/view";
import { EditorState, Compartment, Prec } from "@codemirror/state";
import { sql, PostgreSQL, MySQL, SQLite } from "@codemirror/lang-sql";
import { editorStyles, getCompletionStyles } from "./styles";
import { lotusVariablesPlugin } from "./plugins/lotus_variables";
import { ContextAwareCompletion } from "./context_aware_completion";
import { load } from "./settings";

const editorTheme = EditorView.theme(editorStyles);
const languageCompartment = new Compartment();
const completionThemeCompartment = new Compartment();

function isDarkMode() {
  const theme = load("theme") || "system";
  
  if (theme === "dark") {
    return true;
  } else if (theme === "light") {
    return false;
  } else {
    // theme === "system" - check system preference
    const wantsDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
    return wantsDark;
  }
}

function dialectFromName(name = "postgres") {
  switch (name.toLowerCase()) {
    case "postgres":
    case "postgresql":
      return PostgreSQL;
    case "mysql":
      return MySQL;
    case "sqlite":
      return SQLite;
    default:
      return PostgreSQL;
  }
}

function sqlExt(schema, dialectName, contextCompletion) {
  const cfg = {
    upperCaseKeywords: true,
    dialect: dialectFromName(dialectName),
  };
  if (schema) cfg.schema = schema;

  const sqlLang = sql(cfg);

  if (contextCompletion) {
    return [
      sqlLang,
      sqlLang.language.data.of({
        autocomplete: contextCompletion.createCompletionSource(),
      }),
    ];
  }

  return sqlLang;
}

export function createEditor({
  textarea,
  parent,
  schema = null,
  dialectName = "postgres",
  onChange,
  onRun,
  onVars,
}) {
  let currentSchema = schema;
  let currentDialect = dialectName;

  const contextCompletion = new ContextAwareCompletion(currentSchema);

  const extensions = [
    basicSetup,
    languageCompartment.of(
      sqlExt(currentSchema, currentDialect, contextCompletion),
    ),
    completionThemeCompartment.of(
      EditorView.theme(getCompletionStyles(isDarkMode())),
    ),
    editorTheme,
    EditorView.lineWrapping,
    placeholder("SELECT * FROM table_name"),
  ];

  if (onRun) {
    extensions.push(
      Prec.highest(
        keymap.of([
          {
            key: "Mod-Enter",
            run: () => {
              onRun();
              return true;
            },
          },
          {
            key: "Ctrl-Enter",
            run: () => {
              onRun();
              return true;
            },
          },
        ]),
      ),
    );
  }

  if (onVars) {
    extensions.push(lotusVariablesPlugin(onVars));
  }

  const view = new EditorView({
    state: EditorState.create({ doc: textarea.value, extensions }),
    parent,
    dispatch: (tr) => {
      view.update([tr]);
      if (tr.docChanged && onChange) onChange(view.state.doc.toString());
    },
  });

  let themeObserver = null;

  const updateCompletionTheme = () => {
    view.dispatch({
      effects: completionThemeCompartment.reconfigure(
        EditorView.theme(getCompletionStyles(isDarkMode())),
      ),
    });
  };

  if (typeof MutationObserver !== "undefined") {
    themeObserver = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        if (
          mutation.type === "attributes" &&
          (mutation.attributeName === "class" ||
            mutation.attributeName === "data-theme")
        ) {
          updateCompletionTheme();
        }
      });
    });

    themeObserver.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ["class", "data-theme"],
    });
    themeObserver.observe(document.body, {
      attributes: true,
      attributeFilter: ["class", "data-theme"],
    });
  }

  const mediaQuery = window.matchMedia("(prefers-color-scheme: dark)");
  const mediaQueryListener = () => updateCompletionTheme();
  mediaQuery.addEventListener("change", mediaQueryListener);

  return {
    view,
    getContent() {
      return view.state.doc.toString();
    },
    setContent(content) {
      view.dispatch({
        changes: { from: 0, to: view.state.doc.length, insert: content ?? "" },
      });
    },
    updateSchema(newSchema) {
      currentSchema = newSchema;
      contextCompletion.updateSchema(currentSchema);
      view.dispatch({
        effects: languageCompartment.reconfigure(
          sqlExt(currentSchema, currentDialect, contextCompletion),
        ),
      });
    },
    updateDialect(newDialect) {
      currentDialect = newDialect || "postgres";
      view.dispatch({
        effects: languageCompartment.reconfigure(
          sqlExt(currentSchema, currentDialect, contextCompletion),
        ),
      });
    },
    updateTheme() {
      updateCompletionTheme();
    },
    destroy() {
      if (themeObserver) {
        themeObserver.disconnect();
      }
      mediaQuery.removeEventListener("change", mediaQueryListener);
      view.destroy();
    },
  };
}
