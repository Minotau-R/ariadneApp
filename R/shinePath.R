#' shinePath: interactively explore and cross the ariadne resource graph
#' 
#' @name shinePath
#' 
#' @description
#' shinePath launches a Shiny app to interactively explore and cross the ariadne
#' resource graph, effectively providing a simple alternative to its
#' programmatic access with ariadne and ariadnePy.
#' 
#' @seealso
#' \itemize{
#'   \item ariadne: \url{https://github.com/Minotau-R/ariadne}
#'   \item ariadneDB: \url{https://github.com/Minotau-R/ariadneDB}
#'   \item Zenodo: \url{https://zenodo.org/records/18788725}
#' }
#' 
#' @examples
#' if( interactive() ){
#'     # Launch ariadne app
#'     shinePath()
#' }

#' @export
#' @rdname shinePath
#' @importFrom ariadne ariadne
shinePath <- function(){
    # Initialise permanent objects
    pObjects <- new.env()
    # Initialise reactive objects
    rObjects <- reactiveValues(by = NULL, path_df = NULL, x2y = NULL)
    # Import ariadne graph
    pObjects$graph <- ariadne() |>
        as_undirected(mode = "each")
    # Create user interface
    ui <- .landing_page(pObjects)
    # Create server side
    server <- function(input, output){
        .create_observers(input, output, rObjects, pObjects)
    }
    # Launch app
    shinyApp(ui = ui, server = server)
}
