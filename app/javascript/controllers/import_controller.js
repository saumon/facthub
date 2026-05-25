import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "form",
    "submitButton",
    "fileInput",
    "fileLabel",
    "progressRegion",
    "progressFill",
    "progressBar",
    "statusText",
    "percentText",
    "summaryRegion"
  ]

  static values = {
    statusUrl: String
  }

  connect() {
    this._pollTimer = null
  }

  disconnect() {
    this._stopPolling()
  }

  updateFileLabel() {
    const files = this.fileInputTarget.files
    if (files.length === 0) {
      this.fileLabelTarget.textContent = "No file chosen"
    } else if (files.length === 1) {
      this.fileLabelTarget.textContent = files[0].name
    } else {
      this.fileLabelTarget.textContent = `${files.length} files selected`
    }
  }

  async startImport(event) {
    event.preventDefault()

    const form = this.formTarget
    const formData = new FormData(form)

    // Show progress region immediately
    this._showProgress()
    this._updateProgress(0, "Starting import…")
    this.submitButtonTarget.disabled = true

    let response
    try {
      response = await fetch(form.action, {
        method: "POST",
        body: formData,
        headers: { "X-CSRF-Token": this._csrfToken() }
      })
    } catch (_err) {
      this._showError("Network error — please try again.")
      return
    }

    if (!response.ok) {
      const data = await response.json().catch(() => ({}))
      this._showError(data.error || "Import could not be started.")
      return
    }

    const data = await response.json()
    this.statusUrlValue = data.status_url
    this._startPolling()
  }

  // ── private ──────────────────────────────────────────────────────────────

  _startPolling() {
    this._pollTimer = setInterval(() => this._poll(), 1000)
  }

  _stopPolling() {
    if (this._pollTimer) {
      clearInterval(this._pollTimer)
      this._pollTimer = null
    }
  }

  async _poll() {
    let data
    try {
      const res = await fetch(this.statusUrlValue, {
        headers: { "Accept": "application/json", "X-CSRF-Token": this._csrfToken() }
      })
      data = await res.json()
    } catch (_err) {
      return
    }

    const pct = data.progress_percent || 0
    const statusLabel = this._statusLabel(data.status, pct)
    this._updateProgress(pct, statusLabel)

    const TERMINAL = ["completed", "completed_with_errors", "failed"]
    if (TERMINAL.includes(data.status)) {
      this._stopPolling()
      this._renderTerminalSummary(data)
    }
  }

  _statusLabel(status, pct) {
    if (status === "pending")     return "Waiting to start…"
    if (status === "processing")  return `Processing… ${pct}%`
    if (status === "completed")   return "Import completed"
    if (status === "completed_with_errors") return "Completed with errors"
    if (status === "failed")      return "Import failed"
    return status
  }

  _showProgress() {
    this.progressRegionTarget.classList.remove("hidden")
    if (this.hasSummaryRegionTarget) {
      this.summaryRegionTarget.classList.add("hidden")
    }
  }

  _updateProgress(pct, label) {
    this.progressFillTarget.style.width = `${pct}%`
    this.progressBarTarget.setAttribute("aria-valuenow", pct)
    this.statusTextTarget.textContent = label
    this.percentTextTarget.textContent = `${pct}%`
  }

  _renderTerminalSummary(data) {
    this._updateProgress(
      data.progress_percent || 100,
      this._statusLabel(data.status, 100)
    )

    const addedColor = data.status === "failed" ? "text-red-600" : "text-emerald-600"
    const filesRows  = (data.files || []).map(f => this._fileRow(f)).join("")
    const dateLabel  = data.completed_at
      ? new Date(data.completed_at).toLocaleString("en-US", { month: "short", day: "2-digit", year: "numeric", hour: "2-digit", minute: "2-digit", hour12: false }).replace(",", " ·")
      : ""

    this.summaryRegionTarget.innerHTML = `
      <div class="mt-4 space-y-3">
        <div class="flex flex-wrap gap-4 text-sm">
          <span class="font-medium ${addedColor}">${this._capitalize(data.status.replace(/_/g, " "))}</span>
          ${dateLabel ? `<span class="text-slate-400">${dateLabel}</span>` : ""}
          <span class="text-slate-600"><strong>${data.added_facts_count}</strong> facts added</span>
          <span class="text-slate-600"><strong>${data.ignored_duplicates_count}</strong> duplicates ignored</span>
          ${data.invalid_files_count > 0
            ? `<span class="text-amber-600"><strong>${data.invalid_files_count}</strong> file(s) rejected</span>`
            : ""}
          ${data.error_message
            ? `<span class="text-red-600">${this._escHtml(data.error_message)}</span>`
            : ""}
        </div>
        ${filesRows.length > 0 ? `
        <div class="overflow-hidden rounded-xl border border-slate-200">
          <table class="w-full text-sm">
            <thead>
              <tr class="bg-slate-50 border-b border-slate-200">
                <th class="px-4 py-2 text-left text-xs font-semibold text-slate-500 uppercase tracking-wider">File</th>
                <th class="px-4 py-2 text-left text-xs font-semibold text-slate-500 uppercase tracking-wider">Status</th>
                <th class="px-4 py-2 text-right text-xs font-semibold text-slate-500 uppercase tracking-wider">Added</th>
                <th class="px-4 py-2 text-right text-xs font-semibold text-slate-500 uppercase tracking-wider">Ignored</th>
                <th class="px-4 py-2 text-left text-xs font-semibold text-slate-500 uppercase tracking-wider">Note</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">${filesRows}</tbody>
          </table>
        </div>` : ""}
      </div>`

    this.summaryRegionTarget.classList.remove("hidden")
    this.submitButtonTarget.disabled = false
  }

  _fileRow(file) {
    const isRejected = file.status.startsWith("rejected")
    const rowCls = isRejected ? "bg-red-50/50" : "hover:bg-indigo-50/30 transition"
    const badgeCls = file.status === "completed"
      ? "bg-emerald-100 text-emerald-700"
      : isRejected ? "bg-red-100 text-red-700" : "bg-slate-100 text-slate-600"
    const label   = file.status.replace(/_/g, " ").replace(/\b\w/g, c => c.toUpperCase())
    const note    = file.error_message ? this._escHtml(file.error_message) : "—"

    return `<tr class="${rowCls}">
      <td class="px-4 py-2 font-mono text-slate-700 text-xs">${this._escHtml(file.filename)}</td>
      <td class="px-4 py-2"><span class="inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium ${badgeCls}">${label}</span></td>
      <td class="px-4 py-2 text-right text-slate-700">${file.added_facts_count}</td>
      <td class="px-4 py-2 text-right text-slate-700">${file.ignored_duplicates_count}</td>
      <td class="px-4 py-2 text-xs text-slate-400 truncate max-w-xs">${note}</td>
    </tr>`
  }

  _showError(message) {
    this.statusTextTarget.textContent = message
    this.statusTextTarget.classList.add("text-red-600")
    this.submitButtonTarget.disabled = false
  }

  _csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content || ""
  }

  _escHtml(str) {
    return String(str)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
  }

  _capitalize(str) {
    return str.charAt(0).toUpperCase() + str.slice(1)
  }
}
