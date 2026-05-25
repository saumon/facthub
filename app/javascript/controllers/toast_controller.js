import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Auto-dismiss after 4 s
    this.timeout = setTimeout(() => this.dismiss(), 4000)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  dismiss() {
    this.element.classList.add("opacity-0")
    this.element.addEventListener("transitionend", () => this.element.remove(), { once: true })
  }
}
