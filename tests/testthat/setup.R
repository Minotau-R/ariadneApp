
# Import example path table
data("pathMeta", package = "ariadne")
# Initialise inputs
input <- new.env()
# Initialise outputs
output <- new.env()
# Initialise permanent objects
pObjects <- new.env()
# Import ariadne graph
pObjects$graph <- ariadne::ariadne() |>
    as_undirected(mode = "each")
# Initialise reactive objects
rObjects <- reactiveValues(by = "chebi ~ gmm", path_df = pathMeta, x2y = NULL)
