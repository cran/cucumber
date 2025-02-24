## ----include = FALSE----------------------------------------------------------
library(cucumber)
library(testthat)
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)


## ----error = TRUE-------------------------------------------------------------
try({
# tests/testthat/test-bookstore.R
test_that("Bookstore: Adding a book to cart", {
  # Given
  bookstore <- Bookstore$new()
  # When
  bookstore$select("The Hobbit, J.R.R. Tolkien")
  bookstore$add_to_cart()
  # Then
  bookstore$cart_includes("The Hobbit, J.R.R. Tolkien")
})
})


## -----------------------------------------------------------------------------
# tests/testthat/setup-bookstore.R
Bookstore <- R6::R6Class(
  public = list(
    select = function(title) {

    },
    add_to_cart = function() {

    },
    cart_includes = function(title) {

    }
  )
)


## -----------------------------------------------------------------------------
storage <- c()
books <- list(
  tibble::tibble(id = 1, title = "The Hobbit, J.R.R. Tolkien"),
  tibble::tibble(id = 2, title = "The Lord of the Rings, J.R.R. Tolkien")
)

select_book <- function(title) {
  books |>
    purrr::keep(\(x) x$title == title) |>
    purrr::pluck(1)
}

add_to_cart <- function(id) {
  storage <<- c(storage, id)
}

get_cart <- function() {
  books |>
    purrr::keep(\(x) x$id %in% storage)
}


## -----------------------------------------------------------------------------
# tests/testthat/setup-bookstore.R
Bookstore <- R6::R6Class(
  private = list(
    selected_id = NULL
  ),
  public = list(
    select = function(title) {
      private$selected_id <- select_book(title)$id
    },
    add_to_cart = function() {
      add_to_cart(private$selected_id)
    },
    cart_includes = function(title) {
      testthat::expect_in(title, purrr::map_chr(get_cart(), "title"))
    }
  )
)


## -----------------------------------------------------------------------------
# tests/testthat/test-bookstore.R
test_that("Bookstore: Adding a book to cart", {
  # Given
  bookstore <- Bookstore$new()
  # When
  bookstore$select("The Hobbit, J.R.R. Tolkien")
  bookstore$add_to_cart()
  # Then
  bookstore$cart_includes("The Hobbit, J.R.R. Tolkien")
})


## -----------------------------------------------------------------------------
test_that("Bookstore: Adding multiple books to cart", {
  # Given
  bookstore <- Bookstore$new()
  # When
  bookstore$select("The Hobbit, J.R.R. Tolkien")
  bookstore$add_to_cart()
  bookstore$select("The Lord of the Rings, J.R.R. Tolkien")
  bookstore$add_to_cart()
  # Then
  bookstore$cart_includes(c("The Hobbit, J.R.R. Tolkien", "The Lord of the Rings, J.R.R. Tolkien"))
})


## -----------------------------------------------------------------------------
# tests/acceptance/steps/steps.R
given("I am in the bookstore", function(context) {

})

when("I select {string}", function(title, context) {
  context$selected_id <- select_book(title)$id
})

when("I add selected book to the cart", function(context) {
  add_to_cart(context$selected_id)
})

then("I should see {string} in the cart", function(title, context) {
  expect_in(title, purrr::map_chr(get_cart(), "title"))
})


## ----include = FALSE----------------------------------------------------------
cucumber:::run(
  c(
    'Feature: Bookstore',
    '  Scenario: Adding a book to cart',
    '    Given I am in the bookstore',
    '    When I select "The Hobbit, J.R.R. Tolkien"',
    '    When I add selected book to the cart',
    '    Then I should see "The Hobbit, J.R.R. Tolkien" in the cart'
  ),
  steps = cucumber:::get_steps()
)


## ----include = FALSE----------------------------------------------------------
cucumber:::run(
  c(
    'Feature: Bookstore',
    '  Scenario: Adding a book to cart',
    '    Given I am in the bookstore',
    '    When I select "The Hobbit, J.R.R. Tolkien"',
    '    When I add selected book to the cart',
    '    Then I should see "The Hobbit, J.R.R. Tolkien" in the cart',
    '',
    '  Scenario: Adding multiple books to cart',
    '    Given I am in the bookstore',
    '    When I select "The Hobbit, J.R.R. Tolkien"',
    '    When I add selected book to the cart',
    '    When I select "The Lord of the Rings, J.R.R. Tolkien"',
    '    When I add selected book to the cart',
    '    Then I should see "The Hobbit, J.R.R. Tolkien" in the cart',
    '    Then I should see "The Lord of the Rings, J.R.R. Tolkien" in the cart'
  ),
  steps = cucumber:::get_steps()
)

