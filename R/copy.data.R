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
    type <- detect.type(adjust.selection())

    if (type[['supported']]) {
        copy.to.clipboard(get.tsv(type))
    } else {
        message(ifelese(is.null(type[['type']])
                       , 'Nothing was copied to the clipboard - variable does not exist.')
                       , message('Nothing was copied to the clipboard - variable type is not supported.'))
    }
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
        if (is.matrix(type[['value']])) {
            type[['type'     ]] <- 'matrix'
            type[['supported']] <- T
        } else if (is.atomic(type[['value']])) {
            type[['type'     ]] <- 'atomic'
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

    if (type[['type']] == 'matrix') {
        tsv <- get.tsv.matrix(type)
    } else if (type[['type']] == 'atomic') {
        tsv <- get.tsv.atomic(type)
    }

    return(tsv)
}

#' @family generate.tsv
#' @title Generate tsv for vector
#' @description Method generates tsv string for an atomic vector
#'
#' @param type The list of 4 values (as returned by \code{\link{detect.type}}):
#'     \describe{
#'         \item{name}{name of the variable - not used}
#'         \item{type}{should be \code{atomic} - not checked, not used}
#'         \item{value}{an atomic vector}
#'         \item{supported}{should be \code{TRUE} - not checked, not used}
#'     }
#'
#' @details 1 or 2 rows seperated with \code{\\n} will be generated. If it is
#'          a named vector, first row will be a tab separated list of names.
#'          Second row will be a \code{\\t} separated list of vector values.
#'
#' @return tsv string
#'
get.tsv.atomic <- function(type = list(name=NULL, type='atomic', value=NULL, supported=T))
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
#'         \item{name}{name of the variable - not used}
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
#'
#' @return tsv string
#'
get.tsv.matrix <- function(type = list(name=NULL, type='matrix', value=NULL, supported=T))
{
    if (is.null(type[['value']])) {
        return('')
    }

    # new matrix will be created, where first row will contain column names
    # and first column will contain rownames. Obviously when they exist.
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
                new.mat <- rbind( c( paste(names(mat.names), collapse='\\')
                                          , mat.names[[2]]
                                   )
                                , new.mat )
            }
        }
    }

    return(paste(apply(new.mat, 1, paste, collapse='\t'), collapse='\n'))
}

copy.to.clipboard <- function(tsv = NULL)
{
    return(!is.null(tsv) && writeClipboard(tsv, format=1))
}

adjust.selection <- function()
{
    context <- rstudioapi::getActiveDocumentContext()
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

    # show what was finally selected
    rstudioapi::setSelectionRanges( rstudioapi::document_range( rstudioapi::document_position(row.num.start, start)
                                                              , rstudioapi::document_position(row.num.start, end + 1))
                                  , context$id)

    # selected text
    return(substr(line, start, end))
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
