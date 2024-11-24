import { BaseConfig } from "https://deno.land/x/ddc_vim@v4.0.4/types.ts";
import { fn } from "https://deno.land/x/ddc_vim@v4.0.4/deps.ts";
import { ConfigArguments } from "https://deno.land/x/ddc_vim@v4.0.4/base/config.ts";

export class Config extends BaseConfig {
  override async config(args: ConfigArguments): Promise<void> {
    args.contextBuilder.patchGlobal({
      ui: "pum",
      sources: [
        "lsp",
        "around",
        "vsnip",
        "file",
        "skkeleton",
        "emoji",
        "dictionary",
      ],
      sourceOptions: {
        "lsp": {
          dup: "keep",
          mark: "LSP",
          forceCompletionPattern: "\\.\\w*|:\\w*|->\\w*",
        },

        skkeleton: {
          mark: "SKK",
          matchers: [],
          sorters: [],
          isVolatile: true,
        },

        emoji: {
          mark: "emoji",
          matchers: ["emoji"],
          sorters: [],
        },

        _: {
          // -- matchers = { "matcher_head" },
          // -- sorters = { "sorter_rank" },

          matchers: ["matcher_fuzzy"],
          sorters: ["sorter_fuzzy"],
          converters: ["converter_fuzzy"],
          // -- keywordPattern: "[a-zA-Z_:]\\w*",
          keywordPattern: "\\k+",
        },
        around: { mark: "around" },
        path: {
          mark: "P",
        },
        file: {
          mark: "F",
          isVolatile: true,
          forceCompletionPattern: `\S/\S*`,
        },
        vsnip: {
          mark: "vsnip",
        },
      },
      sourceParams: {
        lsp: {
          // TODO: Vsnip
          // "snippetEngine":
          enableResolveItem: true,
          enableAdditionalTextEdit: true,
          sorters: ["sorter_lsp-kind"],
          kindLabels: { "Class": "c" },
        },
      },
      postFilters: ["sorter_head"],
    });
  }
}
