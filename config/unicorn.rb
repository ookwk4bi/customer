worker_processes 2
RAILS_ROOT = File.expand_path('../../', __FILE__)
listen  "#{RAILS_ROOT}/tmp/sockets/unicorn.sock"
pid     "#{RAILS_ROOT}/tmp/pids/unicorn.pid"
# listen 7080
stderr_path "#{RAILS_ROOT}/log/unicorn.log"
stdout_path "#{RAILS_ROOT}/log/unicorn.log"
preload_app true