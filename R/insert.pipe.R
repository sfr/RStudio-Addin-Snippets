#' @title Insert pipe
#'
#' @description Method inserts pipes at the current position(s) of the cursor(s)
#'              or replaces all selections, plus it reformats pipe(s)
#'              surroundings (see Details for more)
#'
#' @details Method aims to achieve the following format:
#' \itemize{
#'   \item exactly one space before \code{\%>\%}
#'   \item line cannot start with \code{\%>\%} (unless it is first line of the
#'         file). It will find last non-empty line before the cursor position.
#'   \item new line after \code{\%>\%}
#'   \item next line will be indented as the current line is + N spaces;
#'         where N is dependent on the RStudio settings
#'   \item then it's followed by the next word, or it is the end of the line.
#' }
#'
#' @export
#'
insert.pipe <- function()
{
    context <- rstudioapi::getActiveDocumentContext()
    positions <- lapply(context[['selection']], '[[', 'range')
    indentation <- .rs.readUiPref('num_spaces_for_tab')

    if (length(positions) > 0)
    {
        for (i in 1:length(positions))
        {
            result <- resolve.selection(context, positions[[i]], indentation)
            positions <- update.positions(positions, i, result$range$start[['row']], result$column)

            # replace newly created range
            rstudioapi::modifyRange(result$range, result$text, context$id)
            rstudioapi::setCursorPosition(positions, context$id)

            # renew the context
            context <- rstudioapi::getActiveDocumentContext()
        }
    }
}

#' @title Process selection
#' @description Method will resolve one selection according to rules specified
#'              in \code{\link{insert.pipe}}
#'
#' @param context     Actual document context
#' @param position    document_range to resolve
#' @param indentation value of \code{.rs.readUiPref('num_spaces_for_tab')}
#'
#' @return The list of 3 values:
#'     \describe{
#'         \item{range}{\code{document_range} which will be replaced by
#'                      the \code{text}}
#'         \item{text}{new text to replace the \code{range}}
#'         \item{column}{new end of the original selection}
#'     }
#'
#' @details The returned \code{column} is not the same as the end of the
#'          \code{range}, becuse range will end at the edn of the line. The
#'          \code{column} is important for calculating the expansion or
#'          shinkage of the original range (\code{position}), in the case there
#'          are multiple selections in the file. Next selection could even start
#'          at that very \code{column}.
resolve.selection <- function(context, position, indentation)
{
    # get cursor/selection position
    row.num.start <- position$start[['row'   ]]
    col.num.start <- position$start[['column']]

    row.num.end   <- position$end[['row'   ]]
    col.num.end   <- position$end[['column']]

    end.line.len  <- nchar(context$contents[[row.num.end]]) + 1

    # trim all trailing spaces before the cursor position
    before <- sub('\\s+$', '', substr( context$contents[[row.num.start]]
                                     , 0
                                     , col.num.start - 1))

    # in the case of empty line, continue trimming on the previous line.
    while (before == '' && row.num.start > 1)
    {
        row.num.start <- row.num.start - 1
        before <- sub('\\s+$', '', context$contents[[row.num.start]])
    }

    # trim the malformed pipe before the cursor
    before <- sub('\\s*%\\s*>\\s*%$', '', before)

    # trim all leading spaces after cursor position
    after <- sub('^\\s+', '', substr( context$contents[[row.num.end]]
                                    , col.num.end
                                    , end.line.len))

    # how many spaces needs to be added:
    #     indentation of the current line
    #         (position of the first non-whitespace character)
    #     plus default indentation set up in project preferences.
    reps <- max(0, as.integer(regexpr('\\S+', before)) - 1) + indentation

    # replace with:
    #     trimmed 'before' string,
    #     space,
    #     pipe,
    #     end of line,
    #     indentation
    #     trimmed 'after' string
    replacement <- paste0(c(before, ' ', '%>%', '\n', rep(' ', reps), after), collapse='')

    # create new selection:
    #     from the start of the first non-empty line before the cursor
    #     to the end of the cursor line
    new.range <- rstudioapi::document_range( rstudioapi::document_position(row.num.start, 0)
                                           , rstudioapi::document_position(row.num.end, end.line.len))

    return(list(range=new.range, text=replacement, column=reps))
}

#' @title Update positions
#' @description Method update selection positions in the document.
#'
#' @param positions List of documents positions/ranges.
#' @param index     Index to the \code{list} - element to update
#' @param row       new last row of the \code{index} selection
#'                  (will be incermented by 1)
#' @param column    new last column of the \code{index} selection
#'                  (will be incermented by 1)
#'
#' @return Updated list of positions
#'
#' @details The function of the method is to keep track of changes and movement
#'          of the rows and columns in the documemnt when selections are
#'          shrinked or expanded.
update.positions <- function(positions, index, row, column)
{
    # remember the old end cursor of the range
    old.row    <- positions[[index]]$end[['row'   ]]
    old.column <- positions[[index]]$end[['column']]

    # calculate the difference to teh new end
    row.diff   <- row    + 1 - old.row
    col.diff   <- column + 1 - old.column

    # current range is updates and change to position object, as we do have only
    # cursor - not a selection
    positions[[index]] <- rstudioapi::document_position(row + 1, column + 1)

    # loop through the rest of positions
    if (index < length(positions)) {
        for (i in (index+1):length(positions))
        {
            # if the next selection starts in the same row as the previous one
            # ended updates to the column position needs to be made
            if (positions[[i]]$start[['row']] == old.row) {
                positions[[i]]$start[['column']] <- positions[[i]]$start[['column']] + col.diff
            }

            # if the next selection ends in the same row as the previous one
            # updates to the column position needs to be made
            if (positions[[i]]$end[['row']] == old.row) {
                positions[[i]]$end[['column']] <- positions[[i]]$end[['column']] + col.diff
            }

            # update start and end row of the next position
            positions[[i]]$start[['row']] <- positions[[i]]$start[['row']] + row.diff
            positions[[i]]$end  [['row']] <- positions[[i]]$end  [['row']] + row.diff
        }
    }

    return(positions)
}
