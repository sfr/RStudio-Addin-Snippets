# dummy method for unit testing purposes
.foobar <- function( .x_y_z, a )
{
a <- F # not indented on purpose

    if (missing(.x_y_z)) {
        print('Please set a list .x_y_z.')
    } else {
        print(.x_y_z$pi)
    }

    a
}

top.context <- rstudioapi::getActiveDocumentContext()
top.context[['selection']][[1]] <- NULL
save(top.context, file='.\\tests\\testthat\\data\\.foobar.Rdata')
rm(top.context)
