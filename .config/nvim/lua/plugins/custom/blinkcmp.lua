return {
  {
    'saghen/blink.cmp',
    -- optional: provides snippets for the snippet source
    dependencies = 'rafamadriz/friendly-snippets',

    version = '*',
    opts = {
      keymap = { preset = 'default' },

      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono',
      },
    },
  },
}
