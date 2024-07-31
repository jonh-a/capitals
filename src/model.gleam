pub type Model {
  Model(
    // #(name, capital, flag, population)
    correct: List(#(String, String, String, Float)),
    // #(name, capital, flag, population)
    misspelled: List(#(String, String, String, Float)),
    // #(name, capital, flag, population, guess)
    incorrect: List(#(String, String, String, Float, String)),
    // input string
    current_guess: String,
    // #(name, capital, flag, population)
    countries_remaining: List(#(String, String, String, Float)),
    // whether all questions are answered
    game_over: Bool,
    // whether the input is paused to display correct answer
    paused: PausedType,
    // number of hints used during current question
    hints: Int,
    // number of hints used during game
    total_hints_used: Int,
    // ["americas", "africa" ...]
    continent_filter: List(String),
    // whether to limit questions to >10m
    population_filter: Bool,
    // number of countries initially fetched
    total_number_of_countries: Int,
  )
}

pub type PausedType {
  PausedForWrongAnswer
  PausedForWrongSpelling
  NotPaused
}
