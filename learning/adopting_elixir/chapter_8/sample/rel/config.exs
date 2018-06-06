Path.join(["rel", "plugins", "*.exs"])
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
  default_release: :default,
  default_environment: Mix.env()

environment :dev do
  set(dev_mode: true)
  set(include_erts: false)
  set(cookie: :"@pKWUt2X!E{kHsbf<o%~0]0=&)=k2E($_W.X*Oh^q`5crULVfhZlPq[4v;H.RRX2")
end

environment :prod do
  set(include_erts: true)
  set(include_src: false)
  set(cookie: :"WD4@SpJmc$xqVO<0LrR6&9M^558>$Gzm;SiaX0hVBV/L55Wm_6s9RM$ICjAjM9=n")
end

release :sample do
  set(version: current_version(:sample))
  set(vm_args: "rel/vm.args")

  set(
    applications: [
      runtime_tools: :permanent
      # not_really_important_app: :temporary
    ]
  )
end
