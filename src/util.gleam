import edit_distance/levenshtein
import gleam/int
import gleam/list
import gleam/result
import gleam/string

/// fetch first country from countries_remaining list
pub fn get_current_country(
  countries_remaining: List(#(String, String, String, Float)),
) -> #(String, String, String, Float) {
  countries_remaining
  |> list.first()
  |> result.unwrap(#("", "", "", 0.0))
}

/// check to see if the current country is the last country in the list
pub fn has_next_country(
  countries_remaining: List(#(String, String, String, Float)),
) -> Bool {
  list.length(countries_remaining) > 1
}

/// correct answers are stored without accents/diacritics, so guesses are
/// converted to non-accented form for comparison
pub fn convert_accents(guess: String) -> String {
  guess
  |> string.to_graphemes()
  |> list.reduce(fn(acc, char) {
    case char {
      "á" | "à" | "â" | "å" | "ã" -> acc <> "a"
      "æ" -> acc <> "ae"
      "č" -> acc <> "c"
      "é" | "ë" -> acc <> "e"
      "í" -> acc <> "i"
      "ó" | "ø" | "ö" -> acc <> "o"
      "ș" -> acc <> "s"
      "ž" -> acc <> "z"
      _ -> acc <> char
    }
  })
  |> result.unwrap("")
}

/// exclude hint input (]) and convert all input to lowercase
pub fn normalize_guess(guess) -> String {
  guess
  |> string.lowercase()
  |> string.to_graphemes()
  |> list.filter(fn(char) { char != "]" })
  |> string.join("")
}

pub type AccurateEnoughResponse {
  Exact
  Close
  Nope
}

/// use levenshtein distance to determine if guess was simply misspelled
/// or whether it should be counted as purely wrong
pub fn check_if_accurate_enough(guess, capital) -> AccurateEnoughResponse {
  let distance = levenshtein.distance(guess, capital)
  let threshold =
    { guess |> string.length() |> int.max(capital |> string.length()) } / 3

  case guess == capital, distance <= threshold {
    True, _ -> Exact
    False, True -> Close
    False, False -> Nope
  }
}
