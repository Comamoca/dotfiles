/** @jsxImportSource @opentui/solid */
import type { TuiPlugin, TuiPluginApi, TuiPluginModule, TuiSlotContext, TuiSlotPlugin } from "@opencode-ai/plugin/tui"
import type { JSX } from "@opentui/solid"
import { createSignal } from "solid-js"

const BRAILLE = ["⠀", "⠁", "⠃", "⠇", "⡇", "⡏", "⡟", "⡿", "⣿"] as const

type Options = {
  cells: number
  showCost: boolean
  showModel: boolean
  intervalMs: number
}

type Snapshot = {
  key: string
  model: string
  used: number
  limit: number
  percent: number
  cost: number
}

const num = (value: unknown): number =>
  typeof value === "number" && Number.isFinite(value) ? value : 0

function configure(options: Record<string, unknown> | undefined): Options {
  const cells = num(options?.cells)
  const intervalMs = num(options?.intervalMs)
  return {
    cells: cells > 0 && cells <= 40 ? Math.round(cells) : 10,
    showCost: options?.showCost !== false,
    showModel: options?.showModel !== false,
    intervalMs: intervalMs >= 200 ? Math.round(intervalMs) : 1000,
  }
}

function activeSessionID(api: TuiPluginApi): string | undefined {
  const route = api.route.current
  if (route?.name !== "session") return undefined
  const id = (route.params as Record<string, unknown> | undefined)?.sessionID
  return typeof id === "string" ? id : undefined
}

// Mirrors opencode's own Context section: the last assistant step with output,
// summed as input + output + reasoning + cache.read + cache.write.
function readUsage(api: TuiPluginApi): Snapshot | null {
  try {
    const id = activeSessionID(api)
    if (!id) return null

    const messages = api.state.session.messages(id) as ReadonlyArray<any>
    let last: any
    for (let i = messages.length - 1; i >= 0; i--) {
      const message = messages[i]
      if (message?.role === "assistant" && num(message?.tokens?.output) > 0) {
        last = message
        break
      }
    }
    if (!last) return null

    const session = typeof (api.state.session as any).get === "function" ? (api.state.session as any).get(id) : undefined
    let cost = typeof session?.cost === "number" ? session.cost : 0
    if (!cost) {
      for (const message of messages) {
        if (message?.role === "assistant") cost += num(message?.cost)
      }
    }

    const tokens = last.tokens
    const used = num(tokens?.input) + num(tokens?.output) + num(tokens?.reasoning) + num(tokens?.cache?.read) + num(tokens?.cache?.write)
    const provider = api.state.provider.find((item) => item.id === last.providerID)
    const model = provider?.models?.[last.modelID] as any
    const limit = num(model?.limit?.context)
    const percent = limit > 0 ? Math.round((used / limit) * 100) : 0
    const name = typeof model?.name === "string" && model.name ? model.name : String(last.modelID ?? "?")

    return {
      key: `${name}\u0000${used}\u0000${limit}\u0000${Math.round(cost * 10000)}`,
      model: name,
      used,
      limit,
      percent,
      cost,
    }
  } catch {
    return null
  }
}

function buildBar(percent: number, cells: number): string {
  const levels = BRAILLE.length - 1
  const clamped = Math.max(0, Math.min(100, percent))
  const value = Math.floor((clamped * cells * levels) / 100)
  const full = Math.floor(value / levels)
  const partial = value % levels
  let out = ""
  for (let i = 0; i < cells; i++) {
    if (i < full) out += BRAILLE[levels]
    else if (i === full) out += BRAILLE[partial]
    else out += BRAILLE[0]
  }
  return out
}

const compact = (value: number): string => `${Math.floor(value / 1000)}k`

function StatusBar(props: { ctx: TuiSlotContext; data: Snapshot; options: Options }): JSX.Element {
  const theme = props.ctx.theme.current
  const percent = props.data.percent
  const color = percent >= 70 ? theme.error : percent >= 50 ? theme.warning : theme.success
  const tokens =
    props.data.limit > 0 ? `${compact(props.data.used)}/${compact(props.data.limit)}` : `${percent}%`
  return (
    <box width="100%" flexDirection="row" gap={1} paddingLeft={1} paddingRight={1} flexShrink={0}>
      {props.options.showModel ? <text fg={theme.accent}>[{props.data.model}]</text> : null}
      <text fg={color}>{buildBar(percent, props.options.cells)}</text>
      <text fg={theme.text}>{tokens}</text>
      <box flexGrow={1} />
      {props.options.showCost ? <text fg={theme.textMuted}>{`$${props.data.cost.toFixed(4)}`}</text> : null}
    </box>
  )
}

const tui: TuiPlugin = async (api, options) => {
  if (options?.enabled === false) return

  const config = configure(options)
  const [data, setData] = createSignal<Snapshot | null>(null, {
    equals: (a, b) => (a?.key ?? "") === (b?.key ?? ""),
  })

  const refresh = () => setData(readUsage(api))
  refresh()

  const timer = setInterval(refresh, config.intervalMs)
  api.lifecycle.onDispose(() => clearInterval(timer))

  const plugin: TuiSlotPlugin = {
    order: 45,
    slots: {
      app_bottom(ctx: TuiSlotContext): JSX.Element {
        const current = data()
        return (current ? <StatusBar ctx={ctx} data={current} options={config} /> : null) as JSX.Element
      },
    },
  }

  api.slots.register(plugin)
}

const plugin: TuiPluginModule & { id: string } = {
  id: "comamoca.context-status",
  tui,
}

export default plugin
