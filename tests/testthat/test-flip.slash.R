context('reversing slashes')

test_that('reveresed slashes', {
    expect_identical(flip('no change'),     'no change')
    expect_identical(flip('/////'),         '\\\\\\\\\\')
    expect_identical(flip('\\\\\\\\\\'),    '/////')
    expect_identical(flip('a/b/c/d'),       'a\\b\\c\\d')
    expect_identical(flip('/a/b/c/d/'),     '\\a\\b\\c\\d\\')
    expect_identical(flip('\t/a\\b/c\\d/'), '\t\\a/b\\c/d\\')
})
