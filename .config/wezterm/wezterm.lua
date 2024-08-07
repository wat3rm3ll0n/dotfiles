local ui = require 'configs.ui'
local mux = require 'configs.mux'

local config = {}
local wezterm = require 'wezterm'

local process_icons = {
  ['docker'] = wezterm.nerdfonts.linux_docker,
  ['docker-compose'] = wezterm.nerdfonts.linux_docker,
  ['psql'] = wezterm.nerdfonts.dev_postgresql,
  ['ssh'] = wezterm.nerdfonts.fa_exchange,
  ['ssh-add'] = wezterm.nerdfonts.fa_exchange,
  ['kubectl'] = wezterm.nerdfonts.linux_docker,
  ['nvim'] = wezterm.nerdfonts.linux_neovim,
  ['make'] = wezterm.nerdfonts.seti_makefile,
  ['vim'] = wezterm.nerdfonts.dev_vim,
  ['node'] = wezterm.nerdfonts.dev_nodejs_small,
  ['go'] = wezterm.nerdfonts.seti_go,
  ['python3'] = wezterm.nerdfonts.dev_python,
  ['zsh'] = wezterm.nerdfonts.dev_terminal,
  ['bash'] = wezterm.nerdfonts.cod_terminal_bash,
  ['sudo'] = wezterm.nerdfonts.fa_hashtag,
  ['lazydocker'] = wezterm.nerdfonts.linux_docker,
  ['git'] = wezterm.nerdfonts.dev_git,
  ['lazygit'] = wezterm.nerdfonts.dev_git,
  ['lua'] = wezterm.nerdfonts.seti_lua,
  ['wget'] = wezterm.nerdfonts.mdi_arrow_down_box,
  ['curl'] = wezterm.nerdfonts.md_curling,
  ['gh'] = wezterm.nerdfonts.dev_github_badge,
}

local function get_current_working_dir(tab)
  local current_dir = tab.active_pane and tab.active_pane.current_working_dir or { file_path = '' }
  local HOME_DIR = os.getenv 'HOME'

  return current_dir.file_path == HOME_DIR and '~' or string.gsub(current_dir.file_path, '(.*[/\\])(.*)', '%2')
end

local function get_process(tab)
  if not tab.active_pane or tab.active_pane.foreground_process_name == '' then
    return nil
  end

  local process_name = string.gsub(tab.active_pane.foreground_process_name, '(.*[/\\])(.*)', '%2')
  if string.find(process_name, 'kubectl') then
    process_name = 'kubectl'
  end

  return process_icons[process_name] or string.format('[%s]', process_name)
end

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local has_unseen_output = false
  if not tab.is_active then
    for _, pane in ipairs(tab.panes) do
      if pane.has_unseen_output then
        has_unseen_output = true
        break
      end
    end
  end

  local cwd = wezterm.format {
    { Text = get_current_working_dir(tab) },
  }

  local process = get_process(tab)
  local title = process and string.format(' %s (%s) ', process, cwd) or ' [?] '

  if has_unseen_output then
    return {
      { Background = { Color = '#f38ba8' } },
      { Foreground = { Color = '#11111b' } },
      { Text = title },
    }
  end

  return {
    { Text = title },
  }
end)

ui.apply_to_config(config)
mux.apply_to_config(config)

return config
