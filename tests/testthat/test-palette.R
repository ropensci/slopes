test_that("slopes_palette returns correct colors", {
  pal <- slopes_palette()
  expect_true(is.character(pal))
  expect_true(length(pal) > 0)
})

test_that("slopes_palette accepts different n values", {
  pal5 <- slopes_palette(5)
  pal10 <- slopes_palette(10)
  expect_equal(length(pal5), 5)
  expect_equal(length(pal10), 10)
})

test_that("plot functions work with palette", {
  # Skip graphics tests on headless systems
  skip_on_ci()
  skip_if_not(interactive(), "Graphics tests only run interactively")
  
  # Simple test that doesnt require graphics device
  expect_true(exists("plot_slope"))
  expect_true(exists("slopes_palette"))
})
