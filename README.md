# thesis_pres

Presentation for master thesis in computer science and engineering at Università di Bologna

## Release

This project generates slides in ITALIAN for a slides my master thesis presentation

The latest release provides a compiled pdf and pptx of the latest commit version of the slides

Also the slides are available on [gh-pages](https://oldranda1414.github.io/thesis_pres/)

## Dependencies

Dependencies are tracked using Nix.

To enter the development environment run:

```sh
nix develop
```

Also marp should be installed seperately for slides compilation to work.

The easiest way to install marp is through npm:

```sh
npm install -g @marp-team/marp-cli@latest
```

## Usage

Commands are simplified using just.

To see all available commands run:

```sh
just
```

To open slides in watch mode:

```sh
just slides
```
