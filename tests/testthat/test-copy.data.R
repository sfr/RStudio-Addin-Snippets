context('Copy data to clipboard')

source('common.R')

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
    expected <- list(name=name, type='vector', value=get0(name, envir=.GlobalEnv), supported=T)
    rm(vec, envir=.GlobalEnv)
    expect_identical(actual, expected)

    assign(name, letters[1:5], envir=.GlobalEnv)
    actual <- detect.type(name)
    expected <- list(name=name, type='vector', value=get0(name, envir=.GlobalEnv), supported=T)
    rm(vec, envir=.GlobalEnv)
    expect_identical(actual, expected)

    assign('vec', matrix(1:10, nrow=2), envir=.GlobalEnv)
    actual <- detect.type(name)
    expected <- list(name=name, type='matrix', value=get0(name, envir=.GlobalEnv), supported=T)
    rm(vec, envir=.GlobalEnv)
    expect_identical(actual, expected)

    assign('vec', data.frame(1:10), envir=.GlobalEnv)
    actual <- detect.type(name)
    expected <- list(name=name, type='data.frame', value=get0(name, envir=.GlobalEnv), supported=T)
    rm(vec, envir=.GlobalEnv)
    expect_identical(actual, expected)

    assign('vec', array(1:10), envir=.GlobalEnv)
    actual <- detect.type(name)
    expected <- list(name=name, type='array', value=get0(name, envir=.GlobalEnv), supported=T)
    rm(vec, envir=.GlobalEnv)
    expect_identical(actual, expected)
})

test_that('get.tsv',
{
    # vector
    expect_identical( get.tsv(list(type='vector', value=1:3))
                    , '1\t2\t3')

    # matrix
    expect_identical( get.tsv(list(type='matrix', value=matrix(1:12, nrow=3, byrow=T)))
                    , '1\t2\t3\t4\n5\t6\t7\t8\n9\t10\t11\t12')

    # data frame
    expect_identical( get.tsv(list(type='data.frame', value=data.frame(a=1:3, b=letters[10:12], c=seq(as.Date('2004-01-01'), by='week', len=3), stringsAsFactors=T)))
                    , 'a\tb\tc\n1\tj\t2004-01-01\n2\tk\t2004-01-08\n3\tl\t2004-01-15')

    # array
    expect_identical(get.tsv(list(type='array', value=array(1:12, dim=c(3, 4), dimnames=list(x=c('a', 'b', 'c'), y=c('k', 'l', 'm', 'm')))))
                    , 'x\\y\tk\tl\tm\tm\na\t1\t4\t7\t10\nb\t2\t5\t8\t11\nc\t3\t6\t9\t12')
})

test_that('get.tsv.vector',
{
    expect_identical(get.tsv.vector(), '')

    vec <- 1:3
    expect_identical(get.tsv.vector(list(value=vec)), '1\t2\t3')

    names(vec) <- letters[1:3]
    expect_identical(get.tsv.vector(list(value=vec)), 'a\tb\tc\n1\t2\t3')

    vec <- c(vec, 4)
    expect_identical(get.tsv.vector(list(value=vec)), 'a\tb\tc\t\n1\t2\t3\t4')

    vec <- c(vec, NA)
    expect_identical(get.tsv.vector(list(value=vec)), 'a\tb\tc\t\t\n1\t2\t3\t4\tNA')
})

