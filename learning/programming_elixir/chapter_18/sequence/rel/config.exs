Path.join(["rel", "plugins", "*.exs"])
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    default_release: :default,
    default_environment: Mix.env()

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"*CFO}>P(Sow(SvM,toMyg<rN;Z5$haUw23GQ`$>X!^.pc[=KZ;~XS7.C!0O)hg%2"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"DbFmLTPtMf$Z~]Ss&AG1AjHl$bp*s_^g(q;fAI3u1_0!D{Eki?z0|28gT7tV]?0;"
end


release :sequence do
  set version: current_version(:sequence)
  set applications: [
    :runtime_tools
  ]
end
