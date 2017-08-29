.onLoad <- function(libname, pkgname) {
  op <- options()
  op.snippetsaddin <- list(
    op.snippetsaddin.dec_sep = ","
  )
  toset <- !(names(op.snippetsaddin) %in% names(op))
  if(any(toset)) options(op.snippetsaddin[toset])
  invisible()
}


#' @title Copy data the clipboard
#'
#' @description Method will copy a value of the selected variable into
#'              the clipboard.
#'
#' @details Method will find the first word that would be a valid variable name
#'          which is 'touched' by the cursor or selection. In the case there is
#'          multiple cursors/selection only the first one (the primary one) will
#'          be considered.
#'
#' @export
#'
copy.data <- function()
{
    # find the first 'word' that would be a valid variable name
    # and then find if such a variable exists and what type it is
    context <- rstudioapi::getActiveDocumentContext()
    selection <- adjust.selection(context)

    # show what was finally selected
    rstudioapi::setSelectionRanges(selection$range, context$id)
    
    # modify decimal separator output
    old_opts <- getOption("OutDec")
    options(OutDec = getOption("op.snippetsaddin.dec_sep"))
    type <- detect.type(selection$text)

    if (type[['supported']])
        res <- copy.to.clipboard(get.tsv(type))
    else
        res <- message(get.error.message(type))
    
    # make decimal output to default
    options(OutDec = old_opts)
  
   return(res)
}

#' @title Print error message
#' @description Method returns appropriate error message.
#'
#' @param type The list of 4 values:
#'            \describe{
#'                \item{name}{name of the variable - not used}
#'                \item{type}{type of the variable}
#'                \item{value}{value of the variable - not used}
#'                \item{supported}{\code{TRUE} if tsv can be generated,
#'                                 \code{FALSE} otherwise - not used}
#'            }
#'
#' @return error message
#'
get.error.message <- function(type = list(type=NULL))
{
    return(ifelse( is.null(type[['type']])
                 , 'Nothing was copied to the clipboard - variable does not exist.'
                 , 'Nothing was copied to the clipboard - variable type is not supported.'))
}

#' @title Check the type of the variable
#' @description Method checks if the variable exists, and what type it is. Based
#'              on that it decides if the type is supported or not.
#'
#' @param variable.name The name of the variable taht will be checked.
#'
#' @return The list of 4 values:
#'     \describe{
#'         \item{name}{name of the variable}
#'         \item{type}{type of the variable}
#'         \item{value}{value of the variable}
#'         \item{supported}{\code{TRUE} if tsv can be generated,
#'                          \code{FALSE} otherwise}
#'     }
#'
detect.type <- function(variable.name = '')
{
    type <- list( name      = variable.name
                , type      = NULL
                , value     = NULL
                , supported = F )

    if (   is.character(type[['name']])
        && nchar(type[['name']]) > 0
        && !is.null(type[['value']] <- get0(type[['name']], envir=.GlobalEnv))
       ) {
        if (is.table(type[['value']])) {
            type[['type'     ]] <- 'table'
            type[['supported']] <- T
        } else if (is.data.frame(type[['value']])) {
            type[['type'     ]] <- 'data.frame'
            type[['supported']] <- T
        } else if (is.matrix(type[['value']])) {
            type[['type'     ]] <- 'matrix'
            type[['supported']] <- T
        } else if (is.array(type[['value']])) {
            type[['type'     ]] <- 'array'
            type[['supported']] <- T
        } else if (is.vector(type[['value']])) {
            type[['type'     ]] <- 'vector'
            type[['supported']] <- T
        }
    }

    return(type)
}

