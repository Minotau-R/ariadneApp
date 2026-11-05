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

#' @rdname shinePath
#' @export
shinePath <- function(){
    shinyApp(ui = ui(), server = server)
}
