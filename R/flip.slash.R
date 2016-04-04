#' @title Flips slashes orientation in code selections or from clipboard
#'
#' @description Method reverse orientation of slashes in the selected code
#'              or in the clipboard.
#'
#' @usage
#'
#' @details Method will go through all code selections and reverse orientation
#'          of all slashes found. In the case there is no content selected or
#'          only white-space is selected, content of the clipboard will be put
#'          there - again with all slashes reversed.
#' @export
#'
flip.slash <- function()
{
    context <-  rstudioapi::getActiveDocumentContext()

    # will hold converted clipboard text, in the case it needs to be used multiple times
    fromClipboard <- NULL

    for (con in context$selection)
    {
        # does selection contain only whitespace?
        replacement <- ifelse( gsub('\\s', '', con$text) != ''
                             , flip(con$text)
                             , ifelse( is.null(fromClipboard) && (getClipboardFormats(T)[1] == 1L)
                                     , flip(readClipboard(1))
                                     , fromClipboard )
                             )

        rstudioapi::modifyRange(con$range, replacement, context$id)
    }
}

#' @title Flips slashes orientation
#'
#' @description Method reverse orientation of slashes in the string
#'
#' @param text character where slashes orientation will be flipped
#'
#' @details If method find forward or backward slash in the \code{text} then
#'          it will reverse its orientation. In the case there are no slashes
#'          in the \code{text}, unmodified \code{text} is returned.
#'
#' @return Method returns string with reversed orientation of slashes.
#'
#' @examples
#' flip('/usr\\bin/') == flip(flip(flip('/usr\\bin/')))
#' flip('no change') == 'no change'
#'
#' @export
#'
flip <- function(text = character(0))
{
    changes <- as.integer(gregexpr('[/\\]', text)[[1]])

    if (length(changes) == 1 && changes == -1) {
        return(text)
    } else {
        replacement <- strsplit(text, '')[[1]]

        for (pos in changes)
        {
            replacement[pos] <- ifelse(replacement[pos] == '/', '\\', '/')
        }

        return(paste0(replacement, collapse=''))
    }
}
