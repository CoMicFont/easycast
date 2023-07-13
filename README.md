# Easycast - A simple projection system for RaspberryPI

## How to install on a fresh Raspberry PI

1. Clone the repository locally

```sh
git clone git@github.com:CoMicFont/easycast.git
```

You'll need git, install it first if needed.

2. Install the Deployment Required Initial State

```sh
cd easycast
sudo ./bin/dris
```

This may take some time, as it will run a distribution upgrade and install
various needed packages (some of them may take some time to install).

3. Install/Upgrade easycast itself

```sh
./bin/upgrade
./bin/compile
```

This will install ruby dependencies and compile the assets.

## How to get started as a developer

Please make sure you have a ruby environment (>= 2.7) and that the following
commands work fine:

```
bundle install --path vendor/bundle
bundle exec rake test
```
