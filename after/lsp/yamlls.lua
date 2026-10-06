return {
  settings = {
    yaml = {
      format = {
        enable = true,
        singleQuote = false,
        bracketSpacing = false,
      },
      keyOrdering = false,
      customTags = {
        '!override sequence',
        '!override mapping',
        '!reset sequence',
        '!reset mapping',
        '!reset scalar',
      },
    },
  },
}
