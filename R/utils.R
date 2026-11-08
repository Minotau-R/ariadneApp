
.executeAriadne <- function(rObjects, rname, fun, ...) {
    
    x <- tryCatch({withCallingHandlers({
        
        x <- do.call(fun, list(...))
        return(x)
        
        # nocov start
        }, message = function(m) {
        
            showNotification(conditionMessage(m), type = "message")
            invokeRestart("muffleMessage")
        
        }, warning = function(w) {
            
            showNotification(conditionMessage(w), type = "warning")
            invokeRestart("muffleWarning")

        })}, error = function(e) {
            
            .print_message(paste(e, collapse = " "), footer = NULL)
            return(rObjects[[rname]])
        })
        # nocov end
    return(x)
}

.print_message <- function(..., title = "Invalid input:") {
    # nocov start
    showModal(modalDialog(title = title, ..., easyClose = TRUE))
    # nocov end
}
