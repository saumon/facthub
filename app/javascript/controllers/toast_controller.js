import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Slide in
    requestAnimationFrame(() => {
      this.element.classList.remove("opacity-0", "translate-y-2")
      this.element.classList.add("opacity-100", "translate-y-0")
    })

    // Auto-dismiss after 4 s
    this.timeout = setTimeout(() => this.dismiss(), 4000)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  dismiss() {
    this.element.classList.remove("opacity-100", "translate-y-0")
    this.element.classList.add("opacity-0", "translate-y-2")
    this.element.addEventListener("transitionend", () => this.element.remove(), { once: true })
  }
}
