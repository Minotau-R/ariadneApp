
#' @importFrom ariadne drawPath weavePath weaveComplex
#' @importFrom stats reformulate
#' @importFrom shinyjs runjs enable
#' @importFrom waiter Waiter spin_fading_circles
.create_observers <- function(input, output, rObjects, pObjects) {
    # Set node and edge ids
    vertex_attr(pObjects$graph, "id") <- V(pObjects$graph)$name
    edge_attr(pObjects$graph, "id") <- seq_along(E(pObjects$graph))
    # Retrieve node and edge data
    node_df <- as_data_frame(pObjects$graph, what = "vertices")
    edge_df <- as_data_frame(pObjects$graph, what = "edges")
    # Create default network
    output$network <- renderVisNetwork({
        # Define default network
        visIgraph(pObjects$graph, randomSeed = 123) |>
            visNodes(color = "darkorange") |>
            visEdges(color = list(color = "lightgrey", highlight = "red")) |>
            visInteraction(
                dragNodes = FALSE,
                multiselect = TRUE,
                selectConnectedEdges = FALSE
            ) |>
            visEvents(
                select = "function(x) {
                    Shiny.onInputChange('net_data', x);
                ;}"
            )
    })
    # Select resources
    observe({
        # Based on whether resources are defined
        if( is.null(input$resource) ){
            # Select all nodes and edges
            node_df$hidden <- FALSE
            edge_df$hidden <- FALSE
        }else{
            # Find edges included in selected resources
            edge_selected <- edge_df$source %in% input$resource
            # Find nodes included in selected resources
            nodes <- unique(
                c(edge_df$from[edge_selected], edge_df$to[edge_selected])
            )
            # Hide edges and nodes absent in selected resources
            edge_df$hidden <- !edge_selected
            node_df$hidden <- !node_df$id %in% nodes
        }
        # Update network
        visNetworkProxy("network") |>
            visUpdateNodes(nodes = node_df) |>
            visUpdateEdges(edges = edge_df)
    })
    # Reset parameters when one or less nodes are selected
    observe({
        # Check observe requirements
        nodes <- unlist(input$net_data$nodes)
        req(length(nodes) < 2L)
        # Reset edge labels
        edge_df$label <- " "
        # If one node is selected
        if( !is.null(nodes) ){
            # Reset network
            visNetworkProxy("network") |>
                visUpdateEdges(edges = edge_df) |>
                visSetSelection(nodesId = nodes, highlightEdges = FALSE)
        }
        # Reset observers to default
        updateTextInput(inputId = "by", value = NA)
        updateNumericInput(inputId = "k", value = 1)
        updateSelectInput(inputId = "include", selected = NA)
        updateSelectInput(inputId = "exclude", selected = NA)
    })
    # Check if formula is input
    observeEvent(input$by, {
      runjs("
            $(document).on('blur', '#by', function() {
                Shiny.setInputValue('by_blur', Math.random());
            });
        ")
    })
    # Draw pathway when two or more nodes are selected
    observe({
        # Check observe requirements
        nodes <- unlist(input$net_data$nodes)
        req(length(nodes) > 1L)
        # Define pathway formula
        rObjects$by <- reformulate(nodes[length(nodes)], nodes[1])
        # Add intermediate nodes to include argument
        include <- if(length(nodes) > 2L) nodes[2:(length(nodes) - 1)] else NULL
        # Update observers based on selected pathway
        updateTextInput(inputId = "by", value = deparse(rObjects$by))
        updateSelectInput(inputId = "include", selected = include)
        # Draw selected pathway
        rObjects$path_df <- .executeAriadne(
            rObjects, "path_df", drawPath,
            graph = pObjects$graph,
            by = rObjects$by,
            k = input$k,
            include = input$include,
            exclude = input$exclude,
            res.name = input$resource
        )
        # Get id of edges in the selected pathway
        edges <- get_edge_ids(pObjects$graph, rObjects$path_df)
        # Find selected edges and nodes
        edge_selected <- edge_df$id %in% edges
        node_selected <- node_df$id %in% union(
            rObjects$path_df$from, rObjects$path_df$to
        )
        # Label selected edges with resource name
        edge_df$label <- ifelse(edge_selected, edge_df$source, " ")
        # If prune is on, hide unselected nodes and edges
        node_df$hidden <- if(input$prune) !node_selected else FALSE
        edge_df$hidden <- if(input$prune) !edge_selected else FALSE
        # Update network
        visNetworkProxy("network") |>
            visUpdateNodes(nodes = node_df) |>
            visUpdateEdges(edges = edge_df) |>
            visSetSelection(
                nodesId = nodes,
                edgesId = edges,
                highlightEdges = FALSE
            )
        # Download path table
        output$draw <- .render_output(rObjects, "path_df")
    })
    # If focus is turned on
    observeEvent(input$focus, {
        # Fit network
        visNetworkProxy("network") |>
            visFit(nodes = unlist(input$net_data$nodes))
    })
    # If weave button is pressed
    observeEvent(input$weave, {
        # Initialise spinner
        w <- Waiter$new(
            html = tagList(spin_fading_circles(), h4("Weaving pathway...")),
            color = "#00000077"
        )
        w$show()
        # Hide spinner upon completion
        on.exit(w$hide(), add = TRUE)
        # Select function by weave type
        FUN <- switch(
            input$weave_type, simple = weavePath, complex = weaveComplex
        )
        # Retrieve initial values
        init <- switch(
             input$init_type,
             text = input$init_text,
             file = fread(input$init_file$datapath)
        )
        # Weave pathway
        rObjects$x2y <- .executeAriadne(
            rObjects, "x2y", FUN,
            graph = pObjects$graph,
            by = rObjects$by,
            k = input$k,
            include = input$include,
            exclude = input$exclude,
            res.name = input$resource,
            init = init,
            prune = input$weave_prune,
            use.names = input$names,
            threshold = input$threshold,
            batch.size = input$batch_size,
            factor = input$factor
        )
        # Enable download button
        if( !is.null(rObjects$x2y) ) enable("download")
    })
    # Weave and download linkmap
    output$download <- .render_output(rObjects, "x2y")
}
