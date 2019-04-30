threads 4, 4
workers 2
preload_app!

before_fork do
  SinatraConciergeApp::DB.disconnect if defined?(SinatraConciergeApp::DB)
end