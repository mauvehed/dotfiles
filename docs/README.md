# dotfiles & config management

mauveFILES for personal and work systems running macOS or Linux

## quick start

```sh
sh -c "$(curl -fsSL get.chezmoi.io)" -- init --apply mauvehed
```

## quick commands

To add new files to chezmoi control:

```sh
chezmoi add <file>
```

To edit a file under chezmoi control:

```sh
chezmoi edit <file>
```

To preview changes before applying:

```sh
chezmoi diff
```

To apply changes from `.local/share/chezmoi/` to ~/ use:

```sh
chezmoi apply
```

To both `git pull` and `chezmoi apply` use `update`

```sh
chezmoi update
```

To force a refresh the downloaded archives (from .`chezmoiexternal.toml`), use the --refresh-externals flag to chezmoi apply:

```sh
chezmoi --refresh-externals apply
```

Or `--refresh-externals` can be shortened to -R:

```sh
chezmoi -R apply
```

## resources

* [Install](https://www.chezmoi.io/install/)
* [Quick Start](https://www.chezmoi.io/quick-start/#using-chezmoi-across-multiple-machines)
* [Setup](https://www.chezmoi.io/user-guide/setup/)
