
#' @importFrom ariadne ariadne drawPath weavePath weaveComplex
#' @importFrom data.table fwrite
server <- function(input, output) {
    # Import ariadne graph
    graph <- ariadne() |>
        as_undirected(mode = "each")
    # Set node and edge ids
    vertex_attr(graph, "id") <- V(graph)$name
    edge_attr(graph, "id") <- seq_along(E(graph))
    # Retrieve node and edge data
    node_df <- as_data_frame(graph, what = "vertices")
    edge_df <- as_data_frame(graph, what = "edges")
    # Create default network
    output$network <- renderVisNetwork({
        # Define default network
        visIgraph(graph, randomSeed = 123) |>
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
    # Draw pathway when two or more nodes are selected
    observe({
        # Check observe requirements
        nodes <- unlist(input$net_data$nodes)
        req(length(nodes) > 1L)
        # Define pathway formula
        path_by <- c(nodes[1], nodes[length(nodes)]) |>
            paste(collapse = "~") |>
            as.formula()
        # Add intermediate nodes to include argument
        include <- if(length(nodes) > 2L) nodes[2:(length(nodes) - 1)] else NULL
        # Update observers based on selected pathway
        updateTextInput(inputId = "by", value = deparse(path_by))
        updateSelectInput(inputId = "include", selected = include)
        # Draw selected pathway
        path_df <- drawPath(
            graph,
            by = path_by,
            k = input$k,
            include = input$include,
            exclude = input$exclude,
            res.name = input$resource
        )
        # Get id of edges in the selected pathway
        edges <- get_edge_ids(graph, path_df)
        # Find selected edges and nodes
        edge_selected <- edge_df$id %in% edges
        node_selected <- node_df$id %in% union(path_df$from, path_df$to)
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
        # Download map table
        output$draw <- downloadHandler(
            filename = function(){
                # Make file name from formula
                path_name <- path_by |>
                    all.vars() |>
                    paste(collapse = "2")
                # Complete file name
                paste0(path_name, "-map-", Sys.Date(), ".tsv")
            },
            content = function(file) fwrite(path_df, file, sep = "\t")
        )
    })
    # If focus is turned on
    observeEvent(input$focus, {
        # Fit network
        visNetworkProxy("network") |>
            visFit(nodes = unlist(input$net_data$nodes))
    })
    # Weave and download linkmap
    output$weave <- downloadHandler(
        filename = function(){
            # Make file name from formula
            path_name <- input$by |>
                as.formula() |>
                all.vars() |>
                paste(collapse = "2")
            # Complete file name
            paste0(path_name, "-links-", Sys.Date(), ".tsv")
        },
        content = function(file){
            # Select function by weave type
            FUN <- switch(
                input$weave_type, simple = weavePath, complex = weaveComplex
            )
            # Weave pathway
            x2y <- FUN(
                graph,
                by = as.formula(input$by),
                k = input$k,
                include = input$include,
                exclude = input$exclude,
                res.name = input$resource,
                init = if( input$init_type == "text") input$init_text else fread(input$init_file$datapath),
                prune = input$weave_prune,
                use.names = input$names,
                threshold = input$threshold,
                batch.size = input$batch_size,
                factor = input$factor
            )
            # Write linkmap to file
            fwrite(x2y, file, sep = "\t")
        }
    )
}
