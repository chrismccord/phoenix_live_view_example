defmodule DemoWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers, except: [live_patch: 1, live_redirect: 1]

  alias Phoenix.LiveView.JS, as: JS

  @doc """
  Renders a component inside the `DemoWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal DemoWeb.PostLive.FormComponent,
        id: @post.id || :new,
        action: @live_action,
        post: @post,
        return_to: Routes.post_index_path(@socket, :index) %>
  """
  def live_modal(component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(DemoWeb.ModalComponent, modal_opts)
  end

  def live_patch(assigns) do
    ~H"""
    <%= Phoenix.LiveView.Helpers.live_patch(render_block(@inner_block), assigns_to_attributes(assigns)) %>
    """
  end

  def live_redirect(assigns) do
    ~H"""
    <%= Phoenix.LiveView.Helpers.live_redirect(@text, assigns_to_attributes(assigns)) %>
    """
  end

  def transition_modal_out do
    JS.toggle(out: "fade-out", to: "#modal") |> JS.toggle(out: "fade-out-scale", to: "#modal-content")
  end

  def modal(assigns) do
    ~H"""
    <div id="modal" class="phx-modal fade-in" phx-remove={transition_modal_out()}>
      <div
        id="modal-content"
        class="phx-modal-content fade-in-scale"
        phx-click-away={JS.dispatch("click", to: "#close")}
        phx-window-keydown={JS.dispatch("click", to: "#close")}
        phx-key="escape"
      >
        <.live_patch
          to={@return_to}
          id="close"
          class="phx-modal-close"
          phx-click={transition_modal_out()}
        >✖</.live_patch>
        <%= live_component @component, assigns %>
      </div>
    </div>
    """
  end
end
