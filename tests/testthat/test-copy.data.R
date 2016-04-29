context('Copy data to clipboard')

################################################################################
# start of the DO NOT CHANGE section !!! - unless you know what you are doing
# position of the code in this section is referenced in the test methods.
# changes here might break tests!

# dummy method
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
# end of the DO NOT CHANGE section !!!
################################################################################

test_that('detect.type',
{
    expect_identical(detect.type(''  ), list(name='',   type=NULL, value=NULL, supported=F))
    expect_identical(detect.type(NULL), list(name=NULL, type=NULL, value=NULL, supported=F))
    expect_identical(detect.type(NA  ), list(name=NA,   type=NULL, value=NULL, supported=F))
    expect_identical(detect.type(5   ), list(name=5,    type=NULL, value=NULL, supported=F))

    # detect.type look for variable in the global environment
    name <- 'vec'
    assign(name, 1:10, envir=.GlobalEnv)
    actual   <- detect.type(name)
    expected <- list(name=name, type='atomic', value=get0(name, envir=.GlobalEnv), supported=T)
    rm(vec, envir=.GlobalEnv)
    expect_identical(actual, expected)

    assign(name, letters[1:5], envir=.GlobalEnv)
    actual <- detect.type(name)
    expected <- list(name=name, type='atomic', value=get0(name, envir=.GlobalEnv), supported=T)
    rm(vec, envir=.GlobalEnv)
    expect_identical(actual, expected)

    assign('vec', matrix(1:10, nrow=2), envir=.GlobalEnv)
    actual <- detect.type(name)
    expected <- list(name=name, type='matrix', value=get0(name, envir=.GlobalEnv), supported=T)
    rm(vec, envir=.GlobalEnv)
    expect_identical(actual, expected)
})

test_that('get.tsv',
{
    # atomic
    expect_identical( get.tsv(list(type='atomic', value=1:3))
                    , '1\t2\t3')

    # matrix
    expect_identical( get.tsv(list(type='matrix', value=matrix(1:12, nrow=3, byrow=T)))
                    , '1\t2\t3\t4\n5\t6\t7\t8\n9\t10\t11\t12')
})

test_that('get.tsv.atomic',
{
    expect_identical(get.tsv.atomic(), '')

    vec <- 1:3
    expect_identical(get.tsv.atomic(list(value=vec)), '1\t2\t3')

    names(vec) <- letters[1:3]
    expect_identical(get.tsv.atomic(list(value=vec)), 'a\tb\tc\n1\t2\t3')

    vec <- c(vec, 4)
    expect_identical(get.tsv.atomic(list(value=vec)), 'a\tb\tc\t\n1\t2\t3\t4')

    vec <- c(vec, NA)
    expect_identical(get.tsv.atomic(list(value=vec)), 'a\tb\tc\t\t\n1\t2\t3\t4\tNA')
})

