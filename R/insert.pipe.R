#' @title Insert pipe
#'
#' @description Method inserts pipes at the current position(s) of the cursor(s)
#'              or replaces all selections, plus it reformats pipe(s)
#'              surroundings (see Details for more)
#'
#' @details Method aims to achieve the following format:
#' \itemize{
#'   \item exactly one space before \code{\%>\%}
#'   \item line cannot start with \code{\%>\%} (unless it is first line of the file).
#'         It will find last non-empty line before the cursor position.
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
    positions <- extract.positions()

    if (length(positions) > 0)
    {
        for (i in 1:length(positions))
        {
            # get cursor/selection position
            row.num.start <- positions[[i]]$start[['row']]
            col.num.start <- positions[[i]]$start[['column']]

            row.num.end   <- positions[[i]]$end[['row']]
            col.num.end   <- positions[[i]]$end[['column']]

            # renew the context
            context <- rstudioapi::getActiveDocumentContext()

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
            reps <- max(0, as.integer(regexpr('\\S+', before)) - 1) + .rs.readUiPref('num_spaces_for_tab')

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

            # replace newly created range
            rstudioapi::modifyRange(new.range, replacement, context$id)

            # cursor should be placed at the end of the indentation
            #end.positions <- update.positions(end.positions, row.num.start, reps, row.num.end)

            positions <- update.positions(positions, i, row.num.start, reps)
            rstudioapi::setCursorPosition(positions, context$id)
        }
    }
}

#' @title Extract selections
#' @description Method collects all selection ranges in the active documnent.
#' @return List of selection ranges.
extract.positions <- function()
{
    positions <- list()

    # loop throu all selections and collect all ranges
    context <- rstudioapi::getActiveDocumentContext()
    for (con in context$selection)
    {
        positions[[length(positions) + 1]] <-
            rstudioapi::document_range(
                rstudioapi::document_position( con$range$start[['row'   ]]
                                             , con$range$start[['column']] )
              , rstudioapi::document_position( con$range$end  [['row'   ]]
                                             , con$range$end  [['column']] ))
    }

    positions
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
    positions[[index]] <- rstudioapi::document_position( row + 1, column + 1)

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
