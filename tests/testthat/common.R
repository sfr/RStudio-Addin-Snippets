# RStudio version that supports Addins
REQUIRED.RSTUDIO.VERSION <- '0.99.1111'

my.setCursorPosition <- function(context, tuples=list())
{
    if (is.atomic(tuples)) {
        tuples <- list(tuples)
    }

    pos <- 1
    for (tuple in tuples)
    {
        if (is.null(names(tuple))) {
            names(tuple) <- c('row', 'column')
        }

        row    <- min(tuple['row'   ], length(context$contents))
        column <- min(tuple['column'],  nchar(context$contents[[row]])+1)

        context[['selection']][[pos]] <-
            list( range=rstudioapi::document_range(
                            rstudioapi::document_position(row, column)
                          , rstudioapi::document_position(row, column))
                , text='')

        pos <- pos + 1
    }

    invisible(context)
}

my.setSelectionRange <- function(context, tuples=list())
{
    if (is.atomic(tuples)) {
        tuples <- list(tuples)
    }

    pos <- 1
    for (tuple in tuples)
    {
        if (is.null(names(tuple))) {
            names(tuple) <- c('row.start', 'column.start', 'row.end', 'column.end')
        }

        row.start <- min(tuple['row.start'], length(context$contents))
        row.end   <- min(tuple['row.end'  ], length(context$contents))

        column.start <- min(tuple['column.start'], nchar(context$contents[[row.start]])+1)
        column.end   <- min(tuple['column.end'  ], nchar(context$contents[[row.end  ]])+1)

        text <- ''
        if (row.start == row.end) {
            substr(context$contents[[row.start]], column.start, column.end-1)
        } else {
            text <- substr(context$contents[[row.start]], column.start, nchar(context$contents[[row.start]]))
            rs <- row.start + 1
            while (rs < row.end)
            {
                text <- c(text, context$contents[[rs]])
                rs <- rs + 1
            }

            text <- c(text, substr(context$contents[[row.end]], 1, column.end-1))
            text <- paste(text, collapse='\n')
        }

        context[['selection']][[pos]] <-
            list( range=rstudioapi::document_range(
                            rstudioapi::document_position(row.start, column.start)
                          , rstudioapi::document_position(row.end, column.end))
                , text=text)

        pos <- pos + 1
    }

    invisible(context)
}
