import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="quiz"
export default class extends Controller {
  static values = {
    cities: Array,
    cityLookup: Object,
  };

  static targets = ["input", "results", "count"];

  normalize(text) {
    return text
      .trim()
      .toLowerCase()
      .replaceAll("ç", "c")
      .replaceAll("ğ", "g")
      .replaceAll("ı", "i")
      .replaceAll("ö", "o")
      .replaceAll("ş", "s")
      .replaceAll("ü", "u")
      .replace(/[^a-z0-9\s-]/g, "")
      .replace(/\s+/g, " ");
  }

  guess() {
    const rawValue = this.inputTarget.value;
    const value = this.normalize(rawValue);

    if (!this.citiesValue.includes(value)) {
      return;
    }

    if (this.foundCities.includes(value)) {
      return;
    }

    this.foundCities.push(value);
    this.renderFoundCity(this.cityLookupValue[value]);

    this.countTarget.textContent = this.foundCities.length;
    this.inputTarget.value = "";
  }

  renderFoundCity(cityName) {
    const li = document.createElement("li");

    li.textContent = `✓ ${cityName}`;

    this.resultsTarget.appendChild(li);
  }
  connect() {
    this.foundCities = [];
  }
}
