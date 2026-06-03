import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = []

  connect() {
    this.allTags = []
    this.selectedNames = this.#currentTagNames()

    this.input    = document.getElementById("tag-text-input")
    this.pills    = document.getElementById("tag-pills")
    this.dropdown = document.getElementById("tag-dropdown")
    this.hidden   = document.getElementById("tag-hidden-fields")

    this.#fetchAllTags()
    this.#bindEvents()
  }


  #currentTagNames() {
    return [...document.querySelectorAll('#tag-hidden-fields input')]
      .map(i => i.value)
      .filter(Boolean)
  }

  async #fetchAllTags() {
    try {
      const res  = await fetch("/admin/tags", {
        headers: { Accept: "application/json" }
      })
      this.allTags = await res.json()  // [{ id, name, count }]
    } catch {
      this.allTags = []
    }
  }

  #bindEvents() {
    this.input.addEventListener("input",   () => this.#onInput())
    this.input.addEventListener("keydown", (e) => this.#onKeydown(e))
    this.pills.addEventListener("click",   (e) => this.#onPillRemove(e))
    document.addEventListener("click",     (e) => {
      if (!e.target.closest(".tag-input-wrapper")) this.#closeDropdown()
    })
  }

  #onInput() {
    const q = this.input.value.trim().toLowerCase()
    if (!q) { this.#closeDropdown(); return }

    const matches = this.allTags.filter(t =>
      t.name.toLowerCase().includes(q) &&
      !this.selectedNames.includes(t.name)
    )

    this.#renderDropdown(q, matches)
  }

  #onKeydown(e) {
    if (e.key === "Enter") {
      e.preventDefault()
      const highlighted = this.dropdown.querySelector(".tag-option.highlighted")
      if (highlighted) {
        this.#addTag(highlighted.dataset.name)
      } else {
        const val = this.input.value.trim()
        if (val) this.#addTag(val)
      }
    } else if (e.key === "Backspace" && !this.input.value) {
      const last = this.selectedNames[this.selectedNames.length - 1]
      if (last) this.#removeTag(last)
    } else if (e.key === "ArrowDown") {
      e.preventDefault()
      this.#moveHighlight(1)
    } else if (e.key === "ArrowUp") {
      e.preventDefault()
      this.#moveHighlight(-1)
    } else if (e.key === "Escape") {
      this.#closeDropdown()
    } else if (e.key === "," || e.key === "Tab") {
      e.preventDefault()
      const val = this.input.value.trim()
      if (val) this.#addTag(val)
    }
  }

  #onPillRemove(e) {
    const btn = e.target.closest(".tag-remove")
    if (!btn) return
    const pill = btn.closest(".tag-pill")
    this.#removeTag(pill.dataset.name)
  }

  #renderDropdown(query, matches) {
    this.dropdown.innerHTML = ""

    // Option to create new tag if no exact match
    const exactMatch = this.allTags.some(
      t => t.name.toLowerCase() === query.toLowerCase()
    )

    if (!exactMatch) {
      const li = this.#dropdownItem(`Create "${this.#titleize(query)}"`, query, true)
      this.dropdown.appendChild(li)
    }

    matches.slice(0, 8).forEach(tag => {
      this.dropdown.appendChild(this.#dropdownItem(tag.name, tag.name, false))
    })

    this.dropdown.hidden = this.dropdown.children.length === 0
  }

  #dropdownItem(label, value, isNew) {
    const li = document.createElement("li")
    li.className = `tag-option${isNew ? " tag-option--new" : ""}`
    li.dataset.name = this.#titleize(value)
    li.textContent = label
    li.addEventListener("mousedown", (e) => {
      e.preventDefault()
      this.#addTag(li.dataset.name)
    })
    return li
  }

  #moveHighlight(dir) {
    const items = [...this.dropdown.querySelectorAll(".tag-option")]
    const cur   = items.findIndex(i => i.classList.contains("highlighted"))
    items.forEach(i => i.classList.remove("highlighted"))
    const next = Math.max(0, Math.min(items.length - 1, cur + dir))
    if (items[next]) items[next].classList.add("highlighted")
  }

  #addTag(name) {
    const normalized = this.#titleize(name.trim())
    if (!normalized || this.selectedNames.includes(normalized)) {
      this.input.value = ""
      this.#closeDropdown()
      return
    }

    this.selectedNames.push(normalized)
    this.#renderPill(normalized)
    this.#addHiddenField(normalized)
    this.input.value = ""
    this.#closeDropdown()

    // Optimistically update local tag list
    if (!this.allTags.find(t => t.name === normalized)) {
      this.allTags.push({ name: normalized })
    }
  }

  #removeTag(name) {
    this.selectedNames = this.selectedNames.filter(n => n !== name)
    this.pills.querySelector(`[data-name="${CSS.escape(name)}"]`)?.remove()
    this.hidden.querySelector(`input[value="${CSS.escape(name)}"]`)?.remove()

    // Ensure at least one hidden field (Rails needs it to submit empty array)
    if (!this.hidden.querySelector("input")) {
      const blank = document.createElement("input")
      blank.type  = "hidden"
      blank.name  = "product[tag_names][]"
      blank.value = ""
      this.hidden.appendChild(blank)
    }
  }

  #renderPill(name) {
    const span  = document.createElement("span")
    span.className   = "tag-pill"
    span.dataset.name = name
    span.innerHTML   = `${name}<button type="button" class="tag-remove" aria-label="Remove ${name}">&times;</button>`
    this.pills.appendChild(span)
  }

  #addHiddenField(name) {
    // Remove blank placeholder if present
    this.hidden.querySelector('input[value=""]')?.remove()

    const input = document.createElement("input")
    input.type  = "hidden"
    input.name  = "product[tag_names][]"
    input.value = name
    this.hidden.appendChild(input)
  }

  #closeDropdown() {
    this.dropdown.hidden = true
    this.dropdown.innerHTML = ""
  }

  #titleize(str) {
    return str.replace(/\w\S*/g, w => w.charAt(0).toUpperCase() + w.slice(1).toLowerCase())
  }
}