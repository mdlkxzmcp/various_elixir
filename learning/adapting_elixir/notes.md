# Notes

## Chapter 3 – Ensuring Code Consistency
See `belief_structure` dir for `mix.exs` example of the following tools:
* `mix credo --strict` / `mix credo _path/_file.ex:_line` -> [linter](https://github.com/rrrene/credo)
* `mix dialyzer` -> [type check](https://github.com/jeremyjh/dialyxir)
* `mix docs` -> [generate documentation](https://github.com/elixir-lang/ex_doc)
* `mix inch` -> [documentation coverage](https://github.com/rrrene/inch_ex)
* `mix coveralls` / `mix coveralls.detail` / `mix coveralls.html` -> [test coverage](https://github.com/parroty/excoveralls)

Those can be added to any project for a greater code consistency, requiring only slight changes in the `mix.exs` file.

---
Other interesting libraries:
* [Bypass](https://github.com/PSPDFKit-labs/bypass) -> running a web API on the same VM as the tests.
* [Mox](https://github.com/plataformatec/mox) -> if *really* needed, an option for mocking.
* [Bureaucrat](https://github.com/api-hogs/bureaucrat) -> Phoenix API documentation! (requires a bit of configuration but well worth it~)

---

---

## Chapter 4 – Legacy Systems and Dependencies
* [terraform](https://github.com/poteto/terraform) -> great library for incrementally replacing a legacy web application.
* `mix hex.outdated` / `mix hex.outdated _package` / `mix hex.audit` -> managing third-party dependencies. 
