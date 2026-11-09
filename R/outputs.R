
#' @importFrom data.table fwrite
.render_output <- function(rObjects, rname) {
    # Select file name based on object name
    fname <- switch(rname, path_df = "path", x2y = "map")
    # Create download handler
    out <- downloadHandler(
        filename = function(){
            # Make file name from formula
            path_name <- rObjects$by |>
                all.vars() |>
                paste(collapse = "2")
            # Complete file name
            paste0(path_name, "-", fname, "-", Sys.Date(), ".tsv")
        },
        content = function(file){
            # Write linkmap to file
            fwrite(rObjects[[rname]], file, sep = "\t")
        }
    )
    return(out)
}
