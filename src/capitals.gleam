import gleam/int
import gleam/io
import gleam/list
import gleam/string
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import lustre/ui
import lustre/ui/layout/aside

// MODEL -----------------------------------------------------------------------

pub type Model {
  Model(
    score: Int,
    correct: List(String),
    incorrect: List(String),
    current_country: String,
    current_guess: String,
  )
}

fn init(_flags) -> Model {
  Model(
    score: 0,
    correct: [],
    incorrect: [],
    current_country: "United States",
    current_guess: "",
  )
}

// UPDATE ----------------------------------------------------------------------

pub type Msg {
  Validate
  UserUpdatedGuess(value: String)
}

const countries = [#("United States", "washington, dc"), #("Canada", "ottawa")]

fn validate_country(model: Model) -> Model {
  let country = model.current_country
  let capital = model.current_guess |> string.lowercase()

  let country_found =
    countries
    |> list.find(fn(x) { x.0 == country && x.1 == capital })

  case country_found {
    Ok(_) ->
      Model(
        ..model,
        score: model.score + 1,
        correct: list.append(model.correct, [country]),
        current_country: next_country(list.append(
          model.correct,
          model.incorrect,
        )),
        current_guess: "",
      )
    Error(_) ->
      Model(
        ..model,
        incorrect: list.append(model.incorrect, [country]),
        current_country: next_country(list.append(
          model.correct,
          model.incorrect,
        )),
        current_guess: "",
      )
  }
}

fn next_country(guessed: List(String)) -> String {
  let country_names = list.map(countries, fn(c) { c.0 })
  io.debug(country_names)
  let remaining_countries =
    country_names
    |> list.filter(fn(country) { list.contains(guessed, country) == False })

  case list.first(remaining_countries) {
    Ok(country) -> country
    Error(_) -> "Game Over"
  }
}

pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    Validate -> validate_country(model)
    UserUpdatedGuess(value) -> Model(..model, current_guess: value)
  }
}

// VIEW ------------------------------------------------------------------------

pub fn view(model: Model) -> element.Element(Msg) {
  let score = int.to_string(model.score)
  let styles = [#("width", "100vw"), #("height", "100vh"), #("padding", "1rem")]

  let content =
    element.fragment([
      ui.field(
        [],
        [element.text("Country: " <> model.current_country)],
        ui.input([
          attribute.value(model.current_guess),
          event.on_input(UserUpdatedGuess),
        ]),
        [],
      ),
      ui.button([event.on_click(Validate)], [element.text("Submit")]),
      element.text("Score: " <> score),
      element.text("Correct: " <> string.join(model.correct, ", ")),
      element.text("Incorrect: " <> string.join(model.incorrect, ", ")),
    ])

  ui.centre([attribute.style(styles)], content)
}

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
