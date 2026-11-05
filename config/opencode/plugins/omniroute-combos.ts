/**
 * omniroute-combos: OmniRoute で追加した combo を opencode のモデル一覧へ
 * 自動で載せるプラグイン。
 *
 * OmniRoute は combo を `GET /v1/models` に `owned_by: "combo"` として出すが、
 * opencode の provider 設定 (`opencode.json`) はモデル一覧が静的で、
 * 書いていないモデルは選択できない。本プラグインは config 読み込み時に
 * combo 一覧を取り込み、`provider.omniroute.models` へ足す。
 *
 * 取得順:
 *   1. `~/.config/opencode/omniroute-combos.json`
 *      (`omniroute-combos` が生成 / `omniroute-combos.timer` が更新)
 *   2. 無い/壊れている場合は `GET /v1/models` を直接叩く
 *
 * combo 名 (`auto/coding:fast` 等) は opencode のモデル ID にそのまま使う。
 * `ProviderModelNotFoundError` を避けるため、明示的に `models` へ登録する。
 *
 * combo は実体が複数モデルの混合なので単価が一意に決まらない。料金を
 * 持たないままだとステータスバーのコストが常に $0 になるため、
 * `omniroute-combo-cost.json` (メンバーの料金を重み付き平均した推定値) を
 * 参照して `cost` を付ける。無い combo は従来どおり cost 無しで載せる。
 */
import type { Plugin } from "@opencode-ai/plugin";
import { readFileSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const PROVIDER_ID = "omniroute";
const BASE_URL = process.env.OMNIROUTE_BASE_URL ?? "http://127.0.0.1:20128/v1";

type ComboCost = {
  input: number;
  output: number;
  cacheRead?: number;
  cacheWrite?: number;
};

// 推定単価は dotfiles 側 (config/opencode/omniroute-combo-cost.json) が正本。
// home-manager はこれを ~/.config/opencode/plugins/ へ symlink するので、
// まずそこを読み、無ければプラグイン自身と同じディレクトリを試す
// (dotfiles から直接読み込んでいるときは後者が効く)。
function comboCosts(): { costs: Record<string, ComboCost>; source?: string } {
  if (process.env.OPENSERVE_COMBO_COST_FILE) {
    try {
      const parsed = JSON.parse(
        readFileSync(process.env.OPENSERVE_COMBO_COST_FILE, "utf8"),
      ) as { combos?: Record<string, ComboCost> };
      return {
        costs: parsed.combos ?? {},
        source: process.env.OPENSERVE_COMBO_COST_FILE,
      };
    } catch {
      return { costs: {} };
    }
  }
  const here = dirname(fileURLToPath(import.meta.url));
  for (
    const file of [
      join(
        homedir(),
        ".config",
        "opencode",
        "plugins",
        "omniroute-combo-cost.json",
      ),
      join(here, "omniroute-combo-cost.json"),
    ]
  ) {
    try {
      const parsed = JSON.parse(readFileSync(file, "utf8")) as {
        combos?: Record<string, ComboCost>;
      };
      return { costs: parsed.combos ?? {}, source: file };
    } catch {
      // 次の候補へ
    }
  }
  return { costs: {} };
}

type ComboEntry = {
  id: string;
  name?: string;
  contextWindow?: number | null;
  maxTokens?: number | null;
};

function comboFile(): string {
  const configHome = process.env.XDG_CONFIG_HOME ?? join(homedir(), ".config");
  return join(configHome, "opencode", "omniroute-combos.json");
}

function apiKey(): string | undefined {
  if (process.env.OMNIROUTE_API_KEY) return process.env.OMNIROUTE_API_KEY;
  try {
    const env = readFileSync(
      `/run/user/${process.getuid?.() ?? 1000}/omniroute.env`,
      "utf8",
    );
    return env.match(/^OMNIROUTE_API_KEY=(.*)$/m)?.[1]?.trim();
  } catch {
    return undefined;
  }
}

function fromSnapshot(): ComboEntry[] | undefined {
  try {
    const parsed = JSON.parse(readFileSync(comboFile(), "utf8")) as {
      combos?: ComboEntry[];
    };
    if (!Array.isArray(parsed.combos) || parsed.combos.length === 0) {
      return undefined;
    }
    return parsed.combos;
  } catch {
    return undefined;
  }
}

async function fromApi(): Promise<ComboEntry[] | undefined> {
  try {
    const key = apiKey();
    const res = await fetch(`${BASE_URL}/models`, {
      headers: key ? { Authorization: `Bearer ${key}` } : undefined,
      signal: AbortSignal.timeout(5000),
    });
    if (!res.ok) return undefined;
    const body = (await res.json()) as {
      data?: Array<{
        id: string;
        owned_by?: string;
        context_length?: number;
        max_output_tokens?: number;
      }>;
    };
    const combos = (body.data ?? [])
      .filter((m) => m.owned_by === "combo")
      .map((m) => ({
        id: m.id,
        name: m.id,
        contextWindow: m.context_length ?? null,
        maxTokens: m.max_output_tokens ?? null,
      }));
    return combos.length > 0 ? combos : undefined;
  } catch {
    return undefined;
  }
}

export const OmnirouteCombosPlugin: Plugin = async ({ client }) => {
  const log = async (message: string, extra?: Record<string, unknown>) => {
    try {
      await client.app.log({
        body: { service: "omniroute-combos", level: "info", message, extra },
      });
    } catch {
      // ログ取得に失敗しても本処理は続ける
    }
  };

  const cached = fromSnapshot();

  return {
    config: async (config) => {
      const provider = config.provider?.[PROVIDER_ID];
      if (!provider) return;

      const combos = cached ?? (await fromApi());
      if (!combos || combos.length === 0) {
        await log("no combos found; leaving omniroute models untouched");
        return;
      }

      const models: Record<string, unknown> = { ...(provider.models ?? {}) };
      const { costs, source: costSource } = comboCosts();
      const added: string[] = [];
      let withCost = 0;
      for (const combo of combos) {
        if (models[combo.id]) continue;
        const limit: Record<string, number> = {};
        if (combo.contextWindow) limit.context = combo.contextWindow;
        if (combo.maxTokens) limit.output = combo.maxTokens;
        const cost = costs[combo.id];
        if (cost) withCost += 1;
        models[combo.id] = {
          name: combo.name ?? combo.id,
          ...(Object.keys(limit).length > 0 ? { limit } : {}),
          ...(cost ? { cost } : {}),
        };
        added.push(combo.id);
      }
      provider.models = models;

      await log(
        `omniroute combos registered (${combos.length} combos, ${added.length} new, ${withCost} with cost)`,
        {
          added,
          costSource: costSource ?? null,
        },
      );
    },
  };
};
