import {
  BaseConfig,
  ContextBuilder,
  Dpp,
  Plugin,
} from "https://deno.land/x/dpp_vim@v0.0.5/types.ts";
import { Denops, fn } from "https://deno.land/x/dpp_vim@v0.0.5/deps.ts";

console.log("dpp.ts is loaded!");

export class Config extends BaseConfig {
  override async config(args: {
    denops: Denops;
    contextBuilder: ContextBuilder;
    basePath: string;
    dpp: Dpp;
  }): Promise<{
    plugins: Plugin[];
    stateLines: string[];
  }> {
    args.contextBuilder.setGlobal({
      protocols: ["git"],
    });

    type Toml = {
      hooks_file?: string;
      ftplugins?: Record<string, string>;
      plugins?: Plugin[];
    };

    type LazyMakeStateResult = {
      plugins: Plugin[];
      stateLines: string[];
    };

    const [context, options] = await args.contextBuilder.get(args.denops);
    const dotfilesDir = "~/.vim/";

    const tomls: Toml[] = [];

    const toml_files: { name: string; lazy: boolean }[] = [
      { name: "dpp.toml", lazy: false },
      { name: "dpp_lazy.toml", lazy: true },
      { name: "lsp.toml", lazy: true },
      { name: "ddu.toml", lazy: true },
      { name: "ddc.toml", lazy: true },
      { name: "ft.toml", lazy: true },
    ];

    const toml_promises = toml_files.map(async (toml) => {
      console.log(toml);
      tomls.push(
        await args.dpp.extAction(
          args.denops,
          context,
          options,
          "toml",
          "load",
          {
            path: await fn.expand(args.denops, dotfilesDir + toml.name),
            options: {
              lazy: toml.lazy,
            },
          },
        ) as Toml,
      );
    });

    await Promise.all(toml_promises);

    const recordPlugins: Record<string, Plugin> = {};
    const ftplugins: Record<string, string> = {};
    const hooksFiles: string[] = [];

    tomls.forEach((toml) => {
      for (const plugin of toml.plugins) {
        recordPlugins[plugin.name] = plugin;
      }

      if (toml.ftplugins) {
        for (const filetype of Object.keys(toml.ftplugins)) {
          if (ftplugins[filetype]) {
            ftplugins[filetype] += `\n${toml.ftplugins[filetype]}`;
          } else {
            ftplugins[filetype] = toml.ftplugins[filetype];
          }
        }
      }

      if (toml.hooks_file) {
        hooksFiles.push(toml.hooks_file);
      }
    });

    const lazyResult = await args.dpp.extAction(
      args.denops,
      context,
      options,
      "lazy",
      "makeState",
      {
        plugins: Object.values(recordPlugins),
      },
    ) as LazyMakeStateResult;

    // console.log(Object.values(recordPlugins));
    console.log({
      plugins: lazyResult.plugins,
      stateLines: lazyResult.stateLines,
    })

    return {
      plugins: lazyResult.plugins,
      stateLines: lazyResult.stateLines,
    };
  }
}
