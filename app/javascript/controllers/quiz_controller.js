import { Controller } from "@hotwired/stimulus";
import L from "leaflet";

// Connects to data-controller="quiz"
export default class extends Controller {
  static values = {
    cities: Array,
    cityLookup: Object,
    guessLookup: Object,
    cityCoordinates: Object,
    duration: Number,
    cityCount: Number,
    mapCenter: Array,
    mapZoom: Number,
  };

  static targets = ["input", "results", "count", "map", "timer"];

  normalize(text) {
    return text
      .trim()
      .toLowerCase()
      .replaceAll("İ", "i")
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

    if (this.foundCities.size === this.cityCountValue) {
      this.finishQuiz("complete");
      return;
    }

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

  initializeMap() {
    this.map = L.map(this.mapTarget).setView(
      this.mapCenterValue,
      this.mapZoomValue,
    );

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: "&copy; OpenStreetMap contributors",
    }).addTo(this.map);
  }

  renderTimer() {
    if (!this.hasTimerTarget) return;

    const minutes = Math.floor(this.remainingSeconds / 60);
    const seconds = this.remainingSeconds % 60;

    this.timerTarget.textContent = `${String(minutes).padStart(2, "0")}:${String(seconds).padStart(2, "0")}`;
  }

  finishQuiz(reason = "time") {
    if (this.finished) return;

    this.finished = true;
    clearInterval(this.timerInterval);
    this.inputTarget.disabled = true;

    if (reason === "complete") {
      alert(`Congratulations! You found all ${this.foundCities.size} cities.`);
    } else {
      alert(`Time's up! You found ${this.foundCities.size} cities.`);
    }
  }

  startTimer() {
    this.remainingSeconds = Number.isFinite(this.durationValue)
      ? this.durationValue
      : 300;
    this.renderTimer();

    this.timerInterval = setInterval(() => {
      this.remainingSeconds -= 1;
      this.renderTimer();

      if (this.remainingSeconds <= 0) {
        this.finishQuiz();
      }
    }, 1000);
  }

  connect() {
    this.foundCities = new Set();

    this.initializeMap();
    this.startTimer();
  }

  disconnect() {
    clearInterval(this.timerInterval);
  }
}
