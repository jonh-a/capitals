import data.{get_countries}
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

pub type Model {
  Model(
    score: Int,
    // #(name, capital, flag)
    correct: List(#(String, String, String)),
    // #(name, capital, flag, guess)
    incorrect: List(#(String, String, String, String)),
    current_guess: String,
    // #(name, capital, flag)
    countries_remaining: List(#(String, String, String)),
    game_over: Bool,
    paused: Bool,
    hints: Int,
  )
}

fn init(_flags) -> Model {
  Model(
    score: 0,
    correct: [],
    incorrect: [],
    current_guess: "",
    countries_remaining: get_countries(),
    game_over: False,
    paused: False,
    hints: 0,
  )
}

// UPDATE ----------------------------------------------------------------------

pub type Msg {
  Validate
  UserUpdatedGuess(value: String)
  UserKeyPress(key: String)
  Hint
}

// fetch first country from countries_remaining list
fn get_current_country(
  countries_remaining: List(#(String, String, String)),
) -> #(String, String, String) {
  let this =
    countries_remaining
    |> list.first()

  case this {
    Ok(this) -> this
    Error(_) -> #("", "", "")
  }
}

// check to see if the current country is the last country in the list
fn has_next_country(
  countries_remaining: List(#(String, String, String)),
) -> Bool {
  let next =
    countries_remaining
    |> list.drop(1)
    |> list.first()

  case next {
    Ok(_) -> True
    Error(_) -> False
  }
}

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

fn normalize_guess(guess) -> String {
  guess
  |> string.lowercase()
  |> string.to_graphemes()
  |> list.filter(fn(char) { char != "]" })
  |> string.join("")
}

/// resume game if paused or compare guess against correct capital
fn handle_button_click(model: Model) -> Model {
  let capital_guess = model.current_guess |> normalize_guess()
  let current_country = get_current_country(model.countries_remaining)
  let guess_was_correct = convert_accents(capital_guess) == current_country.1
  let is_game_over = has_next_country(model.countries_remaining) == False

  let updated_model = Model(..model, current_guess: "", game_over: is_game_over)

  case model.paused, is_game_over, guess_was_correct {
    True, False, _ ->
      Model(
        ..model,
        countries_remaining: model.countries_remaining |> list.drop(1),
        paused: False,
      )

    True, True, _ -> Model(..model, paused: False)

    False, True, True ->
      Model(
        ..updated_model,
        score: model.score + 1,
        correct: list.append(model.correct, [current_country]),
        countries_remaining: [],
      )

    False, True, False ->
      Model(
        ..updated_model,
        incorrect: list.append(model.incorrect, [
          #(
            current_country.0,
            current_country.1,
            current_country.2,
            capital_guess,
          ),
        ]),
        paused: True,
      )

    False, False, True ->
      Model(
        ..updated_model,
        score: model.score + 1,
        correct: list.append(model.correct, [current_country]),
        countries_remaining: model.countries_remaining |> list.drop(1),
      )

    False, False, False ->
      Model(
        ..updated_model,
        incorrect: list.append(model.incorrect, [
          #(
            current_country.0,
            current_country.1,
            current_country.2,
            capital_guess,
          ),
        ]),
        paused: True,
      )
  }
}

fn get_hint(capital: String, hints: Int) -> String {
  capital
  |> string.to_graphemes()
  |> list.take(hints + 1)
  |> string.join("")
}

fn provide_hint(model: Model) -> Model {
  Model(
    ..model,
    hints: model.hints + 1,
    current_guess: get_current_country(model.countries_remaining).1
      |> get_hint(model.hints),
  )
}

/// if game is paused, allow enter w/ empty input to proceed
/// to handle_button_click function. otherwise, ignore enter
/// attempts with no input
fn handle_key_press(key: String, model: Model) -> Model {
  case key, model.current_guess |> string.length, model.paused {
    "Enter", 0, False -> model
    "Enter", _, _ -> handle_button_click(model)
    "]", _, _ -> provide_hint(model)
    _, 0, False -> model
    _, _, _ -> model
  }
}

pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    Validate -> handle_button_click(model)
    UserUpdatedGuess(value) ->
      Model(..model, current_guess: value |> normalize_guess())
    UserKeyPress(key) -> handle_key_press(key, model)
    Hint -> provide_hint(model)
  }
}

// VIEW ------------------------------------------------------------------------

pub fn view(model: Model) -> Element(Msg) {
  let main_styles = [
    #("width", "100vw"),
    #("height", "100vh"),
    #("padding", "1rem"),
  ]
  let score = model.correct |> list.length() |> int.to_string()

  case model.game_over, model.paused {
    True, _ ->
      ui.centre(
        [attribute.style(main_styles)],
        html.div([], [
          html.h1([], [element.text("game over! score: " <> score)]),
          ..missed_table(model)
        ]),
      )
    _, _ -> ui.centre([attribute.style(main_styles)], quiz_input(model))
  }
}

fn quiz_input(model: Model) -> Element(Msg) {
  let button_style = [#("width", "100%"), #("margin-top", "1em")]
  let current_country = get_current_country(model.countries_remaining)
  let hint_button_text = case model.hints {
    0 | 1 -> "hint (])"
    2 | _ -> "no more hints"
  }
  let #(input_text, input_background, button_text) = case model.paused {
    True -> #(current_country.1, "rgb(250, 160, 160)", "resume (enter)")
    False -> #(model.current_guess, "none", "guess (enter)")
  }

  html.div([], [
    ui.centre(
      [attribute.style([#("margin-bottom", "1em")])],
      html.h1([], [
        element.text(
          list.length(model.correct) + list.length(model.incorrect) + 1
          |> int.to_string()
          <> "/10",
        ),
      ]),
    ),
    ui.field(
      [],
      [element.text(current_country.0 <> " " <> current_country.2)],
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
        attribute.style(button_style),
        attribute.disabled(bool.and(
          string.length(model.current_guess) == 0,
          !model.paused,
        )),
      ],
      [element.text(button_text)],
    ),
    ui.button(
      [
        event.on_click(Hint),
        attribute.style(button_style),
        attribute.disabled(bool.or(
          string.length(model.current_guess) != 0,
          model.paused,
        )),
      ],
      [element.text(hint_button_text)],
    ),
    ui.centre(
      [],
      html.div([attribute.style([#("padding", "1em")])], [
        html.span([attribute.style([#("margin", "1em"), #("color", "green")])], [
          model.score
          |> int.to_string()
          |> element.text(),
        ]),
        html.span([attribute.style([#("margin", "1em"), #("color", "red")])], [
          model.incorrect
          |> list.length()
          |> int.to_string()
          |> element.text(),
        ]),
      ]),
    ),
  ])
}

fn incorrect_guess_result(
  country: #(String, String, String, String),
) -> List(Element(a)) {
  [
    html.span([], [
      element.text(
        "❌ " <> country.0 <> " - " <> country.1 <> "... you guessed \"",
      ),
    ]),
    html.span([attribute.style([#("color", "red")])], [element.text(country.3)]),
    html.span([], [element.text("\"")]),
  ]
}

fn missed_table(model: Model) -> List(Element(Msg)) {
  case list.length(model.incorrect) {
    0 -> [html.h1([], [element.text("you didn't miss any!")])]
    _ -> [
      html.br([]),
      html.h1([], [element.text("you got these wrong: ")]),
      html.ul(
        [],
        model.incorrect
          |> list.map(fn(country: #(String, String, String, String)) {
            html.li([], incorrect_guess_result(country))
          }),
      ),
    ]
  }
}

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
