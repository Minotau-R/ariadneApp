test_that("observers", {
  
  out <- .create_observers(input, output, rObjects, pObjects)
  
  expect_s3_class(out, "shiny.render.function")
})
