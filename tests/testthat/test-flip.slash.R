context('reversing slashes')

source('common.R')

################################################################################
# start of the DO NOT CHANGE section !!! - unless you know what you are doing
# position of the code in this section is referenced in the test methods.
# changes here might break tests!
#
# '\\\\\\\\\\\\'
# 'a/b/c/d/e/f/'
# '            ' -  whitespace
# '            ' -  whitespace
#
# '////////////'
# 'a\b\c\d\e\f\'
# 'from/clip' -  whitespace
# 'from/clip' -  whitespace

#
# end of the DO NOT CHANGE section !!!
################################################################################

test_that('flip', {
    expect_identical(flip('         '),     '         ')
    expect_identical(flip('no change'),     'no change')
    expect_identical(flip('/////'),         '\\\\\\\\\\')
    expect_identical(flip('\\\\\\\\\\'),    '/////')
    expect_identical(flip('a/b/c/d'),       'a\\b\\c\\d')
    expect_identical(flip('/a/b/c/d/'),     '\\a\\b\\c\\d\\')
    expect_identical(flip('\t/a\\b/c\\d/'), '\t\\a/b\\c/d\\')
})

test_that('flip.slash', {
    # skip when clipboard is not supported
    skip_on_os(c('mac', 'linux', 'solaris'))

    # skip when it's not RStudio or it's of a version that doesn't support addins
    skip_if_not(rstudioapi::isAvailable(REQUIRED.RSTUDIO.VERSION), 'RStudio is not available!')

    # backup content of the clipboard
    raw.clip <- readClipboard(raw=T)

    # first line of the testing text
    test.first.line <- 8

    # backup original text
    orig.sel <- rstudioapi::document_range(
                          rstudioapi::document_position(test.first.line,       1)
                        , rstudioapi::document_position(test.first.line + 3, Inf))

    rstudioapi::setSelectionRanges(orig.sel)
    orig <- rstudioapi::primary_selection(rstudioapi::getActiveDocumentContext())$text

    # expected result
    rstudioapi::setSelectionRanges(
        rstudioapi::document_range(
                  rstudioapi::document_position(test.first.line + 5    ,   1)
                , rstudioapi::document_position(test.first.line + 5 + 3, Inf)))
    expected <- rstudioapi::primary_selection(rstudioapi::getActiveDocumentContext())$text

    # create selections
    # can be done by Map(c, Map(c, test.first.line:(test.first.line+3), 4), Map(c, test.first.line:(test.first.line+3), 16))
    # but I prefer to call API
    selections <- list( rstudioapi::document_range(
                              rstudioapi::document_position(test.first.line    ,  4)
                            , rstudioapi::document_position(test.first.line    , 16))
                      , rstudioapi::document_range(
                              rstudioapi::document_position(test.first.line + 1,  4)
                            , rstudioapi::document_position(test.first.line + 1, 16))
                      , rstudioapi::document_range(
                              rstudioapi::document_position(test.first.line + 2,  4)
                            , rstudioapi::document_position(test.first.line + 2, 16))
                      , rstudioapi::document_range(
                              rstudioapi::document_position(test.first.line + 3,  4)
                            , rstudioapi::document_position(test.first.line + 3, 16))
                      )

    writeClipboard('from\\clip', 1)
    rstudioapi::setSelectionRanges(selections)
    flip.slash()
    rstudioapi::setSelectionRanges(orig.sel)
    actual <- rstudioapi::primary_selection(rstudioapi::getActiveDocumentContext())$text

    # restore original content
    rstudioapi::modifyRange(orig.sel, orig)
    # restore original content of the clipboard
    writeClipboard(raw.clip)

    # is it correct?
    expect_identical(expected, actual)
})
