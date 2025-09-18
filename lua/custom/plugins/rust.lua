return {
	{
		-- Configuração simples para Rust que desabilita cargo check
		"neovim/nvim-lspconfig",
		opts = {
			rust_analyzer = {
				settings = {
					["rust-analyzer"] = {
						checkOnSave = {
							enable = false, -- Desabilita cargo check automático
						},
					},
				},
			},
		},
	},
}