import data.{get_countries}
import edit_distance/levenshtein
import gleam/bool
import gleam/int
import gleam/list
import gleam/string
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import lustre/ui

// MODEL -----------------------------------------------------------------------

type Model {
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
  )
}

type PausedType {
  PausedForWrongAnswer
  PausedForWrongSpelling
  NotPaused
}

fn init(flags: #(List(String), Bool)) -> Model {
  let continents = flags.0
  let population_filter = flags.1

  Model(
    correct: [],
    misspelled: [],
    incorrect: [],
    current_guess: "",
    countries_remaining: get_countries(continents, population_filter),
    game_over: False,
    paused: NotPaused,
    hints: 0,
    total_hints_used: 0,
    continent_filter: continents,
    population_filter: population_filter,
  )
}

// UPDATE ----------------------------------------------------------------------

/// fetch first country from countries_remaining list
fn get_current_country(
  countries_remaining: List(#(String, String, String, Float)),
) -> #(String, String, String, Float) {
  let this =
    countries_remaining
    |> list.first()

  case this {
    Ok(this) -> this
    Error(_) -> #("", "", "", 0.0)
  }
}

/// check to see if the current country is the last country in the list
fn has_next_country(
  countries_remaining: List(#(String, String, String, Float)),
) -> Bool {
  list.length(countries_remaining) > 1
}

/// correct answers are stored without accents/diacritics, so guesses are
/// converted to non-accented form for comparison
fn convert_accents(guess: String) -> String {
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
  |> fn(x) {
    case x {
      Ok(chars) -> chars
      Error(_) -> ""
    }
  }
}

/// exclude hint input (]) and convert all input to lowercase
fn normalize_guess(guess) -> String {
  guess
  |> string.lowercase()
  |> string.to_graphemes()
  |> list.filter(fn(char) { char != "]" })
  |> string.join("")
}

type AccurateEnoughResponse {
  Exact
  Close
  Nope
}

/// use levenshtein distance to determine if guess was simply misspelled
/// or whether it should be counted as purely wrong
fn check_if_accurate_enough(guess, capital) -> AccurateEnoughResponse {
  let distance = levenshtein.distance(guess, capital)
  let threshold =
    { guess |> string.length() |> int.max(capital |> string.length()) } / 3

  case guess == capital, distance <= threshold {
    True, _ -> Exact
    False, True -> Close
    False, False -> Nope
  }
}

/// main handler for "guess"/"resume" button. if game is paused, then resume
/// and proceed to next question. if the game isn't paused, handle input as
/// submission.
fn handle_button_click(model: Model) -> Model {
  let capital_guess = model.current_guess |> normalize_guess()
  let current_country = get_current_country(model.countries_remaining)
  let guess_response =
    check_if_accurate_enough(convert_accents(capital_guess), current_country.1)
  let is_game_over = has_next_country(model.countries_remaining) == False

  let updated_model = Model(..model, current_guess: "", game_over: is_game_over)

  case model.paused, is_game_over, guess_response {
    PausedForWrongAnswer, False, _ | PausedForWrongSpelling, False, _ ->
      Model(
        ..updated_model,
        countries_remaining: model.countries_remaining |> list.drop(1),
        paused: NotPaused,
        hints: 0,
      )

    PausedForWrongAnswer, True, _ | PausedForWrongSpelling, True, _ ->
      Model(..model, paused: NotPaused)

    NotPaused, True, Exact ->
      Model(
        ..updated_model,
        correct: list.append(model.correct, [current_country]),
        countries_remaining: [],
        hints: 0,
      )

    NotPaused, True, Close ->
      Model(
        ..updated_model,
        misspelled: list.append(model.misspelled, [current_country]),
        countries_remaining: [],
        hints: 0,
        paused: PausedForWrongSpelling,
      )

    NotPaused, True, Nope ->
      Model(
        ..updated_model,
        incorrect: list.append(model.incorrect, [
          #(
            current_country.0,
            current_country.1,
            current_country.2,
            current_country.3,
            capital_guess,
          ),
        ]),
        paused: PausedForWrongAnswer,
      )

    NotPaused, False, Exact ->
      Model(
        ..updated_model,
        correct: list.append(model.correct, [current_country]),
        countries_remaining: model.countries_remaining |> list.drop(1),
        hints: 0,
      )

    NotPaused, False, Close ->
      Model(
        ..updated_model,
        misspelled: list.append(model.misspelled, [current_country]),
        countries_remaining: model.countries_remaining,
        hints: 0,
        paused: PausedForWrongSpelling,
      )

    NotPaused, False, Nope ->
      Model(
        ..updated_model,
        incorrect: list.append(model.incorrect, [
          #(
            current_country.0,
            current_country.1,
            current_country.2,
            current_country.3,
            capital_guess,
          ),
        ]),
        paused: PausedForWrongAnswer,
      )
  }
}

