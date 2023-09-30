map(
  select(
    (.artifacts | map(select(has("app"))) | length) == 1 and
    (.artifacts | map(select(has("app"))) | .[0].app | length) == 1 and
    (.artifacts | map(select(has("installer"))) | length) == 0 and
    (.artifacts | map(select(has("pkg"))) | length) == 0 and
    .sha256 != "no_check"
    ))

