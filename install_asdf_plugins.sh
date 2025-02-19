for plugin in $(cat ~/.tool-versions | sed s/' .*$'//); do
  asdf plugin list | grep $plugin >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    asdf plugin add $plugin
  fi
done
asdf install
