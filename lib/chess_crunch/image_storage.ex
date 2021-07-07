defmodule ChessCrunch.ImageStorage do
  @bucket "chess-crunch"

  def store_image(upload) do
    filename = "#{Ecto.UUID.generate()}#{Path.extname(upload.filename)}"

    {:ok, _} =
      ExAws.S3.put_object(
        @bucket,
        "positions/#{filename}",
        File.read!(upload.path),
        object_options()
      )
      |> ExAws.request()

    filename
  end

  def image_url(filename) do
    "https://chess-crunch.s3.amazonaws.com/positions/#{filename}"
  end

  defp object_options do
    [acl: :public_read]
  end
end
