import { Controller } from "@hotwired/stimulus";
import L from "leaflet";

// Connects to data-controller="quiz"
export default class extends Controller {
  static values = {
    cities: Array,
    cityLookup: Object,
    guessLookup: Object,
    cityCoordinates: Object,
  };

  static targets = ["input", "results", "count", "map"];

  normalize(text) {
    return text
      .trim()
      .replaceAll("İ", "i")
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
    const cityKey = this.guessLookupValue[value];

    if (!cityKey) return;

    if (this.foundCities.has(cityKey)) {
      return;
    }

    this.foundCities.add(cityKey);

    this.renderFoundCity(this.cityLookupValue[cityKey]);
    this.addMarker(cityKey);

    this.countTarget.textContent = this.foundCities.size;
    this.inputTarget.value = "";
  }

  renderFoundCity(cityName) {
    const li = document.createElement("li");

    li.textContent = `✓ ${cityName}`;

    this.resultsTarget.appendChild(li);
  }

  addMarker(cityKey) {
    const city = this.cityCoordinatesValue[cityKey];

    if (!city) return;

    L.marker([city.latitude, city.longitude]).addTo(this.map);
  }
  connect() {
    this.foundCities = new Set();

    this.map = L.map(this.mapTarget).setView([39.0, 35.0], 6);

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: "&copy; OpenStreetMap contributors",
    }).addTo(this.map);
  }
}
