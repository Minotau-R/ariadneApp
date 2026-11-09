
#' @importFrom waiter use_waiter
#' @importFrom shinyjs useShinyjs
#' @importFrom htmltools br div
.landing_page <- function(pObjects){
    # Define landing page
    page_sidebar(
        # Enable extensions
        useShinyjs(),
        use_waiter(),
        
        fillable = FALSE,
        theme = bs_theme(bootswatch = "united"),
        sidebar = sidebar(navset_tab(
            
            nav_panel("Explore", br(),
                
                textInput("by", "Path:", placeholder = "from ~ to"),
                
                numericInput("k", "k:", value = 1, min = 1),
                
                selectInput("include", "Include:",
                    choices = V(pObjects$graph)$name,
                    selected = NULL, multiple = TRUE),
                
                selectInput("exclude", "Exclude:",
                    choices = V(pObjects$graph)$name,
                    selected = NULL, multiple = TRUE),
                
                selectInput("resource", "Resource:",
                    choices = unique(E(pObjects$graph)$source),
                    selected = NULL, multiple = TRUE),
                
                checkboxInput("focus", "Focus"),
                checkboxInput("prune", "Prune"),
                
                downloadButton(outputId = "draw", label = "Draw",
                    class = "btn-warning", icon = icon("pencil"),
                    style = "float: right;")),
            
            nav_panel("Weave", br(),
                
                tags$style(HTML("
                    .shiny-options-group .radio-inline {margin-right: 1rem;}
                ")),
                
                radioButtons("weave_type", "Type:",
                    choices = c("simple", "complex"), inline = TRUE),
                
                radioButtons("init_type", "Initial values as:",
                    choices = c("text", "file"), inline = TRUE),
            
                conditionalPanel(condition = "input.init_type == 'text'",
            
                    selectizeInput("init_text", "Initial values:",
                        choices = NULL, multiple = TRUE,
                        options = list(create = TRUE))),
            
                conditionalPanel(condition = "input.init_type == 'file'",
            
                    fileInput("init_file", "Initial values:",
                        accept = c("csv", "tsv"))),
                
                checkboxInput("names", "Add names", value = TRUE),
                
                accordion(open = FALSE, height = "80%",
                    
                    accordion_panel("Advanced",
                        
                        checkboxInput("weave_prune", "Prune", value = TRUE),        
                                    
                        numericInput("batch_size", "Batch size:",
                            value = NULL, min = 1),
                        
                        numericInput("factor", "Jobs per unit:", value = 3,
                            min = 1, step = 1))),
                
                div(style = "margin-top: +20px"),
                
                conditionalPanel(condition = "input.weave_type == 'complex'",
                
                    sliderInput("threshold", "Threshold:", min = 0, max = 1,
                        value = 0, step = 0.01, ticks = FALSE)),
                
                layout_columns(col_widths = c(6, 6),
                    actionButton(inputId = "weave", label = "Weave",
                        class = "btn-warning", icon = icon("pencil"),
                        style = "float: right;"),
                  
                    downloadButton(outputId = "download", label = "Export",
                        class = "btn-warning", style = "float: right;",
                        enabled = FALSE))))),
        
        visNetworkOutput("network", height = "100vh", width = "100vw")
    )
}
