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
    allCityNames: Array,
  };

  static targets = [
    "input",
    "results",
    "outcome",
    "count",
    "map",
    "timer",
    "percentage",
    "outcome",
  ];

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
    this.showPercentage();

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
    this.inputTarget.placeholder = "Quiz finished.";

    const missed = this.missingCities();

    this.showResults(reason, missed);
  }

  getPercentage() {
    return Math.round((this.foundCities.size / this.cityCountValue) * 100);
  }

  showPercentage() {
    if (!this.hasPercentageTarget) return;

    const percentage = this.getPercentage();
    this.percentageTarget.textContent = `${percentage}%`;
  }

  showResults(reason, missedCities) {
    const title = reason === "complete" ? "Perfect run!" : "Time's up!";

    this.outcomeTarget.hidden = false;

    this.outcomeTarget.innerHTML = `
      <h2>${title}</h2>
      <p>You found ${this.foundCities.size} of ${this.cityCountValue} cities.</p>
      <p>Score: ${this.getPercentage()}</p>

      ${
        missedCities.length > 0
          ? `<h3>Missed Cities</h3>
            <ul>
              ${missedCities.map((city) => `<li>✗ ${city}</li>`).join("")}
            </ul>`
          : `<p>No missed cities. Nicely done.</p>`
      }
    `;
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

  missingCities() {
    const foundName = new Set(
      [...this.foundCities].map((key) => this.cityLookupValue[key]),
    );

    return this.allCityNamesValue.filter((city) => !foundName.has(city));
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