test_that('get.tsv.matrix',
{
    expect_identical(get.tsv.matrix(), '')

    mat <- matrix(1:12, nrow=3, byrow=T)
    expect_identical(get.tsv.matrix(list(value=mat)), '1\t2\t3\t4\n5\t6\t7\t8\n9\t10\t11\t12')

    dimnames(mat) <- list(letters[1:3])
    expect_identical(get.tsv.matrix(list(value=mat)), 'a\t1\t2\t3\t4\nb\t5\t6\t7\t8\nc\t9\t10\t11\t12')

    dimnames(mat) <- list(let=letters[1:3])
    expect_identical(get.tsv.matrix(list(value=mat)), 'a\t1\t2\t3\t4\nb\t5\t6\t7\t8\nc\t9\t10\t11\t12')

    dimnames(mat) <- list(NULL, month.abb[1:4])
    expect_identical(get.tsv.matrix(list(value=mat)), 'Jan\tFeb\tMar\tApr\n1\t2\t3\t4\n5\t6\t7\t8\n9\t10\t11\t12')

    dimnames(mat) <- list(NULL, months=month.abb[1:4])
    expect_identical(get.tsv.matrix(list(value=mat)), 'Jan\tFeb\tMar\tApr\n1\t2\t3\t4\n5\t6\t7\t8\n9\t10\t11\t12')

    dimnames(mat) <- list(letters[1:3], month.abb[1:4])
    expect_identical(get.tsv.matrix(list(value=mat)), '\tJan\tFeb\tMar\tApr\na\t1\t2\t3\t4\nb\t5\t6\t7\t8\nc\t9\t10\t11\t12')

    dimnames(mat) <- list(let=letters[1:3], month.abb[1:4])
    expect_identical(get.tsv.matrix(list(value=mat)), 'let\\\tJan\tFeb\tMar\tApr\na\t1\t2\t3\t4\nb\t5\t6\t7\t8\nc\t9\t10\t11\t12')

    dimnames(mat) <- list(letters[1:3], months=month.abb[1:4])
    expect_identical(get.tsv.matrix(list(value=mat)), '\\months\tJan\tFeb\tMar\tApr\na\t1\t2\t3\t4\nb\t5\t6\t7\t8\nc\t9\t10\t11\t12')

    dimnames(mat) <- list(let=letters[1:3], months=month.abb[1:4])
    expect_identical(get.tsv.matrix(list(value=mat)), 'let\\months\tJan\tFeb\tMar\tApr\na\t1\t2\t3\t4\nb\t5\t6\t7\t8\nc\t9\t10\t11\t12')
})

test_that('copy.to.clipboard',
{
    # skip when clipboard is not supported
    skip_on_os(c('mac', 'linux', 'solaris'))

    # skip when it's not RStudio or it's of a version that doesn't support addins
    skip_if_not(rstudioapi::isAvailable(REQUIRED.RSTUDIO.VERSION), 'RStudio is not available!')


})

