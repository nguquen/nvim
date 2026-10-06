return {
  settings = {
    jsonc = {
      validate = {
        enable = true,
        -- try these (support varies by server version)
        trailingCommas = 'ignore', -- "error" | "warning" | "ignore"
      },
    },
  },
}
