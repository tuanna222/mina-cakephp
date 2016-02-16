require 'mina-cakephp/cakephp/tmp'
require 'mina-cakephp/cakephp/git'
require 'mina-cakephp/cakephp/migrations'
require 'mina-cakephp/cakephp/asset_compress'

namespace :cakephp do  
  desc "Configure CakePHP Core include_path in webroot/index.php file."
  task :cake_core_path do
    regex = "((\\/\\/)?\\s*define\\('CAKE_CORE_INCLUDE_PATH',(.*)\\);)"

    queue %{
      echo "-----> Setting up CakePHP path." && (
        #{echo_cmd %{sed -ri "/#{regex}/ c define('CAKE_CORE_INCLUDE_PATH', '#{cake_path}/lib');"  webroot/index.php }} &&
        echo "------> Done."
      ) || (
        echo "! ERROR: Setup CakePHP path failed."
        echo "! Ensure that the path '#{deploy_to}' is accessible to the SSH user."
      )
    }
  end

  desc "Configure CakePHP debug to 0."
  task :debug_disable do
    regex = "((\\/\\/)?\\s*Configure::write\\('debug',(.*)\\);)"
    queue %{
      echo "-----> Setting up CakePHP debug to 0" && (
        #{echo_cmd %{sed -ri "/#{regex}/ c Configure::write('debug', 0);" Config/core.php }} &&
        echo "------> Done."
      ) || (
        echo "! ERROR: Setup CakePHP debug."
        echo "! Ensure that the path '#{deploy_to}' is accessible to the SSH user."
      )
    }
  end

  desc "Configure CakePHP database connection"
  task :config_database do
  queue %{
    echo "-----> Creating CakePHP database config file." && (
      #{echo_cmd %{mkdir -p #{deploy_to}/#{shared_path}/app/Config}} &&
      #{echo_cmd %{cp #{deploy_to}/current/app/Config/database.php #{deploy_to}/#{shared_path}/app/Config/database.php}} &&
      echo "-----> Done."
    ) || (
      echo "ERROR: Problem to create database config file."
    )
  }
  end
end
# Adaptive tasks to setup CakePHP Application.
task :setup do
  invoke :'cakephp:tmp:create'
  invoke :'cakephp:config_database'
end