#' @family generate.tsv
#' @title Generates tsv
#' @description Method generates tsv string
#'
#' @param type The list of 4 values (as returned by \code{\link{detect.type}}):
#'     \describe{
#'         \item{name}{name of the variable - not used}
#'         \item{type}{type of the variable}
#'         \item{value}{value of the variable}
#'         \item{supported}{if \code{TRUE} the tsv is generated}
#'     }
#'
#' @details if the \code{type} is \code{supported} then it will generate
#'          appropriate tsv representation of the object.
#'
#' @return tsv string
#'
get.tsv <- function(type = list(name=NULL, type=NULL, value=NULL, supported=F))
{
    tsv <- NULL

    if (type[['type']] == 'table') {
        tsv <- get.tsv.table(type)
    } else if (type[['type']] == 'array') {
        tsv <- get.tsv.array(type)
    } else if (type[['type']] == 'data.frame') {
        tsv <- get.tsv.data.frame(type)
    } else if (type[['type']] == 'matrix') {
        tsv <- get.tsv.matrix(type)
    } else if (type[['type']] == 'vector') {
        tsv <- get.tsv.vector(type)
    }

    return(tsv)
}

#' @family generate.tsv
#' @title Generate tsv for vector
#' @description Method generates tsv string for an vector
#'
#' @param type The list of 4 values (as returned by \code{\link{detect.type}}):
#'     \describe{
#'         \item{name}{name of the variable - not used}
#'         \item{type}{should be \code{vector} - not checked, not used}
#'         \item{value}{a vector}
#'         \item{supported}{should be \code{TRUE} - not checked, not used}
#'     }
#'
#' @details 1 or 2 rows seperated with \code{\\n} will be generated. If it is
#'          a named vector, first row will be a tab separated list of names.
#'          Second row will be a \code{\\t} separated list of vector values.
#'
#' @return tsv string
#'
get.tsv.vector <- function(type = list(name=NULL, type='vector', value=NULL, supported=T))
{
    return(ifelse( !is.null(names(type[['value']]))
                 , paste( paste(names(type[['value']]), collapse='\t')
                        , paste(type[['value']], collapse='\t'), sep='\n')
                 , paste(type[['value']], collapse='\t')
                 )
          )
}

#' @family generate.tsv
#' @title Generates tsv for matrix
#' @description Method generates tsv string for a matrix
#'
#' @param type The list of 4 values (as returned by \code{\link{detect.type}}):
#'     \describe{
#'         \item{name}{name of the variable}
#'         \item{type}{should be \code{matrix} - not checked, not used}
#'         \item{value}{matrix}
#'         \item{supported}{should be \code{TRUE} - not checked, not used}
#'     }
#'
#' @details Method will return N or N+1 rows and M or M+1 tab separated columns.
#'          +1 in both cases is when row names and/or column names exist.
#'          If both row and column names exist then top left corner will be
#'          constructed from dimension names if they exists in the format:
#'          Row names dimension name, backslash, column names dimension name.
#'          In the case there are no dimension names, the \code{name}
#'          of the variable will be used for the top left corner cell.
#'
#' @return tsv string
#'
get.tsv.matrix <- function(type = list(name='', type='matrix', value=NULL, supported=T))
{
    tsv <- ''
    if (!is.null(type[['value']])) {
        # new matrix will be created, where first row will contain column names
        # and first column will contain row names. Obviously when they exist.
        new.mat <- type[['value']]
        dimnames(new.mat) <- NULL # not necessary, just to be pedantic

        mat.names <- dimnames(type[['value']])

        if (!is.null(mat.names)) {
            if (is.null(mat.names[[1]])) {
                # we already know that there is at least one non-null value in names
                # and it's not the first one, so we do not have to test for !is.null
                new.mat <- rbind(mat.names[[2]], new.mat)
            } else {
                new.mat <- cbind(mat.names[[1]], new.mat)

                if (!is.null(mat.names[[2]])) {
                    # both row and column names exist, so create top left cell too
                    top.left <- paste(names(mat.names), collapse='\\')
                    if (top.left == '') {
                        top.left <- type[['name']]
                    }

                    new.mat <- rbind( c(top.left, mat.names[[2]])
                                    , new.mat )
                }
            }
        }

        tsv <- paste(apply(new.mat, 1, paste, collapse='\t'), collapse='\n')
    }

    return(tsv)
}

