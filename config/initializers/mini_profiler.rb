if defined?(Rack::MiniProfiler)

  # Have Mini Profiler show up on the right
  Rack::MiniProfiler.config.position = 'right'

  # Have Mini Profiler start in hidden mode - display with short cut (defaulted to 'Alt+P')
  Rack::MiniProfiler.config.start_hidden = false

  Rack::MiniProfiler.config.toggle_shortcut = 'esc'
end