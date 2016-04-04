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
insert.pipe <- function()
{
    context <-  rstudioapi::getActiveDocumentContext()

    # for each cursor position in reverse order! - to avoid clashes
    for (con in rev(context$selection))
    {
        # get cursor/selection position
        row.num.start <- con$range$start[['row']]
        col.num.start <- con$range$start[['column']]

        row.num.end   <- con$range$end[['row']]
        col.num.end   <- con$range$end[['column']]

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
        after <- sub('^\\s+', '', substr( context$contents[[row.num.end  ]]
                                        , col.num.end
                                        , end.line.len))

        # how many spaces needs to be added:
        #     indentation of the current line
        #         (position of the first non-whitespace character)
        #     plus default indentation set up in project preferences.
        reps <- max(0, as.integer(regexpr('\\S+', before)) - 1) +
                .rs.readUiPref('num_spaces_for_tab')

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
        con$range <- rstudioapi::document_range( rstudioapi::document_position(row.num.start, 0)
                                               , rstudioapi::document_position(row.num.end, end.line.len))

        # replace newly created range
        rstudioapi::modifyRange(con$range, replacement, context$id)

        # NOT YET SUPPORTED in RStudio API!
        #     Cursor should be placed at the end of the indentation.
        #     At the moment it will jump to the end on the new line, which is
        #     not desirable in some cases.
        #rstudioapi::setCursorPosition(rstudioapi::document_position(row.num.start + 1, reps))
    }
}