test_that('get.tsv.matrix',
{
    expect_identical(get.tsv.matrix(), '')

    mat <- matrix(1:12, nrow=3, byrow=T)
    expect_identical(get.tsv.matrix(list(name='mat', value=mat)), '1\t2\t3\t4\n5\t6\t7\t8\n9\t10\t11\t12')

    dimnames(mat) <- list(letters[1:3])
    expect_identical(get.tsv.matrix(list(name='mat', value=mat)), 'a\t1\t2\t3\t4\nb\t5\t6\t7\t8\nc\t9\t10\t11\t12')

    dimnames(mat) <- list(let=letters[1:3])
    expect_identical(get.tsv.matrix(list(name='mat', value=mat)), 'a\t1\t2\t3\t4\nb\t5\t6\t7\t8\nc\t9\t10\t11\t12')

    dimnames(mat) <- list(NULL, month.abb[1:4])
    expect_identical(get.tsv.matrix(list(name='mat', value=mat)), 'Jan\tFeb\tMar\tApr\n1\t2\t3\t4\n5\t6\t7\t8\n9\t10\t11\t12')

    dimnames(mat) <- list(NULL, months=month.abb[1:4])
    expect_identical(get.tsv.matrix(list(name='mat', value=mat)), 'Jan\tFeb\tMar\tApr\n1\t2\t3\t4\n5\t6\t7\t8\n9\t10\t11\t12')

    dimnames(mat) <- list(letters[1:3], month.abb[1:4])
    expect_identical(get.tsv.matrix(list(name='mat', value=mat)), 'mat\tJan\tFeb\tMar\tApr\na\t1\t2\t3\t4\nb\t5\t6\t7\t8\nc\t9\t10\t11\t12')

    dimnames(mat) <- list(let=letters[1:3], month.abb[1:4])
    expect_identical(get.tsv.matrix(list(name='mat', value=mat)), 'let\\\tJan\tFeb\tMar\tApr\na\t1\t2\t3\t4\nb\t5\t6\t7\t8\nc\t9\t10\t11\t12')

    dimnames(mat) <- list(letters[1:3], months=month.abb[1:4])
    expect_identical(get.tsv.matrix(list(name='mat', value=mat)), '\\months\tJan\tFeb\tMar\tApr\na\t1\t2\t3\t4\nb\t5\t6\t7\t8\nc\t9\t10\t11\t12')

    dimnames(mat) <- list(let=letters[1:3], months=month.abb[1:4])
    expect_identical(get.tsv.matrix(list(name='mat', value=mat)), 'let\\months\tJan\tFeb\tMar\tApr\na\t1\t2\t3\t4\nb\t5\t6\t7\t8\nc\t9\t10\t11\t12')
})

test_that('get.tsv.data.frame',
{
    expect_identical(get.tsv.data.frame(), '')

    df <- data.frame( a=1:3
                    , b=letters[10:12]
                    , c=seq(as.Date('2004-01-01'), by='week', len=3)
                    , stringsAsFactors=T)

    expect_identical(get.tsv.data.frame(list(name='df', value=df)), 'a\tb\tc\n1\tj\t2004-01-01\n2\tk\t2004-01-08\n3\tl\t2004-01-15')

    row.names(df) <- c('first', 'second', 'third')
    expect_identical(get.tsv.data.frame(list(name='df', value=df)), 'df\ta\tb\tc\nfirst\t1\tj\t2004-01-01\nsecond\t2\tk\t2004-01-08\nthird\t3\tl\t2004-01-15')
})