#' @family generate.tsv
#' @title Generates tsv for data frame
#' @description Method generates tsv string for a data frame
#'
#' @param type The list of 4 values (as returned by \code{\link{detect.type}}):
#'     \describe{
#'         \item{name}{name of the variable}
#'         \item{type}{should be \code{data.frame} - not checked, not used}
#'         \item{value}{a data frame}
#'         \item{supported}{should be \code{TRUE} - not checked, not used}
#'     }
#'
#' @details Method will return N or N+1 rows and M or M+1 tab separated columns.
#'          +1 in both cases is when row names and/or column names exist.
#'          If both row and column names exist then top left corner cell will
#'          contain the \code{name} of the variable.
#'
#' @return tsv string
#'
get.tsv.data.frame <- function(type = list(name='', type='data.frame', value=NULL, supported=T))
{
    tsv <- ''

    if (!is.null(type[['value']])) {
        mat.type <- type
        mat.type[['value']] <- as.matrix(mat.type[['value']])
        mat.type[['type' ]] <- 'matrix'

        tsv <- get.tsv(mat.type)
    }

    return(tsv)
}

#' @family generate.tsv
#' @title Generates tsv for array
#' @description Method generates tsv string for an array
#'
#' @param type The list of 4 values (as returned by \code{\link{detect.type}}):
#'     \describe{
#'         \item{name}{name of the variable}
#'         \item{type}{should be \code{array} - not checked, not used}
#'         \item{value}{an array}
#'         \item{supported}{should be \code{TRUE} - not checked, not used}
#'     }
#'
#' @details 1-dimensional array will be coverted to vector and method
#'          \code{\link{get.tsv.vector}} will be called.
#'          2-dimensional array will be coverted to matrix and method
#'          \code{\link{get.tsv.matrix}} will be called.
#'          3 and more dimensional array will be flattened to matrix and method
#'          \code{\link{get.tsv.matrix}} will be called. Matrix will have
#'          \code{N+1} columns where \code{N} is a number of dimensions and
#'          \code{M} or \code{M+1} rows, where \code{M} is a product of array
#'          dimensions. E.g. if array has following dimensions
#'          \code{dim=c(2, 4, 2)}, then the output table will have
#'          \code{N=3+1=4} columns and \code{M=2*4*2=16} rows. If array
#'          dimensions are named then header row will be added. First \code{N}
#'          columns will be take names from dimensions names and the last column
#'          will be named after variable. Missing names will stay empty.
#'
#' @return tsv string
#'
get.tsv.array <- function(type = list(name='', type='array', value=NULL, supported=T))
{
    tsv <- ''

    if (!is.null(type[['value']])) {
        dimensions <- length(dim(type[['value']]))
        if (dimensions == 1) {
            new.type <- type
            new.type[['value']] <- stats::setNames(as.vector(type[['value']]), names(type[['value']]))
            new.type[['type' ]] <- 'vector'

            tsv <- get.tsv(new.type)
        } else if (dimensions == 2) {
            new.type <- type
            new.type[['value']] <- as.matrix(type[['value']])
            new.type[['type' ]] <- 'matrix'

            tsv <- get.tsv(new.type)
        } else {
            # flatten dimensions to matrix
            new.type <- type
            new.type[['value']] <- as.matrix(as.data.frame(as.table(type[['value']], deparse.level=0)))
            new.type[['type' ]] <- 'matrix'

            if (is.null(names(dimnames(type[['value']])))) {
                colnames(new.type[['value']]) <- NULL
            } else {
                colnames(new.type[['value']]) <- c(names(dimnames(type[['value']])), new.type[['name']])
            }

            tsv <- get.tsv(new.type)
        }
    }

    return(tsv)
}

