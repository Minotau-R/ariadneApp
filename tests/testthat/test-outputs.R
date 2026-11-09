test_that("outputs", {
    
    output$download <- .render_output(rObjects, "path_df")
  
    expect_s3_class(output$download, "shiny.render.function")
    expect_named(output, c("download", "network"))
})
