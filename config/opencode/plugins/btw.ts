import type { Plugin } from "@opencode-ai/plugin"

const RECENT_CONTEXT_LIMIT = 10

export const BtwPlugin: Plugin = async (ctx) => {
  return {
    "command.execute.before": async (input, output) => {
      if (input.command !== "btw") return

      try {
        const result = await ctx.client.session.messages({
          path: { id: input.sessionID },
          query: { limit: RECENT_CONTEXT_LIMIT },
        })

        if (result.error) {
          console.error("[btw] SDK error:", result.error)
          return
        }

        const messages = result.data
        if (!messages || !Array.isArray(messages) || messages.length === 0) return

        const contextLines: string[] = [
          "## Recent conversation context for reference",
          "The user is mid-task. Answer their side question concisely. Do NOT modify files.\n",
        ]

        for (const msg of messages) {
          const role = msg.info.role
          for (const part of msg.parts) {
            if (part.type === "text" && !part.synthetic) {
              const text = part.text.length > 500 ? part.text.slice(0, 500) + "..." : part.text
              contextLines.push(`[${role}]: ${text}\n`)
            }
          }
        }

        output.parts.unshift({
          type: "text",
          text: contextLines.join("\n"),
          synthetic: true,
        } as any)
      } catch (err) {
        console.error("[btw] Failed to inject context:", err)
      }
    },
  }
}
