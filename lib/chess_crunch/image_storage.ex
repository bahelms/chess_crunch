defmodule ChessCrunch.ImageStorage do
  @bucket "chess-crunch"

  def store_image(upload, image_id) do
    image_name = "drills/#{image_id}#{Path.extname(upload.filename)}"

    ExAws.S3.put_object(@bucket, image_name, File.read!(upload.path))
    |> ExAws.request!()
  end
end
