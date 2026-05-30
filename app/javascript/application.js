// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

const themeStorageKey = "geoname-sprint-theme"

function applyTheme(theme) {
  const nextTheme = theme === "light" ? "light" : "dark"
  document.documentElement.dataset.theme = nextTheme

  document.querySelectorAll("[data-theme-toggle]").forEach((button) => {
    button.textContent = nextTheme === "dark" ? "Light" : "Dark"
    button.setAttribute(
      "aria-label",
      `Switch to ${nextTheme === "dark" ? "light" : "dark"} mode`
    )
  })
}

document.addEventListener("turbo:load", () => {
  applyTheme(localStorage.getItem(themeStorageKey))

  document.querySelectorAll("[data-theme-toggle]").forEach((button) => {
    button.addEventListener("click", () => {
      const nextTheme = document.documentElement.dataset.theme === "dark" ? "light" : "dark"
      localStorage.setItem(themeStorageKey, nextTheme)
      applyTheme(nextTheme)
    })
  })
})