test_that('adjust.selection',
{
print(normalizePath('.foobar.Rdata'))
    load('.foobar.Rdata')
    #load('.\\tests\\testthat\\data\\.foobar.Rdata')

    my.setCursorPosition <- function(context, row, column)
    {
        row    <- min(row, length(context$contents))
        column <- min(column, nchar(context$contents[[row]])+1)

        context[['selection']][[1]] <-
            list( range=rstudioapi::document_range(
                            rstudioapi::document_position(row, column)
                          , rstudioapi::document_position(row, column))
                , text='')

        invisible(context)
    }

    my.setSelectionRange <- function(context, row.start, column.start, row.end, column.end)
    {
        row.start <- min(row.start, length(context$contents))
        row.end   <- min(row.end,   length(context$contents))

        column.start <- min(column.start, nchar(context$contents[[row.start]])+1)
        column.end   <- min(column.end,   nchar(context$contents[[row.end  ]])+1)

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

        context[['selection']][[1]] <-
            list( range=rstudioapi::document_range(
                            rstudioapi::document_position(row.start, column.start)
                          , rstudioapi::document_position(row.end, column.end))
                , text=text)

        invisible(context)
    }

    # skip when it's not RStudio or it's of a version that doesn't support addins
    #skip_if_not(rstudioapi::isAvailable(REQUIRED.RSTUDIO.VERSION), 'RStudio is not available!')

    #' @title Generate tests
    place.in.word <- function(expected, info)
    {
        # first char
        context <- my.setCursorPosition(top.context, expected$row, expected$start)
        expect_identical( adjust.selection(context)[['text']], expected[['text']]
                        , paste0(info, ': cursor at the first character'))

        # last char
        context <- my.setCursorPosition(top.context, expected$row, expected$end)
        expect_identical( adjust.selection(context)[['text']], expected[['text']]
                        , paste0(info, ': cursor after the last character'))

        # in the middle
        if (nchar(expected$text) > 1) {
            context <- my.setCursorPosition(top.context, expected$row, expected$start + 1)
            expect_identical( adjust.selection(context)[['text']], expected[['text']]
                            , paste0(info, ': cursor in the middle of the word'))
        }

        # subselection
        if (nchar(expected$text) > 2) {
            context <- my.setSelectionRange(top.context, expected$row, expected$start + 1
                                                       , expected$row, expected$end   - 1)
            expect_identical( adjust.selection(context)[['text']], expected[['text']]
                            , paste0(info, ': selection inside the word'))
        }

        # selection from the start of the word till the end of line
        context <- my.setSelectionRange(top.context, expected$row, expected$start
                                                   , expected$row, Inf)
        expect_identical( adjust.selection(context)[['text']], expected[['text']]
                        , paste0(info, ': selection from the start of the word till the end of line'))

        # selection from the start of the word till the end of file
        context <- my.setSelectionRange(top.context, expected$row, expected$start
                                                   , Inf, Inf )
        expect_identical( adjust.selection(context)[['text']], expected[['text']]
                        , paste0(info, ': selection from the start of the word till the end of file'))

        if (nchar(expected$text) > 1) {
            # selection from middle of the word till the end of line
            context <- my.setSelectionRange(top.context, expected$row, expected$start + 1
                                                       , expected$row, Inf)
            expect_identical( adjust.selection(context)[['text']], expected[['text']]
                            , paste0(info, ': selection from the middle of the word till the end of line'))

            # selection from the middle of the word till the end of file
            context <- my.setSelectionRange(top.context, expected$row, expected$start + 1
                                                       , Inf, Inf)
            expect_identical( adjust.selection(context)[['text']], expected[['text']]
                            , paste0(info, ': selection from the middle of the word till the end of file'))
        }

        # selection from the end of the word till the end of line
        context <- my.setSelectionRange(top.context, expected$row, expected$end
                                                   , expected$row, Inf)
        expect_identical( adjust.selection(context)[['text']], expected[['text']]
                        , paste0(info, ': selection from the end of the word till the end of line'))

        # selection from the end of the word till the end of file
        context <- my.setSelectionRange(top.context, expected$row, expected$end
                                                   , Inf, Inf)
        expect_identical( adjust.selection(context)[['text']], expected[['text']]
                        , paste0(info, ': selection from the end of the word till the end of file'))
    }

    # value is a line number of the line: '# dummy method'
    test.first.line <- 1

    # long word at the beginning of the line
    place.in.word(list(row=test.first.line + 1, start=1, end=8, text='.foobar'), 'long word at the beginning of the line')

    # long word in the middle of the line
    place.in.word(list(row=test.first.line + 1, start=12, end=20, text='function'), 'long word in the middle of the line')

    # long word at the end of the line
    place.in.word(list(row=test.first.line, start=9, end=15, text='method'), 'long word at the end of the line')

    # short word at the beginning of the line
    place.in.word(list(row=test.first.line + 3, start=1, end=2, text='a'), 'short word at the beginning of the line')

    # short word in the middle of the line
    place.in.word(list(row=test.first.line + 6, start=27, end=28, text='a'), 'short word in the middle of the line')

    # short word at the end of the line
    place.in.word(list(row=test.first.line + 11, start=5, end=6, text='a'), 'short word at the end of the line')

    # some non-automated examples
    # multiline selection before the short word
    expected <- list(row=test.first.line + 3, start=1, end=2, text='a')
    context <- my.setSelectionRange(top.context, test.first.line + 1, 32
                                               , expected$row, expected$start)
    expect_identical( adjust.selection(context)[['text']], expected[['text']]
                    , 'multiline selection before the short word')

    # multiline selection before the longer word
    expected <- list(row=test.first.line + 5, start=5, end=7, text='if')
    context <- my.setSelectionRange(top.context, test.first.line + 4, 1
                                               , expected$row, expected$start)
    expect_identical( adjust.selection(context)[['text']], expected[['text']]
                    , 'multiline selection before the short word')
})

test_that('is.namelegal',
{
    line <- 'abc_012.ABC!@#$%^&*()'
    for (pos in 1:11)
    {
        expect_true(is.namelegal(line, pos))
    }

    for (pos in 12:nchar(line))
    {
        expect_false(is.namelegal(line, pos))
    }
})
