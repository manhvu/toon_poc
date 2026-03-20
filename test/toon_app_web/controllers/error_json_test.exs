defmodule ToonAppWeb.ErrorJSONTest do
  use ToonAppWeb.ConnCase, async: true

  test "renders 404" do
    assert ToonAppWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert ToonAppWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
