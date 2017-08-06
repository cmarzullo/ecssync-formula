# ecssync-formula

This formula sets up [ecs-sync](https://github.com/EMCECS/ecs-sync) using saltstack. 

It will setup and 'secure' a mysql db. Everything is in pillar. You are expected to GPG encrypt your secrets.

# TODO

tests

## Develop

This formula uses the salt patterns I'm familiar with. It's built with test-kitchen and kitchen-salt


### For MacoS
Install and setup brew:
```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

```
brew install cask
brew cask install vagrant
```


### Running test-kitchen

You'll need the test-kitchen gem and associated gems. You can try the build thing below.
```
cd <formula dir>
bundle install
```
or
```
sudo gem install test-kitchen
sudo gem install kitchen-vagrant
sudo gem install kitchen-salt
```

Run a converge on the default configuration:
```
kitchen converge default
```