/// allow a max of 2 hints per question
fn provide_hint(model: Model) -> Model {
  case model.hints {
    0 | 1 ->
      Model(
        ..model,
        hints: model.hints + 1,
        current_guess: get_current_country(model.countries_remaining).1
          |> string.to_graphemes()
          |> list.take(model.hints + 1)
          |> string.join(""),
        total_hints_used: model.total_hints_used + 1,
      )

    2 | _ -> model
  }
}

/// if game is paused, allow enter w/ empty input to proceed
/// to handle_button_click function. otherwise, ignore enter
/// attempts with no input
fn handle_key_press(key: String, model: Model) -> Model {
  case key, model.current_guess |> string.length, model.paused {
    "Enter", 0, NotPaused -> model
    "Enter", _, _ -> handle_button_click(model)
    "]", _, _ -> provide_hint(model)
    _, 0, NotPaused -> model
    _, _, _ -> model
  }
}

/// reset game with selected preferences
fn replay(model: Model) -> Model {
  init(#(model.continent_filter, model.population_filter))
}

/// handle checkbox input for a continent
fn check_continent(checked: Bool, continent: String, model: Model) -> Model {
  case checked {
    True ->
      init(#([continent, ..model.continent_filter], model.population_filter))
    False ->
      init(#(
        list.filter(model.continent_filter, fn(x: String) { x != continent }),
        model.population_filter,
      ))
  }
}

fn check_population_filter(checked: Bool, model: Model) -> Model {
  init(#(model.continent_filter, checked))
}

pub type Msg {
  Validate
  UserUpdatedGuess(value: String)
  UserKeyPress(key: String)
  Hint
  Replay
  CheckContinent(checked: Bool, continent: String)
  CheckPopulationFilter(checked: Bool)
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    Validate -> handle_button_click(model)
    UserUpdatedGuess(value) ->
      Model(..model, current_guess: value |> normalize_guess())
    UserKeyPress(key) -> handle_key_press(key, model)
    CheckContinent(checked, continent) ->
      check_continent(checked, continent, model)
    Hint -> provide_hint(model)
    Replay -> replay(model)
    CheckPopulationFilter(checked) -> check_population_filter(checked, model)
  }
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  let main_styles = [#("height", "90vh"), #("padding", "1rem")]

  case model.game_over, model.paused {
    True, _ ->
      ui.centre([attribute.style(main_styles)], game_over_screen(model))

    _, _ -> ui.centre([attribute.style(main_styles)], quiz_input(model))
  }
}

fn quiz_input(model: Model) -> Element(Msg) {
  let g = "green"
  let r = "red"
  let y = "rgb(222, 201, 0)"
  let guess_button_style = [#("width", "100%"), #("margin-top", "1em")]
  let hint_button_style = [#("width", "100%"), #("margin-top", ".2em")]
  let current_country = get_current_country(model.countries_remaining)
  let hint_button_text = case model.hints {
    0 | 1 -> "hint (])"
    2 | _ -> "no more"
  }
  let #(header_text, input_text, input_background, button_text) = case
    model.paused,
    list.length(model.continent_filter)
  {
    _, 0 -> #("select continent(s)", "...", "none", "n/a")
    PausedForWrongAnswer, _ -> #(
      current_country.0 <> " " <> current_country.2,
      current_country.1,
      "rgb(250, 160, 160)",
      "resume",
    )
    PausedForWrongSpelling, _ -> #(
      current_country.0 <> " " <> current_country.2,
      current_country.1,
      "rgb(255, 255, 102)",
      "resume",
    )
    NotPaused, _ -> #(
      current_country.0 <> " " <> current_country.2,
      model.current_guess,
      "none",
      "guess (enter)",
    )
  }

  html.div([attribute.style([#("min-width", "40%"), #("max-width", "90%")])], [
    ui.centre(
      [attribute.style([#("margin-bottom", "1em")])],
      html.h1([], [
        element.text(
          list.length(model.correct)
          + list.length(model.misspelled)
          + list.length(model.incorrect)
          + 1
          |> int.to_string()
          <> case model.continent_filter {
            ["oceania"] -> "/14"
            [] -> "/?"
            _ -> "/15"
          },
        ),
      ]),
    ),
    html.div(
      [
        attribute.style([
          #("padding-bottom", "1em"),
          #("display", "flex"),
          #("flex-wrap", "wrap"),
          #("justify-content", "center"),
        ]),
      ],
      ["americas", "europe", "africa", "asia", "oceania"]
        |> list.map(fn(c: String) {
          html.div([attribute.style([#("padding", "0em .5em 0em")])], [
            ui.input([
              attribute.type_("checkbox"),
              attribute.id(c),
              attribute.checked(list.contains(model.continent_filter, c)),
              event.on_check(fn(checked: Bool) { CheckContinent(checked, c) }),
            ]),
            html.label(
              [attribute.for(c), attribute.style([#("padding-left", ".2em")])],
              [element.text(c)],
            ),
          ])
        }),
    ),
    html.hr([
      attribute.style([
        #("color", "gray"),
        #("width", "70%"),
        #("margin-left", "auto"),
        #("margin-right", "auto"),
        #("padding-bottom", "1em"),
      ]),
    ]),
    html.div(
      [
        attribute.style([
          #("padding-bottom", "1em"),
          #("display", "flex"),
          #("flex-wrap", "wrap"),
          #("justify-content", "center"),
        ]),
      ],
      [
        ui.input([
          attribute.type_("checkbox"),
          attribute.id("population_filter"),
          attribute.checked(model.population_filter),
          event.on_check(CheckPopulationFilter),
        ]),
        html.label(
          [
            attribute.for("population_filter"),
            attribute.style([#("padding-left", ".2em")]),
          ],
          [element.text("population of >10m only")],
        ),
      ],
    ),
    ui.field(
      [],
      [element.text(header_text)],
      ui.input([
        attribute.value(input_text),
        attribute.placeholder("guess the capital..."),
        event.on_input(UserUpdatedGuess),
        event.on_keypress(UserKeyPress),
        attribute.style([#("background-color", input_background)]),
      ]),
      [],
    ),
    ui.button(
      [
        event.on_click(Validate),
        attribute.style(guess_button_style),
        attribute.disabled(bool.and(
          string.length(model.current_guess) == 0,
          model.paused == NotPaused,
        )),
      ],
      [element.text(button_text)],
    ),
    ui.button(
      [
        event.on_click(Hint),
        attribute.style(hint_button_style),
        attribute.disabled(
          model.paused == PausedForWrongSpelling
          || model.paused == PausedForWrongAnswer
          || model.continent_filter |> list.length() == 0,
        ),
      ],
      [element.text(hint_button_text)],
    ),
    ui.centre(
      [],
      html.div([attribute.style([#("padding", "1em")])], [
        html.span([attribute.style([#("margin", "1em"), #("color", g)])], [
          model.correct
          |> list.length()
          |> int.to_string()
          |> element.text(),
        ]),
        html.span([attribute.style([#("margin", "1em"), #("color", y)])], [
          model.misspelled
          |> list.length()
          |> int.to_string()
          |> element.text(),
        ]),
        html.span([attribute.style([#("margin", "1em"), #("color", r)])], [
          model.incorrect
          |> list.length()
          |> int.to_string()
          |> element.text(),
        ]),
      ]),
    ),
  ])
}

fn game_over_screen(model: Model) -> Element(Msg) {
  let correct = model.correct |> list.length() |> int.to_string()
  let incorrect = model.incorrect |> list.length() |> int.to_string()
  let misspelled = model.misspelled |> list.length() |> int.to_string()
  let hints_used = model.total_hints_used |> int.to_string()

  html.div([], [
    html.div([], [
      html.h1([], [
        element.text(
          "right: "
          <> correct
          <> ", misspelled: "
          <> misspelled
          <> ", wrong: "
          <> incorrect,
        ),
      ]),
      html.h1([], [element.text("hints used: " <> hints_used)]),
      ..incorrect_capitals_list(model)
    ]),
    ui.button(
      [
        attribute.style([#("width", "100%"), #("margin-top", "1em")]),
        event.on_click(Replay),
      ],
      [element.text("replay")],
    ),
  ])
}

fn incorrect_guess_result(
  country: #(String, String, String, Float, String),
) -> List(Element(a)) {
  [
    html.span([], [
      element.text(
        "❌ " <> country.0 <> " - " <> country.1 <> "... you guessed \"",
      ),
    ]),
    html.span([attribute.style([#("color", "red")])], [element.text(country.4)]),
    html.span([], [element.text("\"")]),
  ]
}

fn incorrect_capitals_list(model: Model) -> List(Element(Msg)) {
  case list.length(model.incorrect) {
    0 -> [html.h1([], [element.text("you didn't miss any!")])]
    _ -> [
      html.br([]),
      html.h1([], [element.text("you got these wrong: ")]),
      html.ul(
        [],
        model.incorrect
          |> list.map(fn(country: #(String, String, String, Float, String)) {
            html.li([], incorrect_guess_result(country))
          }),
      ),
    ]
  }
}

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) =
    lustre.start(app, "#app", #(
      ["americas", "europe", "africa", "asia", "oceania"],
      False,
    ))

  Nil
}
