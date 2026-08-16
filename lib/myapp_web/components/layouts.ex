defmodule MyappWeb.Layouts do
  @moduledoc false

  use MyappWeb, :html

  embed_templates "layouts/*"

  attr :flash, :map, required: true
  attr :current_scope, :map, default: nil
  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="border-b border-slate-200 bg-white/90 backdrop-blur">
      <div class="mx-auto flex max-w-6xl items-center justify-between px-6 py-4 lg:px-8">
        <a href="/" class="flex items-center gap-3 text-slate-950 transition hover:text-indigo-700">
          <span class="flex size-9 items-center justify-center rounded-xl bg-amber-300 text-slate-950 shadow-sm">
            <.icon name="hero-bell-alert" class="size-5" />
          </span>
          <span class="font-semibold tracking-tight">Beewop</span>
        </a>
        <span class="text-sm font-medium text-slate-500">GitHub → Discord</span>
      </div>
    </header>

    <main class="min-h-screen bg-slate-50 px-5 py-10 sm:px-8 sm:py-14">
      {render_slot(@inner_block)}
    </main>

    <.flash_group flash={@flash} />
    """
  end

  attr :flash, :map, required: true
  attr :id, :string, default: "flash-group"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite" class="fixed right-5 bottom-5 z-50 w-full max-w-sm space-y-3">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />
    </div>
    """
  end
end
