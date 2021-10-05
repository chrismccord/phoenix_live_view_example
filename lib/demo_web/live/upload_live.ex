defmodule DemoWeb.UploadLive do
  use DemoWeb, :live_view

  def render(assigns) do
    ~H"""
    <%= for {_ref, err} <- @uploads.avatar.errors do %>
      <div class="alert alert-danger"><%= humanize(to_string(err)) %></div>
    <% end %>
    <div id="entries">
      <%= for entry <- @uploads.avatar.entries do %>
        <div id={"entry-#{entry.ref}"} class="row">
          <%= live_img_preview entry, width: 75 %>
          <h5><%= entry.client_name %></h5>
          <div class="progress-bar" style={"width: #{entry.progress};"}></div> <%= entry.progress %>%
          <button type="button" phx-click="cancel-upload" phx-value-ref={entry.ref}>
            <i class="far fa-trash"></i>
          </button>
        </div>
      <% end %>
    </div>

    <form phx-change="validate" phx-submit="save" id="upload-form">
      <%= live_file_input @uploads.avatar %>
      <%= if Enum.any?(@uploads.avatar.entries) do %>
        <button type="submit" phx-disable-with="uploading...">
          upload <%= length(@uploads.avatar.entries) %> files
        </button>
      <% end %>
    </form>

    <div id="files">
      <h5>uploaded files (<%= length(@uploaded_files) %>)</h5>
      <%= for url <- @uploaded_files do %>
        <img src={url} width="150"/>
      <% end %>
    </div>
    """
  end

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:avatar, accept: ~w(.jpeg .png), max_entries: 3)}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref)}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :avatar, fn %{} = meta, entry ->
        [ext | _] = MIME.extensions(entry.client_type)
        dest = Path.join("priv/static/uploads", Path.basename(meta.path) <> "." <> ext)
        File.cp!(meta.path, dest)
        Routes.static_path(socket, "/uploads/#{Path.basename(dest)}")
      end)

    {:noreply,
     socket
     |> put_flash(:info, "#{length(uploaded_files)} file(s) uploaded")
     |> update(:uploaded_files, &(&1 ++ uploaded_files))}
  end
end