#' @family generate.tsv
#' @title Generates tsv for table
#' @description Method generates tsv string for a table
#'
#' @param type The list of 4 values (as returned by \code{\link{detect.type}}):
#'     \describe{
#'         \item{name}{name of the variable}
#'         \item{type}{should be \code{table} - not checked, not used}
#'         \item{value}{an table}
#'         \item{supported}{should be \code{TRUE} - not checked, not used}
#'     }
#'
#' @details blank
#'
#' @return tsv string
#'
get.tsv.table <- function(type = list(name='', type='table', value=NULL, supported=T))
{
    tsv <- ''

    if (!is.null(type[['value']])) {
        dimensions <- length(dim(type[['value']]))
        if (dimensions == 1) {
            new.type <- type
            new.type[['value']] <- stats::setNames(as.vector(type[['value']]), names(type[['value']]))
            new.type[['type' ]] <- 'vector'

            tsv <- get.tsv(new.type)
        } else if (dimensions == 2) {
            new.type <- type
            new.type[['value']] <- as.matrix(type[['value']])
            new.type[['type' ]] <- 'matrix'

            tsv <- get.tsv(new.type)
        } else {
            # flatten dimensions to matrix
            new.type <- type
            new.type[['value']] <- as.matrix(as.data.frame(type[['value']]))
            new.type[['type' ]] <- 'matrix'

            if (paste0(names(dimnames(type[['value']])), collapse='') == '') {
                colnames(new.type[['value']]) <- NULL
            } else {
                colnames(new.type[['value']]) <- c(names(dimnames(type[['value']])), new.type[['name']])
            }

            tsv <- get.tsv(new.type)
        }
    }

    return(tsv)
}

#' @title Write to Clipboard
#' @description If there is something to write to clipboard then write it.
#'
#' @param tsv The tab septarated values string
#'
#' @return Methood invisibly returns \code{TRUE} if \code{tsv} was successfully
#'         copied to the clipboard, or \code{FALSE} otherwise.
#'
copy.to.clipboard <- function(tsv = NULL)
{
    invisible(!is.null(tsv) && utils::writeClipboard(tsv, format=1))
}

adjust.selection <- function(context)
{
    con <- rstudioapi::primary_selection(context)

    # rows
    row.num.start <- con$range$start[['row']]
    row.num.end   <- con$range$end[['row']]

    # columns
    start <- con$range$start[['column']]
    end   <- con$range$end[['column']] - 1

    # first row
    line     <- context$contents[[row.num.start]]
    line.len <- nchar(line)

    # does the selection/cursor touches the 'word' on the left?
    # if yes extend selection to the left
    while (start > 1 && is.namelegal(line, start - 1))
    {
        start <- start - 1
    }

    # does the selection start with a non-valid character(s)
    # if yes move to the first valid one. If not found in the current row
    # and selection goes through multiple lines, continue on the next line
    while (   (row.num.start < row.num.end || start <= end)
           && (start > line.len || !is.namelegal(line, start)))
    {
        start <- start + 1

        if (start > line.len) {
            row.num.start <- row.num.start + 1
            start         <- 1
            line          <- context$contents[[row.num.start]]
            line.len      <- nchar(line)
        }
    }

    # at this point starting column was found or end was reached.

    # find the end of the word
    end <- start - 1
    while (end < line.len && is.namelegal(line, end + 1))
    {
        end <- end + 1
    }

    return( list( range = rstudioapi::document_range( rstudioapi::document_position(row.num.start, start)
                                                    , rstudioapi::document_position(row.num.start, end + 1))
                , text = substr(line, start, end)
                )
          )
}

#' @title Test validity
#'
#' @description Method test if the character at the \code{position}
#'              in the \code{line}, could be a part of the valid variable name.
#'
#' @param line     A
#' @param position A position of the character in the \code{line}
is.namelegal <- function(line, position = integer(0))
{
    return(length(grep('[_a-zA-Z0-9\\.]', substr(line, position, position))) > 0)
}
