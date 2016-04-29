# dummy method for copy.data unit testing
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

# dummy method for insert.pipe unit testing
.foobar2 <- function()
{
    select <- function()
    {
        NULL
    }

    filter <- function()
    {
        NULL
    }

    # test here
    a <- select() %   >  %




        filter()


    # expected
    a <- select() %>%
        filter() %>%
            as.data.frame()

    a
}

top.context <- rstudioapi::getActiveDocumentContext()
top.context[['selection']][[1]] <- NULL
save(top.context, file='.\\tests\\testthat\\.foobar.Rdata')
rm(top.context)
