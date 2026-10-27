# ariadneApp <img src="https://raw.githubusercontent.com/Minotau-R/ariadne/devel/man/figures/ariadne_logo.png" align="right" width="120" />

[![issues](https://img.shields.io/github/issues/Minotau-R/ariadneApp)](https://github.com/Minotau-R/ariadneApp/issues)
[![pulls](https://img.shields.io/github/issues-pr/Minotau-R/ariadneApp)](https://github.com/Minotau-R/ariadneApp/pulls)
[![R-CMD-check](https://github.com/Minotau-R/ariadneApp/workflows/build/badge.svg)](https://github.com/Minotau-R/ariadneApp/actions)

ariadneApp is a Shiny app for interactively exploring the ariadne resource graph
that is stored in [ariadneDB](https://github.com/Minotau-R/ariadneDB). Thus, it
is an interactive alternative to the R package
[ariadne](https://github.com/Minotau-R/ariadne) and its Python extension
[ariadnePy](https://github.com/Minotau-R/ariadnePy). With this app, it is
possible to dynamically explore the ariadne resource graph, select pathways
and ultimately cross the graph to link features from different databases.

## Usage

ariadneApp is openly available as a web app at
[this address](https://ariadneapp-minotaur.2.rahtiapp.fi/) (this may change in
the future). Alternatively, it can be installed and deployed locally. For local
use, Internet connection is required.

## Installation instructions

The app can be installed as follows:

```
remotes::install_github("Minotau-R/ariadneApp")
```

## Example

In the local environment, you can import the app and launch it as follows:

```
# Import package
library(ariadneApp)

# Launch app
shinePath()
```

## Code of Conduct

## Acknowledgements

ariadneApp was made possible thanks to the following dependencies:

- ariadne
- visNetwork
- shiny
