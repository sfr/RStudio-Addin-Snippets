#' @title Flips slashes orientation in code selections or from clipboard
#'
#' @description Method reverse orientation of slashes in the selected code
#'              or in the clipboard.
#'
#' @details Method will go through all code selections and reverse orientation
#'          of all slashes found. In the case there is no content selected or
#'          only white-space is selected, content of the clipboard will be put
#'          there - again with all slashes reversed.
#' @export
#'
flip.slash <- function()
{
    context <- rstudioapi::getActiveDocumentContext()
    for (con in rev(context$selection))
        rstudioapi::modifyRange(con$range, find.replacement(con$text), context$id)
}

#' @title Find Replacement
#' @description Method decides what the selection should be replaced with.
#'
#' @param text Selected text
#'
#' @return If text is not empty it will be replaced with the same text with
#'         flipped orientation of slashes. In the case that text is empty or it
#'         contains only whitespaces, if clipboard contains some text other than
#'         whitespaces, then it will be replaces by the text from clipboard with
#'         flipped orientation of slashes. If clipboard is empty, or there is
#'         something of unrecognized format text will stay unchanged.
find.replacement <- function(text)
{
    return(ifelse( gsub('\\s', '', text) != ''
                 , flip(text)
                 , ifelse( utils::getClipboardFormats(T)[1] == 1L
                         , flip(utils::readClipboard(1))
                         , text)
                 )
          )
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
#' \donttest{
#'     flip('/usr\\bin/') == flip(flip(flip('/usr\\bin/')))
#'     flip('no change') == 'no change'}
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
