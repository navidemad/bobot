unless defined?(Spring)
  SimpleCov.start do
    add_filter '/.bundle/'
    add_filter "/spec/"
    add_filter '/config'

    track_files "{app,lib}/**/*.rb"
  end
end