test_that('get.tsv.array',
{
    expect_identical(get.tsv.array(), '')

    arr <- array(1:3)
    expect_identical(get.tsv.array(list(name='arr', value=arr)), '1\t2\t3')

    dimnames(arr) <- list(x=c('a', 'b', 'c'))
    expect_identical(get.tsv.array(list(name='arr', value=arr)), 'a\tb\tc\n1\t2\t3')

    arr <- array(1:12, dim=c(3, 4))
    expect_identical(get.tsv.array(list(name='arr', value=arr)), '1\t4\t7\t10\n2\t5\t8\t11\n3\t6\t9\t12')

    arr <- array(1:12, dim=c(3, 4), dimnames=list(x=c('a', 'b', 'c'), y=c('k', 'l', 'm', 'n')))
    expect_identical(get.tsv.array(list(name='arr', value=arr)), 'x\\y\tk\tl\tm\tn\na\t1\t4\t7\t10\nb\t2\t5\t8\t11\nc\t3\t6\t9\t12')

    # array with dimension names - one of them is missing
    arr <- array(1:24, dim=c(3, 4, 2), dimnames=list(x=c('a', 'b', 'c'), c('k', 'l', 'm', 'n'), z=c('x', 'y')))
    expect_identical(get.tsv.array(list(name='arr', value=arr)), 'x\t\tz\tarr\na\tk\tx\t 1\nb\tk\tx\t 2\nc\tk\tx\t 3\na\tl\tx\t 4\nb\tl\tx\t 5\nc\tl\tx\t 6\na\tm\tx\t 7\nb\tm\tx\t 8\nc\tm\tx\t 9\na\tn\tx\t10\nb\tn\tx\t11\nc\tn\tx\t12\na\tk\ty\t13\nb\tk\ty\t14\nc\tk\ty\t15\na\tl\ty\t16\nb\tl\ty\t17\nc\tl\ty\t18\na\tm\ty\t19\nb\tm\ty\t20\nc\tm\ty\t21\na\tn\ty\t22\nb\tn\ty\t23\nc\tn\ty\t24')

    # array with no dimension names
    arr <- array(1:24, dim=c(3, 4, 2), dimnames=list(c('a', 'b', 'c'), c('k', 'l', 'm', 'n'), c('x', 'y')))
    expect_identical(get.tsv.array(list(name='arr', value=arr)), 'a\tk\tx\t 1\nb\tk\tx\t 2\nc\tk\tx\t 3\na\tl\tx\t 4\nb\tl\tx\t 5\nc\tl\tx\t 6\na\tm\tx\t 7\nb\tm\tx\t 8\nc\tm\tx\t 9\na\tn\tx\t10\nb\tn\tx\t11\nc\tn\tx\t12\na\tk\ty\t13\nb\tk\ty\t14\nc\tk\ty\t15\na\tl\ty\t16\nb\tl\ty\t17\nc\tl\ty\t18\na\tm\ty\t19\nb\tm\ty\t20\nc\tm\ty\t21\na\tn\ty\t22\nb\tn\ty\t23\nc\tn\ty\t24')

    # array with no names at all
    arr <- array(1:24, dim=c(3, 4, 2))
    expect_identical(get.tsv.array(list(name='arr', value=arr)), 'A\tA\tA\t 1\nB\tA\tA\t 2\nC\tA\tA\t 3\nA\tB\tA\t 4\nB\tB\tA\t 5\nC\tB\tA\t 6\nA\tC\tA\t 7\nB\tC\tA\t 8\nC\tC\tA\t 9\nA\tD\tA\t10\nB\tD\tA\t11\nC\tD\tA\t12\nA\tA\tB\t13\nB\tA\tB\t14\nC\tA\tB\t15\nA\tB\tB\t16\nB\tB\tB\t17\nC\tB\tB\t18\nA\tC\tB\t19\nB\tC\tB\t20\nC\tC\tB\t21\nA\tD\tB\t22\nB\tD\tB\t23\nC\tD\tB\t24')
})


test_that('copy.to.clipboard',
{
    expect_false(copy.to.clipboard(NULL))

    # skip when clipboard is not supported
    skip_on_os(c('mac', 'linux', 'solaris'))

    # skip when it's not RStudio or it's of a version that doesn't support addins
    skip_if_not(rstudioapi::isAvailable(REQUIRED.RSTUDIO.VERSION), 'RStudio is not available!')

    tsv <- '1\t2\t3\t'
    expect_true(copy.to.clipboard(tsv))
    expect_identical(getClipboardFormats(T)[1], 1L)
    expect_identical(readClipboard(1), tsv)
})

