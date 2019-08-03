# Transferwise-cli

An easy to use CLI for finding conversion rates and fees from Transferwise instead of going to the web page (ukhhh).

## Installation

Clone the repository

```bash
git clone https://github.com/syedalijabir/transferwise-cli.git
```

## Configuration

Create a "Limited permissions" token for your Transferwise account under `Settings -> API tokens` section.

Open a terminal and create a config file.
```bash
mkdir ~/.tw
touch ~/.tw/config
```
Put your API token in the config file
```bash
cat ~/.tw/config
API_TOKEN="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

```

## Usage
Help flag gives you pointers towards how to use the CLI
```bash
cd transferwise-cli/
./get_rate.sh -h
usage: get_rate.sh [options] [parameter]
Options:
  -a, --amount          Amount to convert e.g. 500
                        Default 1000
  -f, --from            Source currency e.g. EUR
                        Required.
  -t, --to              Target currency e.g. GBP
                        Required.
  -h, --help            Display help menu
```

Example
```bash
./get_rate.sh --from EUR --to AUD --amount 500
EUR     500
AUD     812.5
Rate	1.63326
Fee     2.53
```

Or just put an `alias` under your bash profile
```bash
alias twcli="<path-to>/get_rate.sh --from EUR --to AUD"
```

## Contributing
Pull requests are welcome.
