defmodule Ecom.Uploaders.Image do
  @moduledoc false

  use Arc.Definition

  # Include ecto support (requires package arc_ecto installed):
  use Arc.Ecto.Definition

  # @versions [:original]

  # To add a thumbnail version:
  @versions [:original, :thumb]

  # Whitelist file extensions:
  def validate({file, _}) do
    ~w(.jpg .jpeg .png) |> Enum.member?(Path.extname(file.file_name))
  end

  # Define a thumbnail transformation:
  def transform(:thumb, _file) do
    {:convert, "-strip -thumbnail 300x300"}
  end

  # Override the persisted filenames:
  # def filename(version, _) do
  #   version
  # end

  # Override the storage directory:
  def storage_dir(_version, {_file, scope}) do
    "/var/www/uploads/product/image/#{scope.product_id}"
  end

  def request_dir(_version, {_file, scope}) do
    "uploads/#{scope.id}"
  end

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(_version, _scope) do
  #   "https://placehold.it/100x100"
  # end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  # def s3_object_headers(version, {file, scope}) do
  #   [content_type: Plug.MIME.path(file.file_name)]
  # end
end
