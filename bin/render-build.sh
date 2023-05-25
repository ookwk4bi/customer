#!/usr/bin/env bash
# exit on error
set -o errexit

STORAGE_DIR=/opt/render/project/.render

if [[ ! -d $STORAGE_DIR/chrome ]]; then
  echo "...Downloading Chrome"
  mkdir -p $STORAGE_DIR/chrome
  cd $STORAGE_DIR/chrome
  wget -P ./ https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  dpkg -x ./google-chrome-stable_current_amd64.deb $STORAGE_DIR/chrome
  rm ./google-chrome-stable_current_amd64.deb
  cd $HOME/project/src # Make sure we return to where we were
else
  echo "...Using Chrome from cache"
fi

# Add Chromes location to the PATH
export PATH="${PATH}:${STORAGE_DIR}/chrome/opt/google/chrome"

# Generate binstubs if not present
if [ ! -f bin/bundle ]; then
  bundle binstubs bundler --force
fi

# Execute rake tasks
cd $HOME/project/src # Change directory to the source code directory
bundle install --path vendor/bundle # Install dependencies
bundle exec rake assets:precompile
bundle exec rake assets:clean
bundle exec rake db:migrate