test_that('get.error.message',
{
    expect_identical(get.error.message(list(type=NULL)),     'Nothing was copied to the clipboard - variable does not exist.')
    expect_identical(get.error.message(list(type='vector')), 'Nothing was copied to the clipboard - variable type is not supported.')

    # skip when clipboard is not supported
    skip_on_os(c('mac', 'linux', 'solaris'))

    # skip when it's not RStudio or it's of a version that doesn't support addins
    skip_if_not(rstudioapi::isAvailable(REQUIRED.RSTUDIO.VERSION), 'RStudio is not available!')

    tsv <- '1\t2\t3\t'
    expect_true(copy.to.clipboard(tsv))
    expect_identical(getClipboardFormats(T)[1], 1L)
    expect_identical(readClipboard(1), tsv)
})

test_that('adjust.selection',
{
    load('.foobar.Rdata')

    #' @title Generate tests
    place.in.word <- function(expected, info)
    {
        # first char
        context <- my.setCursorPosition(top.context, c(row=expected$row, column=expected$start))
        expect_identical( adjust.selection(context)[['text']], expected[['text']]
                        , paste0(info, ': cursor at the first character'))

        # last char
        context <- my.setCursorPosition(top.context, c(row=expected$row, column=expected$end))
        expect_identical( adjust.selection(context)[['text']], expected[['text']]
                        , paste0(info, ': cursor after the last character'))

        # in the middle
        if (nchar(expected$text) > 1) {
            context <- my.setCursorPosition(top.context, c(row=expected$row, column=expected$start + 1))
            expect_identical( adjust.selection(context)[['text']], expected[['text']]
                            , paste0(info, ': cursor in the middle of the word'))
        }

        # subselection
        if (nchar(expected$text) > 2) {
            context <- my.setSelectionRange(top.context, c( expected$row, expected$start + 1
                                                          , expected$row, expected$end   - 1))
            expect_identical( adjust.selection(context)[['text']], expected[['text']]
                            , paste0(info, ': selection inside the word'))
        }

        # selection from the start of the word till the end of line
        context <- my.setSelectionRange(top.context, c( expected$row, expected$start
                                                      , expected$row, Inf))
        expect_identical( adjust.selection(context)[['text']], expected[['text']]
                        , paste0(info, ': selection from the start of the word till the end of line'))

        # selection from the start of the word till the end of file
        context <- my.setSelectionRange(top.context, c( expected$row, expected$start
                                                      , Inf, Inf ))
        expect_identical( adjust.selection(context)[['text']], expected[['text']]
                        , paste0(info, ': selection from the start of the word till the end of file'))

        if (nchar(expected$text) > 1) {
            # selection from middle of the word till the end of line
            context <- my.setSelectionRange(top.context, c( expected$row, expected$start + 1
                                                          , expected$row, Inf))
            expect_identical( adjust.selection(context)[['text']], expected[['text']]
                            , paste0(info, ': selection from the middle of the word till the end of line'))

            # selection from the middle of the word till the end of file
            context <- my.setSelectionRange(top.context, c( expected$row, expected$start + 1
                                                          , Inf, Inf))
            expect_identical( adjust.selection(context)[['text']], expected[['text']]
                            , paste0(info, ': selection from the middle of the word till the end of file'))
        }

        # selection from the end of the word till the end of line
        context <- my.setSelectionRange(top.context, c( expected$row, expected$end
                                                      , expected$row, Inf))
        expect_identical( adjust.selection(context)[['text']], expected[['text']]
                        , paste0(info, ': selection from the end of the word till the end of line'))

        # selection from the end of the word till the end of file
        context <- my.setSelectionRange(top.context, c( expected$row, expected$end
                                                      , Inf, Inf))
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
    context <- my.setSelectionRange(top.context, c( test.first.line + 1, 32
                                                  , expected$row, expected$start))
    expect_identical( adjust.selection(context)[['text']], expected[['text']]
                    , 'multiline selection before the short word')

    # multiline selection before the longer word
    expected <- list(row=test.first.line + 5, start=5, end=7, text='if')
    context <- my.setSelectionRange(top.context, c( test.first.line + 4, 1
                                                  , expected$row, expected$start))
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
