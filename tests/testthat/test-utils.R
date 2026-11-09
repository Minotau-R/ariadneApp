test_that("utils", {
    
    expect_no_error(
        path_df <- .executeAriadne(
            rObjects, "path_df", ariadne::drawPath,
            graph = pObjects$graph, by = chebi ~ gmm
        )
    )
    
    #expect_no_error(
    #    x2y <- .executeAriadne(
    #        rObjects, "x2y", ariadne::weavePath,
    #        graph = pObjects$graph, by = chebi ~ gmm
    #    )
    #)
    
})